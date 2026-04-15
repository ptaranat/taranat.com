import { html, type Html } from '../lib/html.ts';
import { layout } from '../layouts/base.ts';

const hero: Html = html`
  <section class="section section--about-hero">
    <div class="grid">
      <div class="about-hero__text">
        <h1 class="display">About</h1>
        <p class="lede">
          I'm a founding engineer based in Jersey City. In 2024 I opened
          Dungeon Books, a sci-fi/fantasy/RPG bookstore and community space.
        </p>
      </div>
      <figure class="about-hero__photo">
        <img
          src="/assets/panat-headshot.jpg"
          alt="Panat Taranat"
          width="800"
          height="1200"
          loading="eager"
        />
      </figure>
    </div>
  </section>
`;

const journey: Html = html`
  <section class="section">
    <div class="grid">
      <div class="col-span-text">
        <h2>Thailand to Jersey City</h2>
        <p>
          I moved from Thailand to the US alone at 13 for boarding school at
          Choate. Showed up in Connecticut with a bag full of clothes.
          Figuring out an unfamiliar environment with no safety net became
          the template for how I work: drop somewhere new, clock what needs
          to happen, execute.
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
          I wanted to be a surgeon. At 18 you only know what a career looks
          like from the outside. By sophomore year of college I had pivoted
          to computational neuroscience, modeling how networks of neurons
          give rise to decisions. That thread pulled me into computer
          science without my noticing.
        </p>
        <p>
          I took a gap year to dig into graph theory and dynamical systems.
          The math that describes brains also describes most of the complex
          systems I was curious about, and I wanted to understand it
          properly before committing to a field. Then I went to grad school
          in Boston for hardware engineering. It was a big jump from a
          biology degree, but by then it made more sense to me than any
          other direction. I worked on brain-computer interfaces, wrote
          high-performance CUDA kernels for computer vision research, and
          spent my last two years teaching Linux kernel drivers and
          embedded systems to MS and PhD students.
        </p>
        <p>
          After grad school I pivoted once more, from hardware to cloud
          and distributed systems. At RapDev I built observability tooling
          for Fortune 500 companies. At Rokt I shipped distributed systems
          powering millions of upsells. These days I'm consulting.
        </p>
        <p>
          If there's a through-line, it's the space between layers of
          abstraction. Logic gates into microarchitecture. Microarchitecture
          into OS. OS into distributed systems. The interesting problems
          live at those intersections.
        </p>
      </div>
    </div>
  </section>
`;

const bookstore: Html = html`
  <section class="section">
    <div class="grid">
      <div class="col-span-text">
        <h2>Dungeon Books</h2>
        <p>
          Carrie and I met across a D&D table. A few sessions in, we were
          sketching what eventually became
          <a href="https://dungeonbooks.com" rel="noreferrer">Dungeon Books</a>,
          a sci-fi/fantasy/RPG bookstore that we opened in Jersey City in
          2024. Carrie came from a career in bookselling; I came in with a
          background in software and a personal collection that had been
          slowly taking over my apartment.
        </p>
        <p>
          The idea came from Appendix N in the original AD&D Dungeon
          Master's Guide, the reading list that inspired the people who
          wrote the game. The store is built around that premise: the same
          shelf can feed the novel you read at home and the campaign you
          run on Saturday. We wanted it to feel more like a friend's
          living room than a retail space, where someone could walk in for
          one book and leave with the one they didn't know they were
          looking for.
        </p>
        <p>
          We run it a little differently than most indie shops. The
          business side gets treated like a small product: we look at
          what's working, try things, and try to be honest with ourselves
          when something isn't. Year one came in at roughly 29% growth
          without loans or outside investors, which still feels surreal to
          type. The part I'm prouder of, though, is that every book on our
          shelves was picked by a person who reads them.
        </p>
        <p>
          Weekly D&D sessions in the back of the store are non-negotiable.
          A lot of our regulars met each other across a table of dice.
        </p>
        <p>
          Outside the shop, I teach AI and technology workshops at the
          Jersey City Free Public Library and give occasional presentations
          on technology and tabletop games at Liberty Science Center. Most
          of my consulting income goes back into the store and the programs
          we run around it.
        </p>
        <p class="about-press">
          <span class="about-press__label">Press:</span>
          <a href="https://www.indiebound.org/blog-posts/dungeon-books-jersey-citys-destination-sci-fi-fantasy-and-rpgs" rel="noreferrer">IndieBound</a>,
          <a href="https://jcitytimes.com/dungeon-books-is-the-latest-addition-to-a-gaming-neighborhood-downtown/" rel="noreferrer">Jersey City Times</a>,
          <a href="https://www.shelf-awareness.com/issue.html?issue=4831#m65357" rel="noreferrer">Shelf Awareness</a>.
        </p>
      </div>
      <figure class="about-figure">
        <img
          src="/assets/panat-carrie-storefront.jpg"
          alt="Panat and Carrie holding a giant d20 in front of the Dungeon Books storefront"
          width="1600"
          height="1067"
          loading="lazy"
        />
        <figcaption>Dungeon Books, Jersey City. Opened 2024.</figcaption>
      </figure>
    </div>
  </section>
`;

const elsewhere: Html = html`
  <section class="section">
    <div class="grid">
      <div class="col-span-text">
        <h2>Elsewhere in my head</h2>
        <ul class="about-interests">
          <li><strong>Reading.</strong> <a href="https://hardcover.app/@panat" rel="noreferrer">hardcover.app/@panat</a></li>
          <li><strong>Boardgames.</strong> <a href="https://kallax.io/u/PXNGH-Panat" rel="noreferrer">kallax.io/u/PXNGH-Panat</a></li>
          <li><strong>Code.</strong> <a href="https://github.com/ptaranat" rel="noreferrer">ptaranat</a>, <a href="https://github.com/script-wizards" rel="noreferrer">script-wizards</a>, <a href="https://github.com/dungeonbooks" rel="noreferrer">dungeonbooks</a></li>
        </ul>
      </div>
    </div>
  </section>
`;

export const aboutPage = (): Html =>
  layout({
    title: 'About — Panat Taranat',
    description:
      'Founding engineer, co-owner of Dungeon Books, and occasional workshop teacher in Jersey City.',
    path: '/about',
    children: html`${hero}${journey}${pivots}${bookstore}${elsewhere}`,
  });
