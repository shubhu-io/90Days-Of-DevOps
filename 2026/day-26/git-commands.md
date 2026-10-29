# Git Commands Reference

Day 26 update — adds GitHub CLI (gh) commands. Final consolidated Days 22–26 reference.

## Setup & Config

| Command | What it does | Example |
|---------|--------------|---------|
| `git --version` | Shows installed Git version | `git --version` |
| `git config --global user.name "Name"` | Sets identity name | `git config --global user.name "Shubham"` |
| `git config --global user.email "email"` | Sets identity email | `git config --global user.email "you@example.com"` |
| `git config --global init.defaultBranch main` | Default branch for new repos | `git config --global init.defaultBranch main` |
| `git config --list --show-origin` | Shows source of each setting | `git config --list --show-origin` |
| `git init` | Initializes a repository | `git init` |
| `git clone <url>` | Copies a remote repo locally | `git clone https://github.com/user/repo.git` |
| `git clone --depth 1 <url>` | Shallow clone for speed | `git clone --depth 1 https://github.com/user/repo.git` |

## Basic Workflow

| Command | What it does | Example |
|---------|--------------|---------|
| `git status` | Staged/unstaged/untracked changes | `git status` |
| `git status -sb` | Short branch-aware status | `git status -sb` |
| `git add <file>` | Stage a file | `git add notes.md` |
| `git add -p` | Stage hunks interactively | `git add -p` |
| `git commit -m "msg"` | Snapshot staged changes | `git commit -m "Add feature"` |
| `git commit -a -m "msg"` | Stage tracked edits + commit | `git commit -a -m "Fix typo"` |
| `git commit --amend -m "msg"` | Fix last commit (unpushed only) | `git commit --amend -m "Better message"` |
| `git restore <file>` | Discard unstaged changes | `git restore notes.md` |
| `git restore --staged <file>` | Unstage a file | `git restore --staged notes.md` |
| `git rm --cached <file>` | Untrack but keep on disk | `git rm --cached .env` |
| `git diff` / `git diff --cached` / `git diff --stat` | Unstaged / staged / summary | `git diff --stat` |

## Branching

| Command | What it does | Example |
|---------|--------------|---------|
| `git branch` | List local branches | `git branch` |
| `git branch -a` / `-vv` / `-r` | All / verbose / remote-only | `git branch -vv` |
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
| `git log --oneline --graph --all` | Visualize topology | `git log --oneline --graph --all` |
| `git rebase <branch>` | Replay current branch onto target | `git rebase main` |
| `git rebase -i HEAD~3` | Interactive cleanup | `git rebase -i HEAD~3` |
| `git rebase --continue` / `--skip` / `--abort` | Resolve flow | `git rebase --continue` |
| `git cherry-pick <hash>` | Copy one commit onto current branch | `git cherry-pick 1a2b3c4` |
| `git cherry-pick -x <hash>` | Copy + record source | `git cherry-pick -x 1a2b3c4` |
| `git cherry-pick --abort` | Cancel conflicted cherry-pick | `git cherry-pick --abort` |

## Stash

| Command | What it does | Example |
|---------|--------------|---------|
| `git stash` | Stash uncommitted changes | `git stash` |
| `git stash push -m "msg"` | Stash with a message | `git stash push -m "wip login"` |
| `git stash push -u -m "msg"` | Stash incl. untracked files | `git stash push -u -m "wip"` |
| `git stash list` | List all stashes | `git stash list` |
| `git stash show` / `-p stash@{0}` | Summary / full diff | `git stash show -p stash@{0}` |
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
| `git remote add upstream <url>` | Add original as upstream (forks) | `git remote add upstream https://github.com/original/repo.git` |
| `git push -u origin <branch>` | Push and set upstream | `git push -u origin main` |
| `git push origin <branch>` | Push branch | `git push origin feature-1` |
| `git push --force-with-lease` | Safer force-push after rebase | `git push --force-with-lease` |
| `git push origin --delete <b>` | Delete remote branch | `git push origin --delete feature-tmp` |
| `git pull` / `git pull --rebase` | Fetch+merge / fetch+rebase | `git pull --rebase` |
| `git fetch` | Download remote refs only | `git fetch origin` |

## Viewing Changes

| Command | What it does | Example |
|---------|--------------|---------|
| `git log --oneline` | One line per commit | `git log --oneline` |
| `git log --oneline --graph --all` | Visual branch history | `git log --oneline --graph --all` |
| `git log -- <file>` | History of one file | `git log -- f.txt` |
| `git show <hash>` | One commit's details | `git show a1b2c3d` |
| `git reflog` | History of HEAD movements | `git reflog` |
| `git blame <file>` | Line authorship | `git blame app.py` |

## Reset & Revert

