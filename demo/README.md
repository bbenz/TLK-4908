# The TLK-4908 demo

The talk reviews two pull requests into the `start` branch. Both hold a coding agent's work. We planted the problems in them, so the demo works the same way every time. Each one is a mistake that coding assistants really make.

| Pull request | Branch | What it shows |
| --- | --- | --- |
| [#1](https://github.com/bbenz/TLK-4908/pull/1) | `demo/agent-pr` | The agent's first try. The review gate fails, and Copilot code review leaves comments. |
| [#2](https://github.com/bbenz/TLK-4908/pull/2) | `demo/agent-fix` | The same first try, then a second commit that makes the review gate pass the wrong way. |

A ruleset protects `start`. The review gate must pass, a code owner must approve changes to the files that judge the code, and every conversation must be resolved. Copilot code review reviews every pull request and every new push. `rulesets/review-gate.json` holds the same rules.

## The agent's first try

| Problem | File | Review gate | Copilot code review |
| --- | --- | --- | --- |
| A made-up book, "Agentic Java in Practice" from "Contoso Press". Its ISBN check digit is wrong, and its link uses the reserved `.example` domain. | `books.json` | Step 1 fails: `BookDataRulesTest` | High |
| The API returns `author` as one string, not `authors` as a list. | `Book.java` | Step 2 fails: oasdiff | High |
| It adds `commons-text` 1.9, which has CVE-2022-42889. | `pom.xml` | Step 3 fails: OSV-Scanner and Grype report it as Critical | Medium |
| The image builds on Java 25 and runs on Java 21. | `Dockerfile` | Step 4 fails: the container stops at once | High |
| The readiness probe calls `/health`. The site answers at `/actuator/health/readiness`. | `k8s/books.yaml` | Passes. No step deploys to Kubernetes. | High |

Copilot also found a real problem in our own data: one book links to an Amazon listing, not to the publisher's site, as `AGENTS.md` asks.

## The second commit

`demo/agent-fix` adds one commit, "Fix the failing checks". The review gate passes.

| Change | Review gate | Copilot code review | Code owners |
| --- | --- | --- | --- |
| Updates commons-text to 1.10.0, and runs the image on Java 25. These are real fixes. | Steps 3 and 4 pass | Marked "resolved since last review" | |
| Changes `api/openapi.yaml` so the contract matches the code. Every client of the API still breaks. | Step 2 passes | High: "breaks the published response contract" | Approval required: the contract has a code owner |
| Changes the last digit of the made-up ISBN, so the check digit is valid. The book is still made up. | Step 1 passes | Medium: "A valid ISBN check digit does not establish that the ISBN belongs to the claimed title." | |
| Leaves the readiness probe at `/health`. | Passes | High, still open | |

`AGENTS.md` tells agents never to edit the contract to make a check pass. The agent did it anyway. Instructions ask. Rules enforce.

On AKS, the second commit never becomes ready: `Readiness probe failed: HTTP probe failed with statuscode: 404`.

## What the runs showed

- Copilot code review found every planted problem, including the probe that no step checks. Its comments do not block a merge on their own. The ruleset makes them count, because every conversation must be resolved before a merge.
- The same commit, reviewed twice, got 6 comments in one review and 5 in the other.
- Copilot reads `pom.xml`. It rated commons-text 1.9 as Medium, because the code does not call the vulnerable part of the library. The scanners rate it as Critical.
- The first gate run on `main` failed. The default Ubuntu 26.04 base image includes `/usr/bin/pebble`, a Go program with known vulnerabilities. The image now uses Ubuntu 24.04.

The reviews ran on October 25, 2026, at the Balanced review effort level. Results change from run to run.

## Run the demo again

You need GitHub Copilot with code review.

1. Fork this repo. Change `@bbenz` in `.github/CODEOWNERS` to your own account.
2. Import `rulesets/review-gate.json` in **Settings** > **Rules** > **Rulesets**, and change its target branch to `start`.
3. Open a pull request from `demo/agent-pr` into `start`.
4. For the second round, open a pull request from a new branch, then push the second commit to it after the first review:

   ```bash
   git push origin demo/agent-pr:refs/heads/round-2
   gh pr create --base start --head round-2 --title "Add the Java and AI book list site (round 2)" --body "Round 2"
   # after Copilot's first review
   git push origin demo/agent-fix:round-2
   ```

To see the probe fail on AKS, deploy `demo/agent-fix` to its own namespace with the scripts in `deploy/aks/`, for example `NAMESPACE=books-round2 DNS_LABEL= deploy/aks/deploy.sh`.
