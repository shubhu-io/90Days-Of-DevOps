# Shell Scripting Cheat Sheet

A practical Bash reference built during **Day 21 of #90DaysOfDevOps**. Targets Bash 4+ on Linux/WSL; most examples also work in Git Bash. For POSIX-only environments use `#!/bin/sh` and skip bashisms (`[[ ]]`, arrays, `local`, `mapfile`, process substitution).

**Jump to:** [Quick reference](#quick-reference) · [Basics](#1-basics) · [Conditionals](#2-operators-and-conditionals) · [Loops](#3-loops) · [Functions](#4-functions) · [Text processing](#5-text-processing) · [Redirection](#6-redirection-pipes-and-substitution) · [One-liners](#7-one-liners) · [Error handling](#8-error-handling-and-debugging) · [Template](#9-starter-template) · [Gotchas](#10-common-gotchas)

## Quick Reference

| Topic | Syntax | Example |
|-------|--------|---------|
| Variable | `VAR="value"` | `NAME="DevOps"` |
| Expansion | `"${VAR}"`, `"${VAR:-default}"` | `echo "${NAME}s"` |
| Argument | `$1`, `$#`, `"$@"` | `./script.sh arg1 arg2` |
| Exit status | `$?`, `exit N` | `cmd; echo "$?"` |
| If | `if [[ cond ]]; then` | `if [[ -f file ]]; then` |
| String test | `[ "$a" = "$b" ]` | `[[ $f == *.log ]]` |
| Integer test | `[ "$n" -gt 5 ]` | `(( n > 5 ))` |
| File test | `[[ -f path ]]` | `[[ -d /tmp && -w /tmp ]]` |
| For loop | `for x in list; do` | `for i in {1..3}; do` |
| While loop | `while cond; do` | `while read -r line; do` |
| Function | `name() { ...; }` | `greet() { echo "Hi $1"; }` |
| Case | `case $x in ... esac` | `case $1 in start) ... ;; esac` |
| Array | `arr=(a b c)` | `echo "${arr[0]}"` |
| Grep | `grep pattern file` | `grep -in "error" app.log` |
| Awk | `awk '{print $1}' file` | `awk -F: '{print $1}' /etc/passwd` |
| Sed | `sed 's/old/new/g' file` | `sed -i.bak 's/foo/bar/g' file` |
| Cut | `cut -d: -f1 file` | `cut -d, -f2 data.csv` |
| Sort | `sort -rn file` | `sort -u names.txt` |
| Uniq | `uniq -c file` | `sort data.txt \| uniq -c` |
| Tr | `tr 'a-z' 'A-Z'` | `tr -d '\r' < win.txt` |
| Wc | `wc -l file` | `wc -l *.log` |
| Head/Tail | `tail -n 20 file` | `tail -F app.log` |
| Redirection | `cmd > out 2>&1` | `cmd &> out` |
| Pipe | `cmd1 \| cmd2` | `grep ERROR app.log \| wc -l` |
| Strict mode | `set -euo pipefail` | `set -Eeuo pipefail` |
| Cleanup | `trap cleanup EXIT` | `trap 'rm -rf "$tmp"' EXIT` |

---

## 1. Basics

### 1.1 Shebang

`#!/usr/bin/env bash` tells the kernel to run the file with `bash` found on `PATH`. `#!/bin/bash` hardcodes the path; both work on most Linux systems.

```bash
#!/usr/bin/env bash
printf 'Hello\n'
```

### 1.2 Running a script

```bash
chmod +x script.sh    # make executable (once)
./script.sh           # run via shebang
bash script.sh        # run with bash; no exec bit needed
source script.sh      # run in current shell (variables persist)
bash -n script.sh     # syntax check only
bash -x script.sh     # trace every command
```

`sh script.sh` may fail on bash-only syntax even if the shebang says bash, because you overrode the interpreter.

### 1.3 Comments

```bash
# full-line comment
echo "hi"    # inline comment
```

There are no block comments; prefix each line with `#`.

### 1.4 Variables and quoting

```bash
NAME="DevOps"          # no spaces around =
COUNT=3
echo "$NAME"           # expand
echo "${NAME}s"        # braces delimit the variable name
echo '$NAME'           # single quotes: literal text
readonly NAME          # make read-only
unset COUNT            # remove
export PATH="/opt/bin:$PATH"   # export to child processes
```

| Form | Meaning |
|------|---------|
| `VAR="x"` | Assign (no spaces around `=`) |
| `"$VAR"` | Expand safely; preserves spaces and prevents globbing |
| `'$VAR'` | Literal, no expansion |
| `"${VAR}s"` | Braces needed when text follows the variable |
| `VAR=x command` | Set for that one command only |

### 1.5 Parameter expansion

| Syntax | Result |
|--------|--------|
| `${VAR:-default}` | `default` if `VAR` is unset or empty |
| `${VAR:=default}` | Assign and return `default` if unset/empty |
| `${VAR:?message}` | Exit with `message` if unset/empty |
| `${VAR:+alternate}` | `alternate` if `VAR` is set and non-empty |
| `${#VAR}` | Length in characters |
| `${VAR:0:5}` | Substring: 5 chars from offset 0 |
| `${VAR#prefix}` / `${VAR##prefix}` | Remove shortest / longest prefix |
| `${VAR%suffix}` / `${VAR%%suffix}` | Remove shortest / longest suffix |
| `${VAR/old/new}` / `${VAR//old/new}` | Replace first / all occurrences |
| `${VAR^^}` / `${VAR,,}` | Uppercase / lowercase (Bash 4+) |

```bash
file="app.log.tar.gz"
echo "${file%.*}"       # app.log.tar
echo "${file%%.*}"      # app
echo "${file#*.}"       # log.tar.gz
echo "${file##*.}"      # gz
echo "${file/log/LOG}"  # app.LOG.tar.gz
```

### 1.6 Arrays

```bash
servers=(web1 web2 "db 1")
echo "${servers[0]}"        # web1
echo "${servers[@]}"        # all elements
echo "${#servers[@]}"       # count
servers+=("cache1")         # append
for s in "${servers[@]}"; do echo "$s"; done
```

Use `"${arr[@]}"`, never `$arr` (which is only element 0). Associative arrays (Bash 4+):

```bash
declare -A env
env[prod]="10.0.0.5"
echo "${env[prod]}"
```

### 1.7 Reading input

```bash
read -r -p "Name: " name        # -r keeps backslashes
read -r -s -p "Password: " pass # -s hides input
echo
printf 'Hello, %s\n' "$name"
```

`read` flags: `-r` raw, `-p` prompt, `-s` silent, `-t 5` timeout, `-n 1` one char, `-a arr` into array.

```bash
while IFS= read -r line; do
    printf '%s\n' "$line"
done < file.txt

IFS=, read -r user pass <<< "admin,s3cret"
```

### 1.8 Command-line arguments

| Variable | Meaning |
|----------|---------|
| `$0` | Script name/path |
| `$1`, `$2`, ... | Positional arguments; use `${10}` after 9 |
| `$#` | Number of arguments |
| `"$@"` | All arguments as separate quoted words (preferred) |
| `"$*"` | All arguments joined into one string (rarely what you want) |
| `$?` | Exit status of the last command |
| `$$` | PID of the current shell |
| `$!` | PID of the last background command |

```bash
printf 'script=%s first=%s count=%s\n' "$0" "${1:-}" "$#"
printf 'args:'; printf ' <%s>' "$@"; printf '\n'
shift                    # drop $1; $2 becomes $1
```

`getopts` for flags:

```bash
while getopts ":f:v" opt; do
    case "$opt" in
        f) file=$OPTARG ;;
        v) verbose=1 ;;
        :) echo "Missing value for -$OPTARG" >&2; exit 2 ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 2 ;;
    esac
done
shift $((OPTIND - 1))
```

---

## 2. Operators and Conditionals

### 2.1 `[ ]` vs `[[ ]]` vs `(( ))`

```bash
[ "$a" = "$b" ]      # POSIX test: always quote variables
[[ $a == b* ]]       # Bash: safer, supports globs, &&, ||, =~
(( n > 5 ))          # arithmetic: no $ needed inside
```

Inside `[ ]`, `<` and `>` compare strings lexicographically (and unquoted they act as shell redirections), never numbers. Use `-lt`/`-gt` or `(( ))` for numeric comparisons.

### 2.2 String comparisons

```bash
[ "$a" = "$b" ]        # equal
[ "$a" != "$b" ]       # not equal
[ -z "$a" ]            # empty
[ -n "$a" ]            # non-empty
[[ $file == *.log ]]   # glob match
[[ $name =~ ^[a-z]+$ ]] # regex match (Bash)
```

| Operator | True when |
|----------|-----------|
| `=`, `==` | Strings equal (`==` is bash-only) |
| `!=` | Strings differ |
| `-z "$s"` | String is empty |
| `-n "$s"` | String is non-empty |

### 2.3 Integer comparisons

```bash
[ "$n" -eq 5 ]    # equal
[ "$n" -ne 5 ]    # not equal
[ "$n" -lt 5 ]    # less than
[ "$n" -gt 5 ]    # greater than
[ "$n" -le 5 ]    # <=
[ "$n" -ge 5 ]    # >=

(( n >= 5 && n <= 10 ))
```

### 2.4 File tests

```bash
[ -e "$f" ]   # exists
[ -f "$f" ]   # regular file
[ -d "$f" ]   # directory
[ -L "$f" ]   # symlink
[ -r "$f" ]   # readable
[ -w "$f" ]   # writable
[ -x "$f" ]   # executable
[ -s "$f" ]   # exists and non-empty
[ "$a" -nt "$b" ]   # a newer than b
[ "$a" -ot "$b" ]   # a older than b
```

```bash
[[ -f "$f" && -r "$f" ]] || { echo "unreadable: $f" >&2; exit 1; }
```

### 2.5 if / elif / else

```bash
if [[ -f "$file" ]]; then
    echo "file"
elif [[ -d "$file" ]]; then
    echo "directory"
else
    echo "missing: $file" >&2
    exit 1
fi

if ! systemctl is-active --quiet nginx; then
    systemctl start nginx
fi
```

### 2.6 Logical operators

```bash
cmd1 && cmd2      # cmd2 only if cmd1 succeeds
cmd1 || cmd2      # cmd2 only if cmd1 fails
! cmd             # invert status
[[ -f "$f" && -r "$f" ]]
```

`cmd1 && cmd2 || cmd3` is not a safe ternary: `cmd3` also runs when `cmd2` fails. Use `if/else` when it matters.

### 2.7 case

```bash
case "$1" in
    start|run) systemctl start nginx ;;
    stop)      systemctl stop nginx ;;
    *.log)     echo "log file" ;;
    "")        echo "missing argument" >&2; exit 2 ;;
    *)         echo "usage: $0 {start|stop}" >&2; exit 2 ;;
esac
```

Patterns are glob-style. `;;` ends a branch; Bash also supports `;&` (fall through) and `;;&` (keep matching).

---

## 3. Loops

### 3.1 for: list, brace, and C-style

```bash
for env in dev staging prod; do
    echo "$env"
done

for i in {1..5}; do echo "$i"; done
for i in {0..10..2}; do echo "$i"; done   # step 2

for ((i = 1; i <= 5; i++)); do
    echo "$i"
done

for ((i = 0; i < ${#arr[@]}; i++)); do
    echo "${arr[i]}"
done
```

### 3.2 while and until

```bash
i=0
while (( i < 5 )); do
    echo "$i"
    i=$((i + 1))
done

n=1
until (( n > 5 )); do
    echo "$n"
    n=$((n + 1))
done
```

### 3.3 break and continue

```bash
for i in {1..10}; do
    (( i == 3 )) && continue   # skip 3
    (( i == 6 )) && break      # stop at 6
    echo "$i"
done
```

`break 2` / `continue 2` act on an outer loop.

### 3.4 Looping over files

```bash
shopt -s nullglob
for file in *.log; do
    printf 'processing %s\n' "$file"
done
```

Without `nullglob`, guard with `[ -e "$file" ] || continue` so a non-matching glob does not loop once with the literal `*.log`.

### 3.5 Looping over command output

```bash
grep 'ERROR' app.log | while IFS= read -r line; do
    printf 'found: %s\n' "$line"
done
```

Avoid the pipe when the loop must update variables (the pipe runs the loop in a subshell):

```bash
count=0
while IFS= read -r line; do
    count=$((count + 1))
done < <(grep 'ERROR' app.log)
echo "$count"

while IFS= read -r line; do
    echo "$line"
done < file.txt
```

Null-safe filenames from `find`:

```bash
while IFS= read -r -d '' file; do
    printf '%s\n' "$file"
done < <(find . -type f -name '*.log' -print0)
```

`mapfile -t lines < file.txt` reads a whole file into an array in one go.

### 3.6 Looping over script arguments

```bash
for arg in "$@"; do
    echo "$arg"
done
```

---

## 4. Functions

### 4.1 Defining and calling

```bash
greet() {
    local name=${1:-world}
    printf 'Hello, %s\n' "$name"
}

greet "DevOps"
```

`function greet { ...; }` also works, but `name() { ...; }` is standard.

### 4.2 Arguments inside functions

`$1`, `$2`, `$#`, and `"$@"` inside a function refer to the function's arguments, not the script's.

```bash
add() {
    echo $(( $1 + $2 ))
}
add 3 4    # 7
```

### 4.3 return vs echo

`return` sets the function's exit status (0-255). To return data, `echo` it and capture with `$()`.

```bash
is_root() {
    [[ $EUID -eq 0 ]]
}
is_root && echo "running as root"

get_date() {
    date +%F
}
today=$(get_date)    # captures stdout; trailing newlines stripped
```

### 4.4 local variables

```bash
count_files() {
    local dir=$1
    local count
    count=$(find "$dir" -maxdepth 1 -type f | wc -l)
    printf '%s\n' "$count"
}
```

Declare `local` separately from `local x=$(cmd)`: the assignment form masks the command's exit status under `set -e`.

### 4.5 Reusable helpers

```bash
log() { printf '[%s] %s\n' "$(date '+%F %T')" "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }

retry() {
    local tries=$1
    shift
    local i
    for ((i = 1; i <= tries; i++)); do
        "$@" && return 0
        sleep "$i"
    done
    return 1
}

retry 3 curl -fsS https://example.com
```

---

## 5. Text Processing

### 5.1 grep

```bash
grep 'ERROR' app.log
grep -in 'error' app.log          # ignore case + line numbers
grep -c 'ERROR' app.log           # count matching lines
grep -v 'INFO' app.log            # invert match
grep -r --include='*.log' 'TODO' . # recursive, filtered
grep -l 'ERROR' *.log             # filenames only
grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}' access.log  # only matches
grep -A3 -B1 'CRITICAL' app.log   # 3 after, 1 before
grep -q 'ERROR' app.log && echo found   # quiet, for tests
```

Also useful: `-w` whole word, `-E` extended regex, `-F` fixed string, `--exclude-dir=.git`.

### 5.2 awk

```bash
awk '{print $1}' access.log              # first field
awk -F: '{print $1, $3}' /etc/passwd     # custom separator
awk -F, 'NR > 1 {sum += $2} END {print sum}' data.csv
awk '$3 > 100 {print $1}' file
awk '/ERROR/ {n++} END {print n+0}' app.log
awk 'BEGIN {FS=","; OFS="\t"} {print $1, $3}' data.csv
awk -v limit=80 '$5+0 >= limit {print}' disk.txt
awk '!seen[$0]++' file                   # dedupe, keep first order
awk '{print $NF}' file                   # last field
```

`NR` = line number, `NF` = field count, `$NF` = last field, `FILENAME` = current file.

### 5.3 sed

```bash
sed 's/old/new/' file             # first occurrence per line
sed 's/old/new/g' file            # all occurrences
sed -E 's/(foo|bar)/X/g' file     # extended regex
sed -n '5,10p' file               # print lines 5-10
sed -n '/START/,/END/p' file      # print a range
sed '/^#/d; /^$/d' file           # delete comments and blank lines
sed -i.bak 's/foo/bar/g' file     # in-place with backup (GNU)
```

BSD/macOS `sed` requires an argument after `-i`: `sed -i '' 's/foo/bar/' file`. Always preview without `-i` first.

### 5.4 cut

```bash
cut -d: -f1 /etc/passwd       # first : field
cut -d, -f2,4 data.csv        # fields 2 and 4
cut -d, -f2- data.csv         # from field 2 to end
cut -d, -f1 --complement data.csv  # everything except field 1
cut -c1-10 file.txt           # characters 1-10
```

`cut` splits on a single delimiter; for arbitrary whitespace use `awk`.

### 5.5 sort

```bash
sort names.txt              # alphabetical
sort -n nums.txt            # numeric
sort -rn nums.txt           # numeric, reverse
sort -u names.txt           # unique
sort -t: -k3,3n /etc/passwd # key 3, numeric
sort -h sizes.txt           # human-readable sizes
sort -V versions.txt        # version order
```

Use `LC_ALL=C sort` in scripts for consistent byte ordering.

### 5.6 uniq

```bash
sort file | uniq        # deduplicate
sort file | uniq -c     # count occurrences
sort file | uniq -d     # duplicates only
sort file | uniq -u     # unique lines only
```

`uniq` only compares adjacent lines, so `sort` first.

### 5.7 tr

```bash
tr 'a-z' 'A-Z' < file.txt          # uppercase
tr -d '\r' < windows.txt > unix.txt # remove CR
tr -s ' ' < file.txt               # squeeze repeated spaces
tr -cd '[:print:]\n' < file.txt    # keep only printable chars
tr ',' '\n' < list.csv             # comma to newline
```

`-d` delete, `-s` squeeze, `-c` complement.

### 5.8 wc

```bash
wc -l file.txt    # lines
wc -w file.txt    # words
wc -c file.txt    # bytes
wc -m file.txt    # characters
wc -l *.log       # per file + total
wc -l < file.txt  # count only, no filename
```

### 5.9 head and tail

```bash
head -n 20 app.log      # first 20 lines
head -c 200 app.log     # first 200 bytes
tail -n 20 app.log      # last 20 lines
tail -n +2 data.csv     # from line 2 (skip header)
tail -f app.log         # follow live
tail -F app.log         # follow across log rotation
tail -f app.log | grep --line-buffered -i error
```

### 5.10 find and xargs

```bash
find . -type f -name '*.log' -mtime +7 -print
find . -type f -size +100M -print
find . -type f -print0 | xargs -0 -r wc -l
```

`-print` first, then replace it with `-delete` when the list looks right. `-print0` + `xargs -0` handles spaces and newlines in filenames.

---

## 6. Redirection, Pipes, and Substitution

| Syntax | Meaning |
|--------|---------|
| `cmd > file` | stdout to file, truncate |
| `cmd >> file` | stdout to file, append |
| `cmd 2> file` | stderr to file |
| `cmd 2>&1` | stderr to where stdout goes |
| `cmd &> file` | stdout + stderr to file (Bash) |
| `cmd < file` | stdin from file |
| `cmd1 \| cmd2` | stdout of `cmd1` to stdin of `cmd2` |
| `cmd1 \|& cmd2` | stdout + stderr piped (Bash) |
| `cmd \| tee file` | write to file and stdout |
| `cmd \| tee -a file` | same, append |
| `$(cmd)` | command substitution |
| `<(cmd)` | process substitution (Bash) |
| `<<< "text"` | here-string (Bash) |

```bash
cmd > out.log 2>&1          # redirect both (order matters)
cmd 2>&1 > out.log          # stderr still goes to the terminal
cmd 2>/dev/null             # hide errors
cmd | tee -a run.log        # keep a copy on screen and on disk

cat <<'EOF' > config.yml    # quoted delimiter: no expansion
key: value
EOF

read -r a b <<< "one two"
diff <(sort a.txt) <(sort b.txt)   # compare command output
```

A pipeline's exit status is the status of its last command unless `set -o pipefail` is enabled.

---

## 7. One-Liners

```bash
# --- Logs ---------------------------------------------------------------
# Count error lines
grep -c 'ERROR' app.log

# Top 5 error messages (adjust the regex to your log format)
grep 'ERROR' app.log | sed 's/.*ERROR[[:space:]]*//' | sort | uniq -c | sort -rn | head -5

# Live error feed across log rotation
tail -F app.log | grep --line-buffered -Ei 'error|fail|critical'

# Delete logs older than 7 days (preview with -print first)
find /var/log/myapp -type f -name '*.log' -mtime +7 -print
find /var/log/myapp -type f -name '*.log' -mtime +7 -delete

# Count lines in all .log files
find . -type f -name '*.log' -exec wc -l {} + | sort -n

# --- Files --------------------------------------------------------------
# Replace a string across files (test without -i first)
grep -rlI --null --exclude-dir=.git 'old_string' . | xargs -0 sed -i.bak 's/old_string/new_string/g'

# Largest files/directories under the current path
du -ah . 2>/dev/null | sort -rh | head -10

# Remove empty files
find . -type f -empty -delete

# --- Services and HTTP --------------------------------------------------
systemctl is-active --quiet nginx && echo "nginx up" || echo "nginx down"
curl -fsS -o /dev/null -w '%{http_code}\n' https://example.com
ss -ltnp 'sport = :8080'

# --- Health and capacity ------------------------------------------------
df -P / | awk 'NR == 2 {gsub(/%/, "", $5); if ($5+0 >= 80) {print "ALERT: / at " $5 "%"; exit 1}}'
free -m | awk '/^Mem:/ {printf "RAM used: %d%%\n", $3/$2*100}'
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -6

# --- Data ---------------------------------------------------------------
curl -fsS https://api.example.com/users | jq -r '.[] | [.name, .status] | @tsv'
awk -F, 'NR > 1 && $3 > 100 {print $1, $3}' data.csv
sort emails.txt | uniq -d

# --- Processes ----------------------------------------------------------
pgrep -af 'my_script.sh'
pkill -f 'my_script.sh'

# --- Retry --------------------------------------------------------------
for i in {1..5}; do curl -fsS https://example.com && break; [[ $i == 5 ]] && exit 1; sleep 2; done
```

---

## 8. Error Handling and Debugging

### 8.1 Exit codes

```bash
cmd
status=$?
if (( status != 0 )); then
    printf 'cmd failed: %d\n' "$status" >&2
fi

exit 0    # success
exit 1    # generic failure
exit 2    # usage error (common convention)
```

`$?` is overwritten by every command; capture it immediately. In pipelines, use `${PIPESTATUS[@]}`:

```bash
false | true
printf '%s\n' "${PIPESTATUS[@]}"   # 1 0
```

### 8.2 Strict mode

```bash
set -e           # exit on unhandled failure
set -u           # error on unset variables
set -o pipefail  # pipeline fails if any command fails
set -E           # inherit ERR traps in functions/subshells
```

```bash
set -Eeuo pipefail
```

`set -e` does not trigger for commands in `if`/`while`/`until` conditions, `&&`/`||` lists, or after `!`. Use `${VAR:-}` for optional variables under `set -u`.

### 8.3 Trace and syntax check

```bash
bash -n script.sh    # parse without executing
bash -x script.sh    # trace execution
shellcheck script.sh # static analysis (install separately)

PS4='+${BASH_SOURCE##*/}:${LINENO}: '
set -x               # trace from here
ls /tmp
set +x               # stop tracing
```

### 8.4 trap and cleanup

```bash
tmp_dir=$(mktemp -d)

cleanup() {
    rm -rf "$tmp_dir"
    printf 'cleanup done\n' >&2
}
trap cleanup EXIT          # runs on normal exit and after trapped signals
trap 'exit 130' INT        # Ctrl-C -> EXIT trap -> cleanup
trap 'exit 143' TERM       # SIGTERM -> EXIT trap -> cleanup

trap 'printf "failed at %s:%s\n" "${BASH_SOURCE[0]}" "$LINENO" >&2' ERR
```

`EXIT` runs on normal exit and on `exit N`. Trap `INT`/`TERM` to `exit 130`/`exit 143` so cleanup still runs exactly once. `trap -p` lists active traps; `trap - EXIT` removes one. `SIGKILL` cannot be trapped.

### 8.5 Fail fast with a message

```bash
: "${DEPLOY_ENV:?set DEPLOY_ENV}"
[ -r "$CONFIG" ] || { echo "cannot read $CONFIG" >&2; exit 1; }
cd "$RELEASE_DIR" || { echo "missing $RELEASE_DIR" >&2; exit 1; }
```

---

## 9. Starter Template

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME=${0##*/}

log() { printf '[%s] %s\n' "$(date '+%F %T')" "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }
usage() { printf 'Usage: %s <file>\n' "$SCRIPT_NAME" >&2; }

tmp_dir=$(mktemp -d)
cleanup() { rm -rf "$tmp_dir"; }
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

main() {
    [ "$#" -eq 1 ] || { usage; exit 2; }

    local file=$1
    [ -r "$file" ] || die "cannot read: $file"

    log "processing $file"
    # ... script logic here ...
}

main "$@"
```

Why this shape: strict mode fails fast, `trap` guarantees cleanup, `main "$@"` preserves arguments, and `local` keeps function state contained.

---

## 10. Common Gotchas

| Symptom | Cause | Fix |
|---------|-------|-----|
| `command not found` on assignment | Spaces around `=` | `VAR="value"`, not `VAR = value` |
| `unary operator expected` / `too many arguments` | Unquoted empty variable in `[ ]` | Quote: `[ "$v" = x ]` or use `[[ ]]` |
| `integer expression expected` | String/empty value used with `-eq` | Validate it or use `[[ $n =~ ^[0-9]+$ ]]` |
| `Permission denied` on `./script.sh` | Missing execute bit | `chmod +x script.sh` or `bash script.sh` |
| Script hides failure in a pipe | Only last command's status is checked | `set -o pipefail`, then inspect `PIPESTATUS` |
| Variables lost after `cmd \| while read` | Pipe runs the loop in a subshell | `done < file` or `done < <(cmd)` |
| `for f in *.log` loops once with `*.log` | Glob matched nothing | `shopt -s nullglob` or `[ -e "$f" ] \|\| continue` |
| `set -e` ignores a failed assignment | `local x=$(cmd)` masks the status | `local x; x=$(cmd)` |
| `((i++))` kills the script | Post-increment returns 1 when old value is 0 | Use `((++i))` or `i=$((i + 1))` |
| `uniq -c` counts are wrong | `uniq` only sees adjacent duplicates | `sort file \| uniq -c` |
| `xargs` breaks on spaces | Whitespace-delimited input | `find ... -print0 \| xargs -0` |
| `read` removes backslashes | Missing `-r` | `read -r line` |
| `sed -i` fails on macOS | BSD `sed` needs a backup argument | `sed -i '' 's/a/b/' file` |
| `$?` is always 0 | Captured after another command (e.g. `echo`) | Capture immediately: `status=$?` |
| stderr is not in the file | Redirect order: `cmd 2>&1 > file` sends stderr to the terminal | `cmd > file 2>&1` |
| Cleanup ran twice or script kept running after Ctrl-C | `trap cleanup EXIT INT TERM` handles the signal without exiting | Keep cleanup on `EXIT`; trap signals with `exit 130`/`exit 143` |
| `find -delete` removed too much | Wrong path/age expression | Always run with `-print` first |
