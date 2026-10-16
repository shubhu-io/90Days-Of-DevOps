# Day 13 - Linux Volume Management (LVM)

## Task
- Understand the three LVM layers (PV -> VG -> LV) and inspect them with `lsblk`, `pvs`, `vgs`, `lvs`, `df -h`
- Create a Physical Volume, a Volume Group and a Logical Volume
- Format and mount the logical volume
- Extend a mounted volume online, and persist it across reboots with `/etc/fstab`
- Practice the operations that follow in real work: add a disk to a VG, move data off a disk, snapshot
- Know exactly which commands destroy data before running them

## Environment
| Item | Value |
|------|-------|
| OS | Ubuntu 22.04 / 24.04 (or WSL2 - loop-file based only) |
| Shell | root shell via `sudo -i` |
| Packages | `sudo apt update && sudo apt install -y lvm2` (provides `pvcreate`, `vgcreate`, `lvcreate`, ...) |
| Block device | a real spare disk `/dev/sdb`, or a loop file when you have no spare disk |
| Filesystem | `ext4` by default; `xfs` where noted |
| Working directory | `/root` while in the root shell |
| Privileges | every command below runs as **root** |

```
+---------------------------+   pvcreate   +---------------------+
| Block device /dev/sdb     |  -----------> | PV  (Physical Vol)  |
| or /dev/loop0 (loop file) |               +---------------------+
+---------------------------+                        |
                                                   | vgcreate
                                                   v
+---------------------------+        lvcreate      +---------------------+
| Logical volume            |  <------------------- | VG  (Volume Group)  |
| /dev/devops-vg/app-data   |                       | devops-vg           |
+---------------------------+                       +---------------------+
              |
              | mkfs.ext4 + mount
              v
        /mnt/app-data   (df -h shows the new filesystem)
```

## Solution

### Prerequisite - Become root and install the tools
**Why:** LVM metadata lives in every device's first few sectors. Only root may write there.

```bash
sudo -i
apt update && apt install -y lvm2

# confirm the tools exist before you plan around them
command -v pvcreate vgcreate lvcreate lvextend resize2fs mkfs.ext4
```

![WSL2 environment and the initial `lsblk -f` disk layout - ext4 on sda/sdb/sdd, swap on sdc, no LVM yet](screenshots/01-environment-lsblk-layout.png)

![`pvs` not found, then `apt install -y lvm2` pulling in the LVM userland](screenshots/02-install-lvm2.png)

### Task 1: Check Current Storage
**Why:** Never create a PV before knowing what is already on the disk. This step is what stops you from
overwriting a partition full of data.

```bash
lsblk
lsblk -f                # adds fstype, mountpoints, and shows LVM type as "lvm"
pvs
vgs
lvs
df -h
df -hT                 # adds filesystem type - useful for spotting tmpfs
findmnt                # full mount table, one entry per line
```

`lsblk -f` marks LVM objects as `TYPE=lvm` and `lvm`, and shows `dm-0` style device-mapper names
(`/dev/mapper/devops-vg-app-data`) next to the friendly `/dev/devops-vg/app-data` path.

![`pvs`, `vgs`, `lvs` empty before anything is created, with `df -h` and `df -hT` for the same disks](screenshots/03-pvs-vgs-lvs-empty.png)

![`findmnt` - the full mount table, one line per mount, before the new filesystem exists](screenshots/04-findmnt-mount-table.png)

### Task 2: Create Physical Volume
**Why:** You need unallocated block storage. Use a real spare disk if you have one, otherwise create a
loop-backed virtual disk - it behaves like a real device for every LVM operation.

Option A - a real spare disk (verify it is genuinely empty first):

```bash
lsblk /dev/sdb
sudo blkid /dev/sdb            # no output => no filesystem/partition signature found
sudo fdisk -l /dev/sdb         # confirm there is nothing to lose
```

In this lab `/dev/sdb` was **not** empty: `blkid` reported an `ext4` signature, so `pvcreate` refused with
`Can't open /dev/sdb exclusively` / `device has a signature`. That is the safe outcome - LVM stopping you
from clobbering data - and it is why Option B exists.

![`/dev/sdb` inspection with `lsblk`/`blkid`/`fdisk -l`, then `pvcreate` refusing because the disk already carries a signature (and `-z y` rejected on this lvm2 build)](screenshots/05-sdb-inspect-pvcreate-refused.png)

Option B - a 1 GiB loop file (no hardware needed, safe on a laptop):

```bash
dd if=/dev/zero of=/tmp/disk1.img bs=1M count=1024
losetup -fP /tmp/disk1.img
losetup -a                    # e.g. /dev/loop0: []: (/tmp/disk1.img)
lsblk /dev/loop0
```

Notes on this step:
- `-f` asks the kernel for a **free** loop device, `-P` asks it to scan for partitions on it.
- `/tmp` is a normal directory on Ubuntu, but on some distros it is `tmpfs` (RAM). Check with `df -h /tmp`;
  if it says `tmpfs`, put the file in `~/` or `/var/tmp` instead so you do not consume 1 GiB of memory.
- To find the device later without guessing: `losetup -j /tmp/disk1.img`
- Never type `of=/dev/sdb` in that `dd` command - `of=` is the **output**, so it writes and destroys the disk.

Because `/dev/sdb` was already signed, `vgcreate` on it failed the same way and the lab switched to the loop
file: `wipefs -n /dev/sdb` (read-only inspection) confirms the signature, then `dd` creates `/root/disk1.img`
and `losetup -fP` attaches it as `/dev/loop0`.

![`vgcreate` on `/dev/sdb` refused, `wipefs -n`/`blkid` confirm the signature, then `dd` builds the 1 GiB loop file `/root/disk1.img`](screenshots/06-vgcreate-refused-loop-file-dd.png)

For the rest of the day, set the device in one variable so you can switch between option A and B:

```bash
DEV=/dev/sdb          # option A
# DEV=/dev/loop0      # option B (or /dev/loop0p1 if you partitioned it)
echo "$DEV"
```

Optional but production-realistic: partition the disk first, and put the PV on the partition.

```bash
parted -s "$DEV" mklabel gpt
parted -s "$DEV" mkpart primary ext4 1MiB 100%
partprobe "$DEV"
lsblk "$DEV"                       # expect sdb1, or loop0p1
DEV=/dev/sdb1                      # point the PV at the partition
```

#### Create the Physical Volume
**Why:** `pvcreate` writes the LVM metadata (a label) into the device and marks the space as available to
LVM. This is the point of no return for data already on that device.

**DESTRUCTIVE - `pvcreate` overwrites the first few sectors and any existing filesystem signature on that
device. Never run it on a disk that has data you have not backed up or verified is empty.**

```bash
# Safe because Step 1 proved the disk is empty. Use -y to skip the confirmation prompt.
pvcreate -y "$DEV"
pvs
pvs -o pv_name,vg_name,pv_size,pv_free,pv_uuid
```

If `pvcreate` refuses because it found a signature:

```bash
# -ff force past signature checks, -y auto-confirm, -z y zero the metadata areas
pvcreate -ff -y -z y "$DEV"
pvs
```

Real LVM output lines to recognise:

```
  PV         VG        Fmt  Attr PSize   PFree
  /dev/sdb   0         lvm2 a--  1020.00m 1020.00m
```

`VG` showing `0` means the PV is not yet part of any volume group - expected at this stage.

### Task 3: Create Volume Group
**Why:** The VG pools one or more PVs into a single pool of physical extents (PEs, 4 MiB by default) that
logical volumes are carved out of.

```bash
vgcreate devops-vg "$DEV"
vgs
vgs -o vg_name,vg_size,vg_free,pv_count,lv_count
```

Choosing the extent size: 4 MiB is the default and fine for a lab. For volumes in the terabytes use
`-s 8M` so the VG does not accumulate hundreds of thousands of tiny extents:

```bash
vgcreate -s 8M devops-vg "$DEV"
```

Check which PVs the VG is built from:

```bash
pvs -o pv_name,vg_name
vgs -o vg_name,pv_count,pv_free
```

### Task 4: Create Logical Volume
**Why:** An LV is the block device you actually format, mount and hand to an application.

