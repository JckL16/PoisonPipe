# Corp Infrastructure Pipeline

Automated deployment pipeline for Corp internal systems.

## Overview

Pushes to this branch are deployed automatically.

**Make sure to test code on development before running, this code will be deployed on the LIVE SYSTEM**

Jack is the final authority before any changes are pushed here.

## Structure

| File | Description |
|------|-------------|
| `playbook.yml` | Ansible playbook with deployment tasks |
| `inventory.ini` | Production host inventory |

## Hosts

| Host | Role |
|------|------|
| flag-holder | Primary production server |
