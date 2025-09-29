#if defined(_WIN32)
#include "volume_locks.h"
#include <windows.h>
#include <restartmanager.h>
#include <vector>
#include <QStringBuilder>
#include <QDebug>

typedef DWORD (WINAPI *RmStartSession_t)(DWORD*, DWORD, WCHAR*);
typedef DWORD (WINAPI *RmRegisterResources_t)(DWORD, UINT, LPCWSTR[], UINT, RM_UNIQUE_PROCESS*, UINT, LPCWSTR*);
typedef DWORD (WINAPI *RmGetList_t)(DWORD, UINT*, UINT*, RM_PROCESS_INFO*, LPDWORD);
typedef DWORD (WINAPI *RmEndSession_t)(DWORD);

static bool loadRm(HMODULE &mod, RmStartSession_t &pStart, RmRegisterResources_t &pReg, RmGetList_t &pList, RmEndSession_t &pEnd)
{
    mod = LoadLibraryW(L"Rstrtmgr.dll");
    if (!mod) {
        qDebug() << "[RM] Failed to load Rstrtmgr.dll, GetLastError=" << GetLastError();
        return false;
    }
    qDebug() << "[RM] Loaded Rstrtmgr.dll";

    pStart = reinterpret_cast<RmStartSession_t>(GetProcAddress(mod, "RmStartSession"));
    pReg   = reinterpret_cast<RmRegisterResources_t>(GetProcAddress(mod, "RmRegisterResources"));
    pList  = reinterpret_cast<RmGetList_t>(GetProcAddress(mod, "RmGetList"));
    pEnd   = reinterpret_cast<RmEndSession_t>(GetProcAddress(mod, "RmEndSession"));

    if (!(pStart && pReg && pList && pEnd)) {
        qDebug() << "[RM] Failed to resolve Restart Manager symbols";
        FreeLibrary(mod);
        mod = nullptr;
        return false;
    }
    return true;
}

// QStringList whoIsUsingPath(const QString &rootPath)
// {
//     qDebug().noquote() << "[RM] Checking lockers for:" << rootPath;

//     HMODULE mod = nullptr;
//     RmStartSession_t RmStartSession = nullptr;
//     RmRegisterResources_t RmRegisterResources = nullptr;
//     RmGetList_t RmGetList = nullptr;
//     RmEndSession_t RmEndSession = nullptr;

//     if (!loadRm(mod, RmStartSession, RmRegisterResources, RmGetList, RmEndSession)) {
//         qDebug() << "[RM] Restart Manager not available";
//         return {};
//     }

//     DWORD session = 0; WCHAR key[CCH_RM_SESSION_KEY+1] = {};
//     QStringList result;

//     DWORD rc = RmStartSession(&session, 0, key);
//     if (rc != ERROR_SUCCESS) {
//         qDebug() << "[RM] RmStartSession failed rc=" << rc;
//         FreeLibrary(mod);
//         return result;
//     }
//     qDebug() << "[RM] RmStartSession ok, session=" << session;

//     std::wstring wpath = rootPath.toStdWString();
//     LPCWSTR resources[1] = { wpath.c_str() };
//     rc = RmRegisterResources(session, 1, resources, 0, nullptr, 0, nullptr);
//     if (rc != ERROR_SUCCESS) {
//         qDebug() << "[RM] RmRegisterResources failed rc=" << rc;
//         RmEndSession(session);
//         FreeLibrary(mod);
//         return result;
//     }
//     qDebug() << "[RM] RmRegisterResources ok";

//     UINT needed = 0;
//     DWORD reason = 0;
//     std::vector<RM_PROCESS_INFO> infos(16);
//     UINT arraySize = static_cast<UINT>(infos.size());

//     qDebug() << "[RM] RmGetList (first call)...";
//     rc = RmGetList(session, &needed, &arraySize, infos.data(), &reason);
//     if (rc == ERROR_MORE_DATA) {
//         qDebug() << "[RM] RmGetList needs more data; needed=" << needed;
//         infos.resize(needed);
//         arraySize = needed;
//         reason = 0;
//         rc = RmGetList(session, &needed, &arraySize, infos.data(), &reason);
//     }

//     if (rc != ERROR_SUCCESS) {
//         qDebug() << "[RM] RmGetList failed rc=" << rc;
//         RmEndSession(session);
//         FreeLibrary(mod);
//         return result;
//     }