```bash
lvcreate -L 500M -n app-data devops-vg
lvs
lvs -o lv_name,lv_size,vg_name,lv_path,lv_attr

# the same LV, addressed three ways - all valid
ls -l /dev/devops-vg/app-data
ls -l /dev/mapper/devops-vg-app-data
readlink -f /dev/devops-vg/app-data      # -> ../../dm-0
```

Other allocation styles you will meet:

```bash
lvcreate -l 100%FREE -n data devops-vg            # take every free extent
lvcreate -l 40 -n data devops-vg                 # 40 extents (40 x 4 MiB = 160 MiB)
lvcreate -n data -L 1G devops-vg                 # same as -L, order does not matter
lvcreate -L 10%VG -n data devops-vg              # 10% of the whole volume group
```

`lvs` attribute column, first two characters, decoded:

| Attr prefix | Meaning |
|-------------|---------|
| `-wi-ao----` | normal LV: `-w` no write, `-i` inherited, `-a` active, `-o` open |
| `swi-a-s---` | snapshot LV (`s` at position 1) |
| `o--ri-------` | origin LV (the real volume a snapshot was taken from) |

### Task 5: Format and Mount
**Why:** An LV is just a block device until you put a filesystem on it. Format once, then mount.

**DESTRUCTIVE - `mkfs` erases everything on the device it is given. Never point it at a device that holds
data, and never format a physical device that has already been `pvcreate`'d.**

```bash
mkfs.ext4 -L appdata /dev/devops-vg/app-data

mkdir -p /mnt/app-data
mount /dev/devops-vg/app-data /mnt/app-data

df -h /mnt/app-data
findmnt /mnt/app-data
blkid /dev/devops-vg/app-data
lsblk -f
```

![`mkfs.ext4 -L appdata` on the LVM LV, then `mount`, and `df -h`/`findmnt`/`lsblk -f`/`vgs`/`lvs` proving `/dev/mapper/devops-vg-app-data` is live at `/mnt/app-data`](screenshots/07-mkfs-mount-lvm-loop.png)

Expected shape of the `df` line:

```
Filesystem                     Size  Used Avail Use% Mounted on
/dev/mapper/devops-vg-app-data  484M  1.6M  456M   1% /mnt/app-data
```

Proof the filesystem is independent of the LV size - write a file:

```bash
dd if=/dev/zero of=/mnt/app-data/testfile bs=1M count=100
sync
ls -lh /mnt/app-data/testfile
df -h /mnt/app-data
rm -f /mnt/app-data/testfile
```

#### Persist the mount across reboots
**Why:** A `mount` you type by hand lives in kernel memory only. `/etc/fstab` makes it survive a reboot -
and use the **UUID**, because `/dev/sdb` names can move between reboots on VMs and USB disks.

```bash
blkid /dev/devops-vg/app-data
# copy the UUID= value from the output, then append this line to /etc/fstab:
grep -n 'app-data' /etc/fstab
```

```bash
# append, do not hand-edit blindly
printf 'UUID=<paste-the-uuid>  /mnt/app-data  ext4  defaults,nofail  0  2\n' >> /etc/fstab

# test every entry in fstab without rebooting
mount -a
findmnt /mnt/app-data
```

![Persisting the mount: `blkid` yields the UUID, the `UUID=...` line is appended to `/etc/fstab`, then `mount -a` + `findmnt` re-resolve `/mnt/app-data` from the UUID](screenshots/09-fstab-uuid-persist-mount.png)

Field meanings for that line: `UUID=...` source, mount point, filesystem type, options, `dump` (0 for
non-root), `fsck` pass order (2 for ext2/3/4, 0 for swap/xfs-btrfs).
`nofail` prevents a missing volume from dropping the server into an emergency shell - a good habit in cloud.

### Task 6: Extend the Volume
**Why:** Growing storage is the whole point of LVM. `lvextend` makes the block device bigger;
`resize2fs` grows the filesystem to fill it. Do both, or the filesystem still reports the old size.

