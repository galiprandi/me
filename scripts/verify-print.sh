#!/usr/bin/env bash
# Verifies the printable CV fits exactly 1 page with safe bottom margin.
# Usage: npm run verify:print   (exit 0 = OK, exit 1 = overflow risk)
set -euo pipefail
cd "$(dirname "$0")/.."

PORT=8899
PDF=/tmp/cv_verify.pdf
# Calibrated on A4 (headless Chrome locale default; user's locale prints A4).
# v10 user-validated baseline measured yMax=741 on A4 (~100pt bottom margin,
# safe against Chrome header/footer overlay ~50pt). Limit 745 accepts the
# validated state and fails on any added printed line (~14pt each).
# Note: print CSS caps the layout to one page, so Pages==1 is a sanity check
# only; the real risk this script guards is the bottom line being cut.
YMAX_LIMIT=745

echo "→ Building..."
npx astro build >/dev/null

echo "→ Serving dist/ on :$PORT ..."
python3 -m http.server "$PORT" -d dist >/dev/null 2>&1 &
SERVER_PID=$!
trap 'kill $SERVER_PID 2>/dev/null || true' EXIT
sleep 1

echo "→ Printing PDF (headless Chrome)..."
google-chrome --headless=new --disable-gpu --no-sandbox \
  --virtual-time-budget=8000 --no-pdf-header-footer \
  --print-to-pdf="$PDF" "http://localhost:$PORT/" >/dev/null 2>&1

PAGES=$(pdfinfo "$PDF" | awk '/^Pages/{print $2}')
YMAX=$(pdftotext -bbox "$PDF" - 2>/dev/null \
  | grep -oE 'yMax="[0-9.]+"' | sed 's/yMax="//;s/"//' \
  | sort -rn | head -1 | cut -d. -f1)

echo ""
echo "  Pages : $PAGES"
echo "  yMax  : ${YMAX}pt (limit ${YMAX_LIMIT}pt)"
echo ""

if [ "$PAGES" != "1" ]; then
  echo "❌ FAIL: $PAGES pages — content overflows to page $((PAGES))"
  exit 1
fi
if [ "$YMAX" -gt "$YMAX_LIMIT" ]; then
  echo "❌ FAIL: bottom margin too tight (${YMAX}pt > ${YMAX_LIMIT}pt)"
  echo "   Compensate ~14pt per printed line (no-print or compress)."
  exit 1
fi

echo "✅ PASS — 1 page A4, yMax=${YMAX}pt (validated baseline: 741)"
exit 0
