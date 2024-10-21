mkdir -p /opt/postgres_exporter
chown -R ubuntu:ubuntu /opt/postgres_exporter
cd /tmp

wget https://github.com/prometheus-community/postgres_exporter/releases/download/v0.15.0/postgres_exporter-0.15.0.linux-amd64.tar.gz
tar -xvzf postgres_exporter-0.15.0.linux-amd64.tar.gz  --strip-components=1 -C /opt/postgres_exporter
chmod +x /opt/postgres_exporter/postgres_exporter

# Make service file

systemctl daemon-reload
systemctl start postgres-exporter
