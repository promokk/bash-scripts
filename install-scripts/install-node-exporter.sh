#!/bin/bash

# Пример выполнения скрипта:
# sudo bash install-node-exporter.sh

# Скачиваем (версии -> https://github.com/prometheus/node_exporter/releases/)
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz

# Распаковка архива
tar xzvf node_exporter-*.t*gz

# Добавляем пользователя
useradd --no-create-home --shell /bin/false node_exporter

# Копируем файлы в /usr/local/bin
cp node_exporter-*.linux-amd64/node_exporter /usr/local/bin

# Меняем владельца на нового пользователя (node_exporter)
chown node_exporter: /usr/local/bin/node_exporter

# Создаём сервис node_exporter
cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Запускаем сервис node_exporter
systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter

