#!/usr/bin/env bash
REMOTE_NAME=onedrive
rclone --vfs-cache-mode writes mount ${REMOTE_NAME}: ~/onedrive
