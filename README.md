# Calculadora Nutricional

Aplicativo Flutter para controle de calorias com autenticação Google OAuth e Firebase Firestore.

## 🚀 Funcionalidades

- ✅ Autenticação com Google OAuth
- ✅ Registro de alimentos e calorias
- ✅ Visualização do total de calorias
- ✅ Deletar alimentos (deslizar para a esquerda)
- ✅ Dados isolados por usuário
- ✅ Sincronização em tempo real com Firebase
- ✅ Logout seguro

## 📱 Estrutura do Projeto

```
lib/
├── controllers/
│   ├── auth_controller.dart      # Gerencia estado de autenticação
│   └── food_controller.dart      # Gerencia alimentos e calorias
├── models/
│   └── food_item.dart            # Modelo de dados de alimento
├── services/
│   ├── auth_service.dart         # Serviço de autenticação Google
│   └── database.dart             # Serviço de banco de dados Firestore
├── views/
│   ├── home.dart                 # Tela principal com lista de alimentos
│   ├── login.dart                # Tela de login
│   └── widgets/
│       └── add_food_dialog.dart  # Dialog para adicionar alimentos
├── firebase_options.dart         # Configurações do Firebase
└── main.dart                     # Entry point do app
```

## 🔧 Configuração

### Pré-requisitos

1. Flutter SDK 3.9.2+
2. Conta Firebase
3. Configuração do Google Sign-In no Firebase Console

### Instalação

1. Clone o repositório e instale as dependências:

```bash
flutter pub get
```

2. Configure o Firebase:

```bash
flutterfire configure
```

3. Deploy das regras de segurança do Firestore:

```bash
firebase deploy --only firestore:rules
```

### Configuração do Google Sign-In (Android)

1. Obtenha o SHA-1 do seu keystore:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

2. Adicione o SHA-1 no Firebase Console:
   - Project Settings → Your apps → Android app
   - Add SHA-1 fingerprint

3. Baixe o novo `google-services.json` e coloque em `android/app/`

## 🔐 Regras de Segurança Firestore

As regras de segurança estão definidas em `firestore.rules`:

- Cada usuário só pode acessar seus próprios dados
- Validação de tipos e limites de dados
- Proteção contra acesso não autorizado

Estrutura dos dados:

```
users/{userId}/food_logs/{documentId}
  ├── name: string (1-100 caracteres)
  ├── calories: int (1-10000)
  └── date: timestamp
```

## 📦 Dependências Principais

```yaml
dependencies:
  firebase_core: ^4.2.1
  firebase_auth: ^6.1.2
  cloud_firestore: ^6.1.0
  google_sign_in: ^6.3.0
  provider: ^6.1.2
```

## 🎯 Como Usar

1. **Login**: Toque em "Entrar com Google" e selecione sua conta
2. **Adicionar Alimento**: Toque no botão + e preencha nome e calorias
3. **Deletar Alimento**: Deslize o item para a esquerda e confirme
4. **Logout**: Toque no ícone de logout no canto superior direito

## 🛠️ Melhorias Implementadas

- ✅ Correção de warnings do Flutter Analyzer
- ✅ Tratamento robusto de erros com mensagens específicas
- ✅ BuildContext safety em operações assíncronas
- ✅ Funcionalidade de deletar alimentos com confirmação
- ✅ Regras de segurança Firestore com validação de dados
- ✅ Mensagens de erro amigáveis ao usuário

## 🐛 Tratamento de Erros

O app trata os seguintes cenários:

### Autenticação

- Conta desabilitada
- Credenciais inválidas
- Login não habilitado
- Erros de rede

### Banco de Dados

- Permissão negada
- Serviço indisponível
- Timeout de conexão
- Item não encontrado
