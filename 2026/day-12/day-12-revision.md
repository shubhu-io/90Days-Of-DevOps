# Day 12 - Breather & Revision (Days 01-11)

## Task
- Re-read the Day 01 plan and adjust it now that eleven days of hands-on work are behind you
- Re-run hands-on commands from the process/service days (04/05) and the file days (06-11)
- Refresh the Day 03 command cheat sheet and mark the 5 commands you would reach for first in an incident
- Recreate one user/ownership scenario end-to-end (Day 09 + Day 11) and verify it
- Answer the four self-check questions in writing, plus run a longer question bank

## Environment
| Item | Value |
|------|-------|
| OS | Ubuntu 22.04 / 24.04 |
| Shell | `bash` (root shell via `sudo -i` for the drill) |
| Working directory | `~/day12-revision` |
| Tools | `ps`, `top`, `systemctl`, `journalctl`, `ss`, `free`, `df`, `ls`, `stat`, `chmod`, `chown`, `id` |
| Optional | the Day 08 cloud VM (nginx + Docker) for the service checks |
| Time budget | 30-45 minutes |

## Solution

### Week 01-11 Map - what each day actually covered
| Day | Topic | One-line takeaway |
|-----|-------|-------------------|
| 01 | Intro to DevOps & Cloud | CI/CD, IaC, monitoring, collaboration; the plan I am executing |
| 02 | Linux architecture, processes, systemd | PID, fork/exec, process states, systemd units and targets |
| 03 | Linux commands practice | First cheat sheet: process, file, network, log commands |
| 04 | Processes and services in practice | `ps`, `top`, `kill`, `systemctl start/stop/status` |
| 05 | Troubleshooting drill: CPU, memory, logs | A repeatable triage order instead of random commands |
| 06 | Read and write text files | `>` vs `>>`, `cat`, heredocs, `tee`, pipes, stderr |
| 07 | File system hierarchy + scenarios | `/etc`, `/var/log`, `/home`, `/proc`, `/tmp` and what belongs where |
| 08 | Cloud server: Docker + Nginx + deploy | ssh/scp, `ufw`, systemd for nginx, `docker run -p`, log retrieval |
| 09 | User and group management | `useradd`, `groupadd`, `usermod -aG`, `775`/`2775` shared dirs |
| 10 | File permissions & file operations | `rwx` maths, `chmod` numeric/symbolic, `umask`, reading errors |
| 11 | File ownership | `chown`, `chgrp`, `-R`, owner vs group, setgid for shared dirs |

### Revision Self-Assessment (mark before you start)
Honest first pass - change any mark before submitting; the value is in the honesty.

| # | Skill (Days 01-11) | Mark |
|---|--------------------|------|
| 1 | Explain the DevOps lifecycle and my own learning plan | can do |
| 2 | Read process state and find the parent of a process (`ps`, `ps --forest`) | can do |
| 3 | Triage a slow box in a fixed order (load -> memory -> disk -> PID -> logs) | can do |
| 4 | Control a service and read its state (`systemctl status/is-active/restart`) | can do |
| 5 | Query the journal (`journalctl -u`, `--since`, `-p err`) | shaky |
| 6 | Redirect stdout/stderr correctly (`>`, `>>`, `2>&1`, `tee`) | can do |
| 7 | Navigate the file system hierarchy and place files where they belong | shaky |
| 8 | Explain `rwx` maths and read/change modes (`ls -l`, `chmod`, `umask`) | can do |
| 9 | Read owner vs group and change them (`chown`, `chgrp`, `ls -ld`) | can do |
| 10 | Create users/groups and manage membership (`useradd`, `usermod -aG`) | can do |
| 11 | Build a shared directory that stays group-owned (`2775` setgid) | shaky |

