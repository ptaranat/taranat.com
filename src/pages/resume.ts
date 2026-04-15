import { html, raw, type Html } from '../lib/html.ts';

const PDF_URL = '/assets/panat_resume.pdf';

const isValidClientId = (s: string): boolean => /^[a-zA-Z0-9]{16,64}$/.test(s);

const rawClientId = process.env.ADOBE_CLIENT_ID ?? '';
const clientId: string | null =
  rawClientId && isValidClientId(rawClientId) ? rawClientId : null;

export const resumeEnabled: boolean = clientId !== null;

export const resumePage = (): Html => {
  if (!clientId) throw new Error('ADOBE_CLIENT_ID not set');
  return html`
<!doctype html>
<html lang="en" style="width:100%;height:100%">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta property="og:title" content="Panat Taranat" />
    <meta property="og:site_name" content="Panat Taranat" />
    <meta property="og:url" content="https://www.taranat.com/" />
    <title>Panat Taranat — Resume</title>
  </head>
  <body style="width:100%;height:100%;margin:0">
    <div id="adobe-dc-view"></div>
    <script src="https://documentcloud.adobe.com/view-sdk/main.js"></script>
    <script>${raw(`
      document.addEventListener('adobe_dc_view_sdk.ready', function () {
        var view = new AdobeDC.View({ clientId: '${clientId}', divId: 'adobe-dc-view' });
        view.previewFile(
          {
            content: { location: { url: window.location.origin + '${PDF_URL}' } },
            metaData: { fileName: 'panat_resume.pdf' }
          },
          {
            showDownloadPDF: true,
            showPageControls: true,
            dockPageControls: true,
            showLeftHandPanel: false,
            showAnnotationTools: false,
            defaultViewMode: 'FIT_WIDTH'
          }
        );
      });
    `)}</script>
  </body>
</html>
`;
};
