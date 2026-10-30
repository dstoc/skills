---
name: npm-dependencies
description: Use before installing or running npm-based tools, or when npm, npx, or build/test commands encounter dependency installation or network errors.
---

# npm dependencies

In the agent environment, network access for dependency installation is available through the managed npm wrapper using these approved commands:

```sh
npm install
npm install -- <package-spec>
npm install --save-dev -- <package-spec>
npm install --save -- <package-spec>
```

Run installs within `$HOME`, including temporary CLI projects. `/tmp` is not shared with the network sandbox. If `npm` does not resolve to the managed wrapper, use `/opt/tools/wrappers/npm` explicitly.

Before using `npx` or `npm exec`, install any missing CLI package explicitly with an approved command, one package spec at a time. Run the command using that installed dependency. Do not rely on an implicit download.

Build/test scripts can also trigger implicit installs. If one fails, identify and explicitly install the missing dependency, then retry. An implicit-download failure does not prohibit this approved installation path.

## Handle installation failures

Distinguish policy restrictions from recoverable dependency problems:

- **ETARGET with a date cutoff:** the release-age policy excluded the requested version. Select an older compatible release that satisfies the task's version requirements. Do not disable or shorten the age restriction. If an exact required version cannot be installed, report that constraint.
- **ERESOLVE:** inspect and reconcile incompatible dependency versions within the authorized task. Do not bypass peer checks with `--force` or `--legacy-peer-deps`.
- **Working-directory or wrapper rejection:** verify the current directory is within HOME and the command matches an approved form. Use the supported directory and command; do not change sandbox policy.
- **Explicit policy or access denial:** report the exact command and sanitized error. Do not use alternate download tools, flags, registries, or package managers to bypass it.

Continue with permitted, compatible solutions. Escalate when none remains, the cause is unclear, or resolving it requires a user decision. Record the actual selected versions and relevant verification results.

These installation constraints describe the agent environment. Do not assume they prohibit a suitable lockfile-based install such as `npm ci` in GitHub-hosted CI.
