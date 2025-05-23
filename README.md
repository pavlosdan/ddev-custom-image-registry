# ddev-private-registry
Easily pull DDEV container images from an authenticated **private mirror**.

## Install per‑project
```bash
ddev get gh:your‑org/ddev-private-registry  # when published
# follow prompts (select rewrite or daemon)
```

## Global install
```bash
mkdir -p ~/.ddev/plugins && cd ~/.ddev/plugins
git clone https://github.com/your-org/ddev-private-registry.git
cd ddev-private-registry
bash scripts/ask-credentials.sh      # enter creds + pick backend
bash scripts/apply-config.sh         # add sudo if you chose daemon
```
All existing DDEV projects will now honour the mirror.

## Back‑end modes
| Mode     | Privilege | How it works | Pros | Cons |
|----------|-----------|--------------|------|------|
| `rewrite` *(default)* | none | Generates a `docker-compose.override` with mirror prefixes | No sudo, works per project | Needs list of images in `private-registry.yml` |
| `daemon` | sudo | Adds mirror to `/etc/docker/daemon.json` (Docker’s native support) | Mirrors *everything*, simplest | Requires root + Docker restart |

Switch later by editing `.env` → change `BACKEND=` then run `scripts/apply-config.sh` (sudo for daemon).

## Configuring which images are mirrored (rewrite)
Edit `.ddev/private-registry.yml`:
```yaml
images:
  - ddev/*          # glob OK
  - myorg/custom:8.3
```

## Uninstall
```bash
ddev add‑on remove ddev-private-registry   # per‑project
~/.ddev/plugins/ddev-private-registry/scripts/remove.sh   # global
```
