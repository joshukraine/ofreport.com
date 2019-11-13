<template>
  <div>
    <TheNavbar />
    <main class="pt-16 md:pt-20">
      <nuxt />
    </main>
    <TheFooter />
  </div>
</template>

<script>
import TheNavbar from '~/components/TheNavbar';
import TheFooter from '~/components/TheFooter.vue';
import site from '~/data/site.json';

export default {
  components: {
    TheNavbar,
    TheFooter,
  },
  computed: {
    canonicalUrl() {
      return `${site.url + this.$route.path}/`;
    },
  },
  head() {
    return {
      meta: [
        { property: 'og:site_name', content: site.name },
        { property: 'og:locale', content: 'en_US' },
        { hid: 'og:url', property: 'og:url', content: this.canonicalUrl },
        { hid: 'og:type', property: 'og:type', content: 'website' },
        { hid: 'og:title', property: 'og:title', content: site.title },
        { hid: 'og:description', property: 'og:description', content: site.description },
        { hid: 'og:image', property: 'og:image', content: site.image },
        { hid: 'og:image:width', property: 'og:image:width', content: '1200' },
        { hid: 'og:image:height', property: 'og:image:height', content: '630' },
        { hid: 'twitter:card', name: 'twitter:card', content: 'summary' },
        { hid: 'twitter:site', name: 'twitter:site', content: '@joshukraine' },
        { hid: 'twitter:url', name: 'twitter:url', content: this.canonicalUrl },
        { hid: 'twitter:title', name: 'twitter:title', content: site.title },
        { hid: 'twitter:description', name: 'twitter:description', content: site.description },
        { hid: 'twitter:image', name: 'twitter:image', content: site.image },
      ],
      link: [
        { hid: 'canonical', rel: 'canonical', href: this.canonicalUrl },
      ],
    };
  },
};
</script>
