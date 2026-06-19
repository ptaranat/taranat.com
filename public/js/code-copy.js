document.addEventListener('click', (e) => {
  if (!(e.target instanceof Element)) return;
  const btn = e.target.closest('.code-copy');
  if (!btn) return;

  const code = btn.dataset.code ?? '';
  if (!navigator.clipboard) {
    flash(btn, 'Failed');
    return;
  }
  navigator.clipboard.writeText(code).then(
    () => flash(btn, 'Copied'),
    () => flash(btn, 'Failed'),
  );
});

function flash(btn, label) {
  btn.textContent = label;
  btn.dataset.copied = 'true';
  clearTimeout(btn._reset);
  btn._reset = setTimeout(() => {
    btn.textContent = 'Copy';
    delete btn.dataset.copied;
  }, 1500);
}
