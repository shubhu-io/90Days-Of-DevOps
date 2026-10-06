# Day 03 - Linux Commands Practice

## Task

Concise recap of every challenge task from `README.md`:

- Build a Linux command cheat sheet covering Process Management, File System, and Networking Troubleshooting.
- Include at least 20 commands with one-line usage notes.
- Add at least 3 networking commands (`ping`, `ip addr`, `dig`, `curl`, etc.).
- Group commands by category; keep concise and readable for real troubleshooting.
- Only include commands you understand (no long copy-pasted lists).

## Environment

| Item | Value | Install / Check Command |
|------|-------|--------------------------|
| OS | Ubuntu 22.04/24.04 LTS (any Debian/RHEL works; notes call out differences) | `cat /etc/os-release` |
| Shell | Bash | `echo $SHELL` |
| Core tools | GNU coreutils, `procps` (`ps`, `top`, `free`), `grep`, `findutils` (preinstalled) | `command -v ps grep find df du ss` |
| Network tools | `iproute2` (`ip`, `ss`), `curl`, `ping` (`iputils-ping`), `dig` (`dnsutils`/`bind-utils`) | `sudo apt-get install -y iproute2 curl iputils-ping dnsutils net-tools traceroute netcat-openbsd` |
| Optional monitors | `htop`, `nc`, `wget` | `sudo apt-get install -y htop wget` |
| Learner values | Your IPs, DNS answers, listening ports | `[TODO - run on your machine]` fill from `ip a`, `dig`, `ss` |

## Solution

### 1) Process management (inspect, control, monitor)

**Why:** "server is slow / app is down" always starts here. Snapshot first, then live view, then act on a precise PID.

```bash
ps aux | head -20
ps -ef | head -10
ps aux --sort=-%cpu | head -10
pstree -p | head -20
top -b -n 1 | head -20
pgrep -a nginx
pidof sshd
kill <PID>
kill -9 <PID>
```

**Illustrative output (run on your machine for real values):**

```text
$ ps aux --sort=-%cpu | head -4   # illustrative
USER   PID %CPU %MEM STAT COMMAND
app   1842 78.1 12.4 R    /usr/bin/python3 /opt/myapp/server.py
root     1  0.0  0.3 Ss   /sbin/init splash

$ ss -tlnp | grep :22   # illustrative
LISTEN 0 128 0.0.0.0:22 0.0.0.0:* users:(("sshd",pid=450,fd=3))
```

| Command | One-line usage | Notes |
|---------|---------------|-------|
| `ps aux` | All processes, detailed (user, PID, %CPU, %MEM, STAT, COMMAND) | Snapshot; pipe to `head`/`grep` |
| `ps -ef` | All processes, full format with PPID and start time | Hierarchy + age |
| `pstree -p` | Process tree with PIDs | See parent → child from PID 1 |
| `top` | Live CPU/MEM/process monitor | `q` quits; `-b -n 1` for captures |
| `htop` | Nicer live monitor (colours, filter, tree) | `sudo apt install htop` |
| `pgrep -a <name>` | Find PIDs by name, show full command | Avoids `ps \| grep grep` |
| `pidof <name>` | PIDs of a running program | Fast exact match |
| `ps -o pid,pcpu,pmem,comm -p <pid>` | Repeatable per-process CPU/mem line | Paste into tickets |
| `kill <PID>` | SIGTERM (graceful stop) | Default; lets app clean up |
| `kill -9 <PID>` | SIGKILL (force; last resort) | Uncatchable; may leave stale sockets/locks |
| `killall <name>` | Signal all processes by name | Dangerous — double-check name first |

### 2) File system (navigate, inspect, search, measure)

**Why:** configs, logs, and deploy artifacts are all files. Half of DevOps debugging is "find the right file, read the right lines, check disk isn't full."

```bash
pwd; ls -la; cd /var/log
find /var/log -name "*.log" 2>/dev/null | head -5
grep -rn "ERROR" /var/log/nginx/ 2>/dev/null | head -10
cat /etc/hostname
head -n 20 /var/log/syslog
tail -n 50 /var/log/syslog
tail -f /var/log/syslog
stat /etc/passwd
du -sh /var/log/* 2>/dev/null | sort -h | tail -5
df -h
```

