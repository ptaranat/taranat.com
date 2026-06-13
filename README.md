# taranat.com

Personal site of Panat Taranat. Bun + Elysia server, hand-written CSS, hypermedia-first.

## Develop

```
bun install
bun run dev
```

Serves on http://localhost:3000.

## Structure

```
src/
  index.ts            Routes (pages + sitemap.xml, robots.txt, feed.xml)
  lib/html.ts         Tagged-template HTML helper (auto-escaping)
  lib/posts.ts        Markdown blog loader (gray-matter + marked)
  lib/syndication.ts  sitemap / robots / RSS generators
  lib/email.ts        Obfuscated email link
  layouts/base.ts     HTML shell, header, footer, <head> meta (OG/Twitter/canonical)
  pages/              One file per route
  content/posts/      Blog posts (Markdown with frontmatter)

public/
  styles/
    tokens/           color, typography, grid
    base.css          resets, body defaults, view transitions
    components.css    site chrome and page components
    main.css          imports all of the above
  js/theme.js         DAY / NIGHT toggle
  assets/             Photos (responsive jpg/webp variants), og.jpg, SVG grain textures
```

## Design tokens

Split by concern: `tokens/color.css`, `tokens/typography.css`, `tokens/grid.css`.

Grid primitive: a single `.grid { grid-template-columns: repeat(var(--num-cols, 1), 1fr) }` scales from 4 to 12 columns across breakpoints. Use `.col-span-text` for readable-width content; `.col-span-full` for edge-to-edge.

Color scheme: `prefers-color-scheme` sets the default, `data-user-color-scheme` overrides it via the header toggle. Both modes share the same token names.

## Images

Photos are served as responsive `<picture>` elements with WebP + JPG variants at
two widths each (e.g. `panat-headshot-800.webp`, `panat-headshot-1365.jpg`). To
regenerate after replacing a source photo, resize with ImageMagick and encode
WebP with `cwebp`. `og.jpg` is the 1200×630 social-share image referenced by the
Open Graph / Twitter tags in `layouts/base.ts`.

## SEO

`SITE_ORIGIN` in `layouts/base.ts` is the canonical origin used for canonical
URLs, OG tags, the sitemap, and the RSS feed. `/sitemap.xml`, `/robots.txt`, and
`/feed.xml` are generated at request time from the route list and blog posts
(`lib/syndication.ts`).

## Environment

No environment variables are required. `PORT` is optional (defaults to 3000) and
`NODE_ENV=production` enables post caching and hides drafts.

## Deploy

Railway runs the Bun service directly. No Dockerfile needed — Railway's nixpacks detects `bun.lock` and wires up `bun run start`.

Set `PORT` and any other env vars via the Railway dashboard.

## License

MIT. See [LICENSE](./LICENSE).
