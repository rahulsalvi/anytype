#!/bin/bash

set -euo pipefail

[ -f .env ] && source .env

declare -A deps
deps["gum"]="github.com/charmbracelet/gum@latest"
deps["get-authkey"]="tailscale.com/cmd/get-authkey@latest"

for dep in "${!deps[@]}"; do
	if ! command -v "${dep}" &>/dev/null; then
		echo "Installing ${dep}"
		go install "${deps[${dep}]}"
	fi
done

if tailscale ip anytype >/dev/null 2>&1; then
	echo "anytype seems to already exist. You should remove it before continuing"
	echo "https://login.tailscale.com/admin/machines"
	exit 1
fi

[ ! -v MINIO_USER ] && MINIO_USER=$(gum input --placeholder="Enter the minio username")
if [ -z "$MINIO_USER" ]; then
	echo "Enter a valid username"
	exit 1
fi
export MINIO_USER

[ ! -v MINIO_PASSWORD ] && MINIO_PASSWORD=$(gum input --password --placeholder="Enter the minio password")
if [ -z "$MINIO_PASSWORD" ]; then
	echo "Enter a valid password"
	exit 1
fi
export MINIO_PASSWORD

echo "Enter your tailscale API client ID"
echo "https://login.tailscale.com/admin/settings/oauth"
TS_API_CLIENT_ID=$(gum input --password)
export TS_API_CLIENT_ID

echo "Enter your tailscale API client secret"
echo "https://login.tailscale.com/admin/settings/oauth"
TS_API_CLIENT_SECRET=$(gum input --password)
export TS_API_CLIENT_SECRET

echo "Generating tailscale auth keys"
TS_AUTHKEY=$(get-authkey -ephemeral -preauth -tags tag:anytype)
export TS_AUTHKEY

gum spin --title "Starting up" --show-output -- docker compose up -d --build

echo "Done!"
