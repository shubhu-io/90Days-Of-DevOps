# Git Commands Reference

Day 23 update — adds branching and remote/GitHub commands (keeps all Day 22 commands).

## Setup & Config

| Command | What it does | Example |
|---------|--------------|---------|
| `git --version` | Shows installed Git version | `git --version` |
| `git config --global user.name "Name"` | Sets identity name | `git config --global user.name "Shubham"` |
| `git config --global user.email "email"` | Sets identity email | `git config --global user.email "you@example.com"` |
| `git config --global init.defaultBranch main` | Default branch for new repos | `git config --global init.defaultBranch main` |
| `git config --global --list` | Lists global config | `git config --global --list` |
| `git config --list --show-origin` | Shows source file of each setting | `git config --list --show-origin` |
| `git init` | Initializes a repository | `git init` |
| `git clone <url>` | Copies a remote repo locally | `git clone https://github.com/user/repo.git` |
| `git clone --depth 1 <url>` | Shallow clone for speed | `git clone --depth 1 https://github.com/user/repo.git` |

## Basic Workflow

| Command | What it does | Example |
|---------|--------------|---------|
| `git status` | Staged/unstaged/untracked changes | `git status` |
| `git status -sb` | Short branch-aware status | `git status -sb` |
| `git add <file>` | Stage a file | `git add notes.md` |
| `git add .` | Stage everything | `git add .` |
| `git add -p` | Stage hunks interactively | `git add -p` |
| `git commit -m "msg"` | Snapshot staged changes | `git commit -m "Add feature"` |
| `git commit -a -m "msg"` | Stage tracked edits + commit | `git commit -a -m "Fix typo"` |
| `git commit --amend -m "msg"` | Fix last commit (unpushed only) | `git commit --amend -m "Better message"` |
| `git restore <file>` | Discard unstaged changes | `git restore notes.md` |
| `git restore --staged <file>` | Unstage a file | `git restore --staged notes.md` |
| `git rm --cached <file>` | Untrack but keep on disk | `git rm --cached .env` |
| `git diff` / `git diff --cached` | Unstaged / staged changes | `git diff --cached` |
| `git diff --stat` | Changed-files summary | `git diff --stat` |

## Branching

| Command | What it does | Example |
|---------|--------------|---------|
| `git branch` | List local branches | `git branch` |
| `git branch -a` | List local + remote branches | `git branch -a` |
| `git branch -vv` | List with upstream + last commit | `git branch -vv` |
| `git branch -r` | List remote-tracking branches only | `git branch -r` |
| `git branch <name>` | Create a branch | `git branch feature-1` |
| `git switch <name>` | Switch branch (modern) | `git switch feature-1` |
| `git switch -c <name>` | Create + switch in one command | `git switch -c feature-2` |
| `git checkout <name>` / `-b <name>` | Older switch / create+switch | `git checkout -b feature-1` |
| `git branch --show-current` | Print current branch name | `git branch --show-current` |
| `git branch -d <name>` | Delete merged branch | `git branch -d feature-tmp` |
| `git branch -D <name>` | Force delete | `git branch -D old` |
| `git merge <branch>` | Merge a branch into current | `git merge feature-1` |
| `git symbolic-ref HEAD` | Show what HEAD points to | `git symbolic-ref HEAD` |

## Remotes (GitHub)

| Command | What it does | Example |
|---------|--------------|---------|
| `git remote -v` | List remotes | `git remote -v` |
| `git remote add origin <url>` | Add remote | `git remote add origin https://...` |
| `git remote set-url origin <url>` | Fix a wrong remote URL | `git remote set-url origin https://...` |
| `git remote add upstream <url>` | Add original repo as upstream (forks) | `git remote add upstream https://github.com/original/repo.git` |
| `git push -u origin <branch>` | Push and set upstream | `git push -u origin main` |
| `git push origin <branch>` | Push branch | `git push origin feature-1` |
| `git push origin --delete <b>` | Delete remote branch | `git push origin --delete feature-tmp` |
| `git fetch` / `git fetch origin` | Download remote refs only | `git fetch origin` |
| `git pull` | Fetch + merge | `git pull` |
| `git pull --rebase` | Fetch + rebase instead of merge | `git pull --rebase` |
| `git log HEAD..origin/main --oneline` | Preview what fetch brought | `git log HEAD..origin/main --oneline` |

## Viewing Changes

| Command | What it does | Example |
|---------|--------------|---------|
| `git log --oneline` | One line per commit | `git log --oneline` |
| `git log --oneline --graph --all` | Visual branch history | `git log --oneline --graph --all` |
| `git log -- <file>` | History of one file | `git log -- feature.txt` |
| `git show <hash>` | One commit's details | `git show a1b2c3d` |
| `git show HEAD --stat` | Last commit + stats | `git show HEAD --stat` |
| `git blame <file>` | Line authorship | `git blame app.py` |

## Day-wise update log

- Day 22: initial Setup/Workflow/Viewing reference.
- Day 23: + Branching, `switch` vs `checkout`, remotes (`origin`/`upstream`), fetch vs pull.
- Day 24: Merging/Rebasing + Stash + Cherry-pick (see `2026/day-24/git-commands.md`).
- Day 25: Reset & Revert (see `2026/day-25/git-commands.md`).
- Day 26: GitHub CLI `gh` (see `2026/day-26/git-commands.md` — final consolidated reference).
