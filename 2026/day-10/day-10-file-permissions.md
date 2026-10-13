# Day 10 - File Permissions & File Operations Challenge

## Task
- Create files with `touch`, `cat`/`echo`, and `vim` (`devops.txt`, `notes.txt`, `script.sh`)
- Read files with `cat`, `head`, `tail`, and `vim` in read-only mode
- Decode and change permissions with `chmod` (numeric and symbolic)
- Actively break permissions and document the exact error messages

## Environment
| Item | Value |
|------|-------|
| OS | Ubuntu 22.04 / 24.04 (any POSIX shell) |
| Shell | `bash` |
| Working directory | `~/day10-lab` |
| Editor | `vim` (`sudo apt install -y vim` if missing) |
| Tools | `touch`, `cat`, `echo`, `tee`, `printf`, `vim`, `head`, `tail`, `wc`, `ls`, `stat`, `chmod`, `umask`, `id` |
| Default umask | `0022` -> new files `644`, new dirs `755` |

## Solution

### Task 1 - Create the files
**Why:** Three different mechanisms: `touch` makes an empty file (and updates timestamps), `>` truncates-and-writes, `vim` is the interactive editor. Know which one you need.

```bash
mkdir -p ~/day10-lab && cd ~/day10-lab

# 1. empty file
touch devops.txt

# 2. file with content (heredoc keeps formatting and quoting exact)
cat > notes.txt <<'EOF'
Day 10 - Linux File Operations
Topic: touch, cat, vim, head, tail, chmod
1. touch creates an empty file and updates timestamps.
2. cat prints contents; > truncates and writes, >> appends.
3. head -n 5 shows the first 5 lines, tail -n 5 the last 5.
4. chmod changes permissions: r=4, w=2, x=1.
EOF

# 3. script, via vim
vim script.sh
#   press  i          -> insert mode
#   type the two lines below
#   press  Esc        -> back to normal mode
#   type  :wq  Enter  -> write and quit
```
![`touch` + `cat > notes.txt` + `vim script.sh` + `ls -l` verify](screenshots/create-files-ls-before.png)
Contents of `script.sh` (typed inside vim):
```bash
#!/bin/bash
echo "Hello DevOps"
```
![`vim script.sh` - typing shebang + echo in vim](screenshots/vim-script-creation.png)
The shebang line is added on purpose: without it, `./script.sh` depends on the caller's `PATH` finding `bash`. With it, the kernel knows which interpreter to use.

Non-interactive equivalents (same result, useful in scripts/CI):
```bash
touch devops.txt
printf '%s\n' '#!/bin/bash' 'echo "Hello DevOps"' > script.sh
```

**Verify:**
```bash
ls -l
```
> **Lab note (honest):** this run was done in `~`, not `~/day10-lab`, so bare `ls -l` in the screenshot lists unrelated files (`grafana-*.deb`, `minikube-linux-amd64`, `microservices/`, …). Prefer a clean dir (`mkdir -p ~/day10-lab && cd ~/day10-lab`) and a targeted listing: `ls -l devops.txt notes.txt script.sh` — that is what the Task 3 screenshot proves.
Expected (with umask `0022`):
```
-rw-r--r-- 1 you you    0 Oct  3 10:20 devops.txt
-rw-r--r-- 1 you you  312 Oct  3 10:20 notes.txt
-rw-r--r-- 1 you you   34 Oct  3 10:20 script.sh
```
Gotcha worth knowing: `cat > notes.txt` only applies your umask when it **creates** the file. If `notes.txt` already existed with mode `664`, the `>` truncates the content but **keeps `664`** - which is why a re-run of this lab can show `664` instead of `644`.

```bash
wc -c devops.txt notes.txt script.sh   # byte counts; devops.txt is 0
stat -c '%n  mode=%a  symbolic=%A  owner=%U:%G  size=%s' devops.txt notes.txt script.sh
```

### Task 2 - Read the files
**Why:** `cat` dumps everything, but for a large file you want the edges - and for editing a file you sometimes must not be able to write.

