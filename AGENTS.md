# AGENTS.md

## Before you open a pull request
- Run `scripts/install-tools.sh` once.
- Run the four checks: `./mvnw -B verify`,
  `scripts/api-diff.sh`, `scripts/scan.sh`,
  and `scripts/smoke-test.sh`.
- Paste each command and its real output in
  the pull request description.
- List anything you did not test.
- Keep one change in each pull request.

## Book data
- Add a book only if you can link to its page
  on the publisher's site.
- Never guess or make up an ISBN. If you are
  not sure, leave the book out and say why.
