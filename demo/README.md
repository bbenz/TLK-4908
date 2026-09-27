# Demo script

1. Create a branch from `start`.
2. Give the agent the prompt in `demo/prompt.md`.
3. Open a pull request against `start`.
4. Watch `review-gate` run.

Fallback:

- Open a pull request from `demo/agent-pr` into `start`.
- The fix is the commit "Fix the review gate findings" on `main`.

If the agent follows `AGENTS.md`, it may run the checks and fix problems itself before it opens the pull request. That is the goal. Use `demo/agent-pr` to show what the gate catches.

## Before the talk

- Run the gate on `main` one more time, because new vulnerabilities come out often.
- If `main` fails, move Spring Boot to the newest patch release or rebuild the image.
- Start a gate run for the `demo/agent-pr` pull request early, because a full run takes a few minutes.
- Check the book data against the publisher pages.
