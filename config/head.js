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
    { name: 'msapplication-TileColor', content: '#2d89ef' },
    { name: 'theme-color', content: '#ffffff' },
  ],
  link: [
    { rel: 'apple-touch-icon', sizes: '180x180', href: '/apple-touch-icon.png' },
    {
      rel: 'icon', type: 'image/png', sizes: '32x32', href: '/favicon-32x32.png',
    },
    {
      rel: 'icon', type: 'image/png', sizes: '16x16', href: '/favicon-16x16.png',
    },
    { rel: 'manifest', href: '/site.webmanifest' },
    { rel: 'mask-icon', href: '/safari-pinned-tab.svg', color: '#5bbad5' },
    {
      rel: 'alternate', type: 'application/rss+xml', title: 'RSS Feed', href: 'https://ofreport.com/feed.xml',
    },
    { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css?family=Lato:700&display=swap' },
    { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css?family=Mate+SC&display=swap' },
    { rel: 'stylesheet', href: 'https://fonts.googleapis.com/icon?family=Material+Icons&display=swap' },
  ],
};
