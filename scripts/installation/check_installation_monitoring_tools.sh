#!/usr/bin/env bash
# list of all scripts about monitoring tools => check install or upgrade tools

# function to comparison tools, use like this:
# version_lt "CURRENT_VERSION_TOOL" "TOOL_MINIMUM_VERSION"
version_lt() {
  # true (0) si $1 < $2
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$2" ]
}

echo "==> Exécution du script de vérification des outils de monitoring:"
echo

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# prometheus + grafana
source "$SCRIPT_DIR/install_prometheus.sh"

# open-telemetry
source "$SCRIPT_DIR/install_opentelemetry.sh"

echo
echo "==> Les services de monitoring Prometheus, Grafana et OpenTelemetry sont à jour."
echo "==> La vérification de tous les outils est terminée (installation + mise à jour)."
echo