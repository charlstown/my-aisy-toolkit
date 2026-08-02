#!/usr/bin/env bash
#
# compute-next-tag.test.sh — pruebas de la lógica de versionado implementada
# en compute-next-tag.sh, en bash plano y con aserciones simples (sin añadir
# ningún runner de tests nuevo al repo).
#
# Cómo correrlo localmente:
#
#   bash .github/scripts/compute-next-tag.test.sh
#
# El script termina con exit 0 si todos los casos pasan, o exit 1 (con un
# resumen de qué caso(s) fallaron) en caso contrario.
#
# Qué hace cada caso de prueba:
#   1. Crea un repositorio git temporal y aislado (git init en un directorio
#      bajo mktemp), con un commit inicial y un remoto "origin" que es a su
#      vez OTRO repo local (bare) en disco — nunca una URL real. Así, cuando
#      compute-next-tag.sh hace `git push origin <tag>` en sus caminos de
#      éxito, ese push se resuelve contra el repo bare local y jamás sale a
#      la red.
#   2. Prepara el estado de tags de partida que necesita el caso (ninguno,
#      v0.3.1, tags mal formados, una colisión ya creada, etc.).
#   3. Invoca compute-next-tag.sh con el título de PR del caso, capturando
#      su código de salida y su salida combinada (stdout+stderr).
#   4. Compara el código de salida y el estado resultante de los tags (tanto
#      en el repo local como en "origin") con lo esperado.
#
# No se ejecuta este script desde ningún workflow de CI todavía; eso se
# integra en un batch posterior (ver specs/003-pr-title-auto-versioning).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_UNDER_TEST="$SCRIPT_DIR/compute-next-tag.sh"

if [[ ! -f "$SCRIPT_UNDER_TEST" ]]; then
  echo "::error::No se encuentra el script bajo prueba en $SCRIPT_UNDER_TEST" >&2
  exit 1
fi

TMP_DIRS=()
cleanup() {
  local d
  for d in "${TMP_DIRS[@]:-}"; do
    [[ -n "$d" ]] && rm -rf "$d" "${d}-origin.git" 2>/dev/null
  done
}
trap cleanup EXIT

# new_tmp_dir
# Crea un directorio temporal nuevo (portable entre mktemp GNU y BSD, sin
# depender de la opción -p que BSD/macOS no soporta) y lo registra para su
# limpieza al terminar el script.
new_tmp_dir() {
  local d
  d="$(mktemp -d)"
  TMP_DIRS+=("$d")
  printf '%s' "$d"
}

TESTS_RUN=0
TESTS_FAILED=0
FAILED_NAMES=()
CURRENT_TEST=""

# ---------------------------------------------------------------------------
# Helpers de aserción / infraestructura
# ---------------------------------------------------------------------------

fail() {
  TESTS_FAILED=$((TESTS_FAILED + 1))
  echo "  FAIL: $1" >&2
}

# make_repo <dir>
# Crea un repo git en <dir> con un commit inicial y un remoto "origin" que
# apunta a un segundo repo bare local (<dir>-origin.git), para que el
# `git push origin <tag>` de compute-next-tag.sh nunca intente alcanzar la
# red real.
make_repo() {
  local dir="$1"
  local origin_dir="${dir}-origin.git"

  git init --quiet "$dir"
  git init --quiet --bare "$origin_dir"

  (
    cd "$dir" || exit 1
    git config user.name "Test User"
    git config user.email "test@example.invalid"
    git remote add origin "$origin_dir"
    git commit --quiet --allow-empty -m "initial commit"
  )
}

# invoke_script <repo_dir> <pr_title>
# Ejecuta compute-next-tag.sh dentro de <repo_dir> con el título de PR dado.
# Deja el código de salida en $STATUS y la salida combinada (stdout+stderr)
# en $OUTPUT.
invoke_script() {
  local dir="$1" title="$2"
  OUTPUT="$(cd "$dir" && bash "$SCRIPT_UNDER_TEST" "$title" 2>&1)"
  STATUS=$?
}

