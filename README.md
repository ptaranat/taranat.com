# taranat.com

Personal site of Panat Taranat. Gleam + Lustre, generated to static HTML, hand-written CSS.

## Develop

```
gleam run
```

Writes the site to `dist/`. Serve it with any static file server:

```
python3 -m http.server -d dist 3000
```

## Structure

```
src/
  taranat.gleam           Route table and build entry point
  taranat/layout.gleam    HTML shell, header, footer, <head> meta (OG/Twitter/canonical)
  taranat/post.gleam      Markdown blog loader, excerpts, code-block rendering
  taranat/syndication.gleam  sitemap / robots / RSS generators
  taranat/email.gleam     Obfuscated email link
  taranat/pages/          One module per route

content/posts/            Blog posts (Markdown with YAML frontmatter)

public/
  styles/
    tokens/               color, typography, grid
    base.css              resets, body defaults, view transitions
    components.css        site chrome, page components, syntax highlighting
    main.css              imports all of the above
  js/theme.js             DAY / NIGHT toggle
  assets/                 Photos (responsive jpg/webp variants), og-default.png, SVG grain textures
```

## Content

Posts are CommonMark + GFM with YAML frontmatter, parsed by
[mork](https://hex.pm/packages/mork):

```
---
title: "Bicycle"
date: 2026-05-02
description: "..."
---
```

`<!--more-->` marks the excerpt cut-off. Without it the first paragraph is used.
Leading image blocks are dropped from excerpts so the index never opens with a photo.

`mork_to_lustre` renders a whole document with no per-node hook, so
`taranat/post.gleam` splits the block list: code blocks are rendered locally to
get the copy-button wrapper and highlighting, and every other run of blocks is
handed back to `mork_to_lustre`.

## Syntax highlighting

[smalto](https://github.com/veeso/smalto) tokenises at build time and emits
`<span class="smalto-*">`. Colors come from `--syn-*` tokens in
`tokens/color.css`, so light and dark are ordinary CSS with no runtime involved.
Add a language by importing its grammar in `taranat/post.gleam`.

## Design tokens

Split by concern: `tokens/color.css`, `tokens/typography.css`, `tokens/grid.css`.

Grid primitive: a single `.grid { grid-template-columns: repeat(var(--num-cols, 1), 1fr) }` scales from 4 to 12 columns across breakpoints. Use `.col-span-text` for readable-width content; `.col-span-full` for edge-to-edge.

Color scheme: `prefers-color-scheme` sets the default, `data-user-color-scheme` overrides it via the header toggle. Both modes share the same token names.

## Images

Photos are served as responsive `<picture>` elements with WebP + JPG variants at
two widths each (e.g. `panat-headshot-800.webp`, `panat-headshot-1365.jpg`). To
regenerate after replacing a source photo, resize with ImageMagick and encode
WebP with `cwebp`. `scripts/gen-og-card.sh` regenerates the 1200×630 social-share
card at `public/assets/og-default.png`.

## SEO

`site_origin` in `taranat/layout.gleam` is the canonical origin used for canonical
URLs, OG tags, the sitemap, and the RSS feed. `/sitemap.xml`, `/robots.txt`,
`/feed.xml`, and `/404.html` are generated at build time from the route list and
blog posts (`taranat/syndication.gleam`).

## Dependencies

`lustre_ssg` and `smalto` are pinned to git rather than Hex. Their current Hex
releases cannot be built: `lustre_ssg` 0.11.0 pins `jot == 4.0.0`, which calls a
`gleam_stdlib` function removed years ago, and every published `smalto` tarball
ships compiled `.erl` artifacts that collide with its own `.gleam` sources.

## Deploy

Railway, from the `Dockerfile`. `railway.toml` selects the Dockerfile builder;
no other configuration is needed.

Railway's builders do not detect Gleam. Railpack supports Node, Python, Go, PHP,
Java, Deno and Elixir, and the Gleam provider belongs to the superseded Nixpacks.
The Dockerfile sidesteps builder detection: it builds with the official Gleam
image and copies `dist/` into a Caddy image.

Caddy resolves `/about` to `/about/index.html`, serves `404.html` with a real
404 status, and sets the RSS and sitemap content types that a bare file server
would otherwise get wrong.

Test the production image locally:

```
docker build -t taranat .
docker run --rm -e PORT=8080 -p 8080:8080 taranat
```

`gleam run` alone produces a self-contained `dist/`, so any static host works
too.

## License

Source code is MIT. See [LICENSE](./LICENSE).

Blog posts under `content/` and media under `public/assets/` are not covered:
they are copyright reserved, and some media is reproduced under fair use and
belongs to its respective owner.
