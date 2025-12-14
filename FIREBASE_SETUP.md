# Guia de Deploy - Firebase

## 📋 Passo a Passo para Configurar o Firebase

### 1. Configuração Inicial do Projeto Firebase

1. Acesse o [Firebase Console](https://console.firebase.google.com/)
2. Crie um novo projeto ou selecione um existente
3. Ative o Google Sign-In:
   - Authentication → Sign-in method
   - Ative "Google"

### 2. Configuração do SHA-1 (Android)

Execute no terminal para obter o SHA-1:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

No Firebase Console:

- Project Settings → Your apps → Android app
- Adicione o SHA-1 fingerprint
- Baixe o `google-services.json` atualizado
- Coloque em `android/app/google-services.json`

### 3. Deploy das Regras do Firestore

O arquivo `firestore.rules` já está configurado. Para fazer deploy:

```bash
firebase deploy --only firestore:rules
```

### 4. Estrutura do Banco de Dados

O Firestore criará automaticamente as coleções ao adicionar o primeiro alimento:

```
Firestore Database:
└── users/
    └── {userId}/              # UID do usuário autenticado
        └── food_logs/         # Subcoleção de alimentos
            └── {documentId}   # ID auto-gerado
                ├── name: string
                ├── calories: int
                └── date: timestamp
```

### 5. Regras de Segurança Implementadas

```javascript
// Apenas o usuário autenticado pode acessar seus dados
allow read, write: if request.auth != null && request.auth.uid == userId;

// Validações:
- name: 1-100 caracteres
- calories: 1-10000 kcal
- date: timestamp válido
```

### 6. Verificar Configuração

Antes de testar:

1. ✅ `google-services.json` está em `android/app/`
2. ✅ SHA-1 adicionado no Firebase Console
3. ✅ Google Sign-In ativado no Authentication
4. ✅ Regras do Firestore deployadas
5. ✅ `flutter pub get` executado

### 7. Testar o App

```bash
# Limpar build anterior
flutter clean

# Instalar dependências
flutter pub get

# Rodar no dispositivo/emulador
flutter run
```

### 8. Monitorar Logs (Opcional)

No Firebase Console:

- **Authentication** → Users: Ver usuários logados
- **Firestore Database** → Data: Ver dados salvos
- **Authentication** → Sign-in method: Verificar configuração

### 9. Comandos Úteis Firebase CLI

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Inicializar projeto (se necessário)
firebase init

# Deploy de regras
firebase deploy --only firestore:rules

# Ver logs
firebase functions:log
```

### 10. Troubleshooting

#### Erro: "Google Sign-In failed"

- Verifique se o SHA-1 está correto
- Baixe novamente o `google-services.json`
- Limpe o cache: `flutter clean`

#### Erro: "Permission denied"

- Verifique as regras do Firestore
- Confirme que o usuário está autenticado
- Veja os logs no Firebase Console

#### Erro: "Plugin not found"

- Execute: `flutter pub get`
- Rebuild: `flutter clean && flutter pub get`

### 11. Configuração de Produção

Para release, gere um keystore de produção:

```bash
keytool -genkey -v -keystore ~/release.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias release
```

Obtenha o SHA-1 do keystore de release:

```bash
keytool -list -v -keystore ~/release.keystore -alias release
```

Adicione no Firebase Console e baixe novo `google-services.json`.

### 12. Referências

- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)
- [FlutterFire](https://firebase.flutter.dev/)
