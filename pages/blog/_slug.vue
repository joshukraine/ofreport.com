<template>
  <div>
    <article>
      <div class="bg-cover bg-center h-56 sm:h-72 md:h-400px lg:h-500px xl:h-600px" :style="{ backgroundImage: 'url(' + fm.cover + ')' }" />
      <div class="container">
        <div class="max-w-3xl mx-auto">
          <p class="text-center text-base text-gray-500 font-semibold">
            {{ fm.caption }}
          </p>

          <div class="mt-6 py-8">
            <h1 class="leading-none">
              {{ fm.title }}
            </h1>
            <p class="text-sm mt-0">
              <a v-if="authorHasSocial"
                 :href="articleAuthor.social"
                 class="text-sm"
              >{{ articleAuthor.name }}</a>
              <span v-else class="text-gray-400">{{ articleAuthor.name }}</span>
              <span class="text-gray-400">&middot; {{ fm.date }}</span>
            </p>

            <div v-if="fm.tags.length > 0" class="mt-4">
              <div v-for="tag in fm.tags"
                   :key="tag"
                   class="inline-block group"
              >
                <nuxt-link class="text-black" :to="`/tags/${tag}`">
                  <span class="opacity-50 inline-block rounded-full bg-blue-600 px-3 py-1 leading-none text-xs text-white font-bold mr-2 mb-2 md:mb-0 group-hover:opacity-100">{{ tag }}</span>
                </nuxt-link>
              </div>
            </div>
          </div>
          <DynamicMarkdown
            :render-fn="renderFn"
            :static-render-fns="staticRenderFns"
          />
        </div>
      </div>
    </article>
  </div>
</template>

<script>
import DynamicMarkdown from '~/components/DynamicMarkdown.vue';
import authorData from '~/data/authors.json';

export default {
  components: {
    DynamicMarkdown,
  },
  data() {
    return {
      authors: authorData.data,
      authorHasSocial: false,
    };
  },
  computed: {
    articleAuthor() {
      return this.authors.find((author) => author.name === this.fm.author);
    },
  },
  async asyncData({ params }) {
    const article = await import(`~/content/articles/${params.slug}.md`);
    return {
      fm: article.attributes, // frontmatter
      renderFn: article.vue.render,
      staticRenderFns: article.vue.staticRenderFns,
    };
  },
  created() {
    try {
      if (Object.keys(this.articleAuthor).includes('social')) {
        this.authorHasSocial = true;
      }
    } catch (error) {
      /* eslint-disable-next-line no-console */
      console.error(`UNKNOWN AUTHOR: Sorry, we have no author named "${this.fm.author}". Check your spelling, or add the new author to authors.json.`);
    }
  },
};
</script>
