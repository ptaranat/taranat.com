import { html, type Html } from '../lib/html.ts';
import { layout } from '../layouts/base.ts';

export const notFoundPage = (): Html =>
  layout({
    title: '404 — Panat Taranat',
    path: '',
    children: html`
      <section class="section section--hero">
        <div class="grid">
          <div class="col-span-text">
            <h1 class="display">404</h1>
            <p class="lede">
              Nothing here. <a href="/">Back to the index.</a>
            </p>
          </div>
        </div>
      </section>
    `,
  });