**Illustrative output:**

```text
$ du -sh /var/log/* 2>/dev/null | sort -h | tail -3   # illustrative
12K  /var/log/auth.log
44M  /var/log/journal
120M /var/log/syslog

$ df -h   # illustrative
Filesystem  Size Used Avail Use% Mounted on
/dev/sda1    30G  12G   17G  42% /
```

| Command | One-line usage | Notes |
|---------|---------------|-------|
| `pwd` | Print working directory | Orient before relative paths |
| `ls -la` | Long list incl. hidden, perms, sizes | `-lh` for human sizes |
| `cd <path>` | Change directory (`cd -` goes back) | Absolute paths in runbooks |
| `find <path> -name "*.log"` | Search files by name/size/time | Add `2>/dev/null` to hide denied |
| `locate <name>` | Fast indexed filename search | Run `sudo updatedb` first if stale |
| `grep -r "pattern" <dir>` | Recursive content search | `-i` case, `-n` lines, `-v` invert, `--include="*.log"` |
| `cat <file>` | Dump whole file | Small files only |
| `less <file>` | Paged view with search (`/`, `q`) | Large files |
| `head -n 20 <file>` | First N lines | Quick peek |
| `tail -n 50 <file>` | Last N lines | Log tails |
| `tail -f <file>` | Follow live growth | `Ctrl+C` stops |
| `stat <file>` | Inode, perms, mtime, size | Forensics |
| `du -sh *` | Disk usage per item, human-readable | Find space hogs |
| `df -h` | Filesystem free/used per mount | First command when disk alerts fire |
| `touch <file>` | Create empty file / bump mtime | Day 06/10 drill |
| `mkdir -p <dir>` | Create dirs incl. parents | Idempotent |
| `cp /etc/hosts /tmp/x` | Copy file | Sanity write test |
| `chmod 644 <file>` | Set perms (`rw-r--r--`) | Day 10 drill |
| `chown user:group <file>` | Change ownership | After uploads/copies as root |
| `rm -rf <dir>` | Recursive force delete — no undo | Triple-check path; never `/` |

### 3) Networking troubleshooting (interfaces, DNS, HTTP, sockets)

**Why:** "works on the box, fails from the browser" is firewall/DNS/routing, not app code. These commands separate the layers in seconds.

```bash
ip addr show
ip route show
ping -c 4 8.8.8.8
ping -c 4 google.com
dig google.com +short
dig @8.8.8.8 google.com
curl -I https://example.com
curl -sv https://example.com -o /dev/null 2>&1 | tail -20
ss -tulnp | head -15
nc -vz 127.0.0.1 22
```

**Illustrative output (yours will differ — record real values):**

```text
$ ip -brief addr   # illustrative
lo  UNKNOWN 127.0.0.1/8 ::1/128
eth0 UP 10.0.1.23/24 fe80::1/64

$ dig google.com +short   # illustrative
142.250.190.14

$ curl -I https://example.com   # illustrative
HTTP/2 200
content-type: text/html; charset=UTF-8

$ ss -tlnp | head -4   # illustrative
State Recv-Q Local Address:Port Peer Address:Port Process
LISTEN 0 128 0.0.0.0:22 0.0.0.0:* users:(("sshd",pid=450,fd=3))
```

| Command | One-line usage | Notes |
|---------|---------------|-------|
| `ip addr show` (`ip a`) | Interfaces, IPs, MAC, state | Replaces `ifconfig` |
| `ip route show` | Routing table + default gateway | No route = no internet |
| `ping -c 4 8.8.8.8` | ICMP reachability to an IP | Tests L3 without DNS |
| `ping -c 4 google.com` | Reachability + DNS in one | Fails here but IP works → DNS issue |
| `dig google.com +short` | Minimal DNS answer | Scriptable |
| `dig @8.8.8.8 google.com` | Query a specific resolver | Proves local resolver vs upstream |
| `nslookup google.com` | Simple DNS lookup | Ubiquitous, less detail than `dig` |
| `curl -I https://example.com` | HTTP headers only | Status/redirects/TLS fast check |
| `curl -L -v <url>` | Follow redirects, verbose | Debug TLS/redirect chains |
| `wget -O- <url> \| head -20` | Fetch body to stdout | `curl` alternative |
| `ss -tulnp` | Listening TCP/UDP sockets + owning PIDs | Replaces `netstat -tulnp` |
| `traceroute -I 8.8.8.8` / `tracepath` | Hop-by-hop path | Find where packets die |
| `nc -vz <host> <port>` | TCP port probe | `Connection refused` vs timeout tells a story |

