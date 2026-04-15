const ESCAPES: Record<string, string> = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#39;',
};

const escape = (s: string): string => s.replace(/[&<>"']/g, (c) => ESCAPES[c]!);

export type Html = { readonly __html: string };

const isHtml = (v: unknown): v is Html =>
  typeof v === 'object' && v !== null && '__html' in (v as object);

export const raw = (s: string): Html => ({ __html: s });

const serialize = (v: unknown): string => {
  if (v == null || v === false) return '';
  if (isHtml(v)) return v.__html;
  if (Array.isArray(v)) return v.map(serialize).join('');
  return escape(String(v));
};

export const html = (
  strings: TemplateStringsArray,
  ...values: unknown[]
): Html => {
  let out = '';
  strings.forEach((str, i) => {
    out += str;
    if (i < values.length) out += serialize(values[i]);
  });
  return { __html: out };
};

export const htmlResponse = (h: Html, init?: ResponseInit): Response =>
  new Response(h.__html, {
    ...init,
    headers: {
      'content-type': 'text/html; charset=utf-8',
      ...(init?.headers ?? {}),
    },
  });
