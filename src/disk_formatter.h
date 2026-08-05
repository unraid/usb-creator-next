/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2025 Raspberry Pi Ltd
 */

#ifndef DISK_FORMATTER_H_
#define DISK_FORMATTER_H_

#include <cstdint>
#include <string>
#include <array>
#include <vector>
#include <system_error>
#include <memory>
#include <optional>
#include "file_operations.h"

namespace rpi_imager {

// Error types for disk formatting operations
enum class FormatError {
  kFileOpenError,
  kFileWriteError,
  kFileSeekError,
  kInvalidParameters,
  kInsufficientSpace,
  kCancelled
};

// Result type for operations that can fail
template<typename T>
class Result {
 public:
  Result(T value) : value_(std::move(value)), error_() {}
  explicit Result(FormatError error) : value_(), error_(error) {}
  
  bool has_value() const { return !error_.has_value(); }
  explicit operator bool() const { return has_value(); }
  
  const T& value() const { return value_.value(); }
  T& value() { return value_.value(); }
  FormatError error() const { return error_.value_or(FormatError::kFileOpenError); }
  
 private:
  std::optional<T> value_;
  std::optional<FormatError> error_;
};

// Specialization for void
template<>
class Result<void> {
 public:
  Result() : error_() {}
  explicit Result(FormatError error) : error_(error) {}
  
  bool has_value() const { return !error_.has_value(); }
  explicit operator bool() const { return has_value(); }
  
  FormatError error() const { return error_.value_or(FormatError::kFileOpenError); }
  
 private:
  std::optional<FormatError> error_;
};

// Configuration for FAT32 formatting
struct Fat32Config {
  std::uint32_t total_sectors;
  std::uint32_t sectors_per_cluster = 8;  // 4KB clusters
  std::uint16_t reserved_sectors = 32;
  std::uint8_t num_fats = 2;
  std::string volume_label = "BOOT";       // More Pi-appropriate than "SDCARD"
  std::uint32_t volume_id = 0x12345678;
};

// MBR partition entry
struct __attribute__((packed)) MbrPartitionEntry {
  std::uint8_t status;
  std::uint8_t first_head;
  std::uint8_t first_sector;
  std::uint8_t first_cylinder;
  std::uint8_t partition_type;
  std::uint8_t last_head;
  std::uint8_t last_sector;
  std::uint8_t last_cylinder;
  std::uint32_t first_lba;
  std::uint32_t num_sectors;
};

// FAT32 boot sector structure
struct __attribute__((packed)) Fat32BootSector {
  std::array<std::uint8_t, 3> jump_instruction;
  std::array<char, 8> oem_name;
  std::uint16_t bytes_per_sector;
  std::uint8_t sectors_per_cluster;
  std::uint16_t reserved_sectors;
  std::uint8_t num_fats;
  std::uint16_t root_entries;  // 0 for FAT32
  std::uint16_t total_sectors_16;  // 0 for FAT32
  std::uint8_t media_descriptor;
  std::uint16_t sectors_per_fat_16;  // 0 for FAT32
  std::uint16_t sectors_per_track;
  std::uint16_t num_heads;
  std::uint32_t hidden_sectors;
  std::uint32_t total_sectors_32;
  std::uint32_t sectors_per_fat_32;
  std::uint16_t ext_flags;
  std::uint16_t fs_version;
  std::uint32_t root_cluster;
  std::uint16_t fs_info_sector;
  std::uint16_t backup_boot_sector;
  std::array<std::uint8_t, 12> reserved;
  std::uint8_t drive_number;
  std::uint8_t reserved1;
  std::uint8_t boot_signature;
  std::uint32_t volume_id;
  std::array<char, 11> volume_label;
  std::array<char, 8> fs_type;
  std::array<std::uint8_t, 420> boot_code;
  std::uint16_t signature;
};

// FSInfo sector structure
struct __attribute__((packed)) Fat32FsInfo {
  std::uint32_t lead_signature;
  std::array<std::uint8_t, 480> reserved1;
  std::uint32_t struct_signature;
  std::uint32_t free_count;
  std::uint32_t next_free;
  std::array<std::uint8_t, 12> reserved2;
  std::uint32_t trail_signature;
};

class DiskFormatter {
 public:
  // Constructor that accepts a FileOperations implementation
  explicit DiskFormatter(std::unique_ptr<FileOperations> file_ops = nullptr);
  ~DiskFormatter() = default;

  // Non-copyable, movable
  DiskFormatter(const DiskFormatter&) = delete;
  DiskFormatter& operator=(const DiskFormatter&) = delete;
  DiskFormatter(DiskFormatter&&) = default;
  DiskFormatter& operator=(DiskFormatter&&) = default;

