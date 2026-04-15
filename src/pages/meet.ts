import { html, type Html } from '../lib/html.ts';

export const meetPage = (): Html => html`
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Schedule a meeting — Panat Taranat</title>
    <style>
      html, body { margin: 0; height: 100%; }
      iframe { display: block; width: 100vw; height: 100dvh; border: 0; }
    </style>
  </head>
  <body>
    <iframe
      src="https://app.cal.com/panat"
      title="Schedule a meeting with Panat"
      allowfullscreen
    ></iframe>
  </body>
</html>
`;
