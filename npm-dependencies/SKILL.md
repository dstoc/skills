---
name: npm-dependencies
description: Use when npm, npx, or build/test commands encounter dependency installation or network errors.
---

# npm dependencies

Network access for npm dependency installation is available through these approved commands:

```sh
npm install
npm install -- <package-spec>
npm install --save-dev -- <package-spec>
npm install --save -- <package-spec>
```

Other commands, including `npx`, `npm exec`, and build/test scripts, may attempt to download or install packages implicitly and fail due to network restrictions.

If this happens:
1. Identify the missing dependencies.
2. Install them explicitly using the approved commands above, one package spec at a time.
3. Retry the original command using the installed dependencies.

An implicit-download failure does not prohibit this approved installation path.

## Handle installation failures

Distinguish policy restrictions from recoverable dependency problems:

- **ETARGET with a date cutoff:** the release-age policy excluded the requested version. Select an older compatible release that satisfies the task's version requirements. Do not disable or shorten the age restriction. If an exact required version cannot be installed, report that constraint.
- **ERESOLVE:** inspect and reconcile incompatible dependency versions within the authorized task. Do not bypass peer checks with `--force` or `--legacy-peer-deps`.
- **Explicit policy or access denial:** report the exact command and sanitized error. Do not use alternate download tools, flags, registries, or package managers to bypass it.

Continue with permitted, compatible solutions. Escalate when none remains, the cause is unclear, or resolving it requires a user decision. Record the actual selected versions and relevant verification results.

These installation constraints describe the agent environment. Do not assume they prohibit a suitable lockfile-based install such as `npm ci` in GitHub-hosted CI.
