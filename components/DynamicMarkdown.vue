<template>
  <div>
    <component :is="markdownContent" />
  </div>
</template>

<script>
import ArticleButton from '~/components/ArticleButton.vue';
import ArticleCallout from '~/components/ArticleCallout.vue';
import ArticleDivider from '~/components/ArticleDivider.vue';
import ArticleImage from '~/components/ArticleImage.vue';
import ArticleSpacer from '~/components/ArticleSpacer.vue';
import ArticleSvg from '~/components/ArticleSvg.vue';

export default {
  props: {
    slug: {
      type: String,
      required: true,
    },
    dir: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      markdownContent: null,
      attributes: null,
    };
  },
  created() {
    this.markdownContent = () => import(`~/content/${this.dir}/${this.slug}.md`).then((md) => {
      this.attributes = md.attributes;
      return {
        extends: md.vue.component,
        components: {
          ArticleButton,
          ArticleCallout,
          ArticleDivider,
          ArticleImage,
          ArticleSpacer,
          ArticleSvg,
        },
      };
    });
  },
};
</script>
