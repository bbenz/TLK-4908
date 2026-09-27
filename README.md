# TLK-4908 books demo

This repo supports the talk "Reviewing AI-Written Java: Coding Assistants and a CI Gate".

It shows how a small review gate can help a team review an AI-written Java change.

## Story

The team writes three things first:

- an API contract in `api/openapi.yaml`
- data rules in `BookDataRulesTest`
- a review gate in GitHub Actions

Then an agent builds the site. The gate reviews the pull request. It checks the build, the API, dependencies, and the container.

## Branch guide

- `start`: the contract, data rules, and gate. `./mvnw verify` fails because `books.json` is not present.
- `demo/agent-pr`: the agent output. The gate finds four planted problems.
- `main`: the fixed version. The gate passes.

## Run the site locally

Use JDK 25.

```bash
./mvnw spring-boot:run
```

Open http://localhost:8080.

## Run the gate locally

Install the pinned tools first:

```bash
scripts/install-tools.sh
```

Then run the four checks:

```bash
./mvnw -B verify
scripts/api-diff.sh
scripts/scan.sh
scripts/smoke-test.sh
```

The container smoke test needs Docker. The container image scan in `scripts/scan.sh` also needs Docker. If Docker is not running, the script skips that image scan and says so.
