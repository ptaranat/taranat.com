import { html, type Html } from '../lib/html.ts';
import { layout } from '../layouts/base.ts';
import { emailLink } from '../lib/email.ts';

const hero: Html = html`
  <section class="section section--hero">
    <div class="grid">
      <div class="home-hero__text">
        <h1 class="display">
          I write code and run a bookstore.
        </h1>
        <p class="lede">
          In 2024, Carrie and I opened
          <a href="https://dungeonbooks.com" rel="noreferrer">Dungeon Books</a>,
          a sci-fi and fantasy shop in Jersey City. I spent years building
          distributed systems and infrastructure, and I wanted to make
          something I could stand inside of.
          <a class="proof-link" href="https://www.indiebound.org/blog-posts/dungeon-books-jersey-citys-destination-sci-fi-fantasy-and-rpgs" rel="noreferrer" aria-label="IndieBound feature on Dungeon Books">So</a>
          <a class="proof-link" href="https://www.shelf-awareness.com/issue.html?issue=4831#m65357" rel="noreferrer" aria-label="Shelf Awareness feature on Dungeon Books">we</a>
          <a class="proof-link" href="https://www.instagram.com/p/C_BjpEsP8iP/" rel="noreferrer" aria-label="Our opening-day post on Instagram, August 2024">did</a>.
          I still code every day: software for the shop, and tools for booksellers. The rest of the week you'll find me behind
          the counter or running D&amp;D nights in the back.
        </p>
      </div>
      <figure class="home-hero__art">
        <picture>
          <source
            type="image/webp"
            srcset="/assets/storefront-watercolor-800.webp 800w, /assets/storefront-watercolor-1400.webp 1400w"
            sizes="(min-width: 60rem) 40vw, 22rem"
          />
          <img
            src="/assets/storefront-watercolor-800.jpg"
            srcset="/assets/storefront-watercolor-800.jpg 800w, /assets/storefront-watercolor-1400.jpg 1400w"
            sizes="(min-width: 60rem) 40vw, 22rem"
            alt="Watercolor painting of the Dungeon Books storefront: a wizard-and-book sign in the window, an A-frame chalkboard on the sidewalk, and a 'Come in, we're open' sign on the door"
            width="1500"
            height="2000"
            loading="eager"
          />
        </picture>
        <figcaption>Dungeon Books, Jersey City.</figcaption>
      </figure>
    </div>
  </section>
`;

const contact: Html = html`
  <section class="section section--contact">
    <div class="grid">
      <div class="col-span-text">
        <h2>Get in touch</h2>
        <p>
          Come by the shop, or reach me here. If you're building in or
          around the indie-bookstore space, I'm always up for a conversation.
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
      'Software engineer and co-owner of Dungeon Books, a sci-fi and fantasy bookstore in Jersey City. I build distributed systems and tools for the indie-bookstore trade.',
    path: '/',
    children: html`${hero}${contact}`,
  });
