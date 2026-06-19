import { Marked } from 'marked';
import { createHighlighterCoreSync } from 'shiki/core';
import { createJavaScriptRegexEngine } from 'shiki/engine/javascript';
import jsonc from '@shikijs/langs/jsonc';
import typescript from '@shikijs/langs/typescript';
import yaml from '@shikijs/langs/yaml';
import bash from '@shikijs/langs/bash';
import materialDarker from '@shikijs/themes/material-theme-darker';
import githubLight from '@shikijs/themes/github-light';

const highlighter = createHighlighterCoreSync({
  themes: [githubLight, materialDarker],
  langs: [jsonc, typescript, yaml, bash],
  engine: createJavaScriptRegexEngine(),
});

const supported = new Set(highlighter.getLoadedLanguages());
const aliases: Record<string, string> = { json: 'jsonc', js: 'typescript', ts: 'typescript', yml: 'yaml', sh: 'bash', shell: 'bash' };

const resolveLang = (lang?: string): string => {
  if (!lang) return 'text';
  const id = aliases[lang] ?? lang;
  return supported.has(id) ? id : 'text';
};

const escapeAttr = (s: string): string =>
  s
    .replace(/&/g, '&amp;')
    .replace(/"/g, '&quot;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\r\n?/g, '\n')
    .replace(/\n/g, '&#10;');

const marked = new Marked({ gfm: true });
marked.use({
  renderer: {
    code({ text, lang }) {
      const highlighted = highlighter.codeToHtml(text, {
        lang: resolveLang(lang),
        themes: { light: 'github-light', dark: 'material-theme-darker' },
      });
      return `<div class="code-block"><button class="code-copy" type="button" aria-label="Copy code" data-code="${escapeAttr(text)}">Copy</button>${highlighted}</div>`;
    },
  },
});

export const renderMarkdown = (md: string): string => marked.parse(md, { async: false }) as string;
