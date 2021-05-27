<template>
  <article
    class="
      flex flex-col
      justify-between
      h-full
      p-4
      overflow-hidden
      bg-white
      rounded-lg
      shadow-md
      md:mx-4
    "
  >
    <div>
      <div v-if="article.cover" class="mb-4 -mx-4 -mt-4">
        <card-image
          :article-cover="article.cover"
          :width="customWidth"
          :alt="altText"
        />
      </div>
      <div>
        <h2 class="mt-0 leading-none">
          <nuxt-link
            class="text-gray-900 hover:text-blue-600"
            :to="`/blog/${article.basename}/`"
          >
            {{ article.title }}
          </nuxt-link>
        </h2>

        <p class="mt-1 text-sm text-gray-600">
          <span>{{ article.author }}</span>
          <span>&middot; {{ publishedOn }}</span>
        </p>

        <div
          v-if="article.preview"
          class="preview-text"
          v-html="renderMd(article.preview)"
        />
      </div>
    </div>
    <div class="flex justify-between pt-2 mt-6 border-t">
      <nuxt-link class="text-base" :to="`/blog/${article.basename}/`">
        Read more
      </nuxt-link>

      <a
        v-if="article.pdf"
        :href="cdnLink(article.pdf)"
        title="Download PDF Newsletter"
        target="_blank"
        rel="noopener noreferrer"
      >
        <svg
          class="w-6 h-6 text-gray-400 fill-current hover:text-red-500"
          viewBox="0 0 640 640"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            d="M537.6 290.6c4.1-10.7 6.4-22.4 6.4-34.6 0-53-43-96-96-96-19.7 0-38.1 6-53.3 16.2C367 128.2 315.3 96 256 96c-88.4 0-160 71.6-160 160 0 2.7.1 5.4.2 8.1C40.2 283.8 0 337.2 0 400c0 79.5 64.5 144 144 144h368c70.7 0 128-57.3 128-128 0-61.9-44-113.6-102.4-125.4zm-132.9 88.7L299.3 484.7c-6.2 6.2-16.4 6.2-22.6 0L171.3 379.3c-10.1-10.1-2.9-27.3 11.3-27.3H248V240c0-8.8 7.2-16 16-16h48c8.8 0 16 7.2 16 16v112h65.4c14.2 0 21.4 17.2 11.3 27.3z"
          />
        </svg>
      </a>
    </div>
  </article>
</template>

<script>
import dayjs from 'dayjs';
import CardImage from '~/components/CardImage.vue';
import markdownit from '~/mixins/markdownit';

export default {
  components: {
    CardImage,
  },
  mixins: [markdownit],
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
      return this.featured ? '740' : '610';
    },
    publishedOn() {
      return dayjs(this.article.date).format('MMMM D, YYYY');
    },
    altText() {
      return this.article.caption ? this.article.caption : '';
    },
  },
  methods: {
    cdnLink(file) {
      return `https://d21yo20tm8bmc2.cloudfront.net/ofr/${file}`;
    },
  },
};
</script>

<style>
.preview-text p {
  @apply .text-base .font-serif;
}
</style>
