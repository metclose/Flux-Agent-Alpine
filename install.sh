#!/bin/sh
set -e

# ── 参数：按 panel → secret 顺序 ──
PANEL_ADDR="${1:-${PANEL_ADDR:-}}"
SECRET="${2:-${SECRET:-}}"

if [ -z "$PANEL_ADDR" ] || [ -z "$SECRET" ]; then
  echo "usage: sh install.sh <panel_addr> <secret>"
  exit 1
fi

INSTALL_DIR="${INSTALL_DIR:-/etc/flux_agent}"
BIN_NAME="${BIN_NAME:-flux_agent}"
SVC_NAME="${SVC_NAME:-flux_agent}"
CONFIG_NAME="${CONFIG_NAME:-config.json}"
GOST_CONFIG_NAME="${GOST_CONFIG_NAME:-gost.json}"
REPO_BASE="${REPO_BASE:-https://github.com/bqlpfy/flux-panel/releases/download/2.0.7-beta}"

# ── 架构检测 ──
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)  BIN_ARCH="amd64" ;;
  aarch64) BIN_ARCH="arm64" ;;
  *) echo "unsupported arch: $ARCH"; exit 1 ;;
esac

# ── 下载二进制到目标目录的临时名，成功后 mv 成正式名 ──
mkdir -p "$INSTALL_DIR"
TMP_BIN="${INSTALL_DIR}/.${BIN_NAME}.download"
cleanup() { rm -f "$TMP_BIN"; }
trap cleanup EXIT INT TERM

echo "Downloading gost-${BIN_ARCH} ..."
curl -fsSL "${REPO_BASE}/gost-${BIN_ARCH}" -o "$TMP_BIN"
chmod +x "$TMP_BIN"
mv -f "$TMP_BIN" "${INSTALL_DIR}/${BIN_NAME}"
trap - EXIT INT TERM

# ── 生成 config.json（每次安装都重建）──
cat > "${INSTALL_DIR}/${CONFIG_NAME}" <<EOF
{
  "addr": "${PANEL_ADDR}",
  "secret": "${SECRET}"
}
EOF
chmod 600 "${INSTALL_DIR}/${CONFIG_NAME}"

# ── gost.json：已存在则跳过，不存在才建空对象 ──
if [ -f "${INSTALL_DIR}/${GOST_CONFIG_NAME}" ]; then
  echo "skip existing ${GOST_CONFIG_NAME}"
else
  echo '{}' > "${INSTALL_DIR}/${GOST_CONFIG_NAME}"
  chmod 600 "${INSTALL_DIR}/${GOST_CONFIG_NAME}"
fi

# ── 写 OpenRC 服务（不写日志文件）──
cat > "/etc/init.d/${SVC_NAME}" <<EOF
#!/sbin/openrc-run

name="${SVC_NAME}"
description="Flux Agent forwarding service"
command="${INSTALL_DIR}/${BIN_NAME}"
command_args=""
directory="/etc/flux_agent"
command_user="root"
command_background="yes"
pidfile="/run/${SVC_NAME}.pid"

depend() {
    need net
}
EOF
chmod +x "/etc/init.d/${SVC_NAME}"

# ── 启动并设开机自启 ──
rc-service "$SVC_NAME" stop 2>/dev/null || true
rc-service "$SVC_NAME" start
rc-update add "$SVC_NAME" default

echo "Done. Service: ${SVC_NAME}"
echo "Check: rc-service ${SVC_NAME} status"
