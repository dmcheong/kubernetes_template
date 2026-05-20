#!/usr/bin/env bash

echo "[INFO] Surveillance des events non normaux..."
echo "[INFO] CTRL+C pour quitter"

kubectl get events -A -w | grep -v "Normal"