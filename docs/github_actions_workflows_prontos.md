# Workflows de CI/CD prontos para publicação manual

Estes dois ficheiros YAML foram escritos e validados (sintaxe YAML confirmada),
mas **não puderam ser enviados automaticamente** para este repositório a
partir do ambiente de desenvolvimento, devido a uma restrição de permissões
do GitHub ("GitHub App" sem o escopo `workflows`). Esta é uma restrição de
segurança da própria plataforma GitHub, independente de qualquer defeito do
projecto.

**Para activar a automação completa (deploy automático a cada `push` para
`main`)**, um administrador do repositório deve:

1. Aceder a https://github.com/nevesmoxi/IED
2. Clicar em `Add file → Create new file`
3. No campo do nome do ficheiro, escrever: `.github/workflows/deploy-pages.yml`
4. Colar o conteúdo da secção "1. deploy-pages.yml" abaixo
5. Fazer *commit directly to the main branch*
6. Repetir os passos 2-5 para `.github/workflows/deploy-firebase.yml` com o
   conteúdo da secção "2. deploy-firebase.yml" abaixo

---

## 1. deploy-pages.yml

```yaml
name: Publicar IED Reader (GitHub Pages)
on:
  push:
    branches: [main]
  workflow_dispatch: {}
permissions:
  contents: read
  pages: write
  id-token: write
concurrency:
  group: "pages"
  cancel-in-progress: false
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.35.4"
          channel: "stable"
      - name: Instalar dependências
        run: flutter pub get
      - name: Compilar Web (release)
        run: flutter build web --release --base-href "/IED/"
      - name: Preservar materiais auxiliares (vídeo, flyer, manual)
        run: |
          mkdir -p staging
          cp -r build/web/. staging/
          for f in anuncio_ied_reader.mp4 ied_tutorial_final.mp4 \
                   download_video.html download_flyer.html \
                   flyer_ied.png flyer_ied.jpg \
                   manual_do_utilizador.html manual_do_utilizador.pdf; do
            if [ -f "docs/$f" ]; then cp "docs/$f" staging/; fi
          done
          touch staging/.nojekyll
      - uses: actions/upload-pages-artifact@v3
        with:
          path: staging
  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

**Nota**: este workflow referencia ficheiros auxiliares (vídeo, flyer, manual)
a partir de uma pasta `docs/` na raiz do repositório. Se esses ficheiros não
existirem nesse local no repositório, essa etapa simplesmente não os copia
(não falha o build) — ajustar os caminhos conforme a organização real do
repositório, se necessário.

Depois de activado, também é necessário o mesmo passo manual único descrito
no README: `Settings → Pages → Source: GitHub Actions` (em vez de "Deploy
from a branch", já que este workflow usa o mecanismo moderno baseado em
Actions, não o branch `gh-pages`).

---

## 2. deploy-firebase.yml

```yaml
name: Publicar IED Reader (Firebase Hosting)
on:
  push:
    branches: [main]
  workflow_dispatch: {}
permissions:
  contents: read
jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.35.4"
          channel: "stable"
      - name: Instalar dependências
        run: flutter pub get
      - name: Compilar Web (release)
        run: flutter build web --release
      - name: Publicar no Firebase Hosting
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: "${{ secrets.GITHUB_TOKEN }}"
          firebaseServiceAccount: "${{ secrets.FIREBASE_SERVICE_ACCOUNT }}"
          projectId: "${{ vars.FIREBASE_PROJECT_ID }}"
          channelId: live
```

**Pré-requisitos antes deste workflow funcionar** (configurar em
`Settings → Secrets and variables → Actions` do repositório):
- **Secret** `FIREBASE_SERVICE_ACCOUNT`: conteúdo integral do JSON da conta
  de serviço, obtido em
  `Firebase Console → Definições do projecto → Contas de serviço → Gerar
  nova chave privada`
- **Variable** `FIREBASE_PROJECT_ID`: o ID do projecto Firebase

**Importante**: este workflow usa `--base-href` padrão (raiz `/`), correcto
para Firebase Hosting. **Não deve ser reutilizada a mesma build do GitHub
Pages** (que usa `--base-href "/IED/"`) — os dois destinos exigem builds
distintas.
