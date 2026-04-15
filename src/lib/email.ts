import { html, type Html } from './html.ts';

const EMAIL_USER = 'panat';
const EMAIL_DOMAIN = 'taranat.com';

const humanReadable = (user: string, domain: string): string =>
  `${user} at ${domain.split('.').join(' dot ')}`;

export const emailLink = (): Html => html`
  <a
    class="obf-email"
    href="#"
    data-u="${EMAIL_USER}"
    data-d="${EMAIL_DOMAIN}"
  >${humanReadable(EMAIL_USER, EMAIL_DOMAIN)}</a>
`;
