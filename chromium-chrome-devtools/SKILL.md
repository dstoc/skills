---
name: chromium-chrome-devtools
description: Use installed Chromium and chrome-devtools for browser automation, inspection, debugging, and local web application compatibility testing.
---

# Chromium + Chrome DevTools CLI

Use the installed Chromium binary with the `chrome-devtools` CLI for browser automation, inspection, and debugging.

## Testing scope

Use Chromium against the application or local test server relevant to the task. Record the browser version, what was exercised, and any unsupported APIs or tooling limitations. Local tests, mocks, and virtual authenticators do not establish compatibility with physical devices, browser providers, or deployment networks. Identify any checks that require later manual verification rather than claiming they passed.

The insecure-certificate browser setting below supports environments with an intercepting proxy. It is not a substitute for testing TLS or certificate-pinning requirements. Include negative tests where relevant and report when browser flags prevent meaningful validation. Never weaken production security to make tests pass.

## Installed commands

- Chromium: `/usr/bin/chromium`
- DevTools CLI: `chrome-devtools`
- Check versions with:

```sh
chromium --version
chrome-devtools --version
```

## Start the browser

Start the DevTools daemon in a persistent terminal/PTY. In this environment, detached child processes from one-shot shell commands may be reaped when the shell exits, so keep the terminal session alive.

Recommended startup:

```sh
chrome-devtools start \
  --headless true \
  --executablePath /usr/bin/chromium \
  --isolated true \
  --acceptInsecureCerts true \
  --usageStatistics false
```

When using Codex tools, create a persistent PTY with `exec_command` (`tty: true`), then use `write_stdin` to send commands and poll for output. A clean shell such as `bash --noprofile --norc` can keep the session available for commands.

`--acceptInsecureCerts true` is intentional: this environment uses an intercepting proxy whose certificate Chromium may not trust. The raw Chromium equivalent is `--ignore-certificate-errors`.

`--isolated true` gives Chromium a fresh temporary user-data directory. It prevents reuse of normal cookies, local storage, cache, and login state; state remains available during the running browser session.

The CLI defaults to an isolated profile when launched through the CLI, but pass the flag explicitly for predictable behavior. To preserve cookies and login state, use a dedicated test profile:

```sh
chrome-devtools start \
  --headless true \
  --executablePath /usr/bin/chromium \
  --userDataDir /home/user/test/.chrome-devtools-profile \
  --acceptInsecureCerts true \
  --usageStatistics false
```

Do not use the same profile directory for simultaneous Chromium instances. A persistent test profile does not override the application's security or storage requirements. Use synthetic test data and keep real credentials out of test artifacts.

## Standard workflow

Required arguments are positional. Optional arguments use `--flags`. Use `--output-format json` when parsing results programmatically.

```sh
# Find the page ID
chrome-devtools list_pages --output-format json

# Navigate the existing page
chrome-devtools navigate_page 1 --url https://example.com

# Inspect the accessibility tree and obtain element UIDs
chrome-devtools take_snapshot 1

# Run page JavaScript
chrome-devtools evaluate_script \
  '() => ({title: document.title, url: location.href})' \
  --pageId 1 --output-format json
```

Navigate to the local application URL supplied by the test server, for example:

```sh
chrome-devtools navigate_page 1 --url http://localhost:8000
```

Use the scheme and port appropriate to the application. Features requiring a secure context may need a locally configured HTTPS server. External navigation is not required for local tests.

## Input automation

Use element UIDs from a fresh `take_snapshot` result. UIDs can change after navigation or DOM updates, so take another snapshot after a significant interaction.

```sh
chrome-devtools click 1 <uid> --includeSnapshot true
chrome-devtools fill 1 <uid> 'text to enter' --includeSnapshot true
chrome-devtools type_text 1 'additional text'
chrome-devtools press_key 1 Enter --includeSnapshot true
chrome-devtools hover 1 <uid> --includeSnapshot true
chrome-devtools drag 1 <source_uid> <target_uid> --includeSnapshot true
chrome-devtools handle_dialog 1 accept
```

Example interaction (illustrative UIDs):

```sh
chrome-devtools take_snapshot 1
# Suppose the current snapshot identifies a button as 1_5.
chrome-devtools click 1 1_5 --includeSnapshot true
# Take a fresh snapshot and use the current field UID, for example 2_6.
chrome-devtools fill 1 2_6 'test@example.com' --includeSnapshot true
```

Never assume those example UIDs remain stable; inspect the current snapshot first.

## Inspection and debugging

```sh
# Viewport or full-page screenshot
chrome-devtools take_screenshot 1 --fullPage true --filePath /tmp/page.png

# Network activity
chrome-devtools list_network_requests 1
chrome-devtools list_network_requests 1 --resourceTypes fetch

# Console output
chrome-devtools list_console_messages 1
chrome-devtools list_console_messages 1 --types error

# CSS matched rules for a snapshot UID
chrome-devtools get_css_styles 1 <uid>

# Create a new page instead of reusing page 1
chrome-devtools new_page 'https://example.com'
```

## Raw Chromium fallback

For a simple HTML dump without DevTools automation:

```sh
chromium --headless --ignore-certificate-errors \
  --dump-dom http://localhost:8000
```

Use the DevTools CLI for DOM snapshots, reliable element interaction, JavaScript evaluation, screenshots, network inspection, and console inspection.

## Daemon management

```sh
chrome-devtools status
chrome-devtools stop
```

Start the daemon once per persistent terminal session; do not run `start`, `status`, or `stop` before every individual CLI command. Keep the PTY alive while working, then stop the daemon when finished.

If a command unexpectedly falls back to an error about missing Google Chrome at `/opt/google/chrome/chrome`, the daemon was not started with the explicit Chromium executable. Stop/restart it using the recommended startup command above.

Use `chrome-devtools <command> --help` for the complete command and option reference.
