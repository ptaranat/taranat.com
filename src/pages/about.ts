import { html, type Html } from '../lib/html.ts';
import { layout } from '../layouts/base.ts';

const hero: Html = html`
  <section class="section section--about-hero">
    <div class="grid">
      <div class="about-lead">
        <figure class="about-hero__photo">
          <picture>
            <source
              type="image/webp"
              srcset="/assets/panat-watercolor-400.webp 400w, /assets/panat-watercolor-736.webp 736w"
              sizes="26rem"
            />
            <img
              src="/assets/panat-watercolor-736.jpg"
              srcset="/assets/panat-watercolor-400.jpg 400w, /assets/panat-watercolor-736.jpg 736w"
              sizes="26rem"
              alt="Watercolor portrait of Panat Taranat"
              width="736"
              height="736"
              loading="eager"
            />
          </picture>
        </figure>
        <h1 class="display">About</h1>
        <p class="lede">
          I'm a software engineer based in Jersey City. In 2024 I opened
          Dungeon Books, a sci-fi and fantasy bookstore.
        </p>
        <h2>Dungeon Books</h2>
        <p>
          Carrie and I met across a D&amp;D table. A few sessions in, we were
          sketching what eventually became
          <a href="https://dungeonbooks.com" rel="noreferrer">Dungeon Books</a>,
          a sci-fi and fantasy bookstore we opened in Jersey City in
          2024. Carrie came from a career in bookselling; I came in with a
          background in software and a personal collection that had been
          slowly taking over my apartment.
        </p>
        <p>
          The idea came from
          <a href="https://hardcover.app/@panat/lists/appendix-n-inspirational-and-educational-reading" rel="noreferrer">Appendix N</a>
          in the original AD&amp;D Dungeon Master's Guide, the reading list that
          inspired the people who wrote the game. The store is built around that premise: the same
          shelf can feed the novel you read at home and the campaign you
          run on Saturday. We wanted it to feel more like a friend's
          living room than a retail space, where someone could walk in for
          one book and leave with one they weren't looking for. I call it foraging for ideas.
        </p>
      </div>
    </div>
  </section>
`;

const pivots: Html = html`
  <section class="section">
    <div class="grid">
      <div class="col-span-text">
        <h2>The pivot trail</h2>
        <p>
          I wanted to be a surgeon. I attended UConn with the intention of
          completing the 8 year BS/MD program. At 18 you only know what a career looks
          like from the outside. By sophomore year of college I had pivoted
          to computational neuroscience, modeling how networks of neurons
          give rise to decisions, cognition and language.
          That thread pulled me into computer science.
        </p>
        <p>
          I took a gap year to dig into graph theory and dynamical systems.
          The math that describes brains also describes most of the complex
          systems I was curious about, and I wanted to understand it
          properly before committing to a field. Then I went to grad school
          in Boston for hardware engineering. It was a big jump from a
          neurobiology degree, but my math background was highly transferrable.
          At Boston University, I worked on brain-computer interfaces, wrote
          high-performance CUDA kernels for computer vision research, and
          spent two years teaching Linux kernel driver development and
          embedded systems to MS and PhD students.
        </p>
        <p>
          After grad school I pivoted once more, from hardware to cloud
          and distributed systems. At RapDev I built observability tooling
          for Fortune 500 companies. At Rokt I shipped distributed systems
          powering millions of upsells.
        </p>
        <p>
          If there's a through-line, it's the space between layers of
          abstraction. Logic gates into microarchitecture. Microarchitecture
          into OS. OS into distributed systems. Interesting problems
          live at those intersections.
        </p>
      </div>
    </div>
  </section>
`;

