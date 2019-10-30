<template>
  <div class="md:mx-4 p-4 h-full flex flex-col justify-between bg-white rounded-lg overflow-hidden shadow-md">
    <div>
      <div v-if="article.cover" class="-mx-4 -mt-4">
        <card-image :article-cover="article.cover"
                    :width="customWidth"
                    :alt="article.caption"
        />
      </div>
      <div>
        <h2 class="mt-4 leading-none">
          <nuxt-link class="text-gray-900 hover:text-blue-600" :to="`/blog/${article.basename}`">
            {{ article.title }}
          </nuxt-link>
        </h2>

        <p class="mt-1 text-sm text-gray-400">
          <span>{{ article.author }}</span>
          <span>&middot; {{ publishedOn }}</span>
        </p>

        <!-- eslint-disable-next-line vue/no-v-html -->
        <div class="preview-text" v-html="renderMd(article.preview)" />
      </div>
    </div>
    <p class="border-t pt-2 mt-6">
      <nuxt-link class="text-base" :to="`/blog/${article.basename}`">
        Read more
      </nuxt-link>
    </p>
  </div>
</template>

<script>
import CardImage from '~/components/CardImage.vue';
import markdownit from '~/mixins/markdownit';

export default {
  components: {
    CardImage,
  },
  mixins: [
    markdownit,
  ],
  props: {
    article: {
      type: Object,
      required: true,
    },
    featured: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    customWidth() {
      if (this.featured) {
        return '740';
      }
      return '610';
    },
    publishedOn() {
      const date = new Date(this.article.date);
      return this.$moment(date).format('MMMM D, YYYY');
    },
  },
};
</script>

<style>
.preview-text p {
  @apply .text-base;
}

h2 > a {
  @apply; }
</style>
