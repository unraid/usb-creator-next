#include "unraidguidvalidator.h"

#include "config.h"

#include <QDebug>

UnraidGuidValidator::UnraidGuidValidator() 
{
    _curl = curl_easy_init();
}

UnraidGuidValidator::~UnraidGuidValidator()
{
    curl_easy_cleanup(_curl);
}

UnraidGuidValidator::Result UnraidGuidValidator::checkDevice(const Drivelist::DeviceDescriptor& deviceDescriptor)
{
    Result result;
    if(!deviceDescriptor.vid.empty() && !deviceDescriptor.pid.empty() && !deviceDescriptor.serialNumber.empty())
    {
        QString SerialPadded = QString::fromStdString(deviceDescriptor.serialNumber).rightJustified(16, '0').right(16);
        result.guid = (QString::fromStdString(deviceDescriptor.vid) + "-" +  QString::fromStdString(deviceDescriptor.pid) + "-" + SerialPadded.left(4) + "-" + SerialPadded.mid(4)).toUpper();

        CURLcode res{CURLcode::CURLE_OK};
        long http_code{0};
        std::string data{""};
        if(_curl)
        {
            curl_easy_setopt(_curl, CURLOPT_CUSTOMREQUEST, "POST");
            curl_easy_setopt(_curl, CURLOPT_URL, UNRAID_GUID_URL);
            curl_easy_setopt(_curl, CURLOPT_FOLLOWLOCATION, 1L);
            curl_easy_setopt(_curl, CURLOPT_DEFAULT_PROTOCOL, "https");
            struct curl_slist *headers = NULL;
            headers = curl_slist_append(headers, "Content-Type: application/x-www-form-urlencoded");
            curl_easy_setopt(_curl, CURLOPT_HTTPHEADER, headers);
            data = "guid=" + result.guid.toStdString();
            curl_easy_setopt(_curl, CURLOPT_POSTFIELDS, data.c_str());
            res = curl_easy_perform(_curl);
            curl_slist_free_all(headers);
            curl_easy_getinfo (_curl, CURLINFO_RESPONSE_CODE, &http_code);
        }

        if (res == CURLcode::CURLE_OK && http_code != 403)
        {
            result.guidValid = true;
        }
    }
    return result;
}


