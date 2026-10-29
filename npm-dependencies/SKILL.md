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

Do not bypass these restrictions with alternative download tools, flags, or package managers. If an explicit install is denied or fails, report the blocker.