```bash
df -h /mnt/app-data          # before:  484M

lvextend -L +200M /dev/devops-vg/app-data
df -h /mnt/app-data          # unchanged! the LV grew, the filesystem did not

resize2fs /dev/devops-vg/app-data
df -h /mnt/app-data          # after: ~678M
lvs
```

The one-command form, which is what you should use in scripts because it cannot forget step two:

```bash
lvextend -r -L +200M /dev/devops-vg/app-data      # -r = resize the filesystem too
df -h /mnt/app-data
```

![`vgs`/`lvs`/`df` before the grow, then `lvextend -r -L +200M` extending the LV and the filesystem online: `df` goes 452M -> 637M](screenshots/08-lvextend-resize2fs-online.png)

Consume everything left in the VG:

```bash
lvextend -l +100%FREE -r /dev/devops-vg/app-data
vgs                                    # VGFree should now be 0.00
```

With an **xfs** filesystem `resize2fs` does not work - use `xfs_growfs` on the mount point instead:

```bash
# DESTRUCTIVE (formatting only - skip if you already have ext4 data)
mkfs.xfs -f /dev/devops-vg/app-data
mount /dev/devops-vg/app-data /mnt/app-data
lvextend -L +200M /dev/devops-vg/app-data
xfs_growfs /mnt/app-data                # xfs_growfs takes the MOUNT POINT, not the device
df -h /mnt/app-data
```

**DESTRUCTIVE - shrinking.** There is no online way to shrink ext4 and none at all for xfs.

```bash
# DESTRUCTIVE: unmount first, check the filesystem, shrink the filesystem, THEN the LV.
# Wrong order (lv first, fs still larger) makes the filesystem unmountable.
umount /mnt/app-data
e2fsck -f /dev/devops-vg/app-data
e2fsck -f /dev/devops-vg/app-data        # run twice; it fixes what it can on the second pass
resize2fs /dev/devops-vg/app-data 300M
lvreduce -L 300M /dev/devops-vg/app-data
mount /dev/devops-vg/app-data /mnt/app-data
df -h /mnt/app-data
```

#### Add more space to the volume group
**Why:** The usual real-world trigger - the VG ran out of free extents and you bought/attached a new disk.

```bash
# DESTRUCTIVE: pvcreate wipes the new disk - verify it is empty first with lsblk / blkid
pvcreate -y /dev/sdc
vgextend devops-vg /dev/sdc
vgs -o vg_name,vg_size,vg_free,pv_count
```

```bash
# then grow the LV into the new space, in one step
lvextend -r -l +100%FREE /dev/devops-vg/app-data
df -h /mnt/app-data
```

### Bonus: Extra LVM Drills

#### Move data off a disk, then remove it
**Why:** Replacing a failing disk without downtime: `pvmove` relocates the LVs to other extents in the VG,
then you detach the old PV. A `vgextend` must have added spare space first (Step 9).

**DESTRUCTIVE-ish - `pvmove` moves live data. Do not interrupt it; an interrupted `pvmove` leaves a PV with
partial metadata and you will need `vgcfgrestore`.**

```bash
# 1. confirm there is room to move into
vgs -o vg_free

# 2. move the data (add -b for a progress report)
pvmove -b /dev/sdb1 /dev/sdc1
vgs -o vg_free

# 3. drop the emptied PV from the VG
vgreduce devops-vg /dev/sdb1
pvs -o pv_name,vg_name,pv_free

# 4. DESTRUCTIVE: clear the PV label so the device can be reused or removed
pvremove -ff -y /dev/sdb1

# 5. DESTRUCTIVE: detach the disk if it is hot-pluggable
#    (for a loop file: losetup -d /dev/loop0)
```

#### LVM snapshot
**Why:** A snapshot is a copy-on-write point-in-time LV. Space is only consumed when the **origin** changes,
which makes cheap pre-upgrade safety nets.

```bash
lvcreate -s -L 50M -n app-data-snap /dev/devops-vg/app-data
lvs -a -o lv_name,lv_size,lv_attr,origin
vgs -o vg_free                  # snapshot consumed free extents
ls -lh /mnt/app-data             # the origin is still fully usable

# take more snapshots safely
# DESTRUCTIVE (removes the snapshot, and any data only the snapshot holds)
lvremove -f /dev/devops-vg/app-data-snap

# DESTRUCTIVE - roll back: discards everything written to the origin since the snapshot
lvconvert --merge /dev/devops-vg/app-data-snap
```

#### Use an LV as swap
**Why:** VMs frequently need swap that can be grown later - exactly what LVM is good at.

```bash
lvcreate -L 1G -n swap devops-vg
mkswap /dev/devops-vg/swap
swapon /dev/devops-vg/app-data 2>/dev/null || swapon /dev/devops-vg/swap
swapon --show
free -h

# persist it
printf '/dev/devops-vg/swap  none  swap  defaults  0  0\n' >> /etc/fstab
swapon --show

# remove swap
swapoff /dev/devops-vg/swap
lvremove -f /dev/devops-vg/swap
```

The `2>/dev/null ||` on the `swapon` line is a typo-guard: if you typed the wrong LV path, `swapon` fails
loudly on the second attempt instead of silently enabling the wrong volume.

#### Teardown (destructive, run only when you are finished)
**Why:** Reversing the lab properly, in the only order that works: stop using, unmount, remove LVs, remove
the VG, remove the PV label, release the device. Skipping a level leaves `vgremove` complaining.

**DESTRUCTIVE - everything below deletes the volumes and every file inside them. Take a backup first if any
of it matters.**

```bash
# DESTRUCTIVE
rm -f /mnt/app-data/testfile
umount /mnt/app-data
swapoff /dev/devops-vg/swap          # only if you created a swap LV

# remove the fstab entry BEFORE you delete the device, or the next boot fails
grep -n 'devops-vg\|/mnt/app-data' /etc/fstab
sed -i '\|/mnt/app-data|d' /etc/fstab
sed -i '\|devops-vg/swap|d' /etc/fstab
grep -n 'devops-vg\|/mnt/app-data' /etc/fstab     # expect no output
mount -a                             # confirm fstab is still valid

# DESTRUCTIVE
lvremove -f /dev/devops-vg/app-data
lvremove -f /dev/devops-vg/swap
lvs -a                               # confirm no LVs remain
vgchange -an devops-vg               # deactivate
vgremove devops-vg
vgs                                  # confirm the VG is gone

# DESTRUCTIVE
pvremove -ff -y "$DEV"
pvs                                  # confirm the PV is gone
wipefs -a "$DEV"                     # remove any leftover signatures

# loop-file cleanup
losetup -d /dev/loop0
rm -f /tmp/disk1.img
```

### Commands Used
```bash
# install
apt update && apt install -y lvm2

# inspect
lsblk ; lsblk -f ; pvs ; vgs ; lvs ; df -h ; df -hT ; findmnt ; blkid /dev/sdb

# create a virtual disk when there is no spare hardware
dd if=/dev/zero of=/tmp/disk1.img bs=1M count=1024
losetup -fP /tmp/disk1.img ; losetup -a ; losetup -j /tmp/disk1.img ; losetup -d /dev/loop0

# partition (optional)
parted -s /dev/sdb mklabel gpt
parted -s /dev/sdb mkpart primary ext4 1MiB 100%
partprobe /dev/sdb

# build the stack
pvcreate -y /dev/sdb              # DESTRUCTIVE on anything already on the disk
pvcreate -ff -y -z y /dev/sdb     # force past an existing signature
vgcreate devops-vg /dev/sdb
vgcreate -s 8M devops-vg /dev/sdb
lvcreate -L 500M -n app-data devops-vg
lvcreate -l 100%FREE -n data devops-vg
lvcreate -l 40%VG -n data devops-vg

# format and mount
mkfs.ext4 -L appdata /dev/devops-vg/app-data      # DESTRUCTIVE
mkfs.xfs -f /dev/devops-vg/app-data               # DESTRUCTIVE
mkdir -p /mnt/app-data
mount /dev/devops-vg/app-data /mnt/app-data
findmnt /mnt/app-data

# persist
printf 'UUID=<uuid>  /mnt/app-data  ext4  defaults,nofail  0  2\n' >> /etc/fstab
mount -a

# grow
lvextend -L +200M /dev/devops-vg/app-data
resize2fs /dev/devops-vg/app-data                 # ext4
xfs_growfs /mnt/app-data                         # xfs
lvextend -r -L +200M /dev/devops-vg/app-data      # both in one command
lvextend -l +100%FREE -r /dev/devops-vg/app-data

# shrink
umount /mnt/app-data
e2fsck -f /dev/devops-vg/app-data
resize2fs /dev/devops-vg/app-data 300M
lvreduce -L 300M /dev/devops-vg/app-data         # DESTRUCTIVE

# capacity changes
vgextend devops-vg /dev/sdc
pvcreate -y /dev/sdc                             # DESTRUCTIVE
pvmove -b /dev/sdb1 /dev/sdc1
vgreduce devops-vg /dev/sdb1
pvremove -ff -y /dev/sdb1                        # DESTRUCTIVE

# snapshots
lvcreate -s -L 50M -n app-data-snap /dev/devops-vg/app-data
lvs -a -o lv_name,lv_size,lv_attr,origin
lvconvert --merge /dev/devops-vg/app-data-snap   # DESTRUCTIVE: discards post-snapshot writes
lvremove -f /dev/devops-vg/app-data-snap         # DESTRUCTIVE

# swap
lvcreate -L 1G -n swap devops-vg
mkswap /dev/devops-vg/swap ; swapon /dev/devops-vg/swap ; swapon --show ; swapoff /dev/devops-vg/swap

# destroy
umount /mnt/app-data ; lvremove -f /dev/devops-vg/app-data ; vgchange -an devops-vg ; vgremove devops-vg
pvremove -ff -y "$DEV" ; wipefs -a "$DEV" ; losetup -d /dev/loop0
```

## Verification
- `pvs` lists one PV with `VG` = `0` before `vgcreate`, then with `VG` = `devops-vg` after
- `vgs` shows `devops-vg` with `LVs` = 1 and `VFree` lower than `VGSize` after `lvcreate`
- `lvs` shows `app-data` at `500.00m`
- `df -h /mnt/app-data` shows ~484M used 1% on `/dev/mapper/devops-vg-app-data` (ext4 metadata is
      reserved, which is why 500M reads as 484M)
- After `lvextend -L +200M` **without** `resize2fs`, `df` still showed the old size - the proof that
      the LV and the filesystem are two separate layers
- After `resize2fs`, `df` showed the larger size
- `mount -a` succeeded and `findmnt /mnt/app-data` resolved the UUID from `/etc/fstab`
- `vgextend` + `lvextend -r -l +100%FREE` grew the volume in place
- `lvs -a -o lv_name,lv_size,lv_attr,origin` showed the snapshot and marked the origin as `o--ri-`
- Teardown left `lvs`, `vgs`, `pvs` empty and `grep -n devops-vg /etc/fstab` returned nothing

## Key Learnings
- LVM is three layers: **PV** (a block device labelled for LVM), **VG** (a pool of 4 MiB physical extents), **LV** (a device carved out of that pool). `pvs`/`vgs`/`lvs` map 1:1 to the three layers.
- Growing is two operations, always in this order: `lvextend` then `resize2fs` - or `lvextend -r` which does both. Skip the second and `df` still shows the old size.
- Mount by **UUID** in `/etc/fstab`, never by `/dev/sdb`, because physical device names move between reboots on VMs.
- The VG is the unit of flexibility: add a PV with `vgextend` to grow capacity, and `pvmove` + `vgreduce` + `pvremove` to retire a disk without downtime.
- `/dev/devops-vg/app-data` and `/dev/mapper/devops-vg-app-data` are the same device; the second is the real `dm-N` node the kernel uses.
- Every filesystem must be checked (`e2fsck`) and can only be *shrunk* while unmounted, and xfs cannot be shrunk at all - decide the size before `mkfs`.
- Snapshots are copy-on-write: cheap to create, they only grow as the origin is written to, and `lvconvert --merge` is an irreversible rollback.