Weak spots re-run today: **journalctl flags** (#5), **file system hierarchy** (#7) and **setgid shared dirs** (#11). All three are covered in the drill and tables below.

### Concept Tables

#### Processes and systemd (Days 02, 04)
| Thing | Meaning |
|-------|---------|
| PID | Process ID, unique while the process lives; recycled after exit |
| PPID | Parent PID; `PPID 1` means systemd adopted an orphan |
| `R` (running) | On CPU or waiting for CPU |
| `S` (sleeping) | Waiting for an event - normal for daemons |
| `D` (uninterruptible sleep) | Blocked on I/O; the "disk is slow" state |
| `Z` (zombie) | Exited, parent has not reaped it; `ps` still shows it |
| `T` (stopped) | Suspended by `SIGSTOP` or `Ctrl+Z` |
| unit | A systemd object: `.service`, `.socket`, `.timer`, `.mount`, `.target` |
| `ActiveState` | `active`, `inactive`, `failed`, `activating` |
| `SubState` | `running`, `dead`, `exited`, `failed` |
| `WantedBy` | Which target pulls the unit in on boot (`multi-user.target` = normal server) |
| `ExecStart` | The command systemd runs; `Type=simple` means that PID is the service |
| restart policy | `Restart=always` / `on-failure`, with `RestartSec=` |

```bash
# the four states that matter
ps -o pid,ppid,user,stat,%cpu,%mem,etime,cmd -p 1        # PID 1 = systemd
ps -ef --forest | head -n 30                             # parent/child shape
ps aux --sort=-%cpu | head -n 6                          # hottest CPU
ps aux --sort=-%mem | head -n 6                          # biggest RSS
ps aux | awk '$8 ~ /Z/'                                 # zombies (STAT is column 8)
```

#### Triage order used on Day 05
| Step | Command | Reads |
|------|---------|-------|
| 1 | `uptime` | load average vs core count (`nproc`) |
| 2 | `free -h` | available memory, not just free memory |
| 3 | `df -h` / `df -i` | full filesystem / exhausted inodes |
| 4 | `top` then `ps` | which PID is consuming it |
| 5 | `iostat -x 1` / `vmstat 1` | I/O wait (`wa`) vs CPU |
| 6 | `ss -tulpn` | who is listening, and on which PID |
| 7 | `journalctl -u <svc> -n 50 --no-pager` | the last 50 lines of the service |
| 8 | `dmesg -T \| tail -n 30` | kernel: OOM killer, disk errors |

#### File system hierarchy (Day 07)
| Path | Holds | DevOps example |
|------|-------|----------------|
| `/` | root of the tree | never `rm -rf /` |
| `/etc` | system-wide configuration | `/etc/passwd`, `/etc/group`, `/etc/fstab`, `/etc/nginx/` |
| `/var` | variable data that grows | `/var/log`, `/var/lib`, `/var/cache` |
| `/var/log` | log files | `syslog`, `auth.log`, `nginx/access.log` |
| `/home` | user home directories | `~/.ssh` (mode `700`) |
| `/root` | root's home | not visible to a normal user |
| `/opt` | add-on/whole-application packages | `/opt/dev-project` from Day 09 |
| `/srv` | data served by system services | web roots, FTP roots |
| `/usr` | userland programs and libraries | `/usr/bin`, `/usr/sbin`, `/usr/local/bin` |
| `/tmp` | temporary files, world-writable | wiped on reboot |
| `/mnt`, `/media` | mount points | the Day 13 LVM mount point goes in `/mnt` |
| `/proc` | virtual: process/kernel state | `/proc/1/status`, `/proc/meminfo` |
| `/sys` | virtual: devices and drivers | `/sys/class/block` |
| `/dev` | device nodes | `/dev/sda`, `/dev/null`, `/dev/loop0` |
| `/boot` | kernel + initrd | touched by kernel updates only |
| `/bin`, `/sbin` | core user/system binaries (symlinks to `/usr/*` on modern Ubuntu) | `/usr/sbin/nginx` |
| `/lib` | shared libraries | `/lib/x86_64-linux-gnu` |

#### File I/O and redirection (Day 06)
| Syntax | Meaning | Trap |
|--------|---------|------|
| `cmd > f` | stdout to `f`, **truncate** | destroys existing content |
| `cmd >> f` | stdout to `f`, append | safe for logs |
| `cmd 2> f` | stderr to `f` | stdout still on the terminal |
| `cmd > f 2>&1` | stdout **and** stderr to `f` | order matters: `2>&1 >f` is wrong |
| `cmd &> f` | both, bash shorthand | not POSIX `sh` |
| `cmd 2>/dev/null` | hide errors | hides real problems too - use sparingly |
| `cmd \| next` | pipe stdout into the next command | only stdout, not stderr |
| `cmd \| tee f` | show on screen *and* save | `tee -a` appends |
| `cmd < f` | stdin from a file | |
| `<<'EOF'` | heredoc literal | the quotes stop `$` expansion |
| `<<EOF` | heredoc expanded | `$var` expands inside |

```bash
cat > notes.txt <<'EOF'
literal $HOME and `backticks` stay as typed
EOF

printf '%s\n' "expanded: $HOME" > out.txt      # printf is safer than echo -n
ss -tulpn > /tmp/net.txt 2>&1                  # both streams, one file
tail -f /var/log/syslog | grep -i error        # follow + filter
```

#### Permissions, ownership and users (Days 09, 10, 11)
| Mode | Symbolic | Meaning | Typical use |
|------|----------|---------|-------------|
| `644` | `-rw-r--r--` | owner rw, group r, other r | config, web assets |
| `600` | `-rw-------` | owner only | SSH private keys, secrets |
| `640` | `-rw-r-----` | owner rw, group r | owner + team |
| `700` | `drwx------` | owner only | `~/.ssh` |
| `750` | `drwxr-x---` | owner rwx, group rx | team directory |
| `755` | `drwxr-xr-x` | everyone can read/traverse | scripts, public dirs |
| `775` | `drwxrwxr-x` | owner + group write | shared team dir |
| `2775` | `drwxrwsr-x` | `setgid`: new files inherit the dir group | shared team dir that must stay group-owned |
| `1777` | `drwxrwxrwt` | `sticky`: only the owner may delete | `/tmp` |
| `4755` | `-rwsr-xr-x` | `setuid`: runs as the file owner | `sudo`, `passwd` |

```text
r = 4   w = 2   x = 1
owner  group  other
 644 =  6 4 4  = rw- r-- r--
 755 =  7 5 5  = rwx r-x r-x
 2775 = 7 7 5 with the setgid bit on the directory
```

On a **directory**, the bits mean something different from a file:
| Bit | On a file | On a directory |
|-----|-----------|----------------|
| `r` | read contents | list names |
| `w` | write contents | create/delete/rename entries |
| `x` | execute | **traverse** into it and stat the entries |

| File | Holds | Why it matters |
|------|-------|----------------|
| `/etc/passwd` | `user:x:UID:GID:gecos:home:shell` | world-readable by design |
| `/etc/shadow` | encrypted passwords | `root` only (`000`/root) |
| `/etc/group` | `group:x:GID:user,user` | supplementary groups |
| `/etc/gshadow` | group passwords | root only |
| `/etc/sudoers` | sudo policy | root only, edit with `visudo` |

| Command | Does |
|---------|------|
| `id` | my uid, gid, and all groups |
| `id -nG <user>` | just the group names for that user |
| `getent passwd <user>` / `getent group <g>` | definitive "does it exist" check |
| `sudo useradd -m -s /bin/bash u` | user + home + shell |
| `sudo groupadd g` | new group |
| `sudo usermod -aG g1,g2 u` | **add** to groups; `-a` is mandatory |
| `sudo userdel -r u` | delete user and home |
| `sudo chown u:g file` | owner and group |
| `sudo chgrp g file` | group only |
| `sudo chown -R u:g dir/` | whole tree |
| `chmod` | mode bits only - never changes owner/group |

### Incident Cheat Sheet - the first 5 I would reach for

```bash
# 1. What is broken right now, at the service level?
systemctl status nginx --no-pager
# 2. What did it just say?
journalctl -u nginx -n 50 --no-pager
# 3. What is eating the machine?
top                      # or: htop
# 4. Who is listening on this port, and which PID?
ss -tulpn
# 5. Is it even reachable from here? (two hops: DNS then TCP)
curl -sI https://example.com ; nc -zv example.com 443
```

The extended Day 03 cheat sheet, grouped by what you are trying to answer:

| Question | Commands |
|----------|----------|
| Is the box up and loaded? | `uptime`, `nproc`, `free -h`, `top`, `vmstat 1` |
| Which process is the problem? | `ps aux --sort=-%cpu \| head`, `ps aux --sort=-%mem \| head`, `pidstat -p <pid> 1`, `lsof -p <pid> \| head` |
| Control a process | `kill -TERM <pid>`, `kill -9 <pid>` (last resort), `pkill -f 'pattern'`, `pgrep -a -f 'pattern'` |
| Service state | `systemctl status <u>`, `systemctl is-active <u>`, `systemctl is-enabled <u>`, `systemctl list-units --failed`, `systemctl cat <u>` |
| Control a service | `sudo systemctl restart <u>`, `sudo systemctl reload <u>`, `sudo systemctl enable --now <u>`, `sudo systemctl daemon-reload` |
| Logs | `journalctl -u <u> -f`, `journalctl -u <u> --since '1 hour ago'`, `journalctl -p err -n 50`, `journalctl -b -k`, `tail -f /var/log/syslog`, `grep -i error /var/log/syslog` |
| Disk | `df -h`, `df -i`, `du -sh /var/* \| sort -h \| tail`, `find / -type f -size +100M 2>/dev/null`, `lsof +D /var/log` |
| Network | `ip a`, `ip r`, `ss -tulpn`, `ping -c 3 1.1.1.1`, `dig +short example.com`, `dig @1.1.1.1 example.com`, `traceroute -n 1.1.1.1`, `curl -sv https://...` |
| Files | `ls -l`, `ls -ld`, `ls -lR`, `stat <file>`, `file <file>`, `find . -name '*.log'`, `du -sh *` |
| Permissions / owners | `namei -l <path>`, `stat -c '%U %G %a' <f>`, `id -nG <user>`, `sudo -u <user> sh -c 'test -r <f>'` |
| Text processing | `grep -rn 'x' .`, `sed -n '10,20p' f`, `sed -i 's/a/b/g' f`, `awk '{print $1}' f`, `sort f \| uniq -c \| sort -rn \| head`, `wc -l` |
| Containers (Day 08) | `docker ps`, `docker logs -f <c>`, `docker exec -it <c> nginx -t`, `docker inspect -f '{{.State.Status}}' <c>`, `docker system df` |
| Misc | `command -v <cmd>`, `history \| tail`, `echo $?`, `date`, `hostnamectl`, `timedatectl`, `uname -a`, `cat /etc/os-release` |

### Hands-On Re-Run Drill (the 15-20 minute part)
**Why:** Reading notes retains less than running commands. This is one copy-paste block that touches
processes, services, logs, files, permissions, ownership and users. The tables and cheat sheet above
*are* the revision; this block is the hands-on part that proves they still work.

```bash
mkdir -p ~/day12-revision && cd ~/day12-revision
sudo -i                                        # root shell; 'exit' when done

# --- processes ---
ps -o pid,ppid,user,stat,%cpu,%mem,etime,cmd -p 1
ps aux --sort=-%mem | head -n 6
uptime ; nproc ; free -h

# --- services: pick one that exists on your box ---
systemctl list-units --type=service --state=running --no-pager | head -n 15
systemctl is-active ssh            # or nginx / cron
systemctl status cron --no-pager
journalctl -u cron -n 20 --no-pager
journalctl -u cron --since '1 hour ago' --no-pager | tail -n 10

# --- logs and network ---
journalctl -p err -n 10 --no-pager
ss -tulpn | head -n 10
df -h /
```

Prove the three shaky skills (#5 journalctl, #7 hierarchy, #11 setgid):

```bash
# #5 journalctl flags against one unit
journalctl -u cron -f                                  # follow live (Ctrl+C to stop)
journalctl -u cron -p err -n 20 --no-pager             # errors only
journalctl -b -k --no-pager | tail -n 10               # this boot, kernel only

# #7 hierarchy: create a file, then find where it belongs
ls -ld /etc /var/log /opt /tmp
cat /etc/os-release | head -n 2

# #11 setgid shared directory that stays group-owned
getent group planners >/dev/null || groupadd planners
id professor >/dev/null 2>&1 || useradd -m -s /bin/bash professor
mkdir -p /opt/dev-project
chown root:planners /opt/dev-project
chmod 2775 /opt/dev-project
sudo -u professor touch /opt/dev-project/t.txt
ls -ld /opt/dev-project ; ls -l /opt/dev-project/t.txt # group is planners, not professor
```

```bash
# --- files, permissions, ownership, users ---
cd ~/day12-revision
printf '%s\n' 'revision file' > rev.txt
echo 'appended line' >> rev.txt
cat rev.txt ; wc -l rev.txt ; ls -l rev.txt

chmod 640 rev.txt && ls -l rev.txt          # -rw-r----- 1 root root
chmod 644 rev.txt && ls -l rev.txt          # back to -rw-r--r--

mkdir -p shared && touch shared/a.txt
chown professor:planners shared             # user/group must exist first
ls -ld shared
stat -c '%n %U:%G %a' shared shared/a.txt
namei -l shared/a.txt
```

```bash
# --- cleanup ---
cd ~ && rm -rf ~/day12-revision
rm -rf /opt/dev-project
exit
```

Record what you observed (fill these in after the run):
- `uptime` load: `____` on `____` cores
- top RSS consumer PID/user: `____`
- Service checked: `____` -> `is-active` returned `____`
- `journalctl -u <svc> -n 20` last meaningful line: `____`
- `df -h /` usage: `____`
- `stat` on `shared/a.txt`: `____`

### Self-Check - the four questions from the task

**1) Which 3 commands save you the most time right now, and why?**
1. `journalctl -u <service> -n 50 --no-pager` - it answers "what happened" in one shot. Every other tool
   tells you about state; the journal tells you the cause and the time it started. During Day 05 this
   single command replaced guesswork in two separate drills.
2. `ps aux --sort=-%mem | head` (and the `-%cpu` variant) - converts "the box is slow" into a
   specific PID and user, which is the only thing that lets me act. One `head` and I have my suspect.
3. `ls -l` / `stat -c '%U %G %a %n' <path>` - ownership and mode in one glance. Days 10-11 showed that most
   "permission denied" mysteries are resolved by looking at the owner, the group and the mode together.

**2) How do you check if a service is healthy? List the exact 2-3 commands you would run first.**
```bash
systemctl is-active nginx                 # 1. machine-readable: active / inactive / failed
systemctl status nginx --no-pager         # 2. human-readable: state, PID, uptime, last log lines
journalctl -u nginx -n 50 --no-pager      # 3. the recent log - is it erroring and restarting?
```
Then the real test, because "active" only means the process exists:
```bash
ss -tulpn | grep :80                      # is it actually listening?
curl -sI http://localhost | head -n 1     # does it answer? expect: HTTP/1.1 200 OK
```
Interpretation rules I wrote down: `is-active` returning `active` while `journalctl` shows
`Started ...`/`Stopped ...` repeatedly means a crash loop - check `Restart=` and the exit status with
`systemctl show nginx -p NRestarts`.

