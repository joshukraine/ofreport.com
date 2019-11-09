<script>
import ArticleButton from '~/components/ArticleButton.vue';
import ArticleCallout from '~/components/ArticleCallout.vue';
import ArticleDivider from '~/components/ArticleDivider.vue';
import ArticleImage from '~/components/ArticleImage.vue';
import ArticleSpacer from '~/components/ArticleSpacer.vue';
import ArticleSvg from '~/components/ArticleSvg.vue';

export default {
  components: {
    ArticleButton,
    ArticleCallout,
    ArticleDivider,
    ArticleImage,
    ArticleSpacer,
    ArticleSvg,
  },
  props: {
    renderFn: {
      type: Function,
      required: true,
    },
    staticRenderFns: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      templateRender: null,
    };
  },
  created() {
    this.templateRender = this.renderFn;
    this.$options.staticRenderFns = this.staticRenderFns;
  },

  render(createElement) {
    return this.templateRender ? this.templateRender() : createElement('div', 'Rendering...');
  },
};
</script>
