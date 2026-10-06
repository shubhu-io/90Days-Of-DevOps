# My 90-Day DevOps Learning Plan

## Task

Concise recap of every challenge task from `README.md`:

- Define your understanding of DevOps and Cloud Engineering in your own words.
- State why you are starting DevOps & Cloud (motivation, career context).
- Define where you want to reach in 90 days (destination, outcomes).
- Explain how you will stay consistent every single day (system, not willpower).
- Mention your current level (student / fresher / working professional / non-IT).
- Define 3 clear goals for the next 90 days (e.g. production-grade app on Kubernetes).
- Define 3 core DevOps skills to build (e.g. Linux troubleshooting, CI/CD, Kubernetes debugging).
- Allocate a weekly time budget (e.g. 2–2.5h weekdays, 4–6h weekends).
- Keep the document under 1 page of core plan (this expanded answer file adds supporting detail around it).
- Be honest and realistic; consistency matters more than perfection.
- Fork the repo, add `learning-plan.md` under `2026/day-01/`, commit, push, and share Day 01 in public.

## Environment

| Item | Value | Install / Check Command |
|------|-------|--------------------------|
| OS | Any (Windows 11 + WSL2 Ubuntu 24.04 recommended, or native Ubuntu 22.04/24.04, or macOS) | `cat /etc/os-release` |
| Shell | Bash (WSL2 / Linux) or PowerShell (Windows-side git ops) | `echo $SHELL` |
| Editor | VS Code + Markdown preview (or `vim` for handwritten-note parity) | `code --version` |
| Git | Git 2.40+ for fork/clone/commit/push | `git --version` |
| GitHub account | Fork of `90DaysOfDevOps` + daily commits | `gh auth status` (optional, if using GitHub CLI) |
| Time tracker | Any (phone timer, Toggl, simple logbook) | n/a — pick one and stick to it |
| LinkedIn | Account for Learn-in-Public posts | n/a |

> All learner-specific values (current role, hours per day, target job) are personal. Fill the `[TODO - run on your machine]` rows in Verification with your own numbers.

## Solution

### 1. Where I am today (current level)

Student / fresher. I know the basics of **Linux & shell**, have touched **programming** (scripting/logic), and use **Git** for version control. Beyond that, my DevOps and cloud knowledge is practically zero — no real infrastructure, no deployment, no production systems.

Expanded context (preserved + clarified):

- **Linux & shell:** can navigate, create files, use `grep`/`tail`, follow a tutorial. Cannot yet debug a broken service under pressure.
- **Programming:** understands variables, loops, conditionals; has written small scripts. Has not built pipelines or automation that runs unattended.
- **Git:** can `clone`/`add`/`commit`/`push` and open a PR. Has not resolved real merge conflicts in a team or written CI that gates merges.
- **Gaps (honest):** cloud accounts, networking (DNS, ports, firewalls), containers, CI/CD, Kubernetes, monitoring, IaC. That is exactly what the 90 days closes.

**Why this matters (DevOps context):** every production incident starts with "what do you already know how to check?" A fresher who can state their baseline precisely gets better help, picks right-sized tasks, and avoids tutorial hell. Hiring managers also trust a candidate who names gaps over one who claims "full stack DevOps" with no evidence.

### 2. What DevOps and Cloud Engineering mean to me

| Term | My understanding (own words) |
|------|-------------------------------|
| DevOps | The discipline of shipping software reliably and repeatedly: small changes, automated tests/builds/deploys, observable systems, fast recovery when things break. Culture (ownership, blameless postmortems) plus tooling (Git, CI/CD, containers, IaC). |
| Cloud Engineering | Running workloads on someone else's datacenter with APIs: provisioning VMs/networks/storage on demand, paying per use, securing access with IAM and security groups, and treating infrastructure as code instead of clicks. |
| SRE overlap | DevOps builds the road; SRE measures it (SLIs/SLOs, error budgets) and keeps the car from crashing. I will borrow SRE habits: runbooks, monitoring, postmortems. |
| Platform mindset | My job is to make deploys boring: any commit can reach production safely, roll back in minutes, and leave logs/metrics behind. |

**Why this matters:** if you cannot explain DevOps in two sentences, you will misuse the tools (e.g. "we do DevOps because we installed Jenkins"). The definition above keeps every later day anchored: Day 08 (cloud VM) is Cloud Engineering; Days 02–07 (Linux) are the substrate DevOps runs on.

### 3. Why I'm doing this (motivation)