**3) How do you safely change ownership and permissions without breaking access? Give one example command.**
- Change ownership and mode in the **same** command so there is never a moment where they disagree.
- Restrict to the narrowest path - never a recursive change on `/` or `$HOME`.
- Keep `o+rx` on directories so other tooling can still traverse them, and set the group the app expects.
```bash
sudo chown www-data:www-data /var/www/myapp && sudo chmod 750 /var/www/myapp
```
For a shared team directory (the Day 09/11 pattern), set setgid so new files stay group-owned:
```bash
sudo mkdir -p /opt/dev-project
sudo chown root:developers /opt/dev-project
sudo chmod 2775 /opt/dev-project
# then verify, including as a non-root user
ls -ld /opt/dev-project
sudo -u tokyo sh -c 'touch /opt/dev-project/t.txt' && ls -l /opt/dev-project/t.txt
```
Rollback plan before touching production: record `getfacl`/mode+owner first
(`stat -c '%U %G %a' <path>`), change one path, verify with `sudo -u <app-user>`, and only then repeat.

**4) What will you focus on improving in the next 3 days?**
- `journalctl` flags under pressure - I still pause on `-u`, `-f`, `--since`, `-p`, `-b`, `-k`. I will
  run all of them against one unit and memorise the output shapes.
- File system layout - knowing *which* directory a thing belongs in (`/etc` config vs `/var/log` data vs
  `/opt` apps) without hesitating, because that decision is what makes a server understandable later.
