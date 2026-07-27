# UNRAID: Product branding layer.
#
# The CMake target, the QML module URI, and the source-tree filenames all stay as
# upstream ("rpi-imager" / "RpiImager"). Only the *product identity* is overridden
# here, and packaging reads these variables rather than hardcoding strings.
#
# This is what keeps the fork rebaseable: rebranding is one file plus a handful of
# one-line variable references, instead of renaming 200+ files. See PORTING.md.
#
# Every value below defaults to upstream's, so setting -DIMAGER_BRAND=rpi (or
# deleting this file) yields a stock Raspberry Pi Imager build.

set(IMAGER_BRAND "unraid" CACHE STRING "Product branding to build (unraid|rpi)")
set_property(CACHE IMAGER_BRAND PROPERTY STRINGS unraid rpi)

if(IMAGER_BRAND STREQUAL "unraid")
    set(_brand_app_name       "Unraid USB Creator")
    set(_brand_exe_name       "unraid-usb-creator")
    set(_brand_bundle_id      "com.limetech.unraid-usb-creator")
    set(_brand_vendor         "Lime Technology, Inc.")
    set(_brand_url_scheme     "unraid-usb-creator")
    set(_brand_org_name       "Lime Technology")
    set(_brand_org_domain     "unraid.net")
    set(_brand_copyright_from "2020")
    # Windows install path and Start-menu group. Upstream hardcodes "Imager" and
    # "Raspberry Pi", both of which are user-visible -- the install directory shows
    # up in Explorer, UAC prompts and Add/Remove Programs.
    set(_brand_win_subdir     "Unraid USB Creator")
    set(_brand_win_menu_group "Unraid")
else()
    set(_brand_app_name       "Raspberry Pi Imager")
    set(_brand_exe_name       "rpi-imager")
    set(_brand_bundle_id      "com.raspberrypi.rpi-imager")
    set(_brand_vendor         "Raspberry Pi Ltd")
    set(_brand_url_scheme     "rpi-imager")
    set(_brand_org_name       "Raspberry Pi")
    set(_brand_org_domain     "raspberrypi.com")
    set(_brand_copyright_from "2020")
    # Defaults preserve upstream's installer layout exactly for -DIMAGER_BRAND=rpi.
    set(_brand_win_subdir     "Imager")
    set(_brand_win_menu_group "Raspberry Pi")
endif()

set(IMAGER_APP_NAME   "${_brand_app_name}"   CACHE STRING "Product display name")
set(IMAGER_EXE_NAME   "${_brand_exe_name}"   CACHE STRING "Installed executable / bundle name")
set(IMAGER_BUNDLE_ID  "${_brand_bundle_id}"  CACHE STRING "macOS bundle id / Linux desktop id")
set(IMAGER_VENDOR     "${_brand_vendor}"     CACHE STRING "Copyright holder")
set(IMAGER_URL_SCHEME "${_brand_url_scheme}" CACHE STRING "Custom URL scheme")
set(IMAGER_WIN_INSTALL_SUBDIR   "${_brand_win_subdir}"     CACHE STRING "Windows install dir under {autopf}\\<vendor>")
set(IMAGER_WIN_START_MENU_GROUP "${_brand_win_menu_group}" CACHE STRING "Windows Start-menu group")
# QSettings location — changing these migrates user settings, keep stable per brand.
set(IMAGER_ORG_NAME   "${_brand_org_name}"   CACHE STRING "QSettings organisation name")
set(IMAGER_ORG_DOMAIN "${_brand_org_domain}" CACHE STRING "QSettings organisation domain")

# Product homepage, used by installers and the Linux desktop/metainfo files.
if(IMAGER_BRAND STREQUAL "unraid")
    set(_brand_homepage "https://unraid.net")
else()
    set(_brand_homepage "https://www.raspberrypi.com/software/")
endif()
set(IMAGER_HOMEPAGE "${_brand_homepage}" CACHE STRING "Product homepage")

# Linux desktop integration. Defaults to upstream's files so an IMAGER_BRAND=rpi
# build installs exactly what upstream does.
if(IMAGER_BRAND STREQUAL "unraid")
    set(_brand_desktop "${CMAKE_CURRENT_SOURCE_DIR}/unraid/packaging/com.limetech.unraid-usb-creator.desktop")
else()
    set(_brand_desktop "${CMAKE_CURRENT_SOURCE_DIR}/../debian/com.raspberrypi.rpi-imager.desktop")
endif()
set(IMAGER_DESKTOP_FILE "${_brand_desktop}" CACHE FILEPATH "Linux .desktop file")

