import Mode from 'frontmatter-markdown-loader/mode';
import markdownIt from 'markdown-it';
import mila from 'markdown-it-link-attributes';
import path from 'path';

export default {
  extractCSS: true,
  quiet: false,
  /* eslint-disable-next-line no-unused-vars */
  extend(config, ctx) {
    config.module.rules.push(
      {
        test: /\.md$/,
        include: path.resolve(__dirname, '../content'),
        loader: 'frontmatter-markdown-loader',
        options: {
          mode: [Mode.VUE_COMPONENT],
          markdownIt: markdownIt({
            html: true,
            linkify: true,
            typographer: true,
          }).use(mila, {
            pattern: /^https?:\/\//,
            attrs: {
              target: '_blank',
              rel: 'noopener noreferrer',
            },
          }),
          vue: {
            root: 'markdown',
          },
        },
      },
    );
  },
};