//     qDebug() << "[RM] RmGetList ok; written=" << arraySize << " reason=" << reason;
//     for (DWORD i = 0; i < arraySize; ++i) {
//         const RM_PROCESS_INFO &p = infos[i];
//         QString name = QString::fromWCharArray(p.strAppName);
//         QString item = name % " (pid=" % QString::number(p.Process.dwProcessId) % ")";
//         qDebug().noquote() << "[RM]  -" << item;
//         result << item;
//     }

//     RmEndSession(session);
//     FreeLibrary(mod);
//     qDebug() << "[RM] End session; found" << result.size() << "locker(s)";
//     return result;
// }

QStringList whoIsUsingPath(const QString &rootPath)
{
    qDebug().noquote() << "[RM] Checking lockers for:" << rootPath;

    HMODULE mod = nullptr;
    RmStartSession_t RmStartSession = nullptr;
    RmRegisterResources_t RmRegisterResources = nullptr;
    RmGetList_t RmGetList = nullptr;
    RmEndSession_t RmEndSession = nullptr;

    if (!loadRm(mod, RmStartSession, RmRegisterResources, RmGetList, RmEndSession)) {
        qDebug() << "[RM] Restart Manager not available";
        return {};
    }

    DWORD session = 0; WCHAR key[CCH_RM_SESSION_KEY+1] = {};
    QStringList result;

    DWORD rc = RmStartSession(&session, 0, key);
    if (rc != ERROR_SUCCESS) {
        qDebug() << "[RM] RmStartSession failed rc=" << rc;
        FreeLibrary(mod);
        return result;
    }
    qDebug() << "[RM] RmStartSession ok, session=" << session;

    std::wstring wpath = rootPath.toStdWString();

    // Also resolve volume GUID path for the mount point (e.g. "H:\")
    WCHAR volGuid[MAX_PATH] = {};
    std::wstring wguid;
    if (!rootPath.isEmpty() && rootPath.endsWith('\\')) {
        if (GetVolumeNameForVolumeMountPointW(wpath.c_str(), volGuid, ARRAYSIZE(volGuid))) {
            wguid = volGuid;
        } else {
            qDebug() << "[RM] GetVolumeNameForVolumeMountPointW failed, gle=" << GetLastError();
        }
    }

    // Prepare resources: drive root and (if available) its GUID name
    std::vector<std::wstring> ownedStrings;
    ownedStrings.push_back(wpath);
    if (!wguid.empty())
        ownedStrings.push_back(wguid);

    std::vector<LPCWSTR> resources;
    for (auto &s : ownedStrings) resources.push_back(s.c_str());

    rc = RmRegisterResources(session,
                             static_cast<UINT>(resources.size()),
                             resources.empty() ? nullptr : resources.data(),
                             0, nullptr,
                             0, nullptr);
    if (rc != ERROR_SUCCESS) {
        qDebug() << "[RM] RmRegisterResources failed rc=" << rc;
        RmEndSession(session);
        FreeLibrary(mod);
        return result;
    }
    qDebug() << "[RM] RmRegisterResources ok";

    UINT needed = 0;
    UINT arraySize = 0;
    DWORD reason = 0;

    // First call to get the required array size
    rc = RmGetList(session, &needed, &arraySize, nullptr, &reason);
    if (rc == ERROR_MORE_DATA && needed > 0) {
        std::vector<RM_PROCESS_INFO> infos(needed);
        arraySize = needed;
        rc = RmGetList(session, &needed, &arraySize, infos.data(), &reason);
        if (rc == ERROR_SUCCESS) {
            qDebug() << "[RM] RmGetList ok; written=" << arraySize << " reason=" << reason;
            for (UINT i = 0; i < arraySize; ++i) {
                const RM_PROCESS_INFO &p = infos[i];
                QString name = QString::fromWCharArray(p.strAppName);
                QString item = name % " (pid=" % QString::number(p.Process.dwProcessId) % ")";
                qDebug().noquote() << "[RM]  -" << item;
                result << item;
            }
        } else {
            qDebug() << "[RM] RmGetList failed rc=" << rc;
        }
    } else if (rc == ERROR_SUCCESS) {
        qDebug() << "[RM] RmGetList ok; no lockers";
    } else {
        qDebug() << "[RM] RmGetList failed rc=" << rc;
    }

    RmEndSession(session);
    FreeLibrary(mod);
    qDebug() << "[RM] End session; found" << result.size() << "locker(s)";
    return result;
}
#endif