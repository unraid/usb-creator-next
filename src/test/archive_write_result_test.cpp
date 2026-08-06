/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2026 Lime Technology, Inc.
 */

#include <catch2/catch_test_macros.hpp>
#include <catch2/matchers/catch_matchers.hpp>

#include <stdexcept>
#include <string>

#include "unraid/archive_write_result.h"

TEST_CASE("successful archive write results do not throw", "[unraid][archive-write]")
{
    REQUIRE_NOTHROW(Unraid::requireArchiveWriteSuccess(0, nullptr));
    REQUIRE_NOTHROW(Unraid::requireArchiveWriteSuccess(1, nullptr));
}

TEST_CASE("every negative archive write result is terminal", "[unraid][archive-write]")
{
    for (const int result : {-10, -20, -25, -30})
    {
        INFO("archive result: " << result);
        REQUIRE_THROWS_WITH(Unraid::requireArchiveWriteSuccess(result, "Write failed"),
                            "Write failed");
    }
}

TEST_CASE("archive write failures have a fallback message", "[unraid][archive-write]")
{
    REQUIRE_THROWS_WITH(Unraid::requireArchiveWriteSuccess(-20, nullptr),
                        "Failed to write a file to the target drive");
}

TEST_CASE("archive entry headers tolerate metadata warnings only", "[unraid][archive-write]")
{
    REQUIRE_NOTHROW(Unraid::requireArchiveHeaderSuccess(0, nullptr));
    REQUIRE_NOTHROW(Unraid::requireArchiveHeaderSuccess(-20, nullptr));
    REQUIRE_THROWS_WITH(Unraid::requireArchiveHeaderSuccess(-25, "Header failed"),
                        "Header failed");
    REQUIRE_THROWS_WITH(Unraid::requireArchiveHeaderSuccess(-30, nullptr),
                        "Failed to create a file on the target drive");
}
