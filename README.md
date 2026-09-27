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


## Planted problems in `demo/agent-pr`

- The book data includes an invented book. `./mvnw -B verify` finds the bad ISBN check digit.
- The API returns `author` as one string instead of `authors` as an array. `scripts/api-diff.sh` finds it.
- The app adds `org.apache.commons:commons-text:1.9`. `scripts/scan.sh` finds CVE-2022-42889 through OSV.
- The Dockerfile builds with Java 25 and runs with Java 21. `scripts/smoke-test.sh` shows the container problem. Running the jar on JDK 21 also fails with `UnsupportedClassVersionError`.

## Book data

The book data was compiled and checked on 2026-09-26 against publisher and bookseller pages.

Titles, authors, and ISBNs can change. Check the publisher page before you use the data.

`scripts/lookup-isbns.sh` reads ISBNs from `books.json` and checks Open Library. It needs `jq`. It only warns, because Open Library does not list every recent book. On 2026-09-26, Open Library had no record for 5 of the 10 books.
