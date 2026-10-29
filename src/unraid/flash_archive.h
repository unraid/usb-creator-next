/* SPDX-License-Identifier: Apache-2.0 */
#ifndef UNRAID_FLASH_ARCHIVE_H
#define UNRAID_FLASH_ARCHIVE_H

#include <QDir>
#include <QString>

namespace Unraid {

/** Recognize the boot files at the root of an extracted Unraid flash archive. */
class FlashArchiveContents
{
public:
    void observeFile(const QString &path)
    {
        const QString rootPath = QDir::cleanPath(path).toLower();
        _hasKernel |= rootPath == QLatin1String("bzimage");
        _hasRootFilesystem |= rootPath == QLatin1String("bzroot");
    }

    bool isUnraid() const { return _hasKernel && _hasRootFilesystem; }

private:
    bool _hasKernel = false;
    bool _hasRootFilesystem = false;
};

} // namespace Unraid

#endif // UNRAID_FLASH_ARCHIVE_H
