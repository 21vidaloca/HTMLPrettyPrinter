#!/usr/bin/env bash
#
# format_and_indent_html.sh
# -------------------------
# 1) Inserts a newline before every "<" and after every ">"
# 2) Removes empty lines
# 3) Strips leading whitespace
# 4) Indents lines by tracking HTML tags (opening vs. closing vs. void)
#
# Usage: ./format_and_indent_html.sh input.html > output.html

set -e  # Exit on error

# --- Check for input --------------------------------------------------------
if [ $# -ne 1 ]; then
  echo "Usage: $0 <html_file>"
  exit 1
fi

input_file="$1"
if [ ! -f "$input_file" ]; then
  echo "Error: '$input_file' is not a valid file."
  exit 1
fi

# --- List of void (self-closing or content-less) HTML tags -------------------
# (HTML5 recommended list)
VOID_TAGS=(
  area base br col embed hr img input link meta
  param source track wbr html
)

# --- Create a temporary file for the first pass -----------------------------
tmpfile="$(mktemp)"

# 1) Insert newline before every '<' and after every '>'
# 2) Remove empty lines
sed 's/</\n</g' "$input_file" \
  | sed 's/>/>\n/g' \
  | grep -v '^[[:space:]]*$' \
  > "$tmpfile"

# --- Indentation level ------------------------------------------------------
indent=0

# --- Function: Check if a tag name is in VOID_TAGS --------------------------
is_void_tag() {
  local t="$1"
  
  for vt in "${VOID_TAGS[@]}"; do
    # (Compare case-insensitively if needed, but typically these are lowercase)
    if [[ "$t" == "$vt" ]]; then
      return 0  # Found -> it's void
    fi
  done
  return 1  # Not found -> not void
}

# --- Read the line-broken HTML from tmpfile ---------------------------------
while IFS= read -r line; do
  # 3) Strip leading whitespace
  line="${line#"${line%%[![:space:]]*}"}"
  
  # Use a case statement to detect opening/closing tags vs. text
  case "$line" in

    # -- Closing tag? (starts with "</")
    "</"*)
      ((indent--))
      printf "%*s%s\n" $((indent*2)) "" "$line"
      ;;

    # -- Opening tag? (starts with "<" but not "</")
    "<"*)
      # Print at current indent
      printf "%*s%s\n" $((indent*2)) "" "$line"
      # Extract just the tag name out of something like <div>, <br/>, <h1>, etc.
      # We'll capture everything immediately after "<" up to the first space, ">", or "/".
      # This is simplistic and may miss complex attributes, but suffices for a quick tag name.
      tag="$(echo "$line" | sed -E 's/^<([a-zA-Z0-9_-]+).*/\1/')"
      # Remove trailing slash if it exists (e.g., <br/> -> br)
      tag="${tag%/}"
      # Check if it's a void tag -> do NOT increment indent
      if is_void_tag "$tag"; then
        :
      else
        indent=$(( indent + 1 ))
      fi
      ;;
      
    # -- Plain text or anything else
    *)
      printf "%*s%s\n" $((indent*2)) "" "$line"
      ;;
  esac

done < "$tmpfile"

# --- Clean up ---------------------------------------------------------------
rm "$tmpfile"