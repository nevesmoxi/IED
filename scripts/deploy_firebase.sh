#!/usr/bin/env bash
# Script de publicação do "IED Reader" no Firebase Hosting.
#
# PRÉ-REQUISITOS (a executar uma única vez por si, fora deste sandbox ou
# interativamente dentro dele):
#   1. firebase login
#      -> abre o browser para autenticação com a sua conta Google.
#   2. firebase projects:create ied-reader-angola  (ou use um projecto já
#      existente seu no Firebase Console: https://console.firebase.google.com)
#   3. Substitua PROJECT_ID abaixo (ou exporte a variável FIREBASE_PROJECT_ID)
#      pelo ID real do projecto Firebase criado.
#
# Depois de concluídos os passos 1–3, basta correr este script sempre que
# quiser publicar uma nova versão do aplicativo.
set -euo pipefail

PROJECT_ID="${FIREBASE_PROJECT_ID:-SUBSTITUA_PELO_SEU_PROJECT_ID}"
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ "$PROJECT_ID" = "SUBSTITUA_PELO_SEU_PROJECT_ID" ]; then
  echo "❌ Defina o PROJECT_ID (edite este script ou exporte FIREBASE_PROJECT_ID)."
  echo "   Crie um projecto gratuito em: https://console.firebase.google.com"
  exit 1
fi

cd "$APP_DIR"

echo "🧹 A limpar e a reconstruir a build Web de produção..."
flutter clean
flutter pub get
flutter build web --release

echo "🔗 A associar o projecto Firebase: $PROJECT_ID"
firebase use "$PROJECT_ID" --add 2>/dev/null || firebase use "$PROJECT_ID"

echo "🚀 A publicar no Firebase Hosting..."
firebase deploy --only hosting --project "$PROJECT_ID"

echo "✅ Publicação concluída. O seu aplicativo está disponível em:"
echo "   https://$PROJECT_ID.web.app"
echo "   https://$PROJECT_ID.firebaseapp.com"
