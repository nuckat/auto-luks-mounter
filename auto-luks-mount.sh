#!/bin/bash

# Read the passphrase from the file
PASSPHRASE=$(< /root/passphrase.txt)

# Function to open and mount a LUKS device
open_and_mount() {
  local device_path=$1
  local luks_name=$2
  local mount_point=$3

  # Check if the LUKS device is already open
  if ! cryptsetup status "$luks_name" >/dev/null 2>&1; then
    echo "$PASSPHRASE" | cryptsetup luksOpen "$device_path" "$luks_name"
  fi

  # Create the mount point if it does not exist
  mkdir -p "$mount_point"

  # Mount the device if it’s not already mounted
  if ! mountpoint -q "$mount_point"; then
    mount /dev/mapper/"$luks_name" "$mount_point"
  fi
}

# Drive #1
# Example: open_and_mount "/dev/disk/by-id/your-device-id-partX" "luks-UUID" "/run/media/username/MountPoint"
# You can do this for how many drives you have. It should work on most distros fine as long as the variables are correct.
open_and_mount "/dev/disk/by-id/" \
  "luks-" \
  "/run/media/username/drivename/"

# Drive #2 
open_and_mount "/dev/disk/by-id/" \
  "luks- \
  "/run/media/username/drivename/"

