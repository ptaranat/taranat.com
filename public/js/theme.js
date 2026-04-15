const KEY = 'user-color-scheme';

const systemMode = () =>
  matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';

const currentMode = () => {
  const v = localStorage.getItem(KEY);
  return v === 'light' || v === 'dark' ? v : systemMode();
};

document.addEventListener('DOMContentLoaded', () => {
  const btn = document.getElementById('theme-toggle');
  if (!btn) return;
  let mode = currentMode();
  document.documentElement.setAttribute('data-user-color-scheme', mode);

  btn.addEventListener('click', () => {
    mode = mode === 'light' ? 'dark' : 'light';
    localStorage.setItem(KEY, mode);
    document.documentElement.setAttribute('data-user-color-scheme', mode);
  });
});
