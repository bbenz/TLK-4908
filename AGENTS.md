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

## Rules you must not change
- Never edit `api/openapi.yaml` or
  `BookDataRulesTest` to make a check pass.
  If you think a rule is wrong, say so in the
  pull request and ask a person.

## Book data
- Add a book only if you can link to its page
  on the publisher's site.
- Never guess or make up an ISBN. If you are
  not sure, leave the book out and say why.

## Containers and Kubernetes
- `compose.yaml` runs the site on port 8080
  with a health check.
- `k8s/books.yaml` holds a Deployment and a
  Service, both named `books`. Use the image
  `books:local`. The deploy scripts replace it.
- Do not set a namespace in `k8s/`.
