#!/bin/bash

# Пример выполнения скрипта:
# sudo bash install-postgresql.sh {dir} \*

# Параметры
# Путь к данным
dir=$1
# По каким ip сервер должен принимать подключения
# host = * - сервер принимает входящие подключения по любому ip
host=$2
# Порт
port=5432
# Часовой пояс
timezone='Europe/Moscow'
# Путь до конфигурационного файла
conf_file_db='/etc/postgresql/16/main/postgresql.conf'

# Настройка репозитория
apt install -y postgresql-common
/usr/share/postgresql-common/pgdg/apt.postgresql.org.sh

# Установка postgresql-16
apt install postgresql-16

# Останавливаем сервис
systemctl stop postgresql@16-main.service

# Переносим все данные в новую директорию
rsync -av /var/lib/postgresql/16/main $dir

# Меняем владельца директории
chown -R postgres:postgres $dir

# Меняем название старой дирктории (В дальнейшем можно удалить. Сначало нужно проверить, что копирование прошло успешно и сервер запускается)
mv /var/lib/postgresql/16/main /var/lib/postgresql/16/main.bak

# Меняем файл конфигурации БД (postgresql.conf)
sed -i -e "s@data_directory = '.*'@data_directory = '$dir/main'@g;
        s@#listen_addresses = '.*'@listen_addresses = '$host'@g;
        s@port = .*@port = $port@g;
        s@log_timezone = '.*'@log_timezone = '$timezone'@g;
	s@^timezone = '.*'@timezone = '$timezone'@g" $conf_file_db

# Запускаем сервис
systemctl restart postgresql@16-main.service
