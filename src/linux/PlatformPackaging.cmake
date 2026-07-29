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

# UNRAID: the binary ships under the product name so the desktop entry's Exec=
# and the AppImage's AppRun resolve. That rename is applied once, in
# unraid_apply_branding() (cmake/UnraidBranding.cmake) -- this platform having
# been the one originally missed is exactly why it is centralised now.
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


