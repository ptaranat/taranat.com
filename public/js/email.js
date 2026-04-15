document.querySelectorAll('.obf-email').forEach((el) => {
  const u = el.dataset.u;
  const d = el.dataset.d;
  if (!u || !d) return;
  const addr = u + '\u0040' + d;
  el.textContent = addr;
  el.href = 'mailto:' + addr;
});
