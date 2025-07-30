#!/bin/bash

# TODO: перевести на англ, вынести параметры в аргументы запуска

ORG="netcracker"       # Название организации
LANGUAGE="Java"         # Язык программирования
TOPIC="core"                # Топик
TARGET_DIR="repos"        # Директория для клонирования

mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR" || exit

echo "Поиск репозиториев в организации $ORG (язык: $LANGUAGE, топик: $TOPIC)..."
REPOS=$(gh repo list --limit 1000 "$ORG" --json name,primaryLanguage,repositoryTopics --jq ".[] | select(.primaryLanguage.name == \"$LANGUAGE\" and (.repositoryTopics[]?.name | contains(\"$TOPIC\"))) | .name" | sort -u)

if [ -z "$REPOS" ]; then
  echo "Не найдено подходящих репозиториев."
  exit 1
fi

echo "Найдены репозитории:"
echo "$REPOS"

echo "Клонирование..."
echo "$REPOS" | while read -r repo; do
  if [ ! -d "$repo" ]; then  # Проверяем, что репозиторий ещё не склонирован
    gh repo clone "$ORG/$repo"
  else
    echo "Репо $repo уже существует, пропускаем."
  fi
done

echo "Готово! Репозитории сохранены в директорию: $TARGET_DIR"
