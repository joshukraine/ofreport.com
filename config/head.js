import site from '../data/site.json';

export default {
  titleTemplate: (titleChunk) => {
    const baseTitle = 'Joshua and Kelsie Steele — Missionaries serving Christ in Ukraine';
    return titleChunk ? `${titleChunk} | ${baseTitle}` : baseTitle;
  },
  htmlAttrs: {
    lang: site.lang,
  },
  meta: [
    { charset: 'utf-8' },
    { name: 'viewport', content: 'width=device-width, initial-scale=1, viewport-fit=cover' },
    { hid: 'description', name: 'description', content: site.description },
    { hid: 'author', name: 'author', content: site.author },
    { hid: 'robots', name: 'robots', content: process.env.APP_ENV === 'prod' ? 'index,follow' : 'noindex,nofollow' },
  ],
  link: [
    { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
    { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css?family=Lato:700&display=swap' },
    { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css?family=Mate+SC&display=swap' },
    { rel: 'stylesheet', href: 'https://fonts.googleapis.com/icon?family=Material+Icons&display=swap' },
  ],
};