# invoke_script_simulating_tag_race <repo_dir> <pr_title> <race_tag>
#
# Variante de invoke_script que simula, de forma determinista (sin
# depender de temporización real ni de hilos concurrentes), la condición de
# carrera (TOCTOU) contra la que protege el guard de colisión de
# compute-next-tag.sh (FR-021): antepone al PATH un shim de "git" que deja
# pasar cualquier comando al git real y, justo después de responder a la
# consulta "git tag -l 'v*'" (el paso con el que el script bajo prueba
# calcula el último tag), crea por detrás <race_tag> — como si otro proceso
# hubiera publicado ese mismo tag exactamente en ese instante — antes de que
# el script llegue a su propia comprobación de colisión (`git rev-parse
# refs/tags/$new_tag`).
#
# Por qué hace falta este shim en vez de simplemente pre-crear el tag antes
# de invocar el script: compute-next-tag.sh calcula "last_tag" como el
# máximo (por sort -V) de los tags vX.Y.Z ya existentes, y "new_tag" es
# siempre estrictamente mayor que "last_tag". Por construcción, por tanto,
# new_tag nunca puede coincidir con ningún tag vX.Y.Z pre-existente antes de
# ejecutar el script: si se pre-creara manualmente el tag que "debería"
# colisionar, ese mismo tag pasaría a ser el nuevo "last_tag" observado por
# el script, que calcularía un incremento aún mayor en vez de colisionar
# (probado y documentado en el caso de prueba test_h más abajo). La única
# forma real de que la colisión ocurra es una carrera entre dos ejecuciones
# casi simultáneas, que es exactamente lo que este shim reproduce de forma
# reproducible.
invoke_script_simulating_tag_race() {
  local dir="$1" title="$2" race_tag="$3"
  local real_git shim_dir

  real_git="$(command -v git)"
  if [[ -z "$real_git" ]]; then
    fail "no se pudo localizar el binario real de git para construir el shim de simulación de carrera"
    STATUS=1
    OUTPUT=""
    return
  fi

  shim_dir="$(new_tmp_dir)"
  mkdir -p "$shim_dir/bin"

  cat > "$shim_dir/bin/git" <<EOF
#!/usr/bin/env bash
"$real_git" "\$@"
status=\$?
if [[ "\$1" == "tag" && "\$2" == "-l" ]]; then
  "$real_git" tag "$race_tag" >/dev/null 2>&1 || true
fi
exit \$status
EOF
  chmod +x "$shim_dir/bin/git"

  OUTPUT="$(cd "$dir" && PATH="$shim_dir/bin:$PATH" bash "$SCRIPT_UNDER_TEST" "$title" 2>&1)"
  STATUS=$?
}

tag_exists() {
  local dir="$1" tag="$2"
  git -C "$dir" rev-parse -q --verify "refs/tags/$tag" >/dev/null 2>&1
}

origin_tag_exists() {
  local dir="$1" tag="$2"
  local origin_dir="${dir}-origin.git"
  git -C "$origin_dir" rev-parse -q --verify "refs/tags/$tag" >/dev/null 2>&1
}

assert_equal() {
  local expected="$1" actual="$2" msg="$3"
  if [[ "$expected" != "$actual" ]]; then
    fail "$msg (esperado: '$expected', obtenido: '$actual')"
  fi
}

assert_status() {
  local expected="$1" actual="$2" ctx="$3"
  if [[ "$expected" -ne "$actual" ]]; then
    fail "$ctx: exit code esperado=$expected, obtenido=$actual. Salida del script:"$'\n'"$OUTPUT"
  fi
}

assert_status_nonzero() {
  local actual="$1" ctx="$2"
  if [[ "$actual" -eq 0 ]]; then
    fail "$ctx: se esperaba exit code != 0, pero el script devolvió 0. Salida del script:"$'\n'"$OUTPUT"
  fi
}

# assert_tag_created <repo_dir> <tag>
# Verifica que <tag> exista tanto en el repo local como en el remoto
# "origin" (es decir, que se creó Y se publicó con git push).
assert_tag_created() {
  local dir="$1" tag="$2"
  if ! tag_exists "$dir" "$tag"; then
    fail "se esperaba que el tag $tag existiera en el repo local tras ejecutar el script. Salida del script:"$'\n'"$OUTPUT"
  fi
  if ! origin_tag_exists "$dir" "$tag"; then
    fail "se esperaba que el tag $tag se hubiera publicado (git push) en origin. Salida del script:"$'\n'"$OUTPUT"
  fi
}

# assert_only_tags <repo_dir> <tag1> [<tag2> ...]
# Verifica que el conjunto exacto de tags del repo local sea el indicado
# (ni de más, ni de menos).
assert_only_tags() {
  local dir="$1"; shift
  local expected_sorted actual_sorted
  expected_sorted="$(printf '%s\n' "$@" | sort)"
  actual_sorted="$(git -C "$dir" tag -l | sort)"
  if [[ "$expected_sorted" != "$actual_sorted" ]]; then
    fail "conjunto de tags inesperado en el repo local. esperado: [$*], obtenido: [$(git -C "$dir" tag -l | tr '\n' ' ')]"
  fi
}

run_test() {
  local name="$1" fn="$2"
  TESTS_RUN=$((TESTS_RUN + 1))
  CURRENT_TEST="$name"
  local failed_before=$TESTS_FAILED
  echo "TEST: $name"
  "$fn"
  if [[ "$TESTS_FAILED" -eq "$failed_before" ]]; then
    echo "  OK"
  else
    FAILED_NAMES+=("$name")
  fi
}