```bash
cat notes.txt              # whole file
cat -n notes.txt           # with line numbers
vim -R script.sh           # read-only vim (the task's "read-only mode"); :q to quit
vim -R notes.txt

head -n 5 /etc/passwd      # first 5 lines
```
![`cat notes.txt` + `cat -n` + `vim -R` + `head -n 5 /etc/passwd`](screenshots/read-files-cat-head.png)

```bash
tail -n 5 /etc/passwd      # last 5 lines
wc -l /etc/passwd          # total lines, for context
head -n 1 /etc/passwd      # root's line
tail -n 1 /etc/passwd      # the most recently created system account
```
`/etc/passwd` is ordered by UID, so `head` shows the oldest classic accounts and `tail` shows the newest system/service users - a real insight, not just a syntax drill.

Live-follow variant (nice for a screenshot):
```bash
tail -n 5 -f /var/log/auth.log     # Ctrl+C to exit
```
![`tail -n 5` + `wc -l` + `head/tail -n 1` + `tail -f auth.log`](screenshots/read-files-tail-passwd.png)

### Task 3 - Understand the current permissions
**Why:** Read `ls -l` output right-to-left in the bits: owner, group, others.

```bash
ls -l devops.txt notes.txt script.sh
umask                          # expect 0022
```
> Proof: top 3 lines of the `chmod-executable-script-output.png` screenshot in Task 4 below show this `ls -l` (all `644`) before changes.

| File | Symbolic | Numeric | owner | group | others |
|------|----------|---------|-------|-------|--------|
| `devops.txt` | `-rw-r--r--` | `644` | read+write | read | read |
| `notes.txt` | `-rw-r--r--` | `644` (or `664` on a re-run - see the gotcha above) | read+write | read | read |
| `script.sh` | `-rw-r--r--` | `644` | read+write | read | read |

Answers to the task's questions:
- Nobody can execute any of the three files yet - there is no `x` anywhere.
- Only you (the owner) can write to `devops.txt` and `script.sh`; your group and everyone else are read-only.
- The leading `-` in `-rw-r--r--` means "regular file"; it is `d` for directory, `l` for symlink.

Bit arithmetic: `r=4`, `w=2`, `x=1` -> `rw-` = 6, `r--` = 4, `r-x` = 5, `rwx` = 7, `rw-r--r--` = 644, `rwxrwxr-x` = 775.

### Task 4 - Modify permissions
**Why:** Four changes that cover the two ways you write permissions: symbolic (`+x`, `-w`, `=`) and numeric (`640`, `755`).

```bash
# 1. make script.sh executable, then run it
chmod +x script.sh
ls -l script.sh                  # -rwxr-xr-x
./script.sh                      # Hello DevOps

# symbolic forms (who: operator, what)
chmod u+x script.sh              # owner only
chmod g+x script.sh              # group only
chmod o-x script.sh              # remove execute from others
chmod a+r notes.txt              # everyone can read (a = all)

# 2. devops.txt read-only for everyone (including you)
chmod a-w devops.txt
ls -l devops.txt                 # -r--r--r--  (644 -> 444)
chmod u+w devops.txt             # how to undo it later
```
![`chmod +x script.sh` + `./script.sh` -> Hello DevOps + `u+x/g+x/o-x/a+r/a-w`](screenshots/chmod-executable-script-output.png)
> **Lab note:** the screenshot shows `la -l` (typed 3x) instead of `ls -l`. On Ubuntu `la` is an alias for `ls -A`, so the output is still a valid `ls` listing — the canonical command is `ls -l`. Also note `chmod o-x` leaves `script.sh` at `754` (`-rwxr-xr--`), not `755`; Task 6 restores the final `755`.

```bash
# 3. notes.txt -> 640 (owner rw, group r, others none)
chmod 640 notes.txt
ls -l notes.txt                  # -rw-r-----  (644 -> 640)

# 4. directory project/ with 755
mkdir -p project
chmod 755 project
ls -ld project                   # drwxr-xr-x
```
![`chmod 640 notes.txt` + `mkdir project` + `chmod 755` + `umask`](screenshots/chmod-640-project-755.png)
Before/after table for the write-up:

