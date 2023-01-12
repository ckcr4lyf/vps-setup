cd ~
mkdir -p .apps
cd .apps

wget https://github.com/prometheus/prometheus/releases/download/v2.37.0/prometheus-2.37.0.linux-amd64.tar.gz
tar -xvzf prometheus-2.37.0.linux-amd64.tar.gz
cd prometheus-2.37.0.linux-amd64
chmod +x prometheus promtool

cd ../
wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0-rc.0/node_exporter-1.4.0-rc.0.linux-amd64.tar.gz
tar -xvzf node_exporter-1.4.0-rc.0.linux-amd64.tar.gz
cd node_exporter-1.4.0-rc.0.linux-amd64
chmod +x node_exporter

cd ../
wget https://dl.grafana.com/enterprise/release/grafana-enterprise-9.0.6.linux-amd64.tar.gz
tar -xvf grafana-enterprise-9.0.6.linux-amd64.tar.gz
cd grafana-9.0

# Make service files , then:
systemctl daemon-reload
systemctl start node-exporter
systemctl start prometheus
