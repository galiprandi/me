# API Captures

This directory stores captured HTTP requests (as curl commands) from each job platform's profile editing endpoints.

## How captures work

1. **Browser session**: Use `mcp1_browser_*` (Chrome perfil German) to navigate and interact with the platform
2. **Capture cookies**: `mcp1_browser_evaluate(() => document.cookie)` extracts session cookies
3. **Capture network requests**: `mcp1_browser_network_requests()` logs all API calls made during profile edits
4. **Export as curl**: `mcp1_browser_network_request(index)` gets full headers + body of a specific request
5. **Save here**: Each platform gets a `.sh` file with reusable curl commands

## Files

| File | Platform | Status |
|---|---|---|
| `indeed.sh` | Indeed (profile.indeed.com) | Pending |
| `bumeran.sh` | Bumeran (bumeran.com.ar) | Pending |
| `computrabajo.sh` | Computrabajo (computrabajo.com.ar) | Pending |
| `glassdoor.sh` | Glassdoor (glassdoor.com) | Pending |
| `linkedin.sh` | LinkedIn (linkedin.com) | Pending |
| `remote-co.sh` | Remote.co | Pending |
| `remoteok.sh` | RemoteOK | Pending |
| `workana.sh` | Workana | Pending |

## Usage

```bash
# Source the platform file to get functions
source .agents/skills/job-search/api-captures/indeed.sh

# Get current profile
indeed_get_profile

# Update experience
indeed_update_experience "$EXP_ID" "$TITLE" "$COMPANY" "$START_MONTH" "$START_YEAR" "$END_MONTH" "$END_YEAR" "$DESCRIPTION"
```

## Future: MCP multi-plataforma

These captures are the foundation for a custom MCP server that exposes:
- `update_profile(platform, data)`
- `add_experience(platform, data)`
- `get_profile(platform)`
- `align_all_platforms()` — bulk sync from CV