| File | Before | Command | After |
|------|--------|---------|-------|
| `script.sh` | `-rw-r--r--` (644) | `chmod +x script.sh` | `-rwxr-xr-x` (755) |
| `devops.txt` | `-rw-r--r--` (644) | `chmod a-w devops.txt` | `-r--r--r--` (444) |
| `notes.txt` | `-rw-r--r--` (644) | `chmod 640 notes.txt` | `-rw-r-----` (640) |
| `project/` | `drwxr-xr-x` (755) | `chmod 755 project` | `drwxr-xr-x` (755, unchanged) |

Numeric reference for the modes you will actually use:

| Mode | Symbolic | Use case |
|------|----------|----------|
| `600` | `-rw-------` | SSH private keys, secrets |
| `644` | `-rw-r--r--` | ordinary readable config, web assets |
| `640` | `-rw-r-----` | readable by owner + group only |
| `700` | `drwx------` | private directory (`~/.ssh`) |
| `750` | `drwxr-x---` | team directory, outsiders excluded |
| `755` | `drwxr-xr-x` | public directories, scripts |
| `775` | `drwxrwxr-x` | shared team directory (Day 09 pattern) |
| `777` | `rwxrwxrwx` | almost always a bug |

`umask` is the other half of the story - it is what subtracts bits when a file is created:
```bash
umask        # 0022 -> files 666 & ~022 = 644 ; dirs 777 & ~022 = 755
umask 0002   # -> files 664, dirs 775  (friendlier for shared teams)
touch shared-file.txt && ls -l shared-file.txt
umask 0022   # set it back
```

### Task 5 - Test permissions and document the real errors
**Why:** The point of the lab. These are the exact strings you will see in a terminal and must be able to read in production.

```bash
# 1. write to a read-only file (re-apply read-only first -
#    Task 4 ended with `chmod u+w` as the undo demo, so the file is
#    writable again at this point)
chmod a-w devops.txt
ls -l devops.txt               # -r--r--r-- confirms read-only for all
echo "hacked" >> devops.txt
# bash: devops.txt: Permission denied

# ...and the same failure from a different program (the kernel refuses, not bash)
python3 -c "open('devops.txt','a').write('x')"
# PermissionError: [Errno 13] Permission denied: 'devops.txt'
chmod u+w devops.txt           # restore so later steps can use the file
```
> **Lab note:** in this run's `permission-denied-tests.png` the `echo` + `python3` lines print **no** error — because `devops.txt` was still writable there (Task 4's `chmod u+w` undo was in effect). The sequence above is the corrected repro: `chmod a-w` first, then the write genuinely fails. The denied proofs actually visible in the screenshot are `./notes.txt`, `chmod -x` + `./script.sh`, and `sudo -u nobody ls project/private`.

# 2. execute a file that has no execute bit
./notes.txt
# bash: ./notes.txt: Permission denied
# ...even though it is perfectly readable:
cat notes.txt > /dev/null && echo "read is fine"

# 3. bypass the x bit on purpose - bash can read it if you ask it to
bash notes.txt
# (bash tries to execute each line as a shell command - proof that the kernel
#  only enforces the x bit for direct execution)

# 4. remove execute from script.sh and try again
chmod -x script.sh && ./script.sh
# bash: ./script.sh: Permission denied
chmod +x script.sh && ./script.sh      # Hello DevOps
```
![`echo >> devops.txt` + `./notes.txt: Permission denied` + `bash notes.txt` + `chmod -x` retest](screenshots/permission-denied-tests.png)

```bash
# 5. directory permission failures (the ones that actually bite in DevOps)
mkdir -p project/private
chmod 700 project/private
touch project/private/secret.txt
sudo -u nobody ls project/private
# ls: cannot open directory 'project/private': Permission denied
# and: cannot enter a directory without the x bit
chmod 600 project/private && cd project/private
# bash: cd: project/private: Permission denied