I don't want to stay a "just learned theory" person. I want to be an engineer who can build, ship, break and fix real systems. This 90 days is my execution blueprint, not a reading list.

Three concrete drivers:

1. **Employability:** I want a GitHub history that proves I can run `nginx` on a cloud VM, containerise it, and debug it — not just certificates.
2. **Craft:** I enjoy the moment a broken service comes back because *I* read the logs correctly. Chasing that feeling daily.
3. **Compounding:** 90 small public commits beat one frantic month before interviews. Learn-in-Public posts are my accountability partner.

**Why this matters:** motivation fades; systems persist. Writing the "why" down is what you re-read on Day 34 when Kubernetes RBAC makes you want to quit.

### 4. Where I want to reach — 3 clear goals for the next 90 days

1. **Deploy a production-grade application on Kubernetes** — containerized, Helm-managed, with monitoring and logs running.
   - Proof: public repo with `Dockerfile`, Helm chart, `kubectl get pods` screenshot, Prometheus/Grafana or equivalent showing metrics.
   - Stretch: Ingress + TLS + resource limits + liveness/readiness probes.
2. **Build and own a full CI/CD pipeline** — code commit → test → build image → push to registry → deploy, fully automated.
   - Proof: GitHub Actions (or GitLab CI) YAML in repo, green runs, image in Docker Hub/GHCR/ECR, auto-deploy to VM or cluster.
   - Stretch: branch protection, image scanning, rollback run.
3. **Get a real DevOps job/interview** — complete hands-on projects, an honest public learning log (Learn in Public), and be able to explain every system I built end-to-end.
   - Proof: resume with 3 projects, LinkedIn series `#90DaysOfDevOps`, mock incident explanations recorded in runbooks (Days 04–05 pattern).

| Goal | Done looks like | Target week |
|------|-----------------|-------------|
| K8s app + monitoring | Live URL or cluster manifests + dashboards | Weeks 9–12 |
| CI/CD pipeline | Green pipeline + registry + auto-deploy | Weeks 6–9 |
| Job-ready | Resume + 3 READMEs + interview stories | Weeks 11–13 |

**Why this matters:** vague goals ("learn AWS") never finish. Each goal above has an artifact a reviewer can click. That is how DevOps work is judged in production too: by running systems, not intentions.

### 5. My 3 core skills to build

1. **Linux & shell troubleshooting** — logs, processes, networking, permissions, debugging under pressure.
   - Maps to Days 02–10 directly. Daily reps: `ps`, `systemctl`, `journalctl`, `ss`, `chmod`, `grep`/`tail -f`.
2. **CI/CD + containers** — Docker, GitHub Actions/GitLab CI, registries, pipeline design and failure handling.
   - Maps to mid-course Docker + pipeline days. Reps: `docker build/run/logs`, YAML pipelines, caching, secrets.
3. **Kubernetes & cloud fundamentals** — deployments, services, config/secrets, debugging pods, and core AWS concepts.
   - Maps to late-course K8s + cloud days. Reps: `kubectl describe/logs/exec`, Helm, EC2/SG/IAM basics.

| Skill | Signal I have it | Practice loop |
|-------|------------------|---------------|
| Linux troubleshooting | Fix a failed `ssh`/`nginx` from logs alone in < 15 min | Daily drills (Days 04–05 runbooks) |
| CI/CD + containers | Green pipeline after breaking the Dockerfile on purpose | One pipeline change per week |
| K8s + cloud | `CrashLoopBackOff` diagnosed via `describe` + `logs` | Weekly K8s scenario |

### 6. Time budget (4+ hours, every day)

- **Mon–Fri:** 4–4.5 hours — 1.5h theory/notes, 2h hands-on lab, 0.5h notes + commit.
- **Sat–Sun:** 6+ hours — longer projects, breaking & fixing what I built, writing the public posts.

Weekly template (illustrative — adapt to your calendar):

```text
Mon  1.5h lesson + 2h lab + 0.5h commit/post
Tue  same split, next topic
Wed  same split
Thu  same split + weekly LinkedIn post draft
Fri  same split, lighter lab (review week)
Sat  6h project block (build / break / fix / screenshot)
Sun  6h project + weekly review (what worked, what slipped, next-week plan)
Total: ~32-34h/week (illustrative)
```

