const md = require('markdown-it')({
  linkify: true,
  typographer: true,
});

const mila = require('markdown-it-link-attributes');

md.use(mila, {
  pattern: /^https?:\/\//,
  attrs: {
    target: '_blank',
    rel: 'noopener',
  },
});


export default {
  methods: {
    renderMd(input) {
      return md.render(input);
    },
    renderInlineMd(input) {
      return md.renderInline(input);
    },
  },
};
