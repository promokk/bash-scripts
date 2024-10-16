#!/bin/bash

# Пример выполнения скрипта:
# sudo bash install-victoriametrics.sh {dir}

# Параметры
# Путь к данным
dir=$1

# Скачиваем (версии -> https://github.com/VictoriaMetrics/VictoriaMetrics/releases)
curl -LO https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v1.101.0/victoria-metrics-linux-amd64-v1.101.0.tar.gz

# Распаковка архивов
tar zxf victoria-metrics-linux-amd64-*.tar.gz -C /usr/local/bin/

# Добавляем пользователей
useradd --no-create-home --shell /usr/sbin/nologin victoria_metrics

# Создаем каталог для идентификатора процесса
mkdir -p /run/victoriametrics

# Меняем владельца на нового пользователя (victoria_metrics)
chown victoria_metrics:victoria_metrics $dir /run/victoriametrics

# Настраиваем сервис
cat << EOF > /etc/systemd/system/victoriametrics.service
[Unit]
Description=VictoriaMetrics
After=network.target

[Service]
Type=simple
User=victoria_metrics
PIDFile=/run/victoriametrics/victoriametrics.pid
ExecStart=/usr/local/bin/victoria-metrics-prod -storageDataPath $dir -retentionPeriod 30d -httpListenAddr=:8428 -enableTCP6
ExecStop=/bin/kill -s SIGTERM $MAINPID
StartLimitBurst=5
StartLimitInterval=0
Restart=on-failure
RestartSec=1

[Install]
WantedBy=multi-user.target
EOF

# Запускаем сервис victoria-metrics
systemctl daemon-reload
systemctl start victoriametrics
systemctl enable victoriametrics