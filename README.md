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
```
## Private registry modes
| Mode     | Privilege | How it works | Pros | Cons |
|----------|-----------|--------------|------|------|
| `rewrite` *(default)* | none | Pulls and tags the images from the private registry. | No sudo, works per project | Needs list of images in `private-registry/config.example.com` |
| `daemon` | sudo | Adds mirror to `/etc/docker/daemon.json` (Docker’s native support) | Mirrors *everything*, simplest | Requires linux host + root + Docker restart |

Switch later by editing `.env.ddev-private-registry` → change `PR_MODE=` then run `ddev restart` (sudo for daemon).

## Configuring which images are mirrored (rewrite)
Edit `.ddev/private-registry/config.example.yml`:
```yaml
images:
  - ddev/ddev-webserver
  - myorg/custom:8.3
```

## Uninstall
```bash
ddev add‑on remove ddev-private-registry
```