const bookstore: Html = html`
  <section class="section">
    <div class="grid">
      <figure class="about-figure">
        <picture>
          <source
            type="image/webp"
            srcset="/assets/dungeonbooks-shelves-800.webp 800w, /assets/dungeonbooks-shelves-1500.webp 1500w"
            sizes="(min-width: 60rem) 65rem, 100vw"
          />
          <img
            src="/assets/dungeonbooks-shelves-1500.jpg"
            srcset="/assets/dungeonbooks-shelves-800.jpg 800w, /assets/dungeonbooks-shelves-1500.jpg 1500w"
            sizes="(min-width: 60rem) 65rem, 100vw"
            alt="Shelves of sci-fi and fantasy novels and RPG books inside Dungeon Books"
            width="1500"
            height="1000"
            loading="lazy"
          />
        </picture>
        <figcaption>Inside the shop.</figcaption>
      </figure>
      <div class="col-span-text">
        <p>
          We run it a little differently than most indie shops. The
          business side gets treated like a small product: we look at
          what's going well, experiment, and be honest with ourselves
          when something isn't working out. Year one came in at 29% growth
          without loans or outside investors, which feels surreal to
          type. The part I'm prouder of, though, is that every book on our
          shelves was picked by a person who reads them.
        </p>
        <p>
          Weekly D&amp;D sessions in the back of the store are non-negotiable.
          A lot of our regulars met each other across a table of dice.
        </p>
        <p>
          Outside the shop, I teach AI and technology workshops at the
          Jersey City Free Public Library and occassionally give presentations
          on technology and tabletop games at Liberty Science Center. Most
          of what I earn goes back into the store and the programs we run
          around it.
        </p>
        <p class="about-press">
          <span class="about-press__label">Press:</span>
          <a href="https://www.indiebound.org/blog-posts/dungeon-books-jersey-citys-destination-sci-fi-fantasy-and-rpgs" rel="noreferrer">IndieBound</a>,
          <a href="https://jcitytimes.com/dungeon-books-is-the-latest-addition-to-a-gaming-neighborhood-downtown/" rel="noreferrer">Jersey City Times</a>,
          <a href="https://www.shelf-awareness.com/issue.html?issue=4831#m65357" rel="noreferrer">Shelf Awareness</a>.
        </p>
      </div>
      <figure class="about-figure">
        <picture>
          <source
            type="image/webp"
            srcset="/assets/panat-carrie-storefront-800.webp 800w, /assets/panat-carrie-storefront-1280.webp 1280w"
            sizes="(min-width: 60rem) 65rem, 100vw"
          />
          <img
            src="/assets/panat-carrie-storefront-1280.jpg"
            srcset="/assets/panat-carrie-storefront-800.jpg 800w, /assets/panat-carrie-storefront-1280.jpg 1280w"
            sizes="(min-width: 60rem) 65rem, 100vw"
            alt="Panat and Carrie holding a giant d20 in front of the Dungeon Books storefront"
            width="1280"
            height="853"
            loading="lazy"
          />
        </picture>
        <figcaption>Panat and Carrie out front. Dungeon Books, Jersey City, opened 2024.</figcaption>
      </figure>
    </div>
  </section>
`;

const elsewhere: Html = html`
  <section class="section">
    <div class="grid">
      <div class="col-span-text">
        <h2>Elsewhere</h2>
        <ul class="about-interests">
          <li><strong>Reading.</strong> <a href="https://hardcover.app/@panat" rel="noreferrer">hardcover.app/@panat</a></li>
          <li><strong>Boardgames.</strong> <a href="https://kallax.io/u/PXNGH-Panat" rel="noreferrer">kallax.io/u/PXNGH-Panat</a></li>
          <li><strong>Music.</strong> <a href="https://www.last.fm/user/ptaranat" rel="noreferrer">last.fm/user/ptaranat</a></li>
          <li><strong>Code.</strong> <a href="https://github.com/ptaranat" rel="noreferrer">ptaranat</a>, <a href="https://github.com/script-wizards" rel="noreferrer">script-wizards</a>, <a href="https://github.com/dungeonbooks" rel="noreferrer">dungeonbooks</a></li>
          <li><strong>Social.</strong> <a href="https://x.com/ptaranat" rel="noreferrer">x.com/ptaranat</a>, <a href="https://www.linkedin.com/in/taranat" rel="noreferrer">linkedin.com/in/taranat</a></li>
        </ul>
      </div>
    </div>
  </section>
`;

export const aboutPage = (): Html =>
  layout({
    title: 'About — Panat Taranat',
    description:
      'Software engineer and co-owner of Dungeon Books, based in Jersey City.',
    path: '/about',
    children: html`${hero}${bookstore}${pivots}${elsewhere}`,
  });
