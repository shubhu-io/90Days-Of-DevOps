# Git Commands Reference

A living document — updated every day (Days 22–26). Each command: one line on what it does + an example. Day 22 covers Setup, Basic Workflow, Viewing Changes.

## Setup & Config

| Command | What it does | Example |
|---------|--------------|---------|
| `git --version` | Shows installed Git version | `git --version` |
| `git config --global user.name "Name"` | Sets your identity name for commits | `git config --global user.name "Shubham"` |
| `git config --global user.email "email"` | Sets your identity email | `git config --global user.email "you@example.com"` |
| `git config --global init.defaultBranch main` | Default branch name for new repos | `git config --global init.defaultBranch main` |
| `git config --global core.editor "code --wait"` | Editor for commit messages | `git config --global core.editor "code --wait"` |
| `git config --global --list` | Lists all global config values | `git config --global --list` |
| `git config --list --show-origin` | Shows where each setting comes from | `git config --list --show-origin` |
| `git init` | Initializes a new Git repository | `git init` |
| `git init -b main` | Init with explicit branch name | `git init -b main` |
| `git clone <url>` | Copies a remote repository locally | `git clone https://github.com/user/repo.git` |
| `git clone --depth 1 <url>` | Shallow clone (latest commit only, faster) | `git clone --depth 1 https://github.com/user/repo.git` |
| `git help <cmd>` / `git <cmd> --help` | Opens manual for a subcommand | `git log --help` |

## Basic Workflow

| Command | What it does | Example |
|---------|--------------|---------|
| `git status` | Shows staged/unstaged/untracked changes | `git status` |
| `git status -sb` | Short branch-aware status | `git status -sb` |
| `git add <file>` | Stages a file for the next commit | `git add git-commands.md` |
| `git add .` | Stages all changes in current directory | `git add .` |
| `git add -p` | Interactively stage hunks (precise commits) | `git add -p` |
| `git commit -m "msg"` | Snapshots staged changes with a message | `git commit -m "Add reference file"` |
| `git commit -a -m "msg"` | Stages tracked-file edits + commits in one step | `git commit -a -m "Fix typo"` |
| `git commit --amend -m "msg"` | Replaces the last commit (message/content, unpushed only) | `git commit --amend -m "Better message"` |
| `git commit --allow-empty -m "msg"` | Creates a commit with no changes (practice/CI trigger) | `git commit --allow-empty -m "Trigger CI"` |
| `git restore <file>` | Discards unstaged changes in a file | `git restore notes.md` |
| `git restore --staged <file>` | Unstages a file, keeps disk edits | `git restore --staged notes.md` |
| `git rm <file>` | Removes file from disk and staging | `git rm old.txt` |
| `git rm --cached <file>` | Untracks file but keeps it on disk (e.g. committed `.env`) | `git rm --cached .env` |
| `git mv <old> <new>` | Renames/moves a tracked file | `git mv old.md new.md` |
| `git diff` | Shows unstaged changes | `git diff` |
| `git diff --stat` | Summary of changed files | `git diff --stat` |

## Viewing Changes

| Command | What it does | Example |
|---------|--------------|---------|
| `git diff --cached` | Shows staged changes vs last commit | `git diff --cached` |
| `git diff HEAD` | All uncommitted changes vs last commit | `git diff HEAD` |
| `git log` | Full commit history | `git log` |
| `git log --oneline` | One line per commit | `git log --oneline` |
| `git log --oneline -5` | Last 5 commits compactly | `git log --oneline -5` |
| `git log --oneline --graph --all` | Compact visual branch/merge history | `git log --oneline --graph --all` |
| `git log --stat` | Commits plus per-file change stats | `git log --stat` |
| `git log -p` | Commits plus their diffs | `git log -p` |
| `git log -- <file>` | History of one file | `git log -- git-commands.md` |
| `git show <hash>` | Details of one commit | `git show a1b2c3d` |
| `git show HEAD --stat` | Last commit with file stats | `git show HEAD --stat` |
| `git blame <file>` | Line-by-line authorship | `git blame app.py` |
| `git blame -L 10,20 <file>` | Blame a line range | `git blame -L 10,20 app.py` |

## Day-wise update log

- Day 22: Setup & Config, Basic Workflow, Viewing Changes (initial reference).
- Day 23: Branching + Remotes (see `2026/day-23/git-commands.md`).
- Day 24: Merging/Rebasing + Stash + Cherry-pick (see `2026/day-24/git-commands.md`).
- Day 25: Reset & Revert (see `2026/day-25/git-commands.md`).
- Day 26: GitHub CLI `gh` (see `2026/day-26/git-commands.md` — final consolidated reference).
