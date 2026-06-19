#!/usr/bin/env bash
# Generates the default social-share card (public/assets/og-default.png).
# Business-card feel: stacked "Panat" / "Taranat", smaller subtitle, and the
# orange URL on the left; full-height storefront watercolor on the right.
# Uses Literata + IBM Plex Mono via ImageMagick + Pango.
#
# Note: do NOT use -gravity with -composite here. With a wide first layer
# present, -gravity NorthWest was causing the smaller layers to be centered.
# -geometry +X+Y alone places each layer at an absolute top-left offset.
set -euo pipefail

OUT="$(dirname "$0")/../public/assets/og-default.png"
WATER="$(dirname "$0")/../public/assets/storefront-watercolor-1400.jpg"

# Palette (matches site light theme).
PAPER='#161616'
INK='#e9e7e2'
MUTED='#9a9a96'
ACCENT='#e08339'

# Text. "Panat" and "Taranat" rendered as separate layers so we control the
# line gap directly (Pango's default line-height leaves them too far apart).
# Smaller subtitle. Orange URL sits on the left.
line1='<span font="Literata Bold 140" foreground="'"$INK"'">Panat</span>'
line2='<span font="Literata Bold 140" foreground="'"$INK"'">Taranat</span>'
tagline='<span font="IBM Plex Mono Medium 30" foreground="'"$MUTED"'" letter_spacing="500">SOFTWARE ENGINEER &#38; BOOKSELLER</span>'
url='<span font="IBM Plex Mono Medium 24" foreground="'"$ACCENT"'" letter_spacing="1400">taranat.com</span>'

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
convert -density 72 -background none pango:"$line1"   "$TMP/line1.png"
convert -density 72 -background none pango:"$line2"   "$TMP/line2.png"
convert -density 72 -background none pango:"$tagline" "$TMP/tagline.png"
convert -density 72 -background none pango:"$url"     "$TMP/url.png"

# Full-height watercolor on the right, covering the right ~37% of the card.
# The source is 1400x1867 (portrait). Cover-fit to the right region.
photo_x=760
photo_w=$(( 1200 - photo_x ))
photo_h=630
convert "$WATER" -resize "${photo_w}x${photo_h}^" -gravity center \
  -extent "${photo_w}x${photo_h}" "$TMP/photo.png"

convert -density 72 -size 1200x630 "xc:$PAPER" \
  "$TMP/photo.png"   -geometry "+${photo_x}+0" -composite \
  "$TMP/line1.png"   -geometry +85+70  -composite \
  "$TMP/line2.png"   -geometry +85+215 -composite \
  "$TMP/tagline.png" -geometry +85+420 -composite \
  "$TMP/url.png"     -geometry +85+560 -composite \
  "$OUT"

echo "wrote $OUT"
