/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2026 Lime Technology, Inc.
 *
 * The GUID produced here is what an Unraid licence is issued against, and
 * unraidd independently recomputes it at boot from the same USB descriptor
 * fields. If the two ever disagree, a user's key stops validating on the machine
 * they bought it for — so these vectors pin the algorithm against unraidd's
 * strncpy_guid() in regis.c rather than against our own implementation.
 */

#include <catch2/catch_test_macros.hpp>

#include "drivelist/drivelist.h"
#include "unraid/unraid_guid.h"

using Unraid::deviceGuid;
using Unraid::normaliseGuidField;

namespace {

Drivelist::DeviceDescriptor usbDevice(const char *vid, const char *pid, const char *serial)
{
    Drivelist::DeviceDescriptor d;
    d.isUSB = true;
    d.vid = vid;
    d.pid = pid;
    d.serialNumber = serial;
    return d;
}

} // namespace

TEST_CASE("normaliseGuidField pads short values on the left", "[unraid][guid]")
{
    // unraidd pads with '0' at the front, never the back.
    REQUIRE(normaliseGuidField("781", 4) == "0781");
    REQUIRE(normaliseGuidField("1234", 16) == "0000000000001234");
    REQUIRE(normaliseGuidField("", 4) == "0000");
}

TEST_CASE("normaliseGuidField truncates from the beginning", "[unraid][guid]")
{
    // Critically NOT left(width): unraidd discards leading characters and keeps
    // the tail, so a 20-character serial keeps its last 16.
    REQUIRE(normaliseGuidField("4C530001120904115535", 16) == "0001120904115535");
    REQUIRE(normaliseGuidField("ABCDE", 4) == "BCDE");
}

TEST_CASE("normaliseGuidField discards whitespace and upper-cases", "[unraid][guid]")
{
    // Real vendors pad descriptor strings with spaces; unraidd counts only
    // non-blank characters when deciding to pad or truncate.
    REQUIRE(normaliseGuidField(" 78 1", 4) == "0781");
    REQUIRE(normaliseGuidField("abcd", 4) == "ABCD");
    REQUIRE(normaliseGuidField("  ab  cd  ", 4) == "ABCD");
    REQUIRE(normaliseGuidField("\t12\n34 ", 4) == "1234");
}

TEST_CASE("deviceGuid builds the 27-character Unraid flash GUID", "[unraid][guid]")
{
    const auto guid = deviceGuid(usbDevice("0781", "5583", "4C530001120904115535"));

    // Serial is normalised to 16 chars then split 4/12.
    REQUIRE(guid == "0781-5583-0001-120904115535");
    REQUIRE(guid.size() == 27);
}

TEST_CASE("deviceGuid normalises every field, not just the serial", "[unraid][guid]")
{
    // The previous implementation padded only the serial and never stripped
    // whitespace or upper-cased vid/pid, so this case produced a GUID that would
    // not match the one unraidd derives for the same stick.
    const auto guid = deviceGuid(usbDevice(" 78 1", "abc", "1234"));
    REQUIRE(guid == "0781-0ABC-0000-000000001234");
    REQUIRE(guid.size() == 27);
}

TEST_CASE("deviceGuid still yields a GUID when the serial is missing", "[unraid][guid]")
{
    // unraidd fills a missing serial with zeros and then blacklists that exact
    // shape. Surfacing it beats hiding the device: the user needs to be told the
    // stick cannot hold a licence.
    const auto guid = deviceGuid(usbDevice("0781", "5583", ""));
    REQUIRE(guid == "0781-5583-0000-000000000000");
}

// Values read straight out of the IORegistry (idVendor / idProduct /
// kUSBSerialNumberString) for two physical sticks used to validate this port on
// macOS. Keeping real hardware here guards against a regression that only shows
// up against actual descriptors — e.g. a numeric vid formatted as decimal rather
// than 4-digit hex.
TEST_CASE("deviceGuid matches known physical devices", "[unraid][guid]")
{
    // ASMT 2115 enclosure: 12-character serial, left-padded to 16.
    REQUIRE(deviceGuid(usbDevice("174C", "55AA", "123456794AA4"))
            == "174C-55AA-0000-123456794AA4");

    // Verbatim STORE N GO: serial is already exactly 16 characters.
    REQUIRE(deviceGuid(usbDevice("18A5", "0250", "070111BB9884CD29"))
            == "18A5-0250-0701-11BB9884CD29");
}

TEST_CASE("deviceGuid returns nothing for devices with no USB identity", "[unraid][guid]")
{
    REQUIRE(deviceGuid(usbDevice("", "", "")).isEmpty());

    Drivelist::DeviceDescriptor internalDisk;
    internalDisk.isUSB = false;
    internalDisk.vid = "0781";
    internalDisk.pid = "5583";
    internalDisk.serialNumber = "1234";
    REQUIRE(deviceGuid(internalDisk).isEmpty());
}
