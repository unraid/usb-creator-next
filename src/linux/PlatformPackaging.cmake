# Linux packaging: installation and runtime checks

if (NOT CMAKE_CROSSCOMPILING)
    find_program(LSBLK "lsblk")
    if (NOT LSBLK)
        message(FATAL_ERROR "Unable to locate lsblk (used for disk enumeration)")
    endif()

    execute_process(COMMAND "${LSBLK}" "--json" OUTPUT_QUIET RESULT_VARIABLE ret)
    if (ret EQUAL "1")
        message(FATAL_ERROR "util-linux package too old. lsblk does not support --json (used for disk enumeration)")
    endif()
endif()

# Generate metainfo.xml at build time so version stays in sync with the binary
add_custom_command(
    OUTPUT "${IMAGER_METAINFO_OUT}"
    COMMAND ${CMAKE_COMMAND}
        -DVERSION_VARS_FILE=${IMAGER_VERSION_VARS}
        -DINPUT=${IMAGER_METAINFO_IN}
        -DOUTPUT=${IMAGER_METAINFO_OUT}
        -P ${CONFIGURE_VERSIONED_SCRIPT}
    DEPENDS
        ${IMAGER_VERSION_VARS}
        ${IMAGER_METAINFO_IN}
    COMMENT "Configuring metainfo.xml with build-time version"
    VERBATIM
)
add_custom_target(generate_metainfo
    DEPENDS "${IMAGER_METAINFO_OUT}")
add_dependencies(generate_metainfo generate_version)
add_dependencies(${PROJECT_NAME} generate_metainfo)

# UNRAID: ship the binary under the product name, as Windows and macOS already
# do (see their PlatformPackaging.cmake). The CMake target keeps upstream's name
# per PORTING.md rule 1; only the installed artefact is renamed.
#
# Without this the desktop entry installed below points Exec= at
# /usr/bin/unraid-usb-creator while the binary lands as /usr/bin/rpi-imager, so
# the launcher is dead on a plain install and the AppImage's AppRun cannot find
# what to exec. Left alone for BUILD_CLI_ONLY, which sets its own OUTPUT_NAME.
if(NOT BUILD_CLI_ONLY)
    set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "${IMAGER_EXE_NAME}")
endif()

install(TARGETS ${PROJECT_NAME} DESTINATION bin)

if(BUILD_CLI_ONLY)
    # CLI-only build: install CLI-specific desktop file (marked as NoDisplay)
    # Icon is still required for AppImage tooling (linuxdeploy) even though NoDisplay=true
    install(FILES "${CMAKE_CURRENT_LIST_DIR}/icon/rpi-imager.svg" DESTINATION share/icons/hicolor/scalable/apps)
    install(FILES "${CMAKE_CURRENT_LIST_DIR}/../../debian/com.raspberrypi.rpi-imager-cli.desktop" DESTINATION share/applications)
else()
    # GUI build: install full desktop integration
    # UNRAID: icon and desktop entry come from the branding layer. The installed
    # basenames must match Icon= / the executable name in the desktop file, and
    # linuxdeploy derives the AppImage name from its Name= field.
    install(FILES "${IMAGER_ICON_SVG}" DESTINATION share/icons/hicolor/scalable/apps
            RENAME "${IMAGER_EXE_NAME}.svg")
    install(FILES "${IMAGER_DESKTOP_FILE}" DESTINATION share/applications)
    install(FILES "${IMAGER_METAINFO_OUT}" DESTINATION share/metainfo)
endif()


