import { SITE_ORIGIN } from '../layouts/base.ts';
import { listPosts } from './posts.ts';

const STATIC_PATHS = ['/', '/about', '/blog', '/meet'];

const xmlEscape = (s: string): string =>
  s.replace(/[&<>"']/g, (c) =>
    c === '&' ? '&amp;'
    : c === '<' ? '&lt;'
    : c === '>' ? '&gt;'
    : c === '"' ? '&quot;'
    : '&#39;',
  );

const cdata = (s: string): string => `<![CDATA[${s.replace(/]]>/g, ']]]]><![CDATA[>')}]]>`;

const rfc822 = (iso: string): string =>
  new Date(`${iso}T00:00:00Z`).toUTCString();

export const sitemapXml = (): string => {
  const posts = listPosts();
  const urls = [
    ...STATIC_PATHS.map((p) => ({ loc: `${SITE_ORIGIN}${p}`, lastmod: undefined as string | undefined })),
    ...posts.map((p) => ({ loc: `${SITE_ORIGIN}/blog/${p.slug}`, lastmod: p.date })),
  ];
  const body = urls
    .map(
      ({ loc, lastmod }) =>
        `  <url>\n    <loc>${xmlEscape(loc)}</loc>${lastmod ? `\n    <lastmod>${lastmod}</lastmod>` : ''}\n  </url>`,
    )
    .join('\n');
  return `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${body}\n</urlset>\n`;
};

export const robotsTxt = (): string =>
  `User-agent: *\nAllow: /\n\nSitemap: ${SITE_ORIGIN}/sitemap.xml\n`;

export const feedXml = (): string => {
  const posts = listPosts();
  const updated = posts[0]?.date;
  const items = posts
    .map((p) => {
      const link = `${SITE_ORIGIN}/blog/${p.slug}`;
      const description = p.description ?? p.excerpt.__html;
      return [
        '    <item>',
        `      <title>${xmlEscape(p.title)}</title>`,
        `      <link>${xmlEscape(link)}</link>`,
        `      <guid isPermaLink="true">${xmlEscape(link)}</guid>`,
        `      <pubDate>${rfc822(p.date)}</pubDate>`,
        `      <description>${cdata(description)}</description>`,
        '    </item>',
      ].join('\n');
    })
    .join('\n');
  return [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">',
    '  <channel>',
    '    <title>Panat Taranat — Blog</title>',
    `    <link>${SITE_ORIGIN}/blog</link>`,
    '    <description>Writing by Panat Taranat.</description>',
    '    <language>en</language>',
    `    <atom:link href="${SITE_ORIGIN}/feed.xml" rel="self" type="application/rss+xml" />`,
    updated ? `    <lastBuildDate>${rfc822(updated)}</lastBuildDate>` : '',
    items,
    '  </channel>',
    '</rss>',
    '',
  ]
    .filter((line) => line !== '')
    .join('\n');
};
