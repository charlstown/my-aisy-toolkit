#!/usr/bin/env bash
#
# compute-next-tag.sh — calcula y publica el siguiente tag semver a partir
# del título de una PR mergeada a main, siguiendo la convención documentada
# en CLAUDE.md (release: -> major, feature: -> minor, fix: -> patch,
# chore: -> sin publicación).
#
# Uso: .github/scripts/compute-next-tag.sh "<título de la PR>"
#
# Debe ejecutarse dentro de un checkout con historial completo de tags
# (p. ej. actions/checkout con fetch-depth: 0).

set -euo pipefail

pr_title="${1:-}"

if [[ -z "$pr_title" ]]; then
  echo "::error::Falta el título de la PR como argumento. Uso: compute-next-tag.sh \"<título de la PR>\""
  exit 1
fi

# 1) Determinar el tipo de bump a partir del prefijo (case-insensitive).
shopt -s nocasematch
if [[ "$pr_title" =~ ^release: ]]; then
  bump="major"
elif [[ "$pr_title" =~ ^feature: ]]; then
  bump="minor"
elif [[ "$pr_title" =~ ^fix: ]]; then
  bump="patch"
elif [[ "$pr_title" =~ ^chore: ]]; then
  bump="none"
else
  echo "::error::El título de la PR \"$pr_title\" no empieza por ningún prefijo válido. Prefijos válidos: release:, feature:, fix:, chore: (case-insensitive)."
  exit 1
fi
shopt -u nocasematch

# 2) Calcular el último tag válido (estrictamente vX.Y.Z), ignorando
# cualquier otro formato de tag (legacy, pre-release, etc.).
last_tag="$(git tag -l 'v*' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1 || true)"

# 3) Calcular la nueva versión.
if [[ -z "$last_tag" ]]; then
  # No hay tag previo: aplicar reglas de versión inicial.
  case "$bump" in
    major)
      new_tag="v1.0.0"
      ;;
    minor|patch)
      new_tag="v0.1.0"
      ;;
    none)
      echo "PR title prefix is 'chore:'; no se publica ningún tag."
      exit 0
      ;;
  esac
else
  if [[ "$bump" == "none" ]]; then
    echo "PR title prefix is 'chore:'; no se publica ningún tag. Último tag existente: $last_tag"
    exit 0
  fi

  version="${last_tag#v}"
  IFS='.' read -r major minor patch <<< "$version"

  # Forzar interpretación en base 10: sin esto, bash interpreta segmentos con
  # ceros a la izquierda (p. ej. "08") como literales octales inválidos y la
  # aritmética siguiente falla con "value too great for base".
  major=$((10#$major))
  minor=$((10#$minor))
  patch=$((10#$patch))

  case "$bump" in
    major)
      major=$((major + 1))
      minor=0
      patch=0
      ;;
    minor)
      minor=$((minor + 1))
      patch=0
      ;;
    patch)
      patch=$((patch + 1))
      ;;
  esac

  new_tag="v${major}.${minor}.${patch}"
fi

# 4) Comprobar colisión: si el tag calculado ya existe, fallar sin sobrescribir.
if git rev-parse "refs/tags/$new_tag" >/dev/null 2>&1; then
  echo "::error::El tag $new_tag ya existe en el repositorio. No se sobrescribe."
  exit 1
fi

# 6) Crear el tag anotado y publicarlo. No se crea ningún GitHub Release.
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

git tag -a "$new_tag" -m "$new_tag"
git push origin "$new_tag"

echo "Tag publicado: $new_tag"