| Slot | Your actual value |
|------|-------------------|
| Weekday hours available | `[TODO - run on your machine]` e.g. 19:00–23:00 |
| Weekend hours available | `[TODO - run on your machine]` e.g. Sat/Sun 09:00–15:00 |
| Non-negotiable minimum | 60 minutes (streak never breaks) |

**Why this matters:** on-call rotations and deploy windows are time-boxed in real jobs. Training yourself to produce a commit + note inside a fixed window mirrors that constraint.

### 7. How I stay consistent (the system)

- Non-negotiable daily minimum: **even 60 minutes counts** — a streak is never broken.
- Every day ends with: **code committed + a short written note** (what I did, what broke, what I learned).
- Weekly review on Sunday: what worked, what's slipping, re-plan the next week.
- Progress is public: post daily/weekly updates with `#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`.
- No over-research. **Build first, read only when I'm stuck.**

Anti-burnout rules:

| Rule | Why |
|------|-----|
| One rest evening per week with only the 60-min minimum | Prevents the Week-3 crash |
| Tired days = docs/screenshots/readme polish, not new K8s concepts | Keeps streak without frying |
| "Two-day rule": never skip twice in a row | One miss is life; two is a new habit |
| Phone away during lab blocks; terminal full-screen | Context-switching is the real time thief |
| Sick/travel plan: read-only day (review notes, write postmortem) | Streak survives reality |

### 8. Honesty check

I know consistency matters more than intensity. Some days I'll be tired and some topics will be hard, but skipping the streak entirely is not an option. In 90 days I want a GitHub full of real work and the confidence to say: *I can run this in production.*

Known risks and mitigations:

| Risk | Mitigation |
|------|------------|
| College/work deadlines eat evenings | Morning 60-min fallback slot reserved |
| Stuck on one topic for days | Time-box to 2 days, ask in community, move on and return |
| Tutorial copying without understanding | Every day must include one command I typed from memory + one error I fixed |
| No cloud budget | Stay in free tier; stop/terminate instances same day (Day 08 habit) |

### 9. Week-by-week roadmap (how the 3 goals decompose)

**Why:** 90 days without milestones drifts. Each phase below ends with a demoable artifact; if a week slips, the artifact (not guilt) tells you.

| Weeks | Focus | Exit artifact |
|-------|-------|---------------|
| 1–2 | Linux + shell + Git habits (Days 01–10 pattern) | Runbooks + `notes.txt`-style labs committed daily |
| 3–4 | Networking, permissions, users, troubleshooting drills | Can fix `ssh`/`nginx` failure from logs in < 15 min |
| 5–6 | Cloud VM (Day 08 pattern) + web deployment | Live `http://<public-ip>` page + `nginx-logs.txt` |
| 7–8 | Docker + registries + first CI pipeline | Image in registry, green pipeline run |
| 9–10 | CI/CD hardening (tests, scans, rollbacks) | Commit → deploy with zero manual steps |
| 11–12 | Kubernetes + monitoring + interview prep | Helm-deployed app with metrics + resume stories |

Rules for the roadmap:

```text
- One phase at a time; never start K8s while the pipeline is still red.
- Each Sunday: mark artifacts done / carried / dropped (dropped is allowed, vague is not).
- Each artifact gets a README section: what it is, how to run it, what breaks it.
- If behind by >1 week: cut scope (smaller app), never cut the daily commit habit.
```

| Your machine (planning values) | Value |
|--------------------------------|-------|
| Phase most at risk for my schedule | `[TODO - run on your machine]` e.g. weeks 9–10 with exams |
| Backup cloud region if free tier fills | `[TODO - run on your machine]` |

### 10. Submission workflow (how this file gets to GitHub)

```bash
# illustrative session — prompts and hashes will differ on your machine
git clone https://github.com/<your-username>/90DaysOfDevOps.git
cd 90DaysOfDevOps/2026/day-01
# create/edit learning-plan.md in VS Code or vim
git status --short
git add learning-plan.md
git commit -m "day-01: add personal 90-day learning plan"
git push origin main
```

LinkedIn post template (2–3 lines + one goal + hashtags):

```text
Day 01 of #90DaysOfDevOps — I committed to shipping, not just studying.
Goal 1: deploy a production-grade app on Kubernetes with monitoring.
Following along with #DevOpsKaJosh #TrainWithShubham
```

## Commands Used

```bash
git clone https://github.com/<your-username>/90DaysOfDevOps.git
cd 90DaysOfDevOps/2026/day-01
code learning-plan.md
git status --short
git add learning-plan.md
git commit -m "day-01: add personal 90-day learning plan"
git push origin main
cat learning-plan.md
wc -l learning-plan.md
```

