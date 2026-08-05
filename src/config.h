#ifndef CONFIG_H
#define CONFIG_H

/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2020-2025 Raspberry Pi Ltd
 */


/* Repository URL */
#define OSLIST_URL                              "https://releases.unraid.net/usb-creator" // UNRAID: Unraid release feed

/* Custom repository manifest file extension (without leading dot) */
#define MANIFEST_EXTENSION                      "rpi-imager-manifest"

/* MIME type for manifest files */
#define MANIFEST_MIME_TYPE                      "application/vnd.raspberrypi.imager-manifest+json"

/* Time synchronization URL (only used on linuxfb QPA platform, URL must be HTTP) */
#define TIME_URL                                "http://downloads.raspberrypi.com/"

/* Phone home the name of images downloaded for image popularity ranking */
#define TELEMETRY_URL                           "" // UNRAID: telemetry disabled (see ENABLE_TELEMETRY=OFF)

/* Hash algorithm for verifying (uncompressed image) checksum */
#define OSLIST_HASH_ALGORITHM                   QCryptographicHash::Sha256

/* Update progressbar every 0.1 second */
#define PROGRESS_UPDATE_INTERVAL                100

/* Default block size for buffer allocation (dynamically adjusted at runtime) */
#define IMAGEWRITER_BLOCKSIZE                   1*1024*1024

/* Enable caching */
#define IMAGEWRITER_ENABLE_CACHE_DEFAULT        true

/* Do not cache if it would bring free disk space under 5 GB */
#define IMAGEWRITER_MINIMAL_SPACE_FOR_CACHING   5*1024*1024*1024ll

/* UNRAID: key-server endpoint used to check a flash GUID is unique/not blacklisted */
#define UNRAID_GUID_URL                         "https://keys.lime-technology.com/validate/guid"

#endif // CONFIG_H
