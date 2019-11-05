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
  head() {
    return {
      meta: [
        { hid: 'og:url', property: 'og:url', content: site.url + this.$route.path },
        { hid: 'og:type', property: 'og:type', content: 'website' },
        { hid: 'og:title', property: 'og:title', content: site.title },
        { hid: 'og:description', property: 'og:description', content: site.description },
        { hid: 'og:image', property: 'og:image', content: site.image },
        { hid: 'og:image:width', property: 'og:image:width', content: '1200' },
        { hid: 'og:image:height', property: 'og:image:height', content: '630' },
        { property: 'og:site_name', content: site.name },
        { property: 'og:locale', content: 'en_US' },
      ],
      link: [
        { hid: 'canonical', rel: 'canonical', href: site.url + this.$route.path },
      ],
    };
  },
  components: {
    TheNavbar,
    TheFooter,
  },
};
</script>
