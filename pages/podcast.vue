<template>
  <article class="pb-8 md:pb-12">
    <section class="container max-w-2xl mx-auto">
      <DynamicMarkdown dir="pages" slug="podcast" />
    </section>
  </article>
</template>

<script>
import DynamicMarkdown from '~/components/DynamicMarkdown.vue';

export default {
  components: {
    DynamicMarkdown,
  },
  data() {
    return {
      description:
        'Documenting our journey to minister to displaced Ukrainians in Eastern Europe.',
      image:
        'https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,h_630,q_auto:best,w_1200/v1646995840/OFReport/assets/jtu_logo_horiz_12-6_lm3zil.png',
      title: 'Journey to Ukraine',
    };
  },
  head() {
    return {
      title: this.title,
      meta: [
        { hid: 'description', name: 'description', content: this.description },
        { hid: 'og:image', property: 'og:image', content: this.image },
        { hid: 'og:title', property: 'og:title', content: this.title },
        { hid: 'og:image:width', property: 'og:image:width', content: '1200' },
        { hid: 'og:image:height', property: 'og:image:height', content: '630' },
        {
          hid: 'og:description',
          property: 'og:description',
          content: this.description,
        },
        { hid: 'twitter:title', name: 'twitter:title', content: this.title },
        {
          hid: 'twitter:description',
          name: 'twitter:description',
          content: this.description,
        },
        { hid: 'twitter:image', name: 'twitter:image', content: this.image },
      ],
    };
  },
};
</script>

<style></style>
