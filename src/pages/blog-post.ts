import { html, type Html } from '../lib/html.ts';
import { layout } from '../layouts/base.ts';
import { type Post, formatDate } from '../lib/posts.ts';

export const blogPostPage = (post: Post): Html =>
  layout({
    title: `${post.title} — Panat Taranat`,
    description: post.description,
    path: `/blog/${post.slug}`,
    type: 'article',
    children: html`
      <article class="section section--post">
        <div class="grid">
          <div class="col-span-text">
            <header class="post-header">
              <p class="post-header__back"><a href="/blog">← All posts</a></p>
              <h1 class="display">${post.title}</h1>
              <time class="post-header__date" datetime="${post.date}">
                ${formatDate(post.date)}
              </time>
            </header>
            <div class="post-body">
              ${post.body}
            </div>
          </div>
        </div>
      </article>
    `,
  });