| Your machine | Value |
|--------------|-------|
| Primary IP (`ip a`) | `[TODO - run on your machine]` |
| Default gateway (`ip route`) | `[TODO - run on your machine]` |
| `dig google.com +short` answer | `[TODO - run on your machine]` |
| Listening ports (`ss -tlnp`) | `[TODO - run on your machine]` |

### 4) Logs, system info, misc (glue commands)

```bash
uname -a
uptime
free -h
whoami; id
date -u
which nginx
man ss
journalctl -u ssh --since -1h --no-pager | tail -20
journalctl -b -p err --no-pager | tail -20
```

| Command | One-line usage | Notes |
|---------|---------------|-------|
| `uname -a` | Kernel/hostname/arch | Version pinning |
| `uptime` | Load averages + uptime | `1.2 0.8 0.4` = 1/5/15 min |
| `free -h` | Memory (watch `available`, not `free`) | Cache is reclaimable |
| `whoami` / `id` | Current user / UID/GID/groups | Permission context |
| `date -u` | UTC time | Correlate with cloud logs |
| `which <cmd>` | Binary path actually executed | PATH surprises |
| `man <cmd>` | Authoritative reference | `q` quits |
| `journalctl -u <svc> --since -1h` | Service logs, last hour | Incident window |
| `journalctl -b -p err` | Errors since boot | Boot failures |

**Why it matters:** interviews and incidents both reward the engineer who types `ss -tlnp`, `journalctl -u x --since -10m`, and `df -h` without thinking. This sheet is that muscle memory on paper.

## Commands Used

```bash
ps aux | head -20
ps -ef | head -10
ps aux --sort=-%cpu | head -10
pstree -p | head -20
top -b -n 1 | head -20
pgrep -a nginx
pidof sshd
kill <PID>
pwd; ls -la; cd /var/log
find /var/log -name "*.log" 2>/dev/null | head -5
grep -rn "ERROR" /var/log/nginx/ 2>/dev/null | head -10
cat /etc/hostname
head -n 20 /var/log/syslog
tail -n 50 /var/log/syslog
tail -f /var/log/syslog
stat /etc/passwd
du -sh /var/log/* 2>/dev/null | sort -h | tail -5
df -h
ip addr show
ip route show
ping -c 4 8.8.8.8
ping -c 4 google.com
dig google.com +short
dig @8.8.8.8 google.com
curl -I https://example.com
ss -tulnp | head -15
nc -vz 127.0.0.1 22
uname -a
uptime
free -h
journalctl -u ssh --since -1h --no-pager | tail -20
```

## Verification

- [ ] `ps aux | head -5` prints columns USER/PID/%CPU/%MEM/COMMAND
- [ ] `ps aux --sort=-%cpu | head -3` shows the hottest process on top
- [ ] `find . -maxdepth 2 -name "*.md" 2>/dev/null | head -3` returns files without permission noise
- [ ] `grep -rn "TODO" . --include="*.md" 2>/dev/null | head -3` searches content correctly
- [ ] `df -h` and `free -h` print sane values (no errors)
- [ ] `ip a | grep -A1 "inet "` shows assigned IPs: `[TODO - run on your machine]` record yours
- [ ] `ping -c 2 8.8.8.8` gets replies (or document blocked ICMP): `[TODO - run on your machine]`
- [ ] `dig google.com +short` returns IPs (or document DNS block): `[TODO - run on your machine]`
- [ ] `curl -I https://example.com | head -1` returns a `HTTP/*` status line
- [ ] `ss -tulnp | head -10` lists listening sockets (may need `sudo` for process names)
- [ ] At least 20 commands above are ones you can explain without notes

