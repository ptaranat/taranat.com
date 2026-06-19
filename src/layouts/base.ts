import { html, type Html, raw } from '../lib/html.ts';
import { emailLink } from '../lib/email.ts';

const ASSET_VERSION = String(Date.now());

export const SITE_ORIGIN = 'https://taranat.com';
const DEFAULT_OG_IMAGE = '/assets/og.jpg';

type LayoutOpts = {
  title: string;
  description?: string;
  path: string;
  type?: 'website' | 'article';
  image?: string;
  children: Html;
};

const isCurrent = (href: string, current: string): boolean =>
  href === '/' ? current === '/' : current === href || current.startsWith(`${href}/`);

const nav = (current: string): Html => {
  const items = [
    { href: '/', label: 'Index' },
    { href: '/about', label: 'About' },
    { href: '/blog', label: 'Blog' },
    { href: '/meet', label: 'Meet' },
  ];
  return html`
    <nav class="site-nav" aria-label="Primary">
      <ul>
        ${items.map(
          (item) => html`
            <li>
              <a
                href="${item.href}"
                ${isCurrent(item.href, current) ? raw('aria-current="page"') : ''}
              >${item.label}</a>
            </li>
          `,
        )}
        <li class="site-nav__theme">
          <button
            id="theme-toggle"
            type="button"
            aria-label="Toggle color scheme"
          ></button>
        </li>
      </ul>
    </nav>
  `;
};

const preBodyScript = raw(`
(function(){
  try {
    var m = localStorage.getItem('user-color-scheme');
    if (m === 'light' || m === 'dark') {
      document.documentElement.setAttribute('data-user-color-scheme', m);
    }
  } catch (e) {}
})();
`);

export const layout = ({
  title,
  description,
  path,
  type = 'website',
  image = DEFAULT_OG_IMAGE,
  children,
}: LayoutOpts): Html => {
  const canonical = `${SITE_ORIGIN}${path}`;
  const ogImage = `${SITE_ORIGIN}${image}`;
  return html`
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>${title}</title>
    ${description ? html`<meta name="description" content="${description}" />` : ''}
    <link rel="canonical" href="${canonical}" />
    <meta property="og:type" content="${type}" />
    <meta property="og:site_name" content="Panat Taranat" />
    <meta property="og:title" content="${title}" />
    ${description ? html`<meta property="og:description" content="${description}" />` : ''}
    <meta property="og:url" content="${canonical}" />
    <meta property="og:image" content="${ogImage}" />
    <meta name="twitter:card" content="summary_large_image" />
    <meta name="twitter:title" content="${title}" />
    ${description ? html`<meta name="twitter:description" content="${description}" />` : ''}
    <meta name="twitter:image" content="${ogImage}" />
    <link rel="alternate" type="application/rss+xml" title="Panat Taranat — Blog" href="/feed.xml" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link
      rel="stylesheet"
      href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:ital,wght@0,400;0,500;0,600;0,700;1,400&family=Literata:ital,opsz,wght@0,7..72,400;0,7..72,500;0,7..72,600;0,7..72,700;1,7..72,400&display=swap"
    />
    <link rel="stylesheet" href="/styles/tokens/color.css?v=${ASSET_VERSION}" />
    <link rel="stylesheet" href="/styles/tokens/typography.css?v=${ASSET_VERSION}" />
    <link rel="stylesheet" href="/styles/tokens/grid.css?v=${ASSET_VERSION}" />
    <link rel="stylesheet" href="/styles/base.css?v=${ASSET_VERSION}" />
    <link rel="stylesheet" href="/styles/components.css?v=${ASSET_VERSION}" />
    <link rel="icon" type="image/x-icon" href="/favicon.ico" />
    <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png" />
    <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png" />
    <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />
    <link rel="manifest" href="/site.webmanifest" />
    <meta name="msapplication-config" content="/browserconfig.xml" />
    <meta name="theme-color" content="#14110e" />
    <script>${preBodyScript}</script>
  </head>
  <body>
    <a class="skip" href="#main">Skip to content</a>
    <header class="site-header">
      <div class="grid">
        <div class="site-masthead">
          <a class="site-title" href="/">PANAT TARANAT</a>
          <span class="site-subtitle">Software Engineer &amp; Bookstore Owner</span>
        </div>
        <details class="site-nav-wrapper">
          <summary class="site-nav-toggle" aria-label="Toggle menu"></summary>
          ${nav(path)}
        </details>
        <script>${raw(`(function(){
          var d = document.currentScript.previousElementSibling;
          var summary = d.querySelector('.site-nav-toggle');
          var mq = matchMedia('(min-width: 60rem)');
          var close = function(){ d.removeAttribute('open'); };
          var sync = function(){ mq.matches ? d.setAttribute('open','') : close(); };
          sync();
          mq.addEventListener('change', sync);
          summary.addEventListener('click', function(e){
            if(mq.matches) return;
            e.preventDefault();
            d.open ? close() : d.setAttribute('open','');
          });
          d.querySelectorAll('.site-nav a').forEach(function(a){
            a.addEventListener('click', function(){ if(!mq.matches) close(); });
          });
          document.addEventListener('click', function(e){
            if(!mq.matches && d.open && !d.contains(e.target)) close();
          });
          document.addEventListener('keydown', function(e){
            if(e.key === 'Escape' && !mq.matches && d.open){ close(); summary.focus(); }
          });
        })();`)}</script>
      </div>
    </header>
    <main id="main" class="site-main">
      ${children}
    </main>
    <footer class="site-footer">
      <div class="grid">
        <div class="col">
          <span>© ${String(new Date().getFullYear())} Panat Taranat</span>
        </div>
        <div class="col">
          ${emailLink()}
        </div>
      </div>
    </footer>
    <script src="/js/theme.js?v=${ASSET_VERSION}" defer></script>
    <script src="/js/email.js?v=${ASSET_VERSION}" defer></script>
    <script src="/js/code-copy.js?v=${ASSET_VERSION}" defer></script>
  </body>
</html>
`;
};
