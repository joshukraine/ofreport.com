<template>
  <article>
    <div v-if="fm.cover" style="background: linear-gradient(to bottom, #1f415c 0%, #0f2847 100%);">
      <div class="bg-cover bg-center h-64 sm:h-400px md:h-500px xl:h-600px"
           :style="{ backgroundImage: 'url(' + coverBgImage + ')' }"
      />
    </div>

    <div class="container">
      <div class="max-w-3xl mx-auto">
        <!-- eslint-disable vue/no-v-html -->
        <p v-if="fm.cover && fm.caption"
           class="mt-2 text-center text-sm sm:text-base text-gray-600 font-semibold"
           v-html="renderInlineMd(fm.caption)"
        />
        <!-- eslint-enable vue/no-v-html -->

        <div class="mt-3 md:mt-6 lg:mt-8 py-4 sm:pt-6">
          <h1 class="leading-none">
            {{ fm.title }}
          </h1>
          <p class="text-sm mt-1">
            <a v-if="authorHasLink"
               :href="articleAuthor.link"
               class="text-sm"
            >{{ articleAuthor.name }}</a>
            <span v-else class="text-gray-600">{{ articleAuthor.name }}</span>
            <span class="text-gray-600">&middot; {{ publishedOn }}</span>
          </p>

          <div v-if="fm.tags.length > 0" class="mt-4">
            <div v-for="tag in fm.tags"
                 :key="tag"
                 class="inline-block group"
            >
              <nuxt-link class="text-black" :to="`/tags/${safeTag(tag)}`">
                <span class="opacity-50 inline-block rounded-full bg-blue-600 px-3 py-1 leading-none text-xs text-white font-bold mr-2 mb-2 md:mb-0 group-hover:opacity-100">{{ tag }}</span>
              </nuxt-link>
            </div>
          </div>
        </div>
        <DynamicMarkdown
          :render-fn="renderFn"
          :static-render-fns="staticRenderFns"
        />
        <ArticleFooter />
      </div>
    </div>
  </article>
</template>

<script>
import dayjs from 'dayjs';
import ArticleFooter from '~/components/ArticleFooter.vue';
import DynamicMarkdown from '~/components/DynamicMarkdown.vue';
import authorData from '~/data/authors.json';
import markdownit from '~/mixins/markdownit';
import { parameterize, cldOptimize } from '~/config/utils/helpers';
import site from '~/data/site.json';

export default {
  components: {
    ArticleFooter,
    DynamicMarkdown,
  },
  mixins: [
    markdownit,
  ],
  async asyncData({ params }) {
    const article = await import(`~/content/articles/${params.slug}.md`);
    return {
      fm: article.attributes, // frontmatter
      renderFn: article.vue.render,
      staticRenderFns: article.vue.staticRenderFns,
    };
  },
  data() {
    return {
      authors: authorData.data,
      authorHasLink: false,
    };
  },
  computed: {
    articleAuthor() {
      return this.authors.find((author) => author.name === this.fm.author);
    },
    coverBgImage() {
      const opts = [
        'c_scale',
        'f_auto',
        'q_auto:best',
        'w_2000',
      ];
      return cldOptimize(this.fm.cover, opts);
    },
    ogImage() {
      const opts = ['c_fill', 'f_auto', 'h_630', 'q_auto', 'w_1200'];
      if (this.fm.cover) {
        return cldOptimize(this.fm.cover, opts);
      }
      return cldOptimize(site.image, opts);
    },
    publishedOn() {
      return dayjs(this.fm.date).format('MMMM D, YYYY');
    },
  },
  created() {
    try {
      if (Object.keys(this.articleAuthor).includes('link')) {
        this.authorHasLink = true;
      }
    } catch (error) {
      /* eslint-disable-next-line no-console */
      console.error(`UNKNOWN AUTHOR: Sorry, we have no author named "${this.fm.author}". Check your spelling, or add the new author to authors.json.`);
    }
  },
  methods: {
    safeTag(tag) {
      return parameterize(tag);
    },
  },
  head() {
    return {
      title: this.fm.title,
      meta: [
        { hid: 'author', name: 'author', content: this.fm.author },
        { hid: 'description', name: 'description', content: this.fm.preview },
        { hid: 'og:type', property: 'og:type', content: 'article' },
        { hid: 'article:author', property: 'article:author', content: this.fm.author },
        { hid: 'article:published_time', property: 'article:published_time', content: this.fm.date },
        { hid: 'og:title', property: 'og:title', content: this.fm.title },
        { hid: 'og:description', property: 'og:description', content: this.fm.preview },
        { hid: 'og:image', property: 'og:image', content: this.ogImage },
        { hid: 'twitter:title', name: 'twitter:title', content: this.fm.title },
        { hid: 'twitter:description', name: 'twitter:description', content: this.fm.preview },
        { hid: 'twitter:image', name: 'twitter:image', content: this.ogImage },
      ],
    };
  },
};
</script>