# 6. cleanup of temporary artefacts only (never the lab files themselves)
rm -f extra shared-file.txt
chmod u+w devops.txt           # make sure devops.txt survived the read-only test
ls -l devops.txt               # must still exist (0 bytes)
```
![`sudo -u nobody ls` denied + `cd` into 600 dir denied + cleanup + final `ls -l`](screenshots/final-state-ls.png)
> **Lab note (honest mistake, kept as evidence):** this run typed `rm -f devops.txt extra shared-file.txt`, deleting the lab file — so `final-state-ls.png` shows `chmod: cannot access 'devops.txt': No such file` and `ls: cannot access 'devops.txt'`. The fix (already applied to this repo) is `touch devops.txt && chmod 444 devops.txt`. Never `rm` a file you then `chmod`; the sequence above is the corrected one.
Error-message cheat sheet for the write-up:

| Command | Result | Why |
|---------|--------|-----|
| `echo x >> read-only-file` | `bash: file: Permission denied` | no `w` bit for you |
| `python3` open for write | `PermissionError: [Errno 13]` | same reason, different language |
| `./notes.txt` (no `x`) | `bash: ./notes.txt: Permission denied` | `x` missing for your class |
| `bash notes.txt` | runs, but as a *shell script* | you named the interpreter, so the `x` bit is irrelevant |
| `cd dir` without `x` | `bash: cd: dir: Permission denied` | `x` on a directory means "traverse", not "run" |
| `ls dir` without `r` | `ls: cannot open directory ...` | `r` lists names, `x` enters |
| `mv a b` across filesystems | `mv: cannot move ... Permission denied` | needs `w` on both dirs (rename vs copy) |

### Task 6 - Clean final state (what the files should look like when you submit)
```bash
# restore exact submit modes (Task 5's `chmod -x` / `chmod 600` tests leave damage)
chmod 444 devops.txt
chmod 640 notes.txt
chmod 755 script.sh
chmod 700 project/private        # re-enterable so it can be removed
rm -rf project/private
chmod 755 project

ls -l devops.txt notes.txt script.sh
ls -ld project
# only after screenshotting everything:
# cd ~ && rm -rf ~/day10-lab
```
> Proof: bottom half of `final-state-ls.png` above shows this final `ls -l` + `ls -ld project` — except that in this run `script.sh` shows `-rw-r--r--` (the `chmod -x` test was never restored before screenshotting) and `devops.txt` is missing (see the Task 5 lab note). The restore block above is the corrected final state, which is what this repo actually contains.

## Files Created
| File | How | Final content | Final mode |
|------|-----|---------------|-----------|
| `devops.txt` | `touch devops.txt` (recreated after the accidental `rm` — see Task 5 note) | empty (0 bytes) | `444` (`-r--r--r--`) |
| `notes.txt` | `cat > notes.txt <<'EOF'` | 6 lines of Day 10 notes | `640` (`-rw-r-----`) |
| `script.sh` | `vim script.sh` | `#!/bin/bash` + `echo "Hello DevOps"` | `755` (`-rwxr-xr-x`, restored in Task 6) |
| `project/` | `mkdir -p project` + `chmod 755` | directory; `project/private/` test artefacts removed in Task 6 | `755` (`drwxr-xr-x`) |

## Permission Changes
Recorded in the Task 4 table above, plus the umask demonstration (`664`/`775` under `umask 0002`).

## Commands Used
```bash
# create
touch devops.txt
cat > notes.txt <<'EOF'
...
EOF
vim script.sh                                  # i -> text -> Esc -> :wq
printf '%s\n' '#!/bin/bash' 'echo "Hello DevOps"' > script.sh

# read
cat notes.txt ; cat -n notes.txt ; vim -R script.sh
head -n 5 /etc/passwd ; tail -n 5 /etc/passwd ; wc -l /etc/passwd

# inspect
ls -l ; ls -ld project
stat -c '%n mode=%a %A %U:%G %s' devops.txt notes.txt script.sh
umask

# modify
chmod +x script.sh ; chmod -x script.sh ; chmod a-w devops.txt ; chmod u+w devops.txt
chmod 640 notes.txt ; chmod 755 project
chmod u+x / g+x / o-x / a+r file

# test
./script.sh ; ./notes.txt ; bash notes.txt
chmod a-w devops.txt && echo x >> devops.txt ; python3 -c "open('devops.txt','a').write('x')"
```

