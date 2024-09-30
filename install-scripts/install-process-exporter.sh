#!/bin/bash

# Пример выполнения скрипта:
# sudo bash install-process-exporter.sh

# Скачиваем (версии -> https://github.com/ncabatoff/process-exporter/releases/)
curl -LO https://github.com/ncabatoff/process-exporter/releases/download/v0.7.10/process-exporter-0.7.10.linux-amd64.tar.gz

# Распаковка архива
tar xzvf process-exporter-*.linux-amd64.tar.gz

# Копируем файлы
cp -rvi process-exporter-*.linux-amd64/process-exporter /usr/local/bin

# Добавляем пользователя
useradd --no-create-home --shell /bin/false process_exporter

# Создаем конфиг
cat << EOF > /etc/process-exporter.yml
process_names:
  - name: "{{.Comm}}"
    cmdline:
    - '.+'
EOF

# Создаём сервис process-exporter
cat << EOF > /etc/systemd/system/process-exporter.service
[Unit]
Description=process_exporter
Wants=network-online.target
After=network-online.target

[Service]
User=process_exporter
Type=simple
ExecStart=/usr/local/bin/process-exporter --config.path /etc/process-exporter.yml
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Запускаем сервис process-exporter
systemctl daemon-reload
systemctl start process-exporter
systemctl enable process-exporter
