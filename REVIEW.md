# Review rules

GitHub Copilot code review reads this file. People who review here follow it too.

- Treat the pull request description as a claim. Look for the commands and the real output that `AGENTS.md` asks for.
- `api/openapi.yaml` is a published contract. A change must keep existing clients working.
- Each new book needs a working link to its page on the publisher's site.
- Say so when a change touches the files that judge the code: `api/openapi.yaml`, `BookDataRulesTest.java`, `scripts/`, `.github/`, `AGENTS.md`, and this file.
- For each problem, point to the line, say what breaks, and suggest a fix.