- Writing single-purpose scripts rather than long interactive command chains, since Day 13+ storage work
  and the later Docker/GitHub Actions days both need commands I can re-run and paste.

### Self-Test Question Bank (with answers)

1. **`ls -l` shows `-rw-r--r-- 1 berlin developers 312 ... notes.txt`. Who can write it?**
   Only `berlin`. The group `developers` and everyone else have `r--` (no `w`). Root can always write, but
   through the kernel's override, not through these bits.

2. **A directory is mode `755`. What can each class do, and what does `x` mean on a directory?**
   `rwx` for the owner, `r-x` for group and others: the owner may create/delete/list, group and others may
   list and traverse but not create. On a directory `x` means "enter/traverse", not "run".

3. **Difference between `chown tokyo f`, `chown :tokyo f`, `chown tokyo: f` and `chown : f`?**
   `tokyo f` -> owner becomes tokyo, group unchanged. `:tokyo` -> group becomes tokyo (group names live in a
   different namespace; here it is just an odd group name). `tokyo:` -> owner tokyo **and** the group set to
   tokyo's login group. `:` alone -> no change at all.

4. **`sudo chown tokyo f` returns `Operation not permitted`. Why, and how to fix?**
   EPERM: you are not root and only root can give a file to a different user. Fix: `sudo`. Contrast with
   `Permission denied` (EACCES), which means "permissions, not privileges".

