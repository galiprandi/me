# tools/

Node.js scripts (.mjs) for the job-search skill.

## Scripts

| Script | Purpose | Status |
|---|---|---|
| `cv-to-profile.mjs` | Parse `src/pages/index.astro` and generate PROFILE.md experiences section | Pending |
| `align-platforms.mjs` | Bulk align all platforms using api-captures/*.sh | Pending |
| `capture-api.mjs` | Helper to extract cookies + network requests from Chrome MCP | Pending |

## Usage

```bash
node .agents/skills/job-search/tools/cv-to-profile.mjs
```
