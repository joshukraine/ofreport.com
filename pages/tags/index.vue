<template>
  <article class="container text-center max-w-xl">
    <div class="my-6 sm:my-8 md:mb-0 lg:mt-12">
      <h1>Article Tags</h1>
    </div>

    <ul class="my-6">
      <li v-for="tag in tags"
          :key="tag[0]"
          class="py-4 sm:py-6 border-b last:border-b-0"
      >
        <nuxt-link :to="`/tags/${tag[0]}`" class="sm:text-xl">
          {{ tag[0] }} ({{ tag[1] }})
        </nuxt-link>
      </li>
    </ul>
  </article>
</template>

<script>
import articles from '~/data/articles.json';
import { getUniqueTags } from '~/config/utils/helpers';

export default {
  data() {
    return {
      tags: [],
    };
  },
  created() {
    this.tags = getUniqueTags(articles).sort();
  },
};
</script>
