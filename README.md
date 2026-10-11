# IED Reader — Introdução ao Estudo do Direito Angolano

Manual digital de Direito Angolano, da autoria de **Neves Moxi**. Aplicativo
Flutter multiplataforma (Web/PWA, Android e iOS), com conteúdo jurídico
cifrado em repouso (AES-256-CBC) e disponibilizado por via de leitura online.

## 🌐 Publicação Web (PWA)

A aplicação está preparada para publicação em dois destinos de alojamento
estático, correspondentes às duas secções abaixo.

### GitHub Pages (pronto — falta uma activação manual única)
Já existe no repositório remoto um branch `gh-pages` com a build de produção
compilada (`--base-href /IED/`). Falta apenas um passo manual, de
realização única, por parte de um administrador do repositório:

1. Aceder a `Settings → Pages` em https://github.com/nevesmoxi/IED/settings/pages
2. Em "Build and deployment" → "Source", seleccionar **Deploy from a branch**
3. Em "Branch", seleccionar `gh-pages` e a pasta `/ (root)` → **Save**

Após este passo, o GitHub publica automaticamente o conteúdo do branch
`gh-pages` em: `https://nevesmoxi.github.io/IED/`

**Actualizações futuras**: cada vez que o conteúdo do livro ou da aplicação
for alterado, é necessário reconstruir e republicar o branch `gh-pages`
manualmente (via `flutter build web --release --base-href "/IED/"` seguido
de push desse resultado para o branch `gh-pages`), uma vez que a automação
total por GitHub Actions (ficheiros `.github/workflows/*.yml`) não pôde ser
adicionada a este repositório a partir deste ambiente — ver nota técnica
abaixo.

> **Nota técnica — automação por GitHub Actions**: foram preparados dois
> workflows completos (`deploy-pages.yml` e `deploy-firebase.yml`) que
> automatizariam a publicação a cada `push` para `main`. O GitHub recusou
> a sua criação a partir deste ambiente por restrição de permissões do
> GitHub App instalado (falta do escopo `workflows`, independente de outras
> permissões administrativas já concedidas). Esta restrição só pode ser
> ultrapassada por um utilizador humano autenticado directamente no GitHub
> (não pelo token do ambiente). Os ficheiros YAML completos encontram-se
> disponíveis para serem colados manualmente em
> `Actions → set up a workflow yourself`, caso se deseje activar esta
> automação — consultar o histórico de desenvolvimento ou solicitar o
> conteúdo exacto dos dois ficheiros.

### Firebase Hosting (opcional, requer configuração única)
A configuração (`firebase.json`) e o script de publicação
(`scripts/deploy_firebase.sh`) já estão prontos no repositório. Requer que
um utilizador com acesso execute, numa máquina local ou neste ambiente:

1. Criar um projecto gratuito em https://console.firebase.google.com
2. Autenticar: `firebase login`
3. Publicar:
   ```bash
   FIREBASE_PROJECT_ID=<id-do-projecto> ./scripts/deploy_firebase.sh
   ```

A partir daí, o link definitivo será `https://<project-id>.web.app`.

Caso se deseje automatizar também este destino via GitHub Actions, o
workflow `deploy-firebase.yml` já está escrito e validado, mas sujeito à
mesma restrição de permissões descrita acima — requer colagem manual via
GitHub web UI e configuração de `FIREBASE_SERVICE_ACCOUNT` (secret) e
`FIREBASE_PROJECT_ID` (variable) em `Settings → Secrets and variables →
Actions`.

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
