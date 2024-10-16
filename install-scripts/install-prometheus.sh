#!/bin/bash

# Пример выполнения скрипта:
# sudo bash install-prometheus.sh {dir}

# Параметры
# Путь к данным
dir=$1

# Скачиваем (версии -> https://prometheus.io/download/)
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.46.0/prometheus-2.46.0.linux-amd64.tar.gz

# Распаковка архива
tar xzvf prometheus-*.t*gz

# Добавляем пользователя
useradd --no-create-home --shell /usr/sbin/nologin prometheus

# Создаём папки и копируем файлы
mkdir /etc/prometheus
mkdir $dir
cp -vi prometheus-*.linux-amd64/prometheus /usr/local/bin
cp -vi prometheus-*.linux-amd64/promtool /usr/local/bin
cp -rvi prometheus-*.linux-amd64/prometheus.yml /etc/prometheus
cp -rvi prometheus-*.linux-amd64/console_libraries /etc/prometheus
cp -rvi prometheus-*.linux-amd64/consoles /etc/prometheus
chown -Rv prometheus: /usr/local/bin/prometheus /usr/local/bin/promtool /etc/prometheus $dir

# Настраиваем сервис
cat << EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path $dir \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries
ExecReload=/bin/kill -HUP $MAINPID

[Install]
WantedBy=multi-user.target
EOF

# Меняем файл конфигурации prometheus
cat << EOF > /etc/prometheus/prometheus.yml
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  external_labels:
    server_name: prometheus01
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ['localhost:9090']
EOF

# Запускаем сервис prometheus
systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus
