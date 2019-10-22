<template>
  <div>
    <h1>All Tags</h1>
    <ul>
      <li v-for="tag in tags" :key="tag">
        <nuxt-link :to="`/tags/${tag}`">
          {{ tag }}
        </nuxt-link>
      </li>
    </ul>
  </div>
</template>

<script>
import articles from '~/data/articles.json';
import { getUniqueTags } from '~/lib/helpers';

export default {
  data() {
    return {
      tags: [],
    };
  },
  created() {
    this.tags = getUniqueTags(articles);
  },
};
</script>
