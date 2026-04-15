import { Elysia } from 'elysia';
import { staticPlugin } from '@elysiajs/static';
import { homePage } from './pages/home.ts';
import { aboutPage } from './pages/about.ts';
import { blogPage } from './pages/blog.ts';
import { meetPage } from './pages/meet.ts';
import { resumeEnabled, resumePage } from './pages/resume.ts';
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

app.listen(Number(process.env.PORT ?? 3000));

console.log(`listening on http://localhost:${app.server?.port}`);
