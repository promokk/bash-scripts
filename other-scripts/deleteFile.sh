#!/bin/bash

# Пример выполнения скрипта:
# bash deleteFile.sh {fileServer} {userName} {rmFile}

# Файл со списком серверов
fileServer=$1

# Пользователь для подключения по ssh
userName=$2

# Объект удаления
rmFile=$3

# Удаление всех строк, содержащих только пробелы:
sed '/^[[:space:]]*$/d' $fileServer > fileTmp; mv fileTmp $fileServer

# Массив серверов
mapfile -t arrServer < $fileServer

for server in ${arrServer[@]}
do
	echo "The deletion process on the server: $server"
	ssh $userName@$server "rm -r $rmFile"
done

echo 'Done!'
