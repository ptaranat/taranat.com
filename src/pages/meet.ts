import { html, type Html } from '../lib/html.ts';
import { layout } from '../layouts/base.ts';

const body: Html = html`
  <section class="section section--meet">
    <div class="grid">
      <div class="col-span-text">
        <h1 class="display">Grab some time with me</h1>
        <p class="lede">
          Here's my calendar. Happy to talk software,
          the bookstore, or anything you're working on.
        </p>
      </div>
      <div class="col-span-full meet-embed">
        <iframe
          src="https://app.cal.com/panat"
          title="Schedule a meeting with Panat"
          loading="lazy"
          allowfullscreen
        ></iframe>
      </div>
    </div>
  </section>
`;

export const meetPage = (): Html =>
  layout({
    title: 'Schedule a meeting — Panat Taranat',
    description:
      'Find a time to chat with Panat Taranat.',
    path: '/meet',
    children: body,
  });
