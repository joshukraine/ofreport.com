<template>
  <div>
    <h1>Articles tagged with: {{ tag }}</h1>
    <ArticlesList :all-articles="taggedArticles"
                  :start-page="startPage"
                  :root-segment="rootSegment"
    />
  </div>
</template>

<script>
import ArticlesList from '~/components/ArticlesList.vue';
import articles from '~/data/articles.json';
import { parameterize } from '~/lib/helpers';

export default {
  components: {
    ArticlesList,
  },
  props: {
    startPage: {
      type: Number,
      required: true,
    },
  },
  data() {
    return {
      taggedArticles: [],
      rootSegment: null,
      tag: null,
    };
  },
  created() {
    this.rootSegment = `tags/${this.$route.params.tag}`;
    this.tag = this.$route.params.tag;
    this.taggedArticles = Object.values(articles).reverse()
      .filter((article) => {
        const safeTags = article.tags.map((tag) => parameterize(tag));
        return safeTags.includes(this.$route.params.tag);
      })
      .map((article) => article);
  },
};
</script>
