# need sudo for the following
mkdir -p /opt/prometheus
chown -R ubuntu:ubuntu /opt/prometheus
mkdir -p /opt/grafana
chown -R ubuntu:ubuntu /opt/grafana
mkdir -p /opt/pushgateway
chown -R ubuntu:ubuntu /opt/pushgateway
mkdir -p /opt/loki
chown -R ubuntu:ubuntu /opt/loki
mkdir -p /opt/promtail
chown -R ubuntu:ubuntu /opt/promtail

# Exporters
mkdir -p /opt/node_exporter
chown -R ubuntu:ubuntu /opt/node_exporter
mkdir -p /opt/postgres_exporter
chown -R ubuntu:ubuntu /opt/postgres_exporter
mkdir -p /opt/redis_exporter
chown -R ubuntu:ubuntu /opt/redis_exporter

cd /tmp

wget https://github.com/prometheus/prometheus/releases/download/v2.42.0/prometheus-2.42.0.linux-amd64.tar.gz
tar -xvzf prometheus-2.42.0.linux-amd64.tar.gz  --strip-components=1 -C /opt/prometheus
chmod +x /opt/prometheus/prometheus
chmod +x /opt/prometheus/promtool

wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar -xvzf node_exporter-1.5.0.linux-amd64.tar.gz --strip-components=1 -C /opt/node_exporter
chmod +x /opt/node_exporter/node_exporter

wget https://dl.grafana.com/enterprise/release/grafana-enterprise-11.2.1.linux-amd64.tar.gz
tar -xzvf grafana-enterprise-11.2.1.linux-amd64.tar.gz --strip-components=1 -C /opt/grafana

wget https://github.com/prometheus/pushgateway/releases/download/v1.6.0/pushgateway-1.6.0.linux-amd64.tar.gz
tar -xzvf pushgateway-1.6.0.linux-amd64.tar.gz --strip-components=1 -C /opt/pushgateway

wget https://github.com/grafana/loki/releases/download/v3.0.1/loki-linux-amd64.zip
unzip loki-linux-amd64.zip -d /opt/loki
mv /opt/loki/loki-linux-amd64 /opt/loki/loki
cp loki-config.yaml /opt/loki/

wget https://github.com/grafana/loki/releases/download/v2.9.0/promtail-linux-amd64.zip
unzip promtail-linux-amd64.zip -d /opt/promtail
mv /opt/promtail/promtail-linux-amd64 /opt/promtail/promtail
cp promtail-config.yaml /opt/promtail/

wget https://github.com/prometheus-community/postgres_exporter/releases/download/v0.15.0/postgres_exporter-0.15.0.linux-amd64.tar.gz
tar -xvzf postgres_exporter-0.15.0.linux-amd64.tar.gz  --strip-components=1 -C /opt/postgres_exporter
chmod +x /opt/postgres_exporter/postgres_exporter

wget https://github.com/oliver006/redis_exporter/releases/download/v1.65.0/redis_exporter-v1.65.0.linux-amd64.tar.gz
tar -xvzf redis_exporter-v1.65.0.linux-amd64.tar.gz  --strip-components=1 -C /opt/redis_exporter
chmod +x /opt/redis_exporter/redis_exporter

# Need to modify grafana.ini!
# Make service files , then:
systemctl daemon-reload
systemctl start node-exporter
systemctl start prometheus
systemctl start pushgateway
systemctl start loki
systemctl start promtail
systemctl start postgres-exporter
systemctl start redis-exporter