## Verification

- [ ] `learning-plan.md` exists under `2026/day-01/` and `cat learning-plan.md` prints it without errors
- [ ] File states current level (student / fresher / professional / non-IT): `[TODO - run on your machine]` confirm yours is written
- [ ] File lists exactly 3 goals, each with a verifiable artifact (repo link, URL, screenshot): `[TODO - run on your machine]` check yours
- [ ] File lists exactly 3 core skills with a practice loop: `[TODO - run on your machine]` check yours
- [ ] Weekly time budget is written with weekday + weekend hours: `[TODO - run on your machine]` fill your hours
- [ ] `git status --short` is clean after commit (nothing left uncommitted)
- [ ] `git log --oneline -3` shows the day-01 commit
- [ ] LinkedIn draft (2–3 lines + 1 goal + 3 hashtags) is ready to post

## Key Learnings

- DevOps is a shipping discipline (small batches, automation, observability, fast recovery), not a tool list.
- Cloud Engineering is API-driven infrastructure with IAM, networks, and cost as first-class concerns.
- Three verifiable goals beat ten vague ones because reviewers click artifacts, not adjectives.
- Skills compound only with daily reps; reading without typing commands does not transfer under incident pressure.
- Time-boxing (theory/lab/commit splits) mirrors real on-call and deploy windows.
- Public commits and posts are accountability, not vanity — the streak is the system.
- Honest baselines ("my cloud knowledge is zero") get better help and better plans than inflated ones.
- Rest and fallback minimums (60 minutes) are what let a 90-day plan survive contact with real life.

## Troubleshooting / Gotchas

- **Forked the wrong repo or cloned upstream read-only:** `git remote -v` shows `upstream` only. Cause: cloned the course repo instead of your fork. Fix: `git remote add origin https://github.com/<you>/90DaysOfDevOps.git` then push to `origin`.
- **`git push` asks for password and fails:** Cause: password auth removed on GitHub. Fix: use a Personal Access Token or `gh auth login`; on Windows use Git Credential Manager.
- **Markdown preview looks broken (tables/headings):** Cause: missing blank line before table or unclosed code fence. Fix: ensure a blank line above/below tables and triple backticks closed with language tag (```text, ```bash).
- **Plan is 3 pages and overwhelming:** Cause: wrote a textbook instead of a blueprint. Fix: cut to 1-page core (level, why, 3 goals, 3 skills, hours, consistency rules); move detail to weekly reviews.
- **Goals are unverifiable ("learn AWS"):** Cause: no artifact defined. Fix: rewrite as "deploy X, pipeline does Y, proof is Z link/screenshot".
- **Burnout by week 3:** Cause: 6-hour days with no rest. Fix: enforce one light evening + 60-min minimum rule; tired days do docs/polish only.
- **No time on weekdays:** Cause: plan assumed ideal evenings. Fix: define a morning 60-min fallback and protect it like a standup meeting.

## Self-check

- [ ] Current level is stated honestly
- [ ] DevOps + Cloud understanding is in my own words
- [ ] Why (motivation) is written down and re-readable on hard days
- [ ] 3 clear goals with verifiable artifacts are listed
- [ ] 3 core skills with practice loops are listed
- [ ] Weekly time budget (weekday + weekend + minimum) is allocated
- [ ] Consistency system (commit + note + weekly review + public posts) is defined
- [ ] File is committed and pushed to my fork under `2026/day-01/`
- [ ] LinkedIn Day 01 post uses `#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

## Screenshots

Kiska screenshot (is day ke liye 2 capture kaafi hai):
- `learning-plan.png` — `learning-plan.md` VS Code me khula hua (preview ya editor)
- `day01-push.png` — `git add/commit/push` terminal output ya GitHub fork me file dikhti hui
- (Optional) `linkedin-post.png` — Day 01 LinkedIn post ka screenshot

Kaha dalna hai:
1. PNG files is folder me save karo: `2026/day-01/screenshots/` (jaise `2026/day-01/screenshots/learning-plan.png`)
2. Is md file me dikhane ke liye is section ke neeche ye lines add karo:
   `![learning-plan](screenshots/learning-plan.png)`
   `![day01-push](screenshots/day01-push.png)`

_Add images to `screenshots/` in this folder and run `.\update-screenshots.ps1` from `My_DevOps_journey` to embed them in `README.md`._
