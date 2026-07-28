#!/usr/bin/env bash
# Run with sudo. Interactively downloads and installs selected monitoring components.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RUN_USER="${RUN_USER:-ubuntu}"
ARCH="linux-amd64"

PROMETHEUS_VERSION="2.42.0"
NODE_EXPORTER_VERSION="1.5.0"
GRAFANA_VERSION="13.1.1"
# Build ID from the GitHub release assets page (changes per release).
GRAFANA_BUILD_ID="29761037902"
PUSHGATEWAY_VERSION="1.6.0"
LOKI_VERSION="3.7.4"
ALLOY_VERSION="1.18.0"
POSTGRES_EXPORTER_VERSION="0.15.0"
REDIS_EXPORTER_VERSION="1.65.0"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT

SELECTED=()

prepare_dir() {
  local dir="$1"
  mkdir -p "${dir}"
  chown -R "${RUN_USER}:${RUN_USER}" "${dir}"
}

download() {
  local url="$1"
  local output="$2"
  wget -q --show-progress -O "${output}" "${url}"
}

has_component() {
  local name="$1"
  local item
  for item in "${SELECTED[@]}"; do
    [[ "${item}" == "${name}" ]] && return 0
  done
  return 1
}

add_component() {
  local name="$1"
  has_component "${name}" || SELECTED+=("${name}")
}

prompt_yes_no() {
  local prompt="$1"
  local default="${2:-n}"
  local answer hint="y/N"

  [[ "${default}" == "y" ]] && hint="Y/n"

  while true; do
    read -r -p "${prompt} [${hint}]: " answer
    answer="${answer:-${default}}"
    case "${answer,,}" in
      y | yes) return 0 ;;
      n | no) return 1 ;;
      *) echo "  Please answer y or n." ;;
    esac
  done
}

select_components() {
  echo "Select monitoring components to install."
  echo

  echo "Metrics:"
  prompt_yes_no "  prometheus (time series database)" && add_component prometheus
  prompt_yes_no "  node-exporter (host metrics)" && add_component node-exporter
  prompt_yes_no "  pushgateway (push-based metrics)" && add_component pushgateway
  prompt_yes_no "  postgres-exporter (PostgreSQL metrics)" && add_component postgres-exporter
  prompt_yes_no "  redis-exporter (Redis metrics)" && add_component redis-exporter

  echo
  echo "Logs:"
  local want_loki=false want_alloy=false
  prompt_yes_no "  loki (log storage)" && { add_component loki; want_loki=true; }
  prompt_yes_no "  alloy (ship nginx logs to loki)" && { add_component alloy; want_alloy=true; }

  if [[ "${want_alloy}" == true && "${want_loki}" == false ]]; then
    echo "  Note: alloy requires loki — including loki."
    add_component loki
  fi

  echo
  echo "Visualization:"
  prompt_yes_no "  grafana (dashboards)" && add_component grafana
}

install_prometheus() {
  prepare_dir /opt/prometheus
  download "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.${ARCH}.tar.gz" \
    "${WORKDIR}/prometheus.tar.gz"
  tar -xzf "${WORKDIR}/prometheus.tar.gz" --strip-components=1 -C /opt/prometheus
  chmod +x /opt/prometheus/prometheus /opt/prometheus/promtool
}

install_node_exporter() {
  prepare_dir /opt/node_exporter
  download "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.${ARCH}.tar.gz" \
    "${WORKDIR}/node_exporter.tar.gz"
  tar -xzf "${WORKDIR}/node_exporter.tar.gz" --strip-components=1 -C /opt/node_exporter
  chmod +x /opt/node_exporter/node_exporter
}

install_pushgateway() {
  prepare_dir /opt/pushgateway
  download "https://github.com/prometheus/pushgateway/releases/download/v${PUSHGATEWAY_VERSION}/pushgateway-${PUSHGATEWAY_VERSION}.${ARCH}.tar.gz" \
    "${WORKDIR}/pushgateway.tar.gz"
  tar -xzf "${WORKDIR}/pushgateway.tar.gz" --strip-components=1 -C /opt/pushgateway
}

install_postgres_exporter() {
  prepare_dir /opt/postgres_exporter
  download "https://github.com/prometheus-community/postgres_exporter/releases/download/v${POSTGRES_EXPORTER_VERSION}/postgres_exporter-${POSTGRES_EXPORTER_VERSION}.${ARCH}.tar.gz" \
    "${WORKDIR}/postgres_exporter.tar.gz"
  tar -xzf "${WORKDIR}/postgres_exporter.tar.gz" --strip-components=1 -C /opt/postgres_exporter
  chmod +x /opt/postgres_exporter/postgres_exporter
}