| Command | What it does | Example |
|---------|--------------|---------|
| `git reset --soft HEAD~1` | Undo last commit, changes stay staged | `git reset --soft HEAD~1` |
| `git reset --mixed HEAD~1` | Undo last commit, changes unstaged (default) | `git reset --mixed HEAD~1` |
| `git reset --hard HEAD~1` | Undo last commit, discard changes (destructive) | `git reset --hard HEAD~1` |
| `git reset --hard <hash>` | Jump branch to any commit (local only) | `git reset --hard a1b2c3d` |
| `git clean -n` / `git clean -fd` | Preview / delete untracked files | `git clean -n` |
| `git revert <hash>` | New commit that undoes `<hash>`, history kept | `git revert a1b2c3d` |
| `git revert -m 1 <hash>` | Revert a merge commit via mainline parent | `git revert -m 1 b2c3d4e` |
| `git revert --continue` | Continue after resolving revert conflict | `git revert --continue` |
| `git revert --abort` | Cancel a conflicted revert | `git revert --abort` |
| `git reflog` | Recover commits lost to a hard reset | `git reflog` |

## GitHub CLI (gh)

| Command | What it does | Example |
|---------|--------------|---------|
| `gh --version` | Shows gh version | `gh --version` |
| `gh auth login` | Authenticate with GitHub | `gh auth login` |
| `gh auth status` | Show login state and scopes | `gh auth status` |
| `gh auth refresh -s repo,workflow` | Add missing token scopes | `gh auth refresh -s repo,workflow` |
| `gh auth refresh -h github.com -s delete_repo` | Add the scope required by `gh repo delete` | `gh auth refresh -h github.com -s delete_repo` |
| `gh auth setup-git` | Configure git credential helper | `gh auth setup-git` |
| `gh repo create <name> --public` | Create a repo from the terminal | `gh repo create demo --public --add-readme` |
| `gh repo clone <owner>/<repo>` | Clone a repo | `gh repo clone user/demo` |
| `gh repo view [--web]` | View repo details / open in browser | `gh repo view user/demo --web` |
| `gh repo list` | List repos (`--json` for scripts) | `gh repo list user --limit 20` |
| `gh repo delete <repo> --yes` | Delete a repo (no undo) | `gh repo delete user/demo --yes` |
| `gh issue create` | Open an issue | `gh issue create -t "Bug" -b "desc" -l bug` |
| `gh label create <name>` | Create a label for issues/PRs | `gh label create documentation --color 0075ca` |
| `gh issue list` / `view` / `close` / `reopen` | Manage issues | `gh issue close 3 --reason completed` |
| `gh issue list --label <l> --state all` | Filter issues by label/state | `gh issue list --label documentation` |
| `gh issue comment <n> --body` | Comment on an issue | `gh issue comment 3 --body "CI failed"` |
| `gh issue edit <n>` | Edit title/body/labels/assignees | `gh issue edit 3 --add-label done` |
| `gh pr create` / `--fill` | Create a PR from commits | `gh pr create --fill` |
| `gh pr list` / `view` / `diff` / `checks` | Inspect PRs | `gh pr view 42` |
| `gh pr checkout <n>` | Test a PR locally | `gh pr checkout 42` |
| `gh pr merge <n> --squash` | Merge a PR (also `--merge`, `--rebase`) | `gh pr merge 42 --squash --delete-branch` |
| `gh pr review <n> --approve` | Approve / request-changes / comment | `gh pr review 42 --approve` |
| `gh run list` / `view` / `watch` | Check workflow runs | `gh run watch 12345` |
| `gh workflow list` / `view` / `run` | Manage workflows | `gh workflow run deploy.yml --ref main` |
| `gh api <endpoint>` | Raw API call (+ `--jq`, `--paginate`) | `gh api user --jq .login` |
| `gh gist create <file>` | Create a gist | `gh gist create notes.md --public` |
| `gh gist list` | List gists | `gh gist list --limit 5` |
| `gh release create <tag>` | Create a release | `gh release create v1.0.0 --notes "First release"` |
| `gh release list` / `view` | List/view releases | `gh release view v1.0.0` |
| `gh alias set <name> <cmd>` | Create a shortcut | `gh alias set prc 'pr create --fill'` |
| `gh search repos <query>` | Search GitHub | `gh search repos "topic:devops"` |
| `gh browse [<repo>]` | Open repo in browser | `gh browse owner/repo` |

## Day-wise update log

- Day 22: Setup/Workflow/Viewing. Day 23: Branching/Remotes. Day 24: Merge/Rebase/Stash/Cherry-pick. Day 25: Reset/Revert.
- Day 26 (final): + full `gh` CLI — auth, repo, issue, PR, runs/workflows, api/gist/release/alias/search. This file is now the complete Days 22–26 reference.
