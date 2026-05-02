import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import matter from 'gray-matter';
import { marked } from 'marked';
import { raw, type Html } from './html.ts';

export type Post = {
  slug: string;
  title: string;
  date: string;
  description?: string;
  draft: boolean;
  body: Html;
  excerpt: Html;
};

const MORE = /<!--\s*more\s*-->/i;

const stripLeadingMedia = (md: string): string => {
  const blocks = md.split(/\n{2,}/);
  while (blocks.length > 0) {
    const first = blocks[0]!.trim();
    const isImageOnly = /^!\[[^\]]*\]\([^)]+\)\s*(\*[^*]+\*)?$/s.test(first);
    if (!isImageOnly) break;
    blocks.shift();
  }
  return blocks.join('\n\n');
};

const buildExcerpt = (raw: string): string => {
  const idx = raw.search(MORE);
  const source = idx >= 0 ? raw.slice(0, idx) : raw;
  const stripped = stripLeadingMedia(source);
  if (idx >= 0) return stripped.trim();
  const firstPara = stripped.split(/\n{2,}/).find((b) => b.trim().length > 0) ?? '';
  return firstPara.trim();
};

const POSTS_DIR = join(import.meta.dir, '..', 'content', 'posts');

const toIsoDate = (v: unknown): string => {
  if (v instanceof Date) return v.toISOString().slice(0, 10);
  if (typeof v === 'string') return v.slice(0, 10);
  throw new Error(`invalid post date: ${String(v)}`);
};

const load = (): Post[] => {
  const entries = readdirSync(POSTS_DIR).filter((f) => f.endsWith('.md'));
  const posts = entries.map((file) => {
    const slug = file.replace(/\.md$/, '');
    const src = readFileSync(join(POSTS_DIR, file), 'utf8');
    const { data, content } = matter(src);
    if (typeof data.title !== 'string') {
      throw new Error(`${file}: missing title`);
    }
    const fullContent = content.replace(MORE, '');
    const excerptMd = buildExcerpt(content);
    return {
      slug,
      title: data.title,
      date: toIsoDate(data.date),
      description: typeof data.description === 'string' ? data.description : undefined,
      draft: data.draft === true,
      body: raw(marked.parse(fullContent, { async: false }) as string),
      excerpt: raw(marked.parse(excerptMd, { async: false }) as string),
    } satisfies Post;
  });
  return posts.sort((a, b) => (a.date < b.date ? 1 : -1));
};

const isProd = process.env.NODE_ENV === 'production';
let cache: Post[] | null = null;

const all = (): Post[] => {
  if (isProd) return (cache ??= load());
  return load();
};

export const listPosts = (): Post[] => all().filter((p) => isProd ? !p.draft : true);

export const getPost = (slug: string): Post | undefined =>
  all().find((p) => p.slug === slug);

export const formatDate = (iso: string): string =>
  new Date(`${iso}T00:00:00Z`).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    timeZone: 'UTC',
  });
