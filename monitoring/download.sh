# need sudo for the following
mkdir -p /opt/prometheus
chown -R poiasd:poiasd /opt/prometheus
mkdir -p /opt/node_exporter
chown -R poiasd:poiasd /opt/node_exporter
mkdir -p /opt/grafana
chown -R poiasd:poiasd /opt/grafana

cd /tmp

wget https://github.com/prometheus/prometheus/releases/download/v2.42.0/prometheus-2.42.0.linux-amd64.tar.gz
tar -xvzf prometheus-2.42.0.linux-amd64.tar.gz  --strip-components=1 -C /opt/prometheus
chmod +x /opt/prometheus/prometheus
chmod +x /opt/prometheus/promtool

wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar -xvzf node_exporter-1.5.0.linux-amd64.tar.gz --strip-components=1 -C /opt/node_exporter
chmod +x /opt/node_exporter/node_exporter

wget https://dl.grafana.com/enterprise/release/grafana-enterprise-9.3.6.linux-amd64.tar.gz
tar -xzvf grafana-enterprise-9.3.6.linux-amd64.tar.gz --strip-components=1 -C /opt/grafana

# Need to modify grafana.ini!

# Make service files , then:
systemctl daemon-reload
systemctl start node-exporter
systemctl start prometheus
