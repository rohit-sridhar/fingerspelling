CONTRIBUTING

Thank you for contributing to the fingerspelling HMM codebase. This file describes how to make changes, run basic checks, and prepare commits.

1) Basic workflow
- Create a branch for your work.
- Make small, focused commits with meaningful messages.
- Include the Co-authored-by trailer in commits made by the assistant:
  Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>

2) Shell scripts
- Add set -euo pipefail at the top of scripts and quote variables.
- Run shellcheck: shellcheck scripts/*.sh and resolve warnings.
- Avoid sudo or host-specific usernames in committed scripts; accept overrides via env vars.

3) Documentation
- Update README.md for any new scripts or configuration options.
- Do not commit large datasets; provide download scripts or pointers instead.

4) Safety and secrets
- Never commit credentials, passwords, or private keys.
- Use environment variables or external config files (document example values in README).

5) Style and testing
- Python code (if added) should follow common linters: flake8/black, and include unit tests where appropriate.
- For shell scripts, prefer clear usage/help output and input validation.

6) Commit message template
- Begin with a short summary line.
- Optionally add a detailed body describing the rationale and any breaking changes.
- End the message with the Co-authored-by trailer shown above.

7) Questions
- Open an issue or contact the repository owner for guidance on larger changes.

Thank you!