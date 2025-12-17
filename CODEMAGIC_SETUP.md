# 🚀 Codemagic CI/CD Setup для ConnectoSphere

## ✅ Что уже готово:
- ✅ Apple Developer Portal Integration создан
- ✅ GitHub репозиторий подключен
- ✅ codemagic.yaml файл создан

---

## 📋 Шаги для завершения настройки:

### 1️⃣ Загрузить GoogleService-Info.plist как секрет

**В Codemagic Dashboard:**

1. Перейди в **ConnectoSphere** → **Environment variables**
2. Нажми **Add variable**
3. Создай переменную:
   - **Variable name**: `GOOGLE_SERVICE_INFO_PLIST`
   - **Variable value**: Вставь содержимое файла `GoogleService-Info.plist`
   - **Variable type**: Choose **File**
   - **Secure**: ✅ (включи)
   - **Group**: `firebase` (создай новую группу)

**Или через файл (рекомендуется):**

1. Перейди в **Files** → **Add file**
2. Upload: `GoogleService-Info.plist`
3. Mark as **Secure**

---

### 2️⃣ Обновить codemagic.yaml (добавить Firebase config)

После секции `environment:` добавь:

```yaml
environment:
  groups:
    - firebase # Группа с GoogleService-Info.plist
  ios_signing:
    distribution_type: app_store
    bundle_identifier: com.example.ConnectoSphere.ConnectoSphere
```

И в секцию `scripts` перед "Install dependencies":

```yaml
- name: Add Firebase config
  script: |
    echo "$GOOGLE_SERVICE_INFO_PLIST" > $CM_BUILD_DIR/ConnectoSphere/GoogleService-Info.plist
```

---

### 3️⃣ Получить App Store Connect ID

**Найди Apple ID приложения:**

1. Открой [App Store Connect](https://appstoreconnect.apple.com)
2. **My Apps** → Выбери **ConnectoSphere** (или создай новое приложение)
3. В URL будет: `...apps/1234567890/...`
4. Скопируй это число (например: `1234567890`)
5. В `codemagic.yaml` замени:
   ```yaml
   APP_STORE_APPLE_ID: 1234567890 # Твой ID
   ```

---

### 4️⃣ Настроить Email уведомления

В `codemagic.yaml` замени:

```yaml
publishing:
  email:
    recipients:
      - your-email@example.com # Замени на свой email
```

---

### 5️⃣ Проверить Bundle ID и Provisioning Profile

**В Apple Developer Portal:**

1. Перейди в [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list)
2. Найди или создай **App ID**:
   - Bundle ID: `com.example.ConnectoSphere.ConnectoSphere`
   - Включи capabilities: **Push Notifications** (если нужно)
3. Создай **App Store Distribution Certificate** (если нет)
4. Создай **App Store Provisioning Profile**

**Codemagic автоматически:**
- Загрузит сертификаты
- Создаст provisioning profiles
- Настроит code signing

---

### 6️⃣ Закоммитить и запушить codemagic.yaml

```bash
cd /Users/simonbakhanets/IdeaProjects/ConnectoSphere

git add codemagic.yaml
git commit -m "Add Codemagic CI/CD configuration"
git push origin main
```

---

### 7️⃣ Запустить первый build

**В Codemagic Dashboard:**

1. Нажми **Check for configuration file** (справа сверху)
2. Выбери workflow: **ios-workflow**
3. Нажми **Start new build**
4. Выбери branch: **main**
5. **Start build**

---

## ⚙️ Настройка Webhooks (автоматические builds)

**В Codemagic:**

1. **ConnectoSphere** → **Webhooks**
2. **Enable webhook**
3. Настрой triggers:
   - ✅ **Push to branch**: `main`, `develop`
   - ✅ **Pull request**: любой branch
   - ✅ **Tag**: `v*.*.*`

**Теперь билды запускаются автоматически при:**
- Push в main/develop
- Создании Pull Request
- Создании тега (например, `v1.0.0`)

---

## 📱 Workflows объяснение:

### `ios-workflow` (Main Build)
- Запускается при push в main
- Собирает IPA
- Автоматически загружает в **TestFlight**
- Опционально отправляет на App Store review

### `ios-pr-workflow` (PR Build)
- Запускается при Pull Request
- Только build для проверки
- Не создает IPA
- Не deploy

---

## 🔐 Секреты и переменные окружения

### Обязательные:
- ✅ `GOOGLE_SERVICE_INFO_PLIST` - Firebase config
- ✅ Apple Developer Portal Integration (уже настроено)

### Опциональные (если нужны):
```yaml
environment:
  vars:
    API_KEY: "your-api-key"
    SERVER_URL: "https://connectosphere112.site/RKx577C7"
```

---

## 📊 Мониторинг builds

**В Dashboard:**
- **Builds** → Все билды
- **Logs** → Детальные логи
- **Artifacts** → Скачать IPA

**Email уведомления:**
- ✅ Success builds
- ✅ Failed builds
- Линк на скачивание IPA

---

## 🚨 Troubleshooting

### ❌ Build failed: "No provisioning profile"

**Решение:**
1. Проверь Bundle ID в Xcode совпадает с codemagic.yaml
2. В Apple Developer Portal создай Provisioning Profile
3. В Codemagic пересоздай integration:
   ```
   Settings → Integrations → Apple Developer Portal → Reconnect
   ```

### ❌ Build failed: "GoogleService-Info.plist not found"

**Решение:**
1. Загрузи файл в Codemagic Files
2. Добавь script для копирования файла (см. шаг 2)

### ❌ Build failed: "Firebase SDK not found"

**Решение:**
Добавь в scripts:
```yaml
- name: Resolve SPM dependencies
  script: |
    xcodebuild -resolvePackageDependencies -project ConnectoSphere.xcodeproj
```

---

## 🎯 Автоматический release flow

### Создать релиз:

```bash
# 1. Увеличь версию в Xcode
# 2. Закоммить
git add .
git commit -m "Release v1.0.0"

# 3. Создать тег
git tag v1.0.0
git push origin v1.0.0

# 4. Codemagic автоматически:
# - Соберет IPA
# - Загрузит в TestFlight
# - Отправит email
```

---

## 📦 Artifacts (что сохраняется)

После каждого build:
- ✅ **IPA файл** - готов для загрузки
- ✅ **dSYM files** - для crash reports
- ✅ **Build logs** - для debugging
- ✅ **.app bundle** - для тестирования

---

## ⏱️ Build время

**Примерное время:**
- Clean build: ~15-20 минут
- Incremental build: ~8-12 минут
- PR check: ~5-8 минут

**Codemagic лимиты (Free tier):**
- 500 минут/месяц
- 1 concurrent build

---

## 🎉 Готово!

После настройки:
1. Push код → автоматический build
2. Build успешен → IPA в TestFlight
3. Тестируй через TestFlight
4. Готов к App Store submit

---

## 📚 Полезные ссылки

- [Codemagic Docs](https://docs.codemagic.io/)
- [iOS code signing](https://docs.codemagic.io/yaml-code-signing/ios-code-signing/)
- [Publishing to App Store](https://docs.codemagic.io/yaml-publishing/app-store-connect/)

