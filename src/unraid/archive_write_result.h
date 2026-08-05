/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2026 Lime Technology, Inc.
 */

#ifndef UNRAID_ARCHIVE_WRITE_RESULT_H
#define UNRAID_ARCHIVE_WRITE_RESULT_H

#include <stdexcept>

namespace Unraid {

/**
 * Make every non-success archive write result terminal.
 *
 * libarchive allows callers to continue after warning-class results, but an
 * incomplete boot drive is never useful. In particular, its Windows backend
 * reports a failed WriteFile() as a warning rather than a fatal result.
 */
inline void requireArchiveWriteSuccess(int result, const char *message)
{
    if (result < 0)
        throw std::runtime_error(message ? message : "Failed to write a file to the target drive");
}

} // namespace Unraid

#endif // UNRAID_ARCHIVE_WRITE_RESULT_H
