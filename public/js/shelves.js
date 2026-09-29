// Mouse controls for the horizontal shelves. Touch already swipes them, and
// Windows Chrome draws an overlay scrollbar that only shows mid-scroll, so a
// mouse user otherwise sees rows that look like they end at the edge.
//
// Arrows at each end fade in on hover and scroll by most of a screen; each is
// shown only while there is more that way. Dragging a row scrolls it, and a
// drag never also opens the book it started on.

const DRAG_THRESHOLD = 5;
// Scroll snap can settle a few pixels short of either end, which would leave
// an arrow up with nothing left to scroll.
const EDGE_SLACK = 8;

for (const viewport of document.querySelectorAll('.shelf__viewport')) {
  const row = viewport.querySelector('.shelf__row');
  const prev = viewport.querySelector('.shelf__arrow--prev');
  const next = viewport.querySelector('.shelf__arrow--next');
  if (!row || !prev || !next) continue;

  const update = () => {
    const max = row.scrollWidth - row.clientWidth;
    viewport.classList.toggle('is-scrollable', max > EDGE_SLACK);
    const atStart = row.scrollLeft <= EDGE_SLACK;
    const atEnd = row.scrollLeft >= max - EDGE_SLACK;
    // Show before hide: hiding the focused arrow would drop keyboard focus to
    // the page, so it goes to the arrow back the other way, which has to be
    // visible to take it.
    if (!atStart) prev.hidden = false;
    if (!atEnd) next.hidden = false;
    if (atStart && document.activeElement === prev && !atEnd) next.focus();
    if (atEnd && document.activeElement === next && !atStart) prev.focus();
    prev.hidden = atStart;
    next.hidden = atEnd;
  };

  // behavior 'auto' defers to the CSS scroll-behavior, which is smooth only
  // when the reader has not asked for reduced motion.
  const page = (dir) => row.scrollBy({ left: dir * row.clientWidth * 0.8 });
  prev.addEventListener('click', () => page(-1));
  next.addEventListener('click', () => page(1));

  row.addEventListener('scroll', update, { passive: true });
  new ResizeObserver(update).observe(row);
  update();

  let start = null;
  let dragged = false;

  row.addEventListener('pointerdown', (e) => {
    if (e.pointerType !== 'mouse' || e.button !== 0) return;
    if (!viewport.classList.contains('is-scrollable')) return;
    start = { x: e.clientX, left: row.scrollLeft, id: e.pointerId };
    dragged = false;
  });

  row.addEventListener('pointermove', (e) => {
    if (!start || e.pointerId !== start.id) return;
    // Released somewhere we never heard about: this is a hover, not a drag.
    if ((e.buttons & 1) === 0) {
      start = null;
      return;
    }
    const dx = e.clientX - start.x;
    if (!dragged && Math.abs(dx) < DRAG_THRESHOLD) return;
    if (!dragged) {
      dragged = true;
      row.setPointerCapture(e.pointerId);
      row.classList.add('is-dragging');
    }
    row.scrollLeft = start.left - dx;
  });

  const end = () => {
    if (!start) return;
    start = null;
    row.classList.remove('is-dragging');
  };
  row.addEventListener('pointerup', end);
  // A cancelled drag gets no closing click to clear the flag, which would
  // then swallow the next real click on a book.
  row.addEventListener('pointercancel', () => {
    end();
    dragged = false;
  });
  // A press that leaves before it becomes a drag is never captured, so its
  // pointerup lands elsewhere. Forget it here instead.
  row.addEventListener('pointerleave', (e) => {
    if (start && !dragged && e.pointerId === start.id) start = null;
  });

  // The click that ends a drag lands on whatever book is under the pointer.
  row.addEventListener(
    'click',
    (e) => {
      if (!dragged) return;
      dragged = false;
      e.preventDefault();
      e.stopPropagation();
    },
    true,
  );

  // Links and covers are natively draggable; that would hijack the drag. A
  // shelf that cannot scroll has no drag of its own, so it keeps the native one.
  row.addEventListener('dragstart', (e) => {
    if (viewport.classList.contains('is-scrollable')) e.preventDefault();
  });
}
