import { html, type Html } from '../lib/html.ts';
import { layout } from '../layouts/base.ts';

export const blogPage = (): Html =>
  layout({
    title: 'Blog — Panat Taranat',
    description: 'Writing by Panat Taranat.',
    path: '/blog',
    children: html`
      <section class="section">
        <div class="grid">
          <div class="col-span-text">
            <h1 class="display">Blog</h1>
            <p class="lede">Coming soon. Migrating posts from the old site.</p>
          </div>
        </div>
      </section>
    `,
  });
