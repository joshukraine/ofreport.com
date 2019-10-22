const parameterize = (tag) => tag.trim()
  .toLowerCase().replace(/[^a-zA-Z0-9 -]/, '').replace(/\s/g, '-');

export { parameterize as default };
