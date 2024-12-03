#!/bin/bash

# Шлях до файлу
FILE_PATH="dynamic/http.routers.docker-localhost.yml"

# Перевірка на існування файлу
if [ ! -f "$FILE_PATH" ]; then
  echo "File $FILE_PATH does not exist. Creating it..."

  # Створення директорії, якщо вона не існує
  mkdir -p $(dirname "$FILE_PATH")

  # Вміст файла
  FILE_CONTENT=$(cat <<EOF
http:
  routers:
    docker-localhost:
      # rule: Host(\`example.com\`)
      rule: HostRegexp(\`{host:.+}\`)
      service: blue@file
EOF
)

  # Створення файла
  echo "$FILE_CONTENT" > "$FILE_PATH"

  echo "File $FILE_PATH created successfully."
else
  echo "File $FILE_PATH already exists."
fi
