import { html, type Html } from '../lib/html.ts';
import { layout } from '../layouts/base.ts';

const body: Html = html`
  <section class="section section--meet">
    <div class="grid">
      <div class="col-span-text">
        <h1 class="display">Book a call</h1>
        <p class="lede">
          Thirty minutes, no agenda required. Happy to talk software,
          distributed systems, the bookstore, or anything you're building
          in or around the indie-bookstore trade.
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
    title: 'Book a call — Panat Taranat',
    description:
      'Schedule a 30-minute call with Panat Taranat — software, distributed systems, or the indie-bookstore trade.',
    path: '/meet',
    children: body,
  });
