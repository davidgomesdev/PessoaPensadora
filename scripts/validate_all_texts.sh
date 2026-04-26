#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-assets/json_files/all_texts.json}"
REFERENCE="${2:-}"

if [[ ! -f "$FILE" ]]; then
  echo "ERROR: file not found: $FILE" >&2
  exit 1
fi

echo "=== Validating: $FILE ==="

# --- Structural checks ---

TOP_TYPE=$(jq -r 'type' "$FILE")
if [[ "$TOP_TYPE" != "array" ]]; then
  echo "FAIL: top-level must be array, got $TOP_TYPE"
  exit 1
fi
echo "OK: top-level is array"

TOP_COUNT=$(jq 'length' "$FILE")
echo "OK: $TOP_COUNT top-level categories"

# Every category/subcategory must have id, title, texts, subcategories
MALFORMED_CATS=$(jq '
  [.. | objects
    | select(has("subcategories"))
    | select(
        (.id | type) != "number"
        or (.title | type) != "string"
        or (.texts | type) != "array"
        or (.subcategories | type) != "array"
      )
    | .id
  ]
' "$FILE")
if [[ "$MALFORMED_CATS" != "[]" ]]; then
  echo "FAIL: malformed categories (missing/wrong-type fields): $MALFORMED_CATS"
  exit 1
fi
echo "OK: all categories have id(number), title(string), texts(array), subcategories(array)"

# Every text must have id, author, title, content
MALFORMED_TEXTS=$(jq '
  [.. | objects
    | select(has("content"))
    | select(
        (.id | type) != "number"
        or (.author | type) != "string"
        or (.title | type) != "string"
        or (.content | type) != "string"
      )
    | .id
  ]
' "$FILE")
if [[ "$MALFORMED_TEXTS" != "[]" ]]; then
  echo "FAIL: malformed texts (missing/wrong-type fields): $MALFORMED_TEXTS"
  exit 1
fi
echo "OK: all texts have id(number), author(string), title(string), content(string)"

# Total text count
TEXT_COUNT=$(jq '[.. | objects | select(has("content"))] | length' "$FILE")
echo "OK: $TEXT_COUNT texts total"

# Unique text IDs (texts may appear in multiple categories)
UNIQUE_TEXT_COUNT=$(jq '[.. | objects | select(has("content")) | .id] | unique | length' "$FILE")
echo "OK: $UNIQUE_TEXT_COUNT unique text IDs ($TEXT_COUNT total including cross-category dupes)"

# Unique category IDs (categories may appear in multiple branches)
UNIQUE_CAT_COUNT=$(jq '[.. | objects | select(has("subcategories")) | .id] | unique | length' "$FILE")
TOTAL_CAT_COUNT=$(jq '[.. | objects | select(has("subcategories")) | .id] | length' "$FILE")
echo "OK: $UNIQUE_CAT_COUNT unique category IDs ($TOTAL_CAT_COUNT total including cross-branch dupes)"

# --- Cross-file comparison (optional) ---

if [[ -n "$REFERENCE" ]]; then
  if [[ ! -f "$REFERENCE" ]]; then
    echo "ERROR: reference file not found: $REFERENCE" >&2
    exit 1
  fi

  echo ""
  echo "=== Comparing against reference: $REFERENCE ==="

  REF_TEXT_IDS=$(jq '[.. | objects | select(has("content")) | .id] | unique | sort' "$REFERENCE")
  NEW_TEXT_IDS=$(jq '[.. | objects | select(has("content")) | .id] | unique | sort' "$FILE")

  if [[ "$REF_TEXT_IDS" == "$NEW_TEXT_IDS" ]]; then
    echo "OK: text IDs match exactly"
  else
    MISSING=$(jq -n --argjson ref "$REF_TEXT_IDS" --argjson new "$NEW_TEXT_IDS" \
      '[$ref[] | select(. as $id | $new | index($id) | not)]')
    EXTRA=$(jq -n --argjson ref "$REF_TEXT_IDS" --argjson new "$NEW_TEXT_IDS" \
      '[$new[] | select(. as $id | $ref | index($id) | not)]')
    [[ "$MISSING" != "[]" ]] && echo "FAIL: IDs in reference but missing from file: $MISSING"
    [[ "$EXTRA"   != "[]" ]] && echo "FAIL: IDs in file but not in reference: $EXTRA"
    exit 1
  fi

  REF_CAT_IDS=$(jq '[.. | objects | select(has("subcategories")) | .id] | unique | sort' "$REFERENCE")
  NEW_CAT_IDS=$(jq '[.. | objects | select(has("subcategories")) | .id] | unique | sort' "$FILE")

  if [[ "$REF_CAT_IDS" == "$NEW_CAT_IDS" ]]; then
    echo "OK: category IDs match exactly"
  else
    MISSING=$(jq -n --argjson ref "$REF_CAT_IDS" --argjson new "$NEW_CAT_IDS" \
      '[$ref[] | select(. as $id | $new | index($id) | not)]')
    EXTRA=$(jq -n --argjson ref "$REF_CAT_IDS" --argjson new "$NEW_CAT_IDS" \
      '[$new[] | select(. as $id | $ref | index($id) | not)]')
    [[ "$MISSING" != "[]" ]] && echo "FAIL: category IDs in reference but missing: $MISSING"
    [[ "$EXTRA"   != "[]" ]] && echo "FAIL: category IDs in file but not in reference: $EXTRA"
    exit 1
  fi
fi

echo ""
echo "=== PASSED ==="
