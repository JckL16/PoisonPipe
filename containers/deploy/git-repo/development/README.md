# Corp Infrastructure Pipeline

Development branch - TEST changes here before merging into prod.

## Overview

Landing place for changes before being pushed to prod. 

## Structure

| File | Description |
|------|-------------|
| `playbook.yml` | Ansible playbook with deployment tasks |
| `inventory.ini` | Target host inventory |

## Workflow

1. Develop and test on this branch (or your own)
2. Open a pull request to prod
3. All PRs MUST be reviewed and approved by Jack before merging

## TODO

- [ ] Add rollback support
- [ ] Improve deployment logging
- [ ] AI PR checker?