# macOS DMG background. Upstream generates one at build time; when this points at
# a file that image is used instead. Empty falls back to upstream's generator.
if(IMAGER_BRAND STREQUAL "unraid")
    set(_brand_dmg_bg "${CMAKE_CURRENT_SOURCE_DIR}/unraid/packaging/dmg-background.png")
else()
    set(_brand_dmg_bg "")
endif()
set(IMAGER_DMG_BACKGROUND "${_brand_dmg_bg}" CACHE FILEPATH "macOS DMG background image (optional)")

# AppStream metadata (software centres). Generated from a .in so the version
# tracks the build, exactly as upstream does for its own.
if(IMAGER_BRAND STREQUAL "unraid")
    set(_brand_metainfo_in  "${CMAKE_CURRENT_SOURCE_DIR}/unraid/packaging/com.limetech.unraid-usb-creator.metainfo.xml.in")
    set(_brand_metainfo_out "${CMAKE_CURRENT_BINARY_DIR}/com.limetech.unraid-usb-creator.metainfo.xml")
else()
    set(_brand_metainfo_in  "${CMAKE_CURRENT_SOURCE_DIR}/../debian/com.raspberrypi.rpi-imager.metainfo.xml.in")
    set(_brand_metainfo_out "${CMAKE_CURRENT_SOURCE_DIR}/../debian/com.raspberrypi.rpi-imager.metainfo.xml")
endif()
set(IMAGER_METAINFO_IN  "${_brand_metainfo_in}"  CACHE FILEPATH "AppStream metainfo template")
set(IMAGER_METAINFO_OUT "${_brand_metainfo_out}" CACHE FILEPATH "Generated AppStream metainfo")

string(TIMESTAMP _brand_current_year "%Y")
set(IMAGER_COPYRIGHT "Copyright © ${_brand_copyright_from}-${_brand_current_year} ${IMAGER_VENDOR}")

# Icons. Upstream ships a pre-compiled Assets.car + .icns pair (needed for macOS
# Tahoe "Liquid Glass" icon variants). We only have a plain .icns, so the Unraid
# brand sets IMAGER_ICON_ASSETS_CAR empty and packaging skips that step.
if(IMAGER_BRAND STREQUAL "unraid")
    set(_brand_icns       "${CMAKE_CURRENT_SOURCE_DIR}/unraid/icons/unraid.icns")
    set(_brand_assets_car "")
    set(_brand_ico        "${CMAKE_CURRENT_SOURCE_DIR}/unraid/icons/unraid.ico")
    set(_brand_png_512    "${CMAKE_CURRENT_SOURCE_DIR}/unraid/icons/unraid512.png")
    set(_brand_svg        "${CMAKE_CURRENT_SOURCE_DIR}/unraid/icons/unraid.svg")
else()
    set(_brand_icns       "${CMAKE_CURRENT_SOURCE_DIR}/icons/AppIcon-compiled.icns")
    set(_brand_assets_car "${CMAKE_CURRENT_SOURCE_DIR}/icons/AppIcon-compiled.car")
    set(_brand_ico        "${CMAKE_CURRENT_SOURCE_DIR}/icons/rpi-imager.ico")
    set(_brand_png_512    "")
    set(_brand_svg        "")
endif()

set(IMAGER_ICON_ICNS       "${_brand_icns}"       CACHE FILEPATH "macOS .icns")
set(IMAGER_ICON_ASSETS_CAR "${_brand_assets_car}" CACHE FILEPATH "macOS compiled Assets.car (optional)")
set(IMAGER_ICON_ICO        "${_brand_ico}"        CACHE FILEPATH "Windows .ico")
set(IMAGER_ICON_PNG_512    "${_brand_png_512}"    CACHE FILEPATH "Linux 512px png")
set(IMAGER_ICON_SVG        "${_brand_svg}"        CACHE FILEPATH "Linux scalable svg")

# Telemetry is off for Unraid builds; upstream defaults it on.
if(IMAGER_BRAND STREQUAL "unraid")
    set(ENABLE_TELEMETRY OFF CACHE BOOL "Enable sending telemetry" FORCE)
endif()

# Expose the identity to C++ as branding.h in the build tree.
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/branding.h.in"
    "${CMAKE_CURRENT_BINARY_DIR}/branding.h"
    @ONLY)

message(STATUS "Branding: ${IMAGER_APP_NAME} (${IMAGER_BUNDLE_ID}), executable '${IMAGER_EXE_NAME}'")
