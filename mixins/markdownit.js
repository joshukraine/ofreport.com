const md = require('markdown-it')({
  html: true,
  linkify: true,
  typographer: true,
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