# ---------------------------------------------------------------------------
# Casos de prueba
# ---------------------------------------------------------------------------

# (a) tag previo v0.3.1 + "feature:" -> v0.4.0
test_a() {
  local dir; dir="$(new_tmp_dir)"
  make_repo "$dir"
  git -C "$dir" tag v0.3.1

  invoke_script "$dir" "feature: añadir login con Google"

  assert_status 0 "$STATUS" "test a"
  assert_tag_created "$dir" "v0.4.0"
  assert_only_tags "$dir" "v0.3.1" "v0.4.0"
}

# (b) tag previo v0.3.1 + "fix:" -> v0.3.2
test_b() {
  local dir; dir="$(new_tmp_dir)"
  make_repo "$dir"
  git -C "$dir" tag v0.3.1

  invoke_script "$dir" "fix: corregir crash al iniciar"

  assert_status 0 "$STATUS" "test b"
  assert_tag_created "$dir" "v0.3.2"
  assert_only_tags "$dir" "v0.3.1" "v0.3.2"
}

# (c) tag previo v0.3.1 + "release:" -> v1.0.0
test_c() {
  local dir; dir="$(new_tmp_dir)"
  make_repo "$dir"
  git -C "$dir" tag v0.3.1

  invoke_script "$dir" "release: v2 API pública"

  assert_status 0 "$STATUS" "test c"
  assert_tag_created "$dir" "v1.0.0"
  assert_only_tags "$dir" "v0.3.1" "v1.0.0"
}

# (d) tag previo v0.3.1 + "chore:" -> no se publica tag, el script termina en éxito
test_d() {
  local dir; dir="$(new_tmp_dir)"
  make_repo "$dir"
  git -C "$dir" tag v0.3.1

  invoke_script "$dir" "chore: actualizar dependencias"

  assert_status 0 "$STATUS" "test d"
  assert_only_tags "$dir" "v0.3.1"
  if origin_tag_exists "$dir" "v0.4.0" || origin_tag_exists "$dir" "v0.3.2" || origin_tag_exists "$dir" "v1.0.0"; then
    fail "no se esperaba ningún push a origin para un título 'chore:'. Salida del script:"$'\n'"$OUTPUT"
  fi
}

# (e) sin tags previos + "feature:" -> v0.1.0
test_e_feature() {
  local dir; dir="$(new_tmp_dir)"
  make_repo "$dir"

  invoke_script "$dir" "feature: primera funcionalidad"

  assert_status 0 "$STATUS" "test e (feature)"
  assert_tag_created "$dir" "v0.1.0"
  assert_only_tags "$dir" "v0.1.0"
}

# (e) sin tags previos + "fix:" -> v0.1.0
test_e_fix() {
  local dir; dir="$(new_tmp_dir)"
  make_repo "$dir"

  invoke_script "$dir" "fix: primer arreglo"

  assert_status 0 "$STATUS" "test e (fix)"
  assert_tag_created "$dir" "v0.1.0"
  assert_only_tags "$dir" "v0.1.0"
}

# (f) sin tags previos + "release:" -> v1.0.0
test_f() {
  local dir; dir="$(new_tmp_dir)"
  make_repo "$dir"

  invoke_script "$dir" "release: primera versión pública"

  assert_status 0 "$STATUS" "test f"
  assert_tag_created "$dir" "v1.0.0"
  assert_only_tags "$dir" "v1.0.0"
}

# (g) título sin prefijo válido -> el script falla (exit != 0), sin publicar tag
test_g() {
  local dir; dir="$(new_tmp_dir)"
  make_repo "$dir"
  git -C "$dir" tag v0.3.1

  invoke_script "$dir" "actualiza el README"

  assert_status_nonzero "$STATUS" "test g"
  assert_only_tags "$dir" "v0.3.1"
}

# (h) el tag calculado ya existe (colisión) -> el script falla sin
# sobrescribir ni publicar nada.
#
# Nota importante: esta colisión NO se puede reproducir simplemente
# pre-creando "a mano" el tag v0.4.0 junto a v0.3.1 antes de invocar el
# script. Si se hiciera así, v0.4.0 pasaría a ser el propio "last_tag" que
# el script detecta (por ser el tag vX.Y.Z de mayor versión presente), y
# "feature:" calcularía v0.5.0 en vez de colisionar — el script terminaría
# en éxito, no en fallo. Por eso este caso usa
# invoke_script_simulating_tag_race, que reproduce de forma determinista la
# única situación real en la que la colisión ocurre: una publicación
# concurrente del mismo tag justo entre el momento en que el script lee el
# último tag y el momento en que comprueba la colisión.
test_h() {
  local dir; dir="$(new_tmp_dir)"
  make_repo "$dir"
  git -C "$dir" tag v0.3.1

  invoke_script_simulating_tag_race "$dir" "feature: esto colisiona con un tag publicado justo antes" "v0.4.0"

  assert_status_nonzero "$STATUS" "test h"
  if [[ "$OUTPUT" != *"ya existe"* ]]; then
    fail "test h: se esperaba un mensaje de error indicando que el tag ya existe. Salida del script:"$'\n'"$OUTPUT"
  fi
  if origin_tag_exists "$dir" "v0.4.0"; then
    fail "test h: el script no debería haber publicado (git push) v0.4.0 tras detectar la colisión. Salida del script:"$'\n'"$OUTPUT"
  fi
}

