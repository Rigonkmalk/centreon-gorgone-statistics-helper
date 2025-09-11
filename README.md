# centreon-gorgone-statistics-helper

This script is for DEV only, it's not a tools for production env.

This script automates debugging setup and statistics collection from Centreon’s **Gorgone daemon**, primarily for diagnostic or troubleshooting purposes.

---

### 📁 Configuration
- Reads `/etc/default/gorgoned` to extract current `severity` level (via 5th `=` split — *likely a typo; should be `-f2`*).
- Assumes Gorgone HTTP API runs on `localhost:8085` (verify port in `/etc/centreon-gorgone/config.d/40-gorgoned.yaml`).

---

### ⚙️ Functions

#### `check_debug()`
- If severity is `"error"`, switches it to `"debug"` and restarts `gorgoned.service`.
- Waits 5s for HTTP server to stabilize post-restart.

#### `token_request()`
- Triggers engine stats collection via Gorgone API → returns async `token`.
- Waits 5s for async task completion.
- Fetches & pretty-prints task logs using token: `GET /api/log/<token>` (requires `jq`).

---

### 🔍 Post-Collection Checks
- Lists running `gorgone` processes (`ps -aux | grep gorgone`).
- Extracts last 300 lines of `[statistics]` module logs → saves to `/tmp/log_gorgone_statistics.txt`.

---

### ⚠️ Notes / Assumptions
- Requires: `curl`, `jq`, `systemctl`, `grep`, `sed`, `ps`, `tail`.
- Port `8085` may vary — confirm in Gorgone config.
- Parsing `cut -d= -f5` likely incorrect — should be `-f2` to get value after first `=`.
- No error handling — assumes services/files exist and commands succeed.

---

✅ Use this script to force debug mode, trigger stats, capture diagnostics, and verify process/module health.
