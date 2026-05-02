import { html, type Html } from '../lib/html.ts';
import { layout } from '../layouts/base.ts';
import { listPosts, formatDate } from '../lib/posts.ts';

const formatIndexDate = (iso: string): string =>
  new Date(`${iso}T00:00:00Z`).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: '2-digit',
    timeZone: 'UTC',
  }).toUpperCase();

export const blogPage = (): Html => {
  const posts = listPosts();
  const count = posts.length;
  return layout({
    title: 'Blog — Panat Taranat',
    description: 'Writing by Panat Taranat.',
    path: '/blog',
    children: html`
      <section class="section section--index">
        <div class="grid">
          <header class="col-span-text index-header">
            <p class="eyebrow">
              Index — ${String(count)} ${count === 1 ? 'entry' : 'entries'}
            </p>
            <h1 class="display">Blog</h1>
          </header>
        </div>
        ${count === 0
          ? html`
              <div class="grid">
                <p class="col-span-text lede">Coming soon.</p>
              </div>
            `
          : html`
              <div class="grid">
                <ul class="col-span-text post-index">
                  ${posts.map(
                    (p) => html`
                      <li class="post-index__entry">
                        <a class="post-index__link" href="/blog/${p.slug}">
                          <time class="post-index__date" datetime="${p.date}">
                            ${formatIndexDate(p.date)}
                          </time>
                          <div class="post-index__body">
                            <h2 class="post-index__title">${p.title}</h2>
                            <div class="post-index__excerpt">${p.excerpt}</div>
                          </div>
                        </a>
                      </li>
                    `,
                  )}
                </ul>
              </div>
            `}
      </section>
    `,
  });
};
