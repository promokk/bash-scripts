#!/bin/bash

# Пример выполнения скрипта:
# bash sshKeyConnect.sh {fileServer} {userName}

# Файл со списком серверов
fileServer=$1

# Пользователь для подключения по ssh
userName=$2

# Удаление всех строк, содержащих только пробелы:
sed '/^[[:space:]]*$/d' $fileServer > fileTmp; mv fileTmp $fileServer

# Массив серверов
mapfile -t arrServer < $fileServer

# Нужно выполнить, если ранее не был сгенерирован ssh-ключ
# ssh-keygen

for server in ${arrServer[@]}
do
	echo "Copying ssh-key --> $server"
	ssh-copy-id $userName@$server
done

echo 'Done!'
