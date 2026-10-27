# Git Commands Reference

Day 24 update — adds merging, rebasing, stash, and cherry-pick commands (keeps Days 22–23).

## Setup & Config

| Command | What it does | Example |
|---------|--------------|---------|
| `git --version` | Shows installed Git version | `git --version` |
| `git config --global user.name "Name"` | Sets identity name | `git config --global user.name "Shubham"` |
| `git config --global user.email "email"` | Sets identity email | `git config --global user.email "you@example.com"` |
| `git config --global init.defaultBranch master` | Default branch for new repos | `git config --global init.defaultBranch master` |
| `git config --list --show-origin` | Shows source of each setting | `git config --list --show-origin` |
| `git init` | Initializes a repository | `git init` |
| `git clone <url>` | Copies a remote repo locally | `git clone https://github.com/user/repo.git` |

## Basic Workflow

| Command | What it does | Example |
|---------|--------------|---------|
| `git status` | Staged/unstaged/untracked changes | `git status` |
| `git status -sb` | Short branch-aware status | `git status -sb` |
| `git add <file>` | Stage a file | `git add notes.md` |
| `git add -p` | Stage hunks interactively | `git add -p` |
| `git commit -m "msg"` | Snapshot staged changes | `git commit -m "Add feature"` |
| `git commit --amend -m "msg"` | Fix last commit (unpushed only) | `git commit --amend -m "Better message"` |
| `git restore <file>` | Discard unstaged changes | `git restore notes.md` |
| `git restore --staged <file>` | Unstage a file | `git restore --staged notes.md` |
| `git diff` / `git diff --cached` | Unstaged / staged changes | `git diff --cached` |

## Branching

| Command | What it does | Example |
|---------|--------------|---------|
| `git branch` | List local branches | `git branch` |
| `git branch -a` | List local + remote branches | `git branch -a` |
| `git branch -vv` | List with upstream info | `git branch -vv` |
| `git switch <name>` | Switch branch | `git switch feature-1` |
| `git switch -c <name>` | Create + switch in one command | `git switch -c feature-2` |
| `git branch --show-current` | Print current branch | `git branch --show-current` |
| `git branch -d <name>` | Delete merged branch | `git branch -d feature-tmp` |
| `git branch -D <name>` | Force delete | `git branch -D old` |

## Merging & Rebasing

| Command | What it does | Example |
|---------|--------------|---------|
| `git merge <branch>` | Merge branch into current | `git merge feature-login` |
| `git merge --no-ff <branch>` | Force a merge commit | `git merge --no-ff feature-x` |
| `git merge --squash <branch>` | Combine branch commits into one staged change | `git merge --squash feature-profile` |
| `git merge --abort` | Cancel a conflicted merge | `git merge --abort` |
| `git log --oneline --graph --all` | Visualize merge topology | `git log --oneline --graph --all` |
| `git rebase <branch>` | Replay current branch onto target | `git rebase master` |
| `git rebase -i HEAD~3` | Interactive rebase (squash/reword/pick) | `git rebase -i HEAD~3` |
| `git rebase --continue` | Continue after resolving conflict | `git rebase --continue` |
| `git rebase --skip` | Skip current commit in rebase | `git rebase --skip` |
| `git rebase --abort` | Cancel rebase | `git rebase --abort` |
| `git cherry-pick <hash>` | Copy one commit onto current branch | `git cherry-pick 1a2b3c4` |
| `git cherry-pick -x <hash>` | Cherry-pick + record source hash | `git cherry-pick -x 1a2b3c4` |
| `git cherry-pick --continue` | Continue after resolving conflict | `git cherry-pick --continue` |
| `git cherry-pick --skip` | Skip current cherry-pick | `git cherry-pick --skip` |
| `git cherry-pick --abort` | Cancel conflicted cherry-pick | `git cherry-pick --abort` |

## Stash

| Command | What it does | Example |
|---------|--------------|---------|
| `git stash` | Stash uncommitted changes | `git stash` |
| `git stash push -m "msg"` | Stash with a message | `git stash push -m "wip login"` |
| `git stash push -u -m "msg"` | Stash incl. untracked files | `git stash push -u -m "wip"` |
| `git stash list` | List all stashes | `git stash list` |
| `git stash show` | Show stashed diff summary | `git stash show` |
| `git stash show -p stash@{0}` | Full diff of a stash | `git stash show -p stash@{0}` |
| `git stash apply` | Restore, keep stash entry | `git stash apply` |
| `git stash pop` | Restore and drop stash entry | `git stash pop` |
| `git stash apply stash@{0}` | Apply a specific stash | `git stash apply stash@{0}` |
| `git stash drop stash@{0}` | Delete one stash | `git stash drop stash@{0}` |
| `git stash clear` | Delete all stashes | `git stash clear` |

## Remotes (GitHub)

| Command | What it does | Example |
|---------|--------------|---------|
| `git remote -v` | List remotes | `git remote -v` |
| `git remote add origin <url>` | Add remote | `git remote add origin https://...` |
| `git remote set-url origin <url>` | Fix remote URL | `git remote set-url origin https://...` |
| `git push -u origin <branch>` | Push and set upstream | `git push -u origin master` |
| `git push origin <branch>` | Push branch | `git push origin feature-1` |
| `git push --force-with-lease` | Safer force-push after rebase | `git push --force-with-lease` |
| `git pull` / `git pull --rebase` | Fetch+merge / fetch+rebase | `git pull --rebase` |
| `git fetch` | Download remote refs only | `git fetch origin` |

## Viewing Changes

| Command | What it does | Example |
|---------|--------------|---------|
| `git log --oneline` | One line per commit | `git log --oneline` |
| `git log --oneline --graph --all` | Visual branch history | `git log --oneline --graph --all` |
| `git show <hash>` | One commit's details | `git show a1b2c3d` |
| `git reflog` | History of HEAD movements | `git reflog` |
| `git blame <file>` | Line authorship | `git blame app.py` |

## Day-wise update log

- Day 22: Setup/Workflow/Viewing. Day 23: Branching/Remotes.
- Day 24: + Merging (`--no-ff`, `--squash`, `--abort`), rebasing (`--continue/--skip/--abort`, `-i`), stash stack, cherry-pick.
- Day 25: Reset & Revert (see `2026/day-25/git-commands.md`).
- Day 26: GitHub CLI `gh` (see `2026/day-26/git-commands.md` — final consolidated reference).
