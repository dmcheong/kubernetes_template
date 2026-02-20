#!/usr/bin/env bash

# ce script permet la vérification de la dernire version de SealedSecret
# ou l'install
# ou met à jour la dernière version indiquée
# installation via bitnami?
# à vérifier

# check if sealedsecret exist if not install
get_latest_github_tag() {
  # Récupère le tag de la dernière release via redirection HTTP
  # ex: v0.34.0
  local repo="$1"
  curl -fsSI "https://github.com/${repo}/releases/latest" \
    | tr -d '\r' \
    | awk -F': ' 'tolower($1)=="location"{print $2}' \
    | awk -F/ '{print $NF}' \
    | tail -n1
}

# ---------------- Paths ----------------
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"
export PATH="$LOCAL_BIN:$PATH"

# ---------------- Config ----------------
REPO="bitnami-labs/sealed-secrets"
MIN_KUBESEAL_VERSION="0.34.0"   # ajuste si tu veux

echo "==> Détection dernière release sealed-secrets..."
LATEST_TAG="$(get_latest_github_tag "$REPO")"
if [[ -z "${LATEST_TAG:-}" ]]; then
  echo "ERREUR: impossible de récupérer la dernière release GitHub."
  exit 1
fi
LATEST_VERSION="${LATEST_TAG#v}"
echo "==> Dernière release détectée: $LATEST_TAG"
echo

# =========================================================
# 1) kubeseal (CLI) - install/upgrade
# =========================================================
echo "==> Vérification de kubeseal"

need_install_kubeseal=0

if ! command -v kubeseal >/dev/null 2>&1; then
  need_install_kubeseal=1
else
  CURRENT_KUBESEAL_VERSION="$(
    kubeseal --version 2>/dev/null \
    | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' \
    | head -n1
  )"

  if [[ -z "${CURRENT_KUBESEAL_VERSION:-}" ]]; then
    need_install_kubeseal=1
  elif version_lt "$CURRENT_KUBESEAL_VERSION" "$MIN_KUBESEAL_VERSION"; then
    need_install_kubeseal=1
  fi
fi

if [[ "$need_install_kubeseal" -eq 1 ]]; then
  echo "==> Installation/upgrade de kubeseal -> $LATEST_TAG"
  curl -fsSL \
    "https://github.com/${REPO}/releases/download/${LATEST_TAG}/kubeseal-linux-amd64" \
    -o "$LOCAL_BIN/kubeseal"
  chmod +x "$LOCAL_BIN/kubeseal"
  echo "==> kubeseal installé: $("$LOCAL_BIN/kubeseal" --version 2>/dev/null || true)"
else
  echo "==> kubeseal OK: $(kubeseal --version 2>/dev/null || true)"
fi
echo

# =========================================================
# 2) sealed-secrets controller + CRD - install if missing
# =========================================================
echo "==> Vérification du controller sealed-secrets (kube-system)"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "ERREUR: kubectl introuvable. Installe kubectl avant."
  exit 1
fi

# Détection simple : deployment sealed-secrets-controller dans kube-system
if kubectl -n kube-system get deploy sealed-secrets-controller >/dev/null 2>&1; then
  echo "==> Controller déjà installé."
else
  echo "==> Installation controller + CRD depuis $LATEST_TAG"
  kubectl apply -f "https://github.com/${REPO}/releases/download/${LATEST_TAG}/controller.yaml"
fi

echo
echo "==> Terminé."
echo "   - kubeseal: $(command -v kubeseal 2>/dev/null || true)"
echo "   - controller: kube-system/sealed-secrets-controller"