5. **Why did `chmod` appear to do nothing in WSL2 under `/mnt/c`?**
   The NTFS/DrvFs mount does not store Linux ownership or mode bits. Copy the file into the Linux
   filesystem (`~`) and modes behave normally.

6. **A user is in groups `developers` and `ops`. A file is `rw-rw---- root:ops`. Can the user edit it?**
   Yes - the kernel checks all of the user's groups, finds `ops`, and grants the group's `rw`.

7. **What does `chmod 2775` do, and why did Day 11 need it?**
   `2775` = `drwxrwsr-x`: rwx for owner, rws for group (the extra `2` is setgid), r-x for others. setgid on a
   directory makes every file created inside inherit the directory's group, so team files stay `developers`
   instead of reverting to the creator's own primary group.

8. **`ps` shows a process with `STAT` = `D`. What is happening?**
   Uninterruptible sleep, normally blocked on disk I/O. `D` processes cannot be killed; combined with high
   `wa` in `vmstat`/`iostat` it points at storage, not CPU.

9. **Difference between `kill -TERM 1234` and `kill -9 1234`?**
   `SIGTERM` asks the process to shut down cleanly (it can flush and close files); `SIGKILL` cannot be caught
   and terminates immediately, risking unflushed data and leftover lock files. Always try `TERM`, wait, then
   escalate.

