# auto-luks-mounter

Auto-mount script for LUKS-encrypted drives on Linux using systemd and bash.

This script automates the unlocking and mounting of multiple LUKS-encrypted drives at startup using systemd.

⚠️ **Use responsibly.** Make sure your `/root/passphrase.txt` is well secured. Anyone with access to it can unlock your encrypted drives.

## Step 1: Download `auto-luks-mount.sh`

Create or place the script here:
```
/usr/local/bin/auto-luks-mount.sh
```

### Collect Drive Info

Run:
```
lsblk
```
Copy each LUKS partition path (e.g., `/dev/sdX`, `/dev/nvmeXnXpY`) to a temp doc.

Then run:
```
udevadm info --query=all --name=/dev/nvmeXnXpY
```
Look for output like:
```
/dev/disk/by-id/nvme-WD_BLACK_SN850X_HS_4000GB_xxxxxx-part3
```

Check mount location:
```
ls /media/username/
# or
ls /run/media/username/
```

Open the script file:
```
sudo nano /usr/local/bin/auto-luks-mount.sh
```

Paste formatted entries:
```bash
# Traditional block device:
open_and_mount /dev/sdb2 luks-xxxx "/media/username/gaming1"

# Another:
open_and_mount /dev/sdc1 luks-yyyy "/media/username/gaming2"

# For changing NVMe IDs:
open_and_mount "/dev/disk/by-id/nvme-xxxxx" \
  "luks-zzzz" \
  "/media/username/nvmedrive"
```

## Step 2: Create `/root/passphrase.txt`

Run:
```
sudo nano /root/passphrase.txt
```
Paste your LUKS passphrase. The script only supports a single passphrase unless you expand its logic.

## Step 3: Set Permissions

```bash
sudo chmod +x /usr/local/bin/auto-luks-mount.sh
sudo chmod 700 /usr/local/bin/auto-luks-mount.sh
sudo chmod 600 /root/passphrase.txt
```

## Step 4: Create systemd service

Create service file:
```
sudo nano /etc/systemd/system/auto-luks-mount.service
```

Paste:
```ini
[Unit]
Description=Mount Encrypted Volumes at Startup
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/auto-luks-mount.sh

[Install]
WantedBy=multi-user.target
```

## Step 5: Enable and Start the Service

Unmount your LUKS drives, then run:
```bash
sudo systemctl enable auto-luks-mount.service
sudo systemctl start auto-luks-mount.service
sudo systemctl status auto-luks-mount.service
```

Reboot to confirm that auto-mounting works.

## Notes & Warnings

- **Don’t add your boot drive.** Those are mounted earlier in the boot sequence.
- Use a strong passphrase or YubiKey for your main drive.
- If the root container is compromised, the `/root/passphrase.txt` becomes a liability.
- This is somewhat pointless if you leave your main drive unencrypted, so I recommend encrypting it and setting up permissions so the passphrase.txt cannot be accessed by anyone except you.
- Debug service logs:
```
journalctl -u auto-luks-mount.service
```
