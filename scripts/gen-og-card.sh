#!/usr/bin/env bash
# Generates the default social-share card (public/assets/og-default.png).
# Type-driven, no photo. Uses Literata + IBM Plex Mono via ImageMagick + Pango.
# Re-run after editing the text or layout below.
set -euo pipefail

OUT="$(dirname "$0")/../public/assets/og-default.png"
PAPER='#f7f6f3'
FRAME='#e0ddd6'
INK='#111111'
MUTED='#4a4a4a'
ACCENT='#e08339'

# Name is the focal point. Orange is used once, on the URL.
name='<span font="Literata SemiBold 132" foreground="'"$INK"'">Panat Taranat</span>'
tagline='<span font="IBM Plex Mono 34" foreground="'"$MUTED"'" letter_spacing="400">software engineer &#38; bookseller</span>'
url='<span font="IBM Plex Mono 27" foreground="'"$ACCENT"'" letter_spacing="1400">taranat.com</span>'

convert -density 72 -size 1200x630 "xc:$PAPER" \
  -stroke "$FRAME" -strokewidth 1 -fill none -draw "rectangle 26,26 1173,603" \
  \( -background none pango:"$name" \)    -gravity NorthWest -geometry +91+178 -composite \
  \( -background none pango:"$tagline" \) -gravity NorthWest -geometry +95+426 -composite \
  \( -background none pango:"$url" \)     -gravity NorthWest -geometry +95+524 -composite \
  "$OUT"

echo "wrote $OUT"
