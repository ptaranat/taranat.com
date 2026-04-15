import { html, type Html } from '../lib/html.ts';
import { layout } from '../layouts/base.ts';
import { engagements } from '../data/engagements.ts';
import { emailLink } from '../lib/email.ts';

const hero: Html = html`
  <section class="section section--hero">
    <div class="grid">
      <div class="col-span-text">
        <h1 class="display">
          Founding engineer for early-stage startups.
        </h1>
        <p class="lede">
          I embed with teams that shipped fast, accumulated debt, and now
          need someone to make the stack scale without slowing them down. I
          clear the critical path, set up the infrastructure, and help hire
          the engineers who take it from there.
        </p>
      </div>
    </div>
  </section>
`;

const engagementsSection: Html = html`
  <section class="section section--engagements">
    <div class="grid">
      <header class="col-span-full section-header">
        <h2>Recent engagements</h2>
      </header>
      <ul class="engagements col-span-full">
        ${engagements.map(
          (e) => html`
            <li class="engagement">
              <div class="engagement-meta">
                <span class="engagement-period">${e.period}</span>
              </div>
              <div class="engagement-body">
                <h3 class="engagement-name">
                  ${e.url
                    ? html`<a href="${e.url}" rel="noreferrer">${e.company}</a>`
                    : e.company}
                </h3>
                <p class="engagement-outcome">${e.outcome}</p>
              </div>
            </li>
          `,
        )}
      </ul>
    </div>
  </section>
`;

const contact: Html = html`
  <section class="section section--contact">
    <div class="grid">
      <div class="col-span-text">
        <h2>Availability</h2>
        <p>
          Two engagements a year, six months at a time. At month six, we
          look at what got built and decide whether to keep going. You can
          book both if you insist. If that sounds like a fit, grab a slot.
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
    title: 'Panat Taranat — Founding Engineer',
    description:
      'Founding engineer for early-stage startups. I embed, clear tech debt, set up infrastructure, and help grow engineering teams.',
    path: '/',
    children: html`${hero}${engagementsSection}${contact}`,
  });
