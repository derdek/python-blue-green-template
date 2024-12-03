#!/bin/bash

set -e
set -u
set -x

git pull --rebase

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if docker-compose is installed
if command_exists docker-compose; then
    DOCKER_COMPOSE_CMD="docker-compose"
# Check if docker compose is installed
elif command_exists docker; then
    DOCKER_COMPOSE_CMD="docker compose"
else
    echo "Neither docker-compose nor docker compose is installed."
    exit 1
fi

# Функція для перевірки, чи працює сервіс
check_service() {
  local host=$1
  local response=$(curl -s -o /dev/null -w "%{http_code}" http://$host/version)
  if [ "$response" -eq 200 ]; then
    return 0
  else
    return 1
  fi
}

bash check_dynamic_main.sh

# Визначаємо, який контейнер потрібно оновити
current_active=$(grep 'service:' dynamic/http.routers.docker-localhost.yml | awk '{print $2}')

bash write_last_commit_hash_to_env.sh

if [ "$current_active" == "blue@file" ]; then
  # Оновлюємо green контейнер
  $DOCKER_COMPOSE_CMD build backend-green
  $DOCKER_COMPOSE_CMD up -d --no-deps backend-green
  new_service="green"
  new_host="green.docker.localhost"
else
  # Оновлюємо blue контейнер
  $DOCKER_COMPOSE_CMD build backend-blue
  $DOCKER_COMPOSE_CMD up -d --no-deps backend-blue
  new_service="blue"
  new_host="blue.docker.localhost"
fi

# Перевіряємо, чи працює новий контейнер
for attempt in {1..5}; do
  sleep $attempt
  if check_service $new_host; then
    # Накатуємо міграцію за допомогою Alembic
    $DOCKER_COMPOSE_CMD run --rm backend-$new_service alembic upgrade head
    # Перевіряємо, чи міграція пройшла успішно
    if [ $? -eq 0 ]; then
      # Переключаємо трафік на новий контейнер
      sed -i "s/$current_active/$new_service@file/" dynamic/http.routers.docker-localhost.yml
      echo "Traffic switched to $new_service"
      break
    else
      echo "Migration failed."
      # Відкатуємо зміни, якщо новий контейнер не працює
      $DOCKER_COMPOSE_CMD down --no-deps backend-$new_service
      # Повертаємо трафік на попередній активний сервіс
      sed -i "s/$new_service@file/$current_active/" dynamic/http.routers.docker-localhost.yml
      exit 1
    fi
  else
    echo "Attempt $attempt failed. Retrying..."
  fi
done

if [ $attempt -eq 5 ]; then
  echo "All attempts failed. Rolling back..."
  # Відкатуємо зміни, якщо новий контейнер не працює
  $DOCKER_COMPOSE_CMD down --no-deps backend-$new_service
  # Повертаємо трафік на попередній активний сервіс
  sed -i "s/$new_service@file/$current_active/" dynamic/http.routers.docker-localhost.yml
  exit 1
fi

echo "Cleaning up unused Docker images..."
docker image prune -f

echo "Deployment completed successfully"
