#!/bin/bash

# Пример выполнения скрипта:
# sudo bash install-docker.sh {dir}

# Параметры
# Путь к данным
dir=$1
# Путь до конфигурационного файла
conf_file='/etc/docker/daemon.json'

# Обновляем список пакетов
apt update

# Устанавливаем docker
apt install docker docker.io

# Останавливаем сервис
systemctl stop docker

# Добавляем пользователей
useradd --no-create-home --shell /usr/sbin/nologin -g docker docker

# Меняем название старой дирктории (В дальнейшем можно удалить. Сначало нужно проверить, что копирование прошло успешно и сервер запускается)
mv /var/lib/docker /var/lib/docker.bak

# Создаем конфигурационный файл docker (daemon.json)
cat << EOF > $conf_file
{
	"data-root": "$dir",
	"storage-driver": "overlay2",
	"log-driver": "json-file",
	"log-opts": {
		"max-size": "10m",
		"max-file": "3"
	}
}
EOF

# Запускаем сервис
systemctl restart docker

# Меняем владельца директории
chown -R docker:docker $dir

# Устанавливаем docker-compose (версии -> https://github.com/docker/compose/releases)
curl -L "https://github.com/docker/compose/releases/download/v2.29.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose

# Добавляем файлу права на исполнение
chmod +x /usr/bin/docker-compose

# Запускаем docker-compose
/usr/bin/docker-compose --version