10. **`systemctl restart nginx` did nothing but the site stayed down. What do you check?**
    `systemctl status nginx --no-pager` for the real error, `journalctl -u nginx -n 50 --no-pager`,
    `nginx -t` for a config syntax error, and `ss -tulpn | grep :80` to see whether a stale process still
    holds the port (`nginx -s stop` or kill the orphan PID).

11. **A file is 644 but its directory is 700. Can a group member read the file?**
    No. To reach the file you need `x` on every directory in the path. Diagnose with
    `namei -l /full/path/file`.

12. **What does `>` do to an existing file, and what does `>>` do?**
    `>` truncates it to zero bytes first, then writes. `>>` appends. Also `> out 2>&1` order matters -
    `2>&1 >out` sends stderr to the old stdout (the terminal).

13. **Where do you look for a failed SSH login on Ubuntu, and what command shows it live?**
    `/var/log/auth.log` (systemd journal on newer systems: `journalctl -u ssh -f` or
    `journalctl -t sshd -f`). Live: `tail -f /var/log/auth.log | grep -i 'failed password'`.

14. **Load average 4.0 on a 2-core box. Healthy?**
    No - load above the core count means runnable work is queued. Correlate with `top` (`%iowait` vs `%cpu`)
    and `vmstat 1` (the `r` and `b` columns) before blaming CPU.

