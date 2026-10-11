# IED Reader — Introdução ao Estudo do Direito Angolano

Manual digital de Direito Angolano, da autoria de **Neves Moxi**. Aplicativo
Flutter multiplataforma (Web/PWA, Android e iOS), com conteúdo jurídico
cifrado em repouso (AES-256-CBC) e disponibilizado por via de leitura online.

## 🌐 Publicação Web (PWA)

O aplicativo é publicado automaticamente como Progressive Web App sempre que
há um `push` para o branch `main`, através de dois workflows independentes
em `.github/workflows/`:

### GitHub Pages (activo por omissão)
`deploy-pages.yml` compila o projecto Flutter para Web e publica no GitHub
Pages do repositório. Não requer qualquer configuração adicional — corre
automaticamente a cada push para `main`.

**Link público**: `https://nevesmoxi.github.io/IED/`

### Firebase Hosting (opcional, requer configuração única)
`deploy-firebase.yml` publica a mesma build no Firebase Hosting. Fica
inactivo até serem configurados os seguintes segredos/variáveis no
repositório (`Settings → Secrets and variables → Actions`):

1. Criar um projecto gratuito em https://console.firebase.google.com
2. Gerar uma conta de serviço: `Definições do projecto → Contas de serviço
   → Gerar nova chave privada` (ficheiro JSON)
3. No GitHub: `Settings → Secrets and variables → Actions`
   - **Secret** `FIREBASE_SERVICE_ACCOUNT`: colar o conteúdo integral do JSON
   - **Variable** `FIREBASE_PROJECT_ID`: o ID do projecto Firebase
4. No separador "Actions" do repositório, executar manualmente o workflow
   "Publicar IED Reader (Firebase Hosting)" uma primeira vez
   (`workflow_dispatch`), ou simplesmente aguardar o próximo push a `main`

A partir daí, o link definitivo será `https://<project-id>.web.app`.

Alternativamente, pode publicar manualmente a partir de uma máquina local
autenticada com `firebase login`, usando o script `scripts/deploy_firebase.sh`.

## 📲 Instalar como aplicativo (PWA)

- **Android (Chrome)**: abrir o link → menu (⋮) → "Instalar aplicativo"
- **iPhone (Safari)**: abrir o link → ícone de partilha → "Adicionar ao Ecrã
  Principal"

## 🧪 Desenvolvimento local

```bash
flutter pub get
flutter run -d chrome          # desenvolvimento com hot reload
flutter build web --release    # build de produção
```

## 🔒 Protecção de conteúdo

O texto integral do livro é armazenado cifrado em
`assets/data/book.enc` e só é descriptografado em memória, em tempo de
execução, nunca sendo escrito em disco — ver `lib/services/book_decryptor.dart`.