## Verification
- `ls -l devops.txt notes.txt script.sh` shows the three files created with `644` (or `664` on a re-run — see the Task 1 gotcha)
- `chmod +x script.sh && ./script.sh` prints `Hello DevOps`
- `ls -l devops.txt` shows `-r--r--r--` (`444`) after the corrected Task 5 `chmod a-w`
- `ls -l notes.txt` shows `-rw-r-----` (`640`) and `ls -ld project` shows `drwxr-xr-x` (`755`)
- `echo "hacked" >> devops.txt` fails with `Permission denied` **only after `chmod a-w`** (in the raw screenshots it succeeds — see the Task 5 lab note)
- `./notes.txt` fails with `Permission denied` while `cat notes.txt` still works
- Task 6 restore leaves the repo in submit state: `444` / `640` / `755` + clean `project/` (deviations visible in `final-state-ls.png` are explained in the Task 5/6 lab notes)

## Key Learnings
- Permissions are three classes (owner/group/others) x three bits (r/w/x); the numeric form is just `4/2/1` summed per class
- `-` at the start of `ls -l` is the file type; on a **directory**, `x` means "traverse into", not "execute"
- Symbolic (`chmod +x`) and numeric (`chmod 755`) are interchangeable; symbolic is safer for targeted edits, numeric for declaring a complete mode
- `umask` decides the mode of every **newly created** file/dir only — changing it (`umask 0002`) affects future files, never existing ones (those need an explicit `chmod`)
- The kernel enforces the `x` bit, not bash: `bash script.sh` works on a non-executable file, `./script.sh` does not
- On a directory, `r` lists names and `x` enters/traverses — `ls` needs **both**; confusing the two causes most "permission denied" puzzles
- Removing write from *all* (`chmod a-w`) locks out the owner too; recovery needs `chmod u+w` or `sudo`

## Troubleshooting / Gotchas
- **`Permission denied` but `ls -l` looks right.** Check the parent directories - `/home/tokyo/Documents` needs `x` on `Documents`. Diagnose the whole path with `namei -l /path/to/file`.
- **Scripts created on Windows fail** with `bash: ./script.sh: /bin/bash^M: bad interpreter`. Fix: `sed -i 's/\r$//' script.sh` (CRLF line endings).
- **`chmod` seems to have no effect.** You are on a mounted filesystem that ignores Linux modes - WSL2's `/mnt/c`, NTFS/exFAT, some NFS/CIFS mounts. Copy the file into `~` (ext4) and it behaves normally.
- **Root can read everything, so testing as root proves nothing.** Use `sudo -u nobody` or a second real user to test permissions honestly.
- **`chmod -R 777 .`** in the wrong directory is unrecoverable and a security hole. Prefer the narrowest path: `chmod 644 /etc/nginx/nginx.conf`.
- **`chown` needs root; `chmod` needs to be the owner (or root).** Being in the right group does not let you chmod a file you do not own.
- **Immutable bit (`chattr +i`)** makes a file unmodifiable even by root - if `chmod` reports `Operation not permitted`, check `lsattr` before assuming a permissions bug.

## Screenshots

All proofs live inline in Tasks 1-6 above. Index of files in `screenshots/`:

| File | Proves |
|------|--------|
| `vim-script-creation.png` | `vim script.sh` with `#!/bin/bash` + `echo "Hello DevOps"` |
| `create-files-ls-before.png` | `touch devops.txt`, `cat > notes.txt`, `vim script.sh`, `ls -l` verify |
| `read-files-cat-head.png` | `cat`, `cat -n`, `vim -R`, `head -n 5 /etc/passwd` |
| `read-files-tail-passwd.png` | `tail -n 5`, `wc -l`, `head/tail -n 1`, `tail -f /var/log/auth.log` |
| `chmod-executable-script-output.png` | `ls -l` before, `chmod +x`, `./script.sh` -> `Hello DevOps`, symbolic `u+x/g+x/o-x/a+r/a-w` |
| `chmod-640-project-755.png` | `chmod 640 notes.txt` -> `-rw-r-----`, `mkdir project` + `chmod 755` -> `drwxr-xr-x`, `umask 0022` |
| `permission-denied-tests.png` | `echo >> devops.txt`, `python3` write, `./notes.txt: Permission denied`, `bash notes.txt`, `chmod -x` retest, `sudo -u nobody ls` denied |
| `final-state-ls.png` | `cd` into `600` dir denied, cleanup, final `ls -l` and `ls -ld project` |