  // Format a device with MBR partition table and FAT32 filesystem
  Result<void> FormatDrive(const std::string& device_path);

  // UNRAID: Unraid boots by locating the volume labelled "UNRAID" (see unraidd
  // regis.c, which reads /dev/disk/by-label/UNRAID), and the bundled
  // make_bootable scripts assume the same. Callers writing an Unraid image must
  // override the default "BOOT" label.
  // UNRAID: deliberately NOT named SetVolumeLabel. <windows.h> defines that as a
  // macro expanding to SetVolumeLabelW under UNICODE, so a member of that name
  // fails to compile on Windows ("no member named SetVolumeLabelW").
  void SetVolumeLabelOverride(const std::string& label) { volume_label_ = label; }

  // Format to a file for testing
  Result<void> FormatFile(
      const std::string& file_path,
      std::uint64_t file_size_bytes);

 private:
  // UNRAID: zero this much at each end of the device before writing our own
  // MBR. See WipeResidualSignatures().
  static constexpr std::uint64_t kResidualWipeBytes = 1024 * 1024;

  // UNRAID: destroy leftover partitioning/filesystem metadata from whatever was
  // on the drive before us.
  //
  // We only write an MBR at LBA 0 and FAT32 from sector 8192, so anything
  // outside those ranges survives -- including the parts that make Windows
  // disbelieve our partition table. A GPT disk keeps a *backup* header in the
  // very last sector with its entry array just before it, and ZFS writes four
  // labels, two of them at the tail of the device. `diskpart clean` and the
  // direct-IOCTL fast path clear the primary structures but are not reliable
  // about the backup GPT.
  //
  // Observed with drives previously used by TrueNAS (GPT + ZFS): Disk
  // Management shows our new partition correctly, but the volume never mounts,
  // so the write fails with "Operating system did not mount FAT32 partition".
  // Wiping with Rufus first is what made it work, because Rufus zeroes both
  // ends. On the pre-2.0 tool the same drives appeared to write successfully
  // and then failed to boot with "no system", which is the same residue
  // surfacing later and less visibly.
  //
  // 1 MiB at each end covers the protective MBR, the primary GPT header and
  // entries (LBA 1-33), the backup GPT (last 33 sectors), and the tail ZFS
  // labels, for ~2 MiB of writes.
  Result<void> WipeResidualSignatures(std::uint64_t device_size_bytes) const;

  static constexpr std::uint32_t kSectorSize = 512;
  static constexpr std::uint32_t kPartitionStartSector = 8192;  // 4MB offset
  static constexpr std::uint8_t kFat32PartitionType = 0x0C;    // FAT32 LBA

  std::unique_ptr<FileOperations> file_ops_;

  // UNRAID: overrides Fat32Config::volume_label when non-empty.
  std::string volume_label_;

  // Convert FileError to FormatError
  FormatError ConvertError(FileError error) const;

  // Write MBR with single partition
  Result<void> WriteMbr(std::uint64_t device_size_bytes) const;

  // Write FAT32 filesystem
  Result<void> WriteFat32(
      std::uint32_t partition_start_sector,
      std::uint32_t partition_size_sectors) const;

  // Helper functions
  // UNRAID: partition_start_sectors is where the FAT32 volume begins; offset_sectors
  // is where this particular copy of the boot sector is written. They differ for the
  // backup copy at +6, and BPB_HiddSec must record the former in BOTH copies -- see
  // the call site in WriteFat32().
  Result<void> WriteBootSector(
      std::uint32_t offset_sectors,
      std::uint32_t partition_start_sectors,
      const Fat32Config& config) const;

  Result<void> WriteFsInfo(
      std::uint32_t offset_sectors,
      const Fat32Config& config) const;

  Result<void> WriteFatTables(
      std::uint32_t fat_start_sector,
      const Fat32Config& config) const;

  Result<void> WriteRootDirectory(
      std::uint32_t root_cluster_sector,
      const Fat32Config& config) const;

  // Utility functions
  Fat32Config CalculateFat32Config(std::uint32_t partition_size_sectors) const;
  std::uint32_t CalculateSectorsPerFat(const Fat32Config& config) const;
  
  Result<void> WriteAtOffset(
      int fd,
      std::uint64_t offset,
      const std::uint8_t* data,
      std::size_t size) const;

  template<typename T>
  Result<void> WriteStructAtOffset(
      int fd,
      std::uint64_t offset,
      const T& structure) const;
};

}  // namespace rpi_imager

#endif  // DISK_FORMATTER_H_ 