15. **`df -h` says 60% used but a write fails with `No space left on device`. Why?**
    Inodes are exhausted: a huge number of tiny files. `df -i` reveals it. Fix by finding and removing
    small files, not by extending the volume.

16. **Command to find the 10 biggest subdirectories under `/var`?**
    `sudo du -sh /var/* 2>/dev/null | sort -h | tail -n 10`

17. **Correct way to add a user to two groups, and what goes wrong without the flag?**
    `sudo usermod -aG g1,g2 user`. Without `-a`, `usermod -G` **replaces** the whole supplementary group list,
    silently removing every previous membership.

18. **`dig example.com` returns an IP but `curl` fails to connect. What is the next check?**
    Name resolution is fine, so it is connectivity: `ping -c 3 <ip>`, then `ss -tulpn` on the server to see if
    anything listens on that port, then the firewall (`sudo ufw status`) and the cloud security group, then
    `nc -zv example.com 443`.

19. **A systemd service exits immediately with status 203/EXEC. Cause?**
    systemd cannot execute `ExecStart` - the binary is missing or not executable. Check
    `systemctl cat <unit>` for the exact path, `command -v <binary>`, `ls -l` on the binary (missing `x`
    bit), and whether the interpreter in a shebang exists.

20. **Why keep `-R --preserve-root` on a recursive `chown`, and what does `-c` add?**
    `--preserve-root` makes the command refuse to operate on `/`, which protects against a destructive typo.
    `-c`/`--changes` prints only the files whose ownership actually changed, so you can confirm the blast
    radius after the fact.

## Commands Used

```bash
# revision re-run drill (Days 01-11)
uptime; free -h; df -h /
ps -o pid,ppid,user,stat,%cpu,%mem,etime,cmd -p 1
ps aux --sort=-%cpu | head -10
ps aux --sort=-%mem | head -10
top -b -n 1 | head -20
systemctl list-units --type=service --state=running --no-pager | head
systemctl is-active ssh || systemctl is-active sshd
systemctl status cron --no-pager
journalctl -u cron -n 20 --no-pager
journalctl -u cron --since '1 hour ago' --no-pager
journalctl -p err -n 10 --no-pager
ss -tulpn
mkdir -p ~/day12-revision && cd ~/day12-revision
printf '%s\n' 'revision file' > rev.txt; echo 'appended line' >> rev.txt
chmod 640 rev.txt; chmod 644 rev.txt
mkdir -p shared && touch shared/a.txt
chown professor:planners shared
ls -ld shared; stat -c '%n %U:%G %a' shared shared/a.txt; namei -l shared/a.txt
id professor; id -nG professor; getent group planners
# setgid shared dir that stays group-owned
mkdir -p /opt/dev-project && chown root:planners /opt/dev-project && chmod 2775 /opt/dev-project
rm -rf ~/day12-revision /opt/dev-project
```

## Verification
- `ps -o pid,ppid,user,stat,%cpu,%mem,etime,cmd -p 1` shows systemd as PID 1
- `systemctl is-active <svc>` printed `active` and `systemctl status` agreed
- `journalctl -u <svc> -n 20 --no-pager` returned real log lines (not `No journal files were found`)
- `journalctl -u <svc> --since '1 hour ago' --no-pager` returned a filtered subset
- `df -h /` and `df -i /` both read successfully
- `>>` appended to `rev.txt` while `>` truncated a copy, both demonstrated
- `chmod 640` then `chmod 644` on `rev.txt` produced `-rw-r-----` then `-rw-r--r--`
- `chown professor:planners shared` succeeded and `ls -ld shared` confirmed it
- `id -nG professor`, `getent group planners` and `stat -c '%U:%G %a'` all agreed with `ls -l`
- `namei -l shared/a.txt` walked the full path with no `root`/`nobody` surprises
- `ls -l /opt/dev-project/t.txt` shows group `planners` even though `professor` created it (setgid proof)

