#!/bin/bash

# 🚀 Codemagic Quick Setup Script для ConnectoSphere

echo "🚀 Настройка Codemagic CI/CD..."
echo ""

# Проверка наличия codemagic.yaml
if [ ! -f "codemagic.yaml" ]; then
    echo "❌ Файл codemagic.yaml не найден!"
    exit 1
fi

echo "✅ codemagic.yaml найден"

# Проверка GoogleService-Info.plist
if [ ! -f "ConnectoSphere/GoogleService-Info.plist" ]; then
    echo "⚠️  GoogleService-Info.plist не найден в ConnectoSphere/"
    echo "📝 Не забудь загрузить его в Codemagic → Environment variables → Files"
else
    echo "✅ GoogleService-Info.plist найден"
fi

# Проверка git
if [ ! -d ".git" ]; then
    echo "❌ Это не git репозиторий!"
    exit 1
fi

echo "✅ Git репозиторий найден"

# Добавление файлов
echo ""
echo "📦 Добавление файлов в git..."
git add codemagic.yaml
git add CODEMAGIC_SETUP.md
git add .gitignore

# Статус
echo ""
echo "📊 Git статус:"
git status --short

# Коммит
echo ""
read -p "🤔 Закоммитить изменения? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git commit -m "Add Codemagic CI/CD configuration

- Add codemagic.yaml with iOS workflow
- Add PR build workflow
- Configure TestFlight deployment
- Add Firebase config handling
- Add setup documentation"
    
    echo ""
    echo "✅ Изменения закоммичены!"
    
    # Push
    echo ""
    read -p "🚀 Запушить в GitHub? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        BRANCH=$(git branch --show-current)
        git push origin $BRANCH
        echo ""
        echo "✅ Изменения запушены в origin/$BRANCH"
        echo ""
        echo "🎉 Готово! Теперь:"
        echo "1. Открой Codemagic Dashboard"
        echo "2. Нажми 'Check for configuration file'"
        echo "3. Запусти первый build!"
        echo ""
        echo "📚 Подробная инструкция: CODEMAGIC_SETUP.md"
    fi
else
    echo ""
    echo "⏸️  Коммит отменен. Когда будешь готов, выполни:"
    echo "   git commit -m 'Add Codemagic CI/CD configuration'"
    echo "   git push origin main"
fi

echo ""
echo "✨ Setup завершен!"