## Troubleshooting / Gotchas
- **`pvcreate: cannot initialize physical volume "/dev/sdb1"`** - it found a filesystem/partition/LVM signature. Read the message; if you are certain the disk is empty, use `pvcreate -ff -y -z y`.
- **`mkfs.ext4` was run on `/dev/devops-vg` instead of `/dev/devops-vg/app-data`** - that wipes the **VG metadata** and every LV in it. `vgdisplay` afterwards will report a corrupt VG; recovery is `vgcfgbackup` / `vgcfgrestore`. Always paste the full LV path into `mkfs`.
- **`lvextend` succeeded but `df -h` did not change** - you still need `resize2fs` (ext) or `xfs_growfs` (xfs), or `lvextend -r`.
- **`resize2fs: ... is a mounted xfs filesystem` / `resize2fs: Cannot open device`** - wrong filesystem family. `xfs_growfs /mnt/app-data` is the xfs equivalent and takes the mount point.
- **The server booted into emergency mode after editing `/etc/fstab`** - an fstab typo or a missing UUID. Boot with `systemd.unit=rescue.target`, or from a live session run `mount -o remount,rw /` then comment the line. Test with `mount -a` **before** rebooting, and keep `nofail` on optional mounts.
- **After a reboot the loop-backed VG is missing** - loop devices are not persistent. Re-attach the file (`losetup -fP /tmp/disk1.img`), then `vgchange -ay` and `mount /mnt/app-data`. This is a loop-device limitation, not an LVM bug.
- **`vgremove` says `1 volume(s) in this volume group still active`** - an LV is still mapped. `lvremove` it, then `vgchange -an devops-vg`, then `vgremove`.
- **`lvcreate` says `not enough free space`** - check `vgs` for `VFree`, or use `vgextend` to add a PV first.
- **WSL2 has no `/dev/sdX`** - use the loop-file method only. `pvcreate` on the WSL2 virtual disk breaks Docker Desktop's data.
- **`dd` with `of=/dev/sdX`** destroys that disk. `of=` is the *output*; `if=` is the input. Double-check the two letters before pressing Enter.
- **A 500M LV shows as ~484M in `df`** - normal: ext4 reserves ~5% plus inode/journal overhead. Do not "fix" it.

## Screenshots

All proofs live inline in the sections above. Index of files in `screenshots/`:

| File | Section | Proves |
|------|---------|--------|
| `01-environment-lsblk-layout.png` | Prerequisite | WSL2 host + initial `lsblk -f` disk layout (no LVM yet) |
| `02-install-lvm2.png` | Prerequisite | `pvs` missing -> `apt install -y lvm2` |
| `03-pvs-vgs-lvs-empty.png` | Task 1 | `pvs`/`vgs`/`lvs` empty, `df -h` and `df -hT` for the same disks |
| `04-findmnt-mount-table.png` | Task 1 | `findmnt` full mount table before the new filesystem exists |
| `05-sdb-inspect-pvcreate-refused.png` | Task 2 | `/dev/sdb` inspection, then `pvcreate` refusing a disk that already has a signature |
| `06-vgcreate-refused-loop-file-dd.png` | Task 2 | `vgcreate` refused on `/dev/sdb`; `wipefs -n` proves the signature; `dd` builds the loop file |
| `07-mkfs-mount-lvm-loop.png` | Task 5 | `mkfs.ext4 -L appdata` on the LV, mounted at `/mnt/app-data` (`df`/`findmnt`/`lsblk -f`/`vgs`/`lvs`) |
| `08-lvextend-resize2fs-online.png` | Task 6 | `lvextend -r -L +200M` grows LV + filesystem online, `df` 452M -> 637M |
| `09-fstab-uuid-persist-mount.png` | Persist mount | `blkid` UUID -> `/etc/fstab`, `mount -a` + `findmnt` re-resolve the mount |

> **Lab note:** the PNGs were captured by the trainee and renamed from their
> `Screenshot 2026-10-16 HHMMSS.png` originals into the order above. This lab ran
> inside WSL2 where `/dev/sdb` was already signed, so the PV/VG/LV were built on a
> loop file (`/root/disk1.img` -> `/dev/loop0`) instead of a raw disk.
