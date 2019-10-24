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
          {{ article.title }}
        </h2>
        <p class="mt-1 text-sm text-gray-400">
          <span>{{ article.author }}</span>
          <span>&middot; {{ article.date }}</span>
        </p>
        <p class="text-base">
          {{ article.preview }}
        </p>
      </div>
    </div>
    <p class="border-t pt-2 mt-6">
      <nuxt-link class="text-base font-bold" :to="`/blog/${article.basename}`">
        Read more
      </nuxt-link>
    </p>
  </div>
</template>

<script>
import CardImage from '~/components/CardImage.vue';

export default {
  components: {
    CardImage,
  },
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
  },
};
</script>
