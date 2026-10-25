# TLK-4908 books demo

This repo supports the talk "Reviewing AI-Written Java: Coding Assistants and a CI Gate" at JCON at IBM TechXchange 2026.

A coding agent builds a small Java web site that lists books about Java and AI. Its pull request goes to two reviewers:

- **A review gate** in GitHub Actions. It runs four checks on every pull request, and all four must pass.
- **GitHub Copilot code review.** It reads the change and leaves comments. A ruleset asks for its review on every pull request and every new push.

A person on the team still approves the merge.

## What the team writes first

- An API contract: `api/openapi.yaml`
- Rules every book must pass: `BookDataRulesTest`
- The review gate: `.github/workflows/review-gate.yml` and the scripts in `scripts/`
- The Azure infrastructure and deployment scripts: `infra/` and `deploy/aks/`
- Rules for agents: `AGENTS.md`. Rules for reviewers: `REVIEW.md`
- `.github/CODEOWNERS`, so a code owner must approve changes to the files that judge the code
- The branch rules: `rulesets/review-gate.json`

Then the agent builds the site from the prompt in `demo/prompt.md`: the Java code, the page, the book data, a `Dockerfile`, `compose.yaml`, and Kubernetes manifests in `k8s/`.

## Run the site

With Docker:

```bash
docker compose up --build
```

Open http://localhost:8080. To use another port, set `APP_PORT`, for example `APP_PORT=8090 docker compose up --build`.

Without Docker, use JDK 25:

```bash
./mvnw spring-boot:run
```

## The review gate

`.github/workflows/review-gate.yml` runs four checks on every pull request, as four steps in one job. Steps 2 to 4 run even when an earlier step fails, so one run shows every problem.

1. **Build and test.** `./mvnw -B verify` runs the tests, including the team's data rules.
2. **Compare the API.** `scripts/api-diff.sh` starts the site and compares the API it serves with `api/openapi.yaml`, using oasdiff.
3. **Scan dependencies.** `scripts/scan.sh` checks the Maven dependencies with OSV-Scanner, writes an SBOM with CycloneDX, and scans the image with Grype.
4. **Test the container.** `scripts/smoke-test.sh` starts the site with `compose.yaml`, waits until it is healthy, calls the API, and checks the Java version in the container.

To run the checks on your machine, use bash. Install the pinned tools first:

```bash
scripts/install-tools.sh
./mvnw -B verify
scripts/api-diff.sh
scripts/scan.sh
scripts/smoke-test.sh
```

`scripts/install-tools.sh` checks the SHA-256 checksum of each download on Linux. The last two checks need Docker. If Docker is not running, `scripts/scan.sh` skips the image scan and says so.

## Copilot code review and the ruleset

`rulesets/review-gate.json` holds these branch rules:

- Require a pull request, one approval, and an approval from a code owner.
- The most recent push must be approved by someone other than the person who pushed it.
- Every conversation must be resolved.
- The review gate must pass.
- Copilot code review reviews every pull request and every new push.

To use the rules in your repo, go to **Settings** > **Rules** > **Rulesets** > **New ruleset** > **Import a ruleset**, and choose the file. It targets your default branch. Change `@bbenz` in `.github/CODEOWNERS` to your own account or team.

Copilot code review reads `REVIEW.md` and `AGENTS.md` from the pull request's branch. It leaves comments, and its comments do not block a merge by themselves. The required checks, the code owners, and the rule that every conversation must be resolved do that.

## Deploy to AKS

You need Docker, the Azure CLI, kubectl, and an Azure subscription. The scripts create Azure resources that cost money while they run. Delete them when you are done.

PowerShell:

```powershell
./deploy/aks/infra.ps1     # a resource group, a container registry, and an AKS cluster
./deploy/aks/deploy.ps1    # build and push the image, then deploy k8s/books.yaml
./deploy/aks/down.ps1      # delete everything
```

Bash:

```bash
deploy/aks/infra.sh
deploy/aks/deploy.sh
deploy/aks/down.sh
```

The default resource group is `tlk4908-books`, in `eastus2`. Change the defaults with parameters in PowerShell, or with environment variables in bash, for example `LOCATION=westus3 deploy/aks/infra.sh`.

`deploy` tags the image with the current commit and deploys it to the namespace `books`. The Service gets a public HTTP address with an Azure DNS name, and the script prints it.

## The demo

The talk reviews two pull requests into the `start` branch, from `demo/agent-pr` and `demo/agent-fix`. `demo/README.md` on the `main` branch explains them.

| Branch | What it holds |
| --- | --- |
| `main` | The finished site. All four checks pass. |
| `start` | The team's files, before the agent's work. The demo pull requests go into this branch. |
| `demo/agent-pr`, `demo/agent-fix` | The agent's work, as we reviewed it in the talk. |

## Book data

The book data was compiled and checked on 2026-09-26 against publisher and bookseller pages. Titles, authors, and ISBNs can change. Check the publisher page before you use the data.

`scripts/lookup-isbns.sh` reads the ISBNs in `books.json` and looks them up in Open Library. It needs `jq`. It only warns, because Open Library does not list every new book. On 2026-09-26, Open Library had no record for 5 of the 10 books.
