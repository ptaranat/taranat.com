import { html, type Html } from '../lib/html.ts';
import { layout } from '../layouts/base.ts';
import { emailLink } from '../lib/email.ts';

const hero: Html = html`
  <section class="section section--hero">
    <div class="grid">
      <div class="col-span-text">
        <h1 class="display">
          I left tech to open a bookstore.
        </h1>
        <p class="lede">
          In 2024, Carrie and I opened
          <a href="https://dungeonbooks.com" rel="noreferrer">Dungeon Books</a>,
          a sci-fi and fantasy shop in Jersey City. I'd spent years building
          distributed systems and infrastructure, and I wanted to make
          something I could stand inside of. So we did. These days you'll
          find me at the shop, recommending books and running D&amp;D nights
          in the back.
        </p>
      </div>
    </div>
  </section>
`;

const contact: Html = html`
  <section class="section section--contact">
    <div class="grid">
      <div class="col-span-text">
        <h2>Get in touch</h2>
        <p>
          Come by the shop, or reach me here.
        </p>
        <ul class="contact-list">
          <li>${emailLink()}</li>
          <li><a href="/meet">Book a call</a></li>
        </ul>
      </div>
    </div>
  </section>
`;

export const homePage = (): Html =>
  layout({
    title: 'Panat Taranat',
    description:
      'Engineer and co-owner of Dungeon Books, a sci-fi and fantasy bookstore in Jersey City.',
    path: '/',
    children: html`${hero}${contact}`,
  });