## Key Learnings

- `ps` is a snapshot, `top`/`htop` are live; `ps --sort=-%cpu` is the paste-into-ticket form.
- `find` locates files, `grep -r` searches inside them; combine both to go from "disk full" to culprit file to culprit line.
- `tail -f` watches growth, `journalctl -u <svc>` scopes to one systemd unit with time filters.
- `ip` replaces `ifconfig`, `ss` replaces `netstat`; learn the modern pair first.
- `ping <IP>` vs `ping <name>` separates L3 reachability from DNS; `dig @8.8.8.8` isolates your resolver.
- `curl -I` checks the HTTP layer in one line; status codes (200/301/403/502) map to different owners.
- `df -h` (space) + `du -sh` (usage) + `lsof +L1` (deleted-open files) is the full disk triage trio.
- Destructive commands (`rm -rf`, `kill -9`, `killall`) need a re-verified target every time.

## Troubleshooting / Gotchas

- **`ping 8.8.8.8` works but `ping google.com` fails:** Cause: DNS broken, network fine. Fix: `cat /etc/resolv.conf`, then `dig @8.8.8.8 google.com` to prove upstream works.
- **`ss` shows nothing but app claims to listen:** Cause: ran without permission or grepped wrong port. Fix: `sudo ss -tlnp | grep -i <app>`; check container port mapping (`-p 8080:80`).
- **`netstat: command not found` on minimal images:** Cause: `net-tools` not installed. Fix: use `ss -tulnp` (preinstalled via `iproute2`).
- **`htop` / `dig` / `traceroute` missing:** Cause: minimal cloud image. Fix: `sudo apt-get install -y htop dnsutils traceroute`.
- **`locate` returns stale/missing results:** Cause: `mlocate.db` outdated. Fix: `sudo updatedb` then retry.
- **Huge output floods terminal (`cat` on a 2 GB log):** Cause: no pager/filter. Fix: `less`, `head/tail`, or `grep -n pattern file | head`.
- **`curl: (6) Could not resolve host`:** Cause: DNS or egress blocked (common in locked-down VPCs). Fix: `dig +short`, check security-group egress and proxy env vars (`env | grep -i proxy`).
- **Permission denied on `tail /var/log/*` or `ss -p`:** Cause: needs elevated read. Fix: prefix `sudo`, or scope to your own unit with `journalctl --user`.

## Self-check

- [ ] 20+ commands listed with one-line notes I understand
- [ ] 3+ networking commands included (`ping`, `ip addr`, `dig`/`curl`)
- [ ] Grouped into Process / File System / Networking (+ logs/misc)
- [ ] Can explain `ps` vs `top` and when each wins
- [ ] Can find listening ports (`ss -tlnp`) and test connectivity (`ping`, `nc`, `curl`)
- [ ] Can search files (`find`) and content (`grep -r`)
- [ ] Know SIGTERM (`kill`) vs SIGKILL (`kill -9`) and when force is justified
- [ ] Comfortable tailing logs (`tail -f`, `journalctl -u <svc>`)

## Screenshots

Kiska screenshot (4 captures):
- `process-commands.png` — `ps aux | head -20` aur `top` (ya `htop`) ka output
- `network-commands.png` — `ip addr` aur `ss -tlnp` ka output (listening ports dikhte hue)
- `file-search.png` — `find` + `grep -r` ka output
- `logs-monitor.png` — `tail -f /var/log/syslog` ya `journalctl -u <svc>` ka output

Kaha dalna hai:
1. PNG files is folder me save karo: `2026/day-03/screenshots/`
2. Is md file me dikhane ke liye is section ke neeche ye lines add karo:
   `![process-commands](screenshots/process-commands.png)`
   `![network-commands](screenshots/network-commands.png)`

_Add images to `screenshots/` in this folder and run `.\update-screenshots.ps1` from `My_DevOps_journey` to embed them in `README.md`._
