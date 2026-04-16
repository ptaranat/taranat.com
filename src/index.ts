import { Elysia } from 'elysia';
import { staticPlugin } from '@elysiajs/static';
import { homePage } from './pages/home.ts';
import { aboutPage } from './pages/about.ts';
import { blogPage } from './pages/blog.ts';
import { meetPage } from './pages/meet.ts';
import { resumeEnabled, resumePage } from './pages/resume.ts';
import { notFoundPage } from './pages/not-found.ts';
import { htmlResponse } from './lib/html.ts';

const app = new Elysia()
  .use(staticPlugin({ assets: 'public', prefix: '/' }))
  .get('/', () => htmlResponse(homePage()))
  .get('/about', () => htmlResponse(aboutPage()))
  .get('/blog', () => htmlResponse(blogPage()))
  .get('/meet', () => htmlResponse(meetPage()));

if (resumeEnabled) {
  app.get('/resume', () => htmlResponse(resumePage()));
}

app.onError(({ code }) => {
  if (code === 'NOT_FOUND') {
    return htmlResponse(notFoundPage(), { status: 404 });
  }
});

app.listen(Number(process.env.PORT ?? 3000));

console.log(`listening on http://localhost:${app.server?.port}`);
