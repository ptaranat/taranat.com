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
  index.ts            Routes
  lib/html.ts         Tagged-template HTML helper (auto-escaping)
  layouts/base.ts     HTML shell, header, footer
  pages/              One file per route
  data/               Content (engagements, etc.)

public/
  styles/
    tokens/           color, typography, grid
    base.css          resets, body defaults, view transitions
    components.css    site chrome and page components
    main.css          imports all of the above
  js/theme.js         DAY / NIGHT toggle
  assets/             PDF, SVG grain textures
```

## Design tokens

Split by concern: `tokens/color.css`, `tokens/typography.css`, `tokens/grid.css`.

Grid primitive: a single `.grid { grid-template-columns: repeat(var(--num-cols, 1), 1fr) }` scales from 4 to 12 columns across breakpoints. Use `.col-span-text` for readable-width content; `.col-span-full` for edge-to-edge.

Color scheme: `prefers-color-scheme` sets the default, `data-user-color-scheme` overrides it via the header toggle. Both modes share the same token names.

## Environment

Copy `.env.example` to `.env.local` and fill in values you need.

- `ADOBE_CLIENT_ID` — required to enable `/resume`. Domain-restricted client ID for the Adobe Document Cloud View SDK. Register one at <https://www.adobe.com/go/dcsdks_credentials> and restrict it to your domain. When unset, the `/resume` route is not registered and returns 404 — there's no plain-download fallback to keep scrapers away.

## Deploy

Railway runs the Bun service directly. No Dockerfile needed — Railway's nixpacks detects `bun.lock` and wires up `bun run start`.

Set `PORT` and any other env vars via the Railway dashboard.

## License

MIT. See [LICENSE](./LICENSE).