## Key Learnings
- Triage is a fixed order (load -> memory -> disk -> top -> ports -> logs), not a list of random commands; skipping to step 7 first wastes minutes
- `active` is not `healthy`: `is-active` + `status` + `journalctl` + one real request (`curl`) is the minimum honest check
- An inode has one UID and one GID; the group is a *set membership* match, so one user can satisfy many groups at once
- Permissions are evaluated per path component, so `namei -l` is the fastest way to find the directory that is blocking you
- setgid on a shared directory (`2775`) is what stops group ownership drifting - the single most useful bit from Day 09/11
- Redirection order (`> f 2>&1`) and truncation (`>`) explain most "where did my file contents go" incidents
- Diagnose by separating state from cause: `ps`/`df`/`ss` give state, `journalctl` and `dmesg` give cause
- Knowing the `/etc` vs `/var/log` vs `/opt` split makes a server readable months later - and tomorrow's LVM work adds `/mnt`

## Troubleshooting / Gotchas
- **`journalctl: No journal files were found`** - `systemd-journald` is not running (a container/minimal image). Use `/var/log/syslog` or `docker logs` instead.
- **`systemctl status` truncated so the error line is missing** - always add `--no-pager` (or set `SYSTEMD_PAGER=cat`) when piping.
- **`ps aux --sort=...` needs the `--`** before option values if your shell globs them; `--sort=-%cpu` is safe.
- **A shell redirect silently created a file owned by root** - you ran the command under `sudo` and used `>`; check ownership right after any root-shell redirect.
- **`sudo -u user ls dir` shows the contents but `sudo -u user cat dir/file` fails** - the directory lacks `x` (traverse), so `ls` lists names it cannot open.
- **`id user` shows the old groups until they re-login** - supplementary groups are read at login; test with `sudo -iu user` (login shell) or `newgrp <group>`.
- **Re-running the lab keeps failing on `useradd`/`groupadd`** - they are not idempotent. Guard with `id "$u" >/dev/null 2>&1 || sudo useradd ...`.
- **`chmod -R 777 .` "fixing" a problem** - it hides the real ownership/mode bug and opens a hole. Fix the specific path instead.

## Screenshots

Suggested filenames (save each PNG to `2026/day-12/screenshots/`):

| File | Task | Proves |
|------|------|--------|
| `01-systemctl-journal-side-by-side.png` | Re-run drill | `systemctl status` + `journalctl -u` for the same service |
| `02-chmod-640-644.png` | Re-run drill | `chmod 640` then `644` on `rev.txt` with `ls -l` after each |
| `03-stat-ownership-proof.png` | Day 09/11 redo | `stat -c '%U:%G %a'` + `namei -l` for the recreated scenario |
| `04-ps-top-triage.png` | Re-run drill | `ps aux --sort=-%mem \| head` triage output |
| `05-setgid-shared-dir.png` | Weak spot #11 | a new file in a `2775` dir inheriting group `planners` |

Embed them inline in the matching section above with one line per image, for example:

```markdown
![systemctl and journalctl side by side](screenshots/01-systemctl-journal-side-by-side.png)
![chmod 640 then 644 proof](screenshots/02-chmod-640-644.png)
![ownership scenario proof](screenshots/03-stat-ownership-proof.png)
![process triage output](screenshots/04-ps-top-triage.png)
![setgid shared directory proof](screenshots/05-setgid-shared-dir.png)
```

> **Lab note:** the PNGs are captured by the trainee and renamed from their
> `Screenshot <date> <time>.png` originals into the task order above. If a
> filename/description ever looks mismatched, open the image and re-check the
> command it shows.
