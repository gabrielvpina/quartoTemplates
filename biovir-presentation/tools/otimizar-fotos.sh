#!/usr/bin/env bash
#===============================================================================
# BIOVIR LAB — otimizar as fotos da equipe
#-------------------------------------------------------------------------------
# POR QUE: as fotos de assets/members/ aparecem no slide com ~48 px de lado,
# mas costumam chegar com 450 px e ~250 kB cada. Como as apresentações são
# self-contained (tudo embutido no .html), isso infla o arquivo final em
# vários MB sem nenhum ganho visual.
#
# O QUE FAZ: guarda os originais em assets/members-originais/ (só na primeira
# execução) e reduz as fotos de assets/members/ para 200 px de lado, em JPEG.
#
# USO:  bash tools/otimizar-fotos.sh
#
# Rode de novo sempre que adicionar fotos novas. Não é obrigatório: sem
# otimizar tudo funciona igual, o .html só fica maior.
#===============================================================================
set -euo pipefail

cd "$(dirname "$0")/.."

ORIGEM="assets/members"
BACKUP="assets/members-originais"
LADO=200
QUALIDADE=85

[ -d "$ORIGEM" ] || { echo "✗ pasta não encontrada: $ORIGEM"; exit 1; }

if [ ! -d "$BACKUP" ]; then
  echo "→ guardando originais em $BACKUP"
  cp -R "$ORIGEM" "$BACKUP"
else
  echo "→ $BACKUP já existe, mantido como está"
fi

if command -v magick >/dev/null 2>&1;   then CONV=magick
elif command -v convert >/dev/null 2>&1; then CONV=convert
elif command -v sips >/dev/null 2>&1;    then CONV=sips
else
  echo "✗ preciso do ImageMagick (magick/convert) ou do sips (macOS)"; exit 1
fi
echo "→ usando: $CONV"

antes=$(du -sk "$ORIGEM" | cut -f1)
n=0

while IFS= read -r -d '' foto; do
  destino="${foto%.*}.jpg"

  case "$CONV" in
    sips) sips -Z "$LADO" -s format jpeg -s formatOptions "$QUALIDADE" \
               "$foto" --out "$destino" >/dev/null 2>&1 ;;
    *)    "$CONV" "$foto" -resize "${LADO}x${LADO}>" -background white \
               -alpha remove -alpha off -quality "$QUALIDADE" "$destino" ;;
  esac

  [ "$foto" != "$destino" ] && rm -f "$foto"
  n=$((n + 1))
done < <(find "$ORIGEM" -type f \( -iname '*.png' -o -iname '*.jpg' \
         -o -iname '*.jpeg' -o -iname '*.webp' \) -print0)

depois=$(du -sk "$ORIGEM" | cut -f1)

echo "✓ $n fotos otimizadas: $((antes / 1024)) MB → $((depois / 1024)) MB"
echo "  agora rode: quarto render"
