<script>
import ArticleImage from '~/components/ArticleImage.vue';

export default {
  components: {
    ArticleImage,
  },
  props: {
    renderFn: {
      type: String,
      required: true,
    },
    staticRenderFns: {
      type: String,
      required: true,
    },
  },
  created() {
    /* eslint-disable no-new-func */
    this.templateRender = new Function(this.renderFn)();
    this.$options.staticRenderFns = new Function(this.staticRenderFns)();
    /* eslint-enable no-new-func */
  },

  render(createElement) {
    return this.templateRender ? this.templateRender() : createElement('div', 'Rendering');
  },
};
</script>