# (i.1) solo hay tags mal formados en el repo -> se ignoran por completo, se
# trata como si no hubiera ningún tag previo.
test_i_only_malformed() {
  local dir; dir="$(new_tmp_dir)"
  make_repo "$dir"
  git -C "$dir" tag v1.2
  git -C "$dir" tag release-2024
  git -C "$dir" tag 1.2.3

  invoke_script "$dir" "feature: sin tags válidos previos"

  assert_status 0 "$STATUS" "test i (solo tags mal formados)"
  assert_tag_created "$dir" "v0.1.0"
}

# (i.2) tags mal formados conviven con un tag vX.Y.Z válido -> el cálculo del
# último tag ignora los mal formados incluso si "ganarían" en un orden de
# texto plano (p. ej. "v1.2" empieza por un dígito mayor que "v0.3.1").
test_i_mixed_with_valid() {
  local dir; dir="$(new_tmp_dir)"
  make_repo "$dir"
  git -C "$dir" tag v0.3.1
  git -C "$dir" tag v1.2
  git -C "$dir" tag release-2024
  git -C "$dir" tag 1.2.3

  invoke_script "$dir" "fix: arreglo con tags mal formados alrededor"

  assert_status 0 "$STATUS" "test i (mezcla con tag válido)"
  assert_tag_created "$dir" "v0.3.2"
}

# (j.1) tag previo v1.0.08 (segmento patch con cero a la izquierda) + "fix:"
# -> v1.0.9, sin que bash interprete "08" como literal octal inválido.
test_j_leading_zero_patch() {
  local dir; dir="$(new_tmp_dir)"
  make_repo "$dir"
  git -C "$dir" tag v1.0.08

  invoke_script "$dir" "fix: arreglo con patch en cero a la izquierda"

  assert_status 0 "$STATUS" "test j (patch con cero a la izquierda)"
  assert_tag_created "$dir" "v1.0.9"
  assert_only_tags "$dir" "v1.0.08" "v1.0.9"
}

# (j.2) tag previo v1.08.0 (segmento minor con cero a la izquierda) + "feature:"
# -> v1.9.0, sin que bash interprete "08" como literal octal inválido.
test_j_leading_zero_minor() {
  local dir; dir="$(new_tmp_dir)"
  make_repo "$dir"
  git -C "$dir" tag v1.08.0

  invoke_script "$dir" "feature: arreglo con minor en cero a la izquierda"

  assert_status 0 "$STATUS" "test j (minor con cero a la izquierda)"
  assert_tag_created "$dir" "v1.9.0"
  assert_only_tags "$dir" "v1.08.0" "v1.9.0"
}

# ---------------------------------------------------------------------------
# Ejecución
# ---------------------------------------------------------------------------

run_test "a) v0.3.1 + feature: -> v0.4.0" test_a
run_test "b) v0.3.1 + fix: -> v0.3.2" test_b
run_test "c) v0.3.1 + release: -> v1.0.0" test_c
run_test "d) v0.3.1 + chore: -> sin tag nuevo, exit 0" test_d
run_test "e) sin tags previos + feature: -> v0.1.0" test_e_feature
run_test "e) sin tags previos + fix: -> v0.1.0" test_e_fix
run_test "f) sin tags previos + release: -> v1.0.0" test_f
run_test "g) título sin prefijo válido -> exit != 0" test_g
run_test "h) tag calculado ya existente -> exit != 0, sin sobrescribir" test_h
run_test "i) tags mal formados (solos) se ignoran -> v0.1.0" test_i_only_malformed
run_test "i) tags mal formados (mezclados con uno válido) se ignoran -> v0.3.2" test_i_mixed_with_valid
run_test "j) v1.0.08 + fix: -> v1.0.9 (sin crash por octal inválido)" test_j_leading_zero_patch
run_test "j) v1.08.0 + feature: -> v1.9.0 (sin crash por octal inválido)" test_j_leading_zero_minor

echo
echo "----"
echo "$TESTS_RUN tests ejecutados, $TESTS_FAILED fallidos."

if [[ "$TESTS_FAILED" -gt 0 ]]; then
  echo "Casos fallidos:"
  for name in "${FAILED_NAMES[@]}"; do
    echo "  - $name"
  done
  exit 1
fi

exit 0
