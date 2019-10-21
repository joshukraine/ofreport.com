<template>
  <div>
    <h1>Articles tagged with: {{ tag }}</h1>
    <ArticlesList :all-articles="taggedArticles"
                  :start-page="1"
                  :root-segment="rootSegment"
    />
  </div>
</template>

<script>
import ArticlesList from '~/components/ArticlesList.vue';
import articles from '~/data/articles.json';

const stringParameterize = (tag) => tag.trim()
  .toLowerCase().replace(/[^a-zA-Z0-9 -]/, '').replace(/\s/g, '-');

export default {
  components: {
    ArticlesList,
  },
  asyncData({ params }) {
    const rootSegment = `tags/${params.tag}`;
    const taggedArticles = Object.values(articles).reverse()
      .filter((article) => {
        const safeTags = article.tags.map((tag) => stringParameterize(tag));
        return safeTags.includes(params.tag);
      })
      .map((article) => article);

    return {
      taggedArticles,
      tag: params.tag,
      rootSegment,
    };
  },
};
</script>
