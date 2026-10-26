---
name: chromium-chrome-devtools
description: Use installed Chromium and chrome-devtools to automate, inspect, and debug the creds web app against a local server during implementation, including browser compatibility experiments available to runners.
---

# Chromium + Chrome DevTools CLI

Use the installed Chromium binary with the `chrome-devtools` CLI for browser automation, inspection, and debugging.

## Creds implementation scope

Implementation runners do not have access to real user devices or deployment networks. Use Chromium and a local server for the proposal's initial compatibility experiments and browser integration tests. Record what was actually exercised and any unsupported APIs or tooling limitations. Local or virtual-authenticator results do not establish real-device/passkey-provider compatibility or deployment UDP reachability. Do not block runner implementation on access to unavailable real devices; leave those checks explicitly identified for later manual verification.

The insecure-certificate browser setting below supports the test environment; it is not a substitute for testing WebTransport certificate-hash pinning. Include explicit mismatch/negative tests and report if the browser flags prevent meaningful validation. Do not weaken production TLS/pinning behavior to make tests pass.

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

Do not use the same profile directory for simultaneous Chromium instances. For creds, preserve the proposal's no-persistent-application-storage requirement; a test profile is not permission to store keys or application credentials.

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

Use the local creds server as the primary test target. The supplied external smoke-test target works with the recommended configuration when reachable:

```sh
chrome-devtools navigate_page 1 --url https://tines.tbuckley.dev
```

It loads with the title `Tines — A place for work to move`. This is a navigation example, not a requirement to access an external service for local creds tests.

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

Example against the test page:

```sh
chrome-devtools take_snapshot 1
# The sign-in button was uid 1_5 in the observed snapshot.
chrome-devtools click 1 1_5 --includeSnapshot true
# The dialog email field then appeared as uid 2_6.
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
  --dump-dom https://tines.tbuckley.dev
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