install_redis_exporter() {
  prepare_dir /opt/redis_exporter
  download "https://github.com/oliver006/redis_exporter/releases/download/v${REDIS_EXPORTER_VERSION}/redis_exporter-v${REDIS_EXPORTER_VERSION}.${ARCH}.tar.gz" \
    "${WORKDIR}/redis_exporter.tar.gz"
  tar -xzf "${WORKDIR}/redis_exporter.tar.gz" --strip-components=1 -C /opt/redis_exporter
  chmod +x /opt/redis_exporter/redis_exporter
}

install_loki() {
  prepare_dir /opt/loki
  prepare_dir /var/lib/loki
  download "https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-${ARCH}.zip" \
    "${WORKDIR}/loki.zip"
  unzip -q "${WORKDIR}/loki.zip" -d /opt/loki
  mv /opt/loki/loki-${ARCH} /opt/loki/loki
  chmod +x /opt/loki/loki
  cp "${SCRIPT_DIR}/loki-config.yaml" /opt/loki/
  chown "${RUN_USER}:${RUN_USER}" /opt/loki/loki-config.yaml
}

install_alloy() {
  prepare_dir /opt/alloy
  prepare_dir /var/lib/alloy
  download "https://github.com/grafana/alloy/releases/download/v${ALLOY_VERSION}/alloy-${ARCH}.zip" \
    "${WORKDIR}/alloy.zip"
  unzip -q "${WORKDIR}/alloy.zip" -d /opt/alloy
  mv /opt/alloy/alloy-${ARCH} /opt/alloy/alloy
  chmod +x /opt/alloy/alloy
  cp "${SCRIPT_DIR}/config.alloy" /opt/alloy/
  chown "${RUN_USER}:${RUN_USER}" /opt/alloy/config.alloy
}

install_grafana() {
  local deb="grafana_${GRAFANA_VERSION}_${GRAFANA_BUILD_ID}_linux_amd64.deb"

  echo "  Downloading Grafana from GitHub (~280MB)..."
  download "https://github.com/grafana/grafana/releases/download/v${GRAFANA_VERSION}/${deb}" \
    "${WORKDIR}/${deb}"

  DEBIAN_FRONTEND=noninteractive apt-get install -y adduser libfontconfig1 musl
  dpkg -i "${WORKDIR}/${deb}" || DEBIAN_FRONTEND=noninteractive apt-get install -f -y

  cp "${SCRIPT_DIR}/grafana.ini" /etc/grafana/grafana.ini
  chown root:grafana /etc/grafana/grafana.ini
  chmod 640 /etc/grafana/grafana.ini

  # The .deb enables grafana-server; we use our own unit file instead.
  systemctl disable --now grafana-server 2>/dev/null || true
}

install_component() {
  case "$1" in
    prometheus) install_prometheus ;;
    node-exporter) install_node_exporter ;;
    pushgateway) install_pushgateway ;;
    postgres-exporter) install_postgres_exporter ;;
    redis-exporter) install_redis_exporter ;;
    loki) install_loki ;;
    alloy) install_alloy ;;
    grafana) install_grafana ;;
    *)
      echo "Unknown component: $1" >&2
      exit 1
      ;;
  esac
}

enable_services() {
  local component
  for component in "${SELECTED[@]}"; do
    cp "${SCRIPT_DIR}/${component}.service" /etc/systemd/system/
  done

  systemctl daemon-reload

  for component in "${SELECTED[@]}"; do
    systemctl enable --now "${component}"
  done
}

main() {
  if [[ ! -t 0 ]]; then
    echo "This script must be run interactively (stdin is not a terminal)." >&2
    echo "Run: sudo bash ${SCRIPT_DIR}/download.sh" >&2
    exit 1
  fi

  select_components

  if [[ ${#SELECTED[@]} -eq 0 ]]; then
    echo
    echo "Nothing selected. Exiting."
    exit 0
  fi

  echo
  echo "Installing: ${SELECTED[*]}"
  echo

  local component
  for component in "${SELECTED[@]}"; do
    echo "==> ${component}"
    install_component "${component}"
  done

  echo
  echo "==> Enabling systemd services"
  enable_services

  echo
  echo "Done. Enabled: ${SELECTED[*]}"
}

main "$@"
