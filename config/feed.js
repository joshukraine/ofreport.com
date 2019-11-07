import markdownIt from 'markdown-it';
import dayjs from 'dayjs';
import articleData from '../data/articles.json';
import site from '../data/site.json';
import { cldOptimize } from './utils/helpers';

const md = markdownIt({
  linkify: true,
  typographer: true,
});

const feedImage = (img) => {
  const opts = [
    'c_scale',
    'f_auto',
    'q_auto',
    'w_560',
  ];
  return cldOptimize(img, opts);
};

export default () => {
  const feedConfig = {
    path: '/feed.xml',
    async create(feed) {
      const cpYear = dayjs().format('YYYY');
      const articles = Object.values(articleData).reverse();
      const recentArticles = articles.slice(0, 10);

      feed.options = {
        title: 'OFReport.com — Joshua and Kelsie Steele',
        description: 'Joshua and Kelsie are missionaries enjoying life as best friends, serving their Savior, and raising up their children to honor Him.',
        id: 'https://ofreport.com/',
        link: 'https://ofreport.com/feed.xml',
        language: site.lang,
        copyright: `Copyright ${cpYear}, Joshua and Kelsie Steele`,
      };

      recentArticles.forEach((a) => {
        feed.addItem({
          title: a.title,
          link: `${site.url}/blog/${a.basename}`,
          description: md.render(a.preview),
          date: new Date(a.iso8601Date),
          image: feedImage(a.cover),
        });
      });
    },
    cacheTime: 1000 * 60 * 15,
    type: 'rss2',
  };

  return feedConfig;
};
