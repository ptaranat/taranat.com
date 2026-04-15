import { html, type Html } from '../lib/html.ts';
import { layout } from '../layouts/base.ts';

export const aboutPage = (): Html =>
  layout({
    title: 'About — Panat Taranat',
    description: 'About Panat Taranat.',
    path: '/about',
    children: html`
      <section class="section">
        <div class="grid">
          <div class="col-span-text">
            <h1 class="display">About</h1>
            <p class="lede">Coming soon. Migrating writing from the old site.</p>
          </div>
        </div>
      </section>
    `,
  });
