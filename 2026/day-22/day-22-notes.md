# Day 22 - Introduction to Git: Your First Repository

## Task

- Task 1 — Install and Configure Git: verify install, set identity (name + email), verify config
- Task 2 — Create Your Git Project: new folder `devops-git-practice`, `git init`, `git status`, explore hidden `.git/`
- Task 3 — Create Your Git Commands Reference: `git-commands.md` with Setup & Config / Basic Workflow / Viewing Changes (what + example per command)
- Task 4 — Stage and Commit: stage file, check staged state, commit with meaningful message, view history
- Task 5 — Make More Changes and Build History: edit/commit at least 3 times, `git diff` between commits, compact history view
- Task 6 — Understand the Git Workflow: answer 5 questions in own words (add vs commit, staging area purpose, `git log` info, `.git/` folder, working dir vs staging vs repo)
- Ongoing — keep updating `git-commands.md` daily with clean one-commit-per-update history

## Environment

| Component | Value / Version | Install / Notes |
|-----------|-----------------|-----------------|
| OS | Windows 10/11 + Git for Windows, or Ubuntu 22.04 / WSL2 | Windows: `winget install --id Git.Git`; Ubuntu: `sudo apt update && sudo apt install -y git` |
| Shell | PowerShell / Git Bash / WSL bash | Any is fine; Git Bash mimics Linux paths on Windows |
| Tools | Git ≥ 2.40 (`git --version` → illustrative `2.43.0`), GitHub free account (push comes Day 23) | `[TODO - run on your machine]` — paste your `git --version` output |
| Verify | `git --version && git config --global --list` | Must print version + your name/email/default branch |

## Solution

### Task 1: Install and Configure Git

WHY it matters for DevOps: every pipeline clones, commits, tags, and audits via Git. A missing identity breaks commits; a wrong default branch (`master` vs `main`) breaks CI triggers.

```bash
git --version
git config --global user.name "Shubham"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global core.editor "code --wait"
git config --global --list
```

Expected output (example — your values will differ):

```text
git version 2.43.0.windows.1
user.name=Shubham
user.email=you@example.com
init.defaultbranch=main
# (illustrative — your version/path will differ; [TODO - run on your machine])
```

| Config | Meaning |
|--------|---------|
| `user.name` / `user.email` | Label stamped on every commit you author |
| `init.defaultBranch` | Branch name `git init` creates (use `main` for CI consistency) |
| `core.editor` | Editor for commit messages when `-m` is omitted |

### Task 2: Create Your Git Project

```bash
mkdir devops-git-practice
cd devops-git-practice
git init
git status
ls -la .git
```

Expected output (example — your values will differ):

```text
Initialized empty Git repository in .../devops-git-practice/.git/
On branch main
No commits yet
nothing to commit (create/copy files and use "git add" to track)
# (example output)
```

What lives inside `.git/`:

| Path | What it is |
|------|------------|
| `HEAD` | Pointer to current branch (`ref: refs/heads/main`) |
| `config` | Repo-local settings (remote URLs, branch defaults) |
| `objects/` | Compressed commit/blob/tree database (the history) |
| `refs/` | Branch and tag pointers |
| `index` | The staging area binary (appears after first `git add`) |
| `hooks/` | Sample scripts Git can trigger (pre-commit, etc.) |

> Deleting `.git/` permanently removes history, branches, and staging — working files stay but are no longer versioned. There is no undo unless you have a clone elsewhere.

### Task 3: Create Your Git Commands Reference

WHY it matters for DevOps: incident response runs on muscle memory. A personal reference you wrote yourself beats googling under pressure.

Create `git-commands.md` inside the repo, grouped into the three required categories. See the companion `git-commands.md` file in this folder (enriched with this day's commands). Minimum content:

```bash
cat > git-commands.md <<'EOF'
# Git Commands Reference
## Setup & Config
## Basic Workflow
## Viewing Changes
EOF
```

Each entry needs: what it does (1 line) + example. Copy the table format from `git-commands.md` — do not just list bare commands.

### Task 4: Stage and Commit

```bash
git status
git add git-commands.md
git status                  # now shows "Changes to be committed"
git diff --cached           # preview what will be committed
git commit -m "Add initial git-commands.md reference"
git log --oneline
```

Expected output (example — your values will differ):

```text
[main (root-commit) a1b2c3d] Add initial git-commands.md reference
 1 file changed, 30 insertions(+)
a1b2c3d Add initial git-commands.md reference
# (illustrative — your hash will differ)
```

| Command | What it stages/records |
|---------|------------------------|
| `git add <file>` | Copies working-dir changes into the index (staging) |
| `git diff --cached` | Shows staged vs HEAD (what the commit will contain) |
| `git commit -m "msg"` | Snapshots index as a new commit on current branch |

Commit message discipline (used by all DevOps changelogs):

```text
Add <what> to <where>        # imperative, scoped, < 72 chars
# Good: "Add Viewing Changes commands to reference"
# Bad:  "update", "fix stuff", "asdf"
```

### Task 5: Make More Changes and Build History

Repeat the edit → diff → stage → commit loop at least 3 times:

```bash
echo "## Extra notes" >> git-commands.md
git status
git diff                    # unstaged changes vs index
git add git-commands.md
git commit -m "Add Viewing Changes commands to reference"

echo "more tips" >> git-commands.md
git add git-commands.md
git commit -m "Add blame and show examples"

git log --oneline
git log --oneline --graph --all
```

Expected output (example — your values will differ):

```text
a1b2c3d Add initial git-commands.md reference
b2c3d4e Add Viewing Changes commands to reference
c3d4e5f Add blame and show examples
# (illustrative — 3+ commits prove the workflow; [TODO - run on your machine])
```

### Task 6: Understand the Git Workflow

1. **`git add` vs `git commit`** — `git add` copies changes from the working directory into the staging area (the index); `git commit` snapshots everything currently in the staging area into a new commit in the repository. Adding prepares; committing records.
2. **What the staging area does** — it is an intermediate "drafting table" between working files and the repo. It lets you choose exactly which hunks/files go into the next commit and review via `git diff --cached` before recording. Git doesn't commit directly so you can build logical, reviewable commits instead of one giant snapshot.
3. **What `git log` shows** — each commit's hash, author, date, message, and parent linkage. Flags change presentation: `--oneline` (one line each), `--graph --all` (branch topology), `-p` (full diffs), `--stat` (file stats).
4. **What `.git/` is** — the hidden directory that IS the repository: commit objects, refs, index, config. Delete it and project files stay but all history/branches/staged state are gone permanently.
5. **Working directory vs staging area vs repository** — working directory: files you edit on disk. Staging area (index): buffer selecting changes for the next commit. Repository (`.git/`): permanent commit database.

| Area | Question it answers |
|------|---------------------|
| Working directory | "What have I changed on disk?" (`git status`, `git diff`) |
| Staging area | "What will the next commit contain?" (`git diff --cached`) |
| Repository | "What is permanently recorded?" (`git log`) |

WHY it matters for DevOps: pipelines build from the repository, not your disk. If it isn't committed, it doesn't exist for CI.

#### Deep dive: commit anatomy + config scopes + detached HEAD

```bash
git show HEAD --stat
git show HEAD --name-only --format="%H %an %ae %ad %s"
git config --list --show-origin
nano .git/HEAD
git symbolic-ref HEAD
```

Expected output (example — your values will differ):

```text
commit a1b2c3d4e5f6 (HEAD -> main)
Author: Shubham <you@example.com>
Date:   Sat Oct 4 2026
    Add initial git-commands.md reference
 git-commands.md | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)
# (example output)
```

| Config scope | File | Command |
|--------------|------|---------|
| System | `/etc/gitconfig` (`--system`) | All users on machine |
| Global | `~/.gitconfig` (`--global`) | Your identity — used in Day 22 |
| Local | `.git/config` (`--local`) | Per-repo overrides (e.g. different email for work) |

Detached HEAD demo (read-only tour, then return — never commit here casually):

```bash
git checkout --detach HEAD~1
git log --oneline -2
git switch main   # reattach
```

WHY it matters for DevOps: CI checks out detached SHAs for reproducible builds; humans should reattach to a branch before editing.

#### Practice drill: three-commit history from scratch

```bash
echo "# practice" > notes.md
git add notes.md && git commit -m "Add notes file"
echo "line 2" >> notes.md && git commit -am "Add second line"
echo "line 3" >> notes.md && git commit -am "Add third line"
git log --oneline
git show HEAD --stat
git log -p -1 | head -30
```

Expected output (example — your values will differ):

```text
c3d4e5f Add third line
b2c3d4e Add second line
a1b2c3d Add notes file
# (illustrative — proves Task 5 repeat loop; keep messages imperative)
```

| View | Answers |
|------|---------|
| `git log --stat` | Which files each commit touched |
| `git show <hash>` | Full diff + metadata of one commit |
| `git blame notes.md` | Who last edited each line (code archaeology) |

## Commands Used

```bash
git --version
git config --global user.name "Shubham"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global --list
mkdir devops-git-practice
cd devops-git-practice
git init
git status
ls -la .git
git add git-commands.md
git diff
git diff --cached
git commit -m "Add initial git-commands.md reference"
git log --oneline
git log --oneline --graph --all
git log -p
git show a1b2c3d
```

## Verification

- `git config --global --list` shows your name, email, default branch
- `git status` is clean after commits (nothing untracked except intended files)
- `git log --oneline` lists at least 3 distinct commits by you
- `git log --oneline --graph --all` shows a single straight line (only `main` so far)
- `.git/` exists; `ls .git` shows `objects`, `refs`, `HEAD`, `config`
- `git-commands.md` exists and covers Setup & Config / Basic Workflow / Viewing Changes
- `git diff` empty + `git diff --cached` empty after commit (nothing left unrecorded)

## Key Learnings

- Git is distributed: every clone carries full history, not just files.
- `git status` is the source of truth for untracked/modified/staged state.
- The index decouples "what I changed" from "what I record" — stage deliberately.
- Commits are immutable snapshots with SHA hashes; messages are the changelog.
- `.git/` is the repo; deleting it deletes project memory with no undo.
- `git diff` (unstaged) vs `git diff --cached` (staged) tells you exactly where changes sit.
- Imperative, scoped commit messages are a core DevOps discipline.

## Troubleshooting / Gotchas

- `fatal: not a git repository` — cause: ran Git outside the initialized folder; fix: `cd devops-git-practice` or re-run `git init` in the right place.
- `Please tell me who you are` on commit — cause: identity not configured; fix: set `user.name`/`user.email` globally then retry.
- `git diff` shows nothing but files changed — cause: changes already staged; fix: use `git diff --cached` for staged content.
- Staged the wrong file — cause: over-broad `git add .`; fix: `git restore --staged <file>` keeps disk edits, unstages.
- Typo in last commit message — cause: rushed `-m`; fix (unpushed only): `git commit --amend -m "new message"`.
- Committed a secret/huge file — cause: no `.gitignore`/review; fix: remove in a follow-up commit now; scrub history later with `git filter-repo` (Day 27 topic).
- `ls .git` shows no `index` — cause: nothing staged yet; fix: normal before first `git add`, not an error.

## Screenshots

### Screenshots to capture

- `git-config.png` — terminal showing `git --version` + `git config --global --list` with your identity.
- `git-init-status.png` — terminal showing `git init` + `git status` + `ls -la .git` contents.
- `git-log-oneline.png` — terminal showing `git log --oneline` with at least 3 commits.
- `git-commands-file.png` — `git-commands.md` open showing all 3 category tables.

### Where to save

1. Save PNGs to `2026/day-22/screenshots/` (e.g. `2026/day-22/screenshots/git-log-oneline.png`).
2. Embed via markdown image lines (add to `README.md` after running the screenshot helper, or reference here):

```markdown
![Git config](screenshots/git-config.png)
![Git init and status](screenshots/git-init-status.png)
![Commit history](screenshots/git-log-oneline.png)
![Commands reference](screenshots/git-commands-file.png)
```

_Save PNGs to `screenshots/` in this folder and embed them in this file with `![name](screenshots/<file>.png)`._
