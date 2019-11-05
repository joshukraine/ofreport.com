<template>
  <article class="mb-8 md:mb-12">
    <section class="container max-w-5xl mx-auto md:px-6 lg:px-4">
      <PageHeader title="Pleased to meet you!" />
      <figure class="steele-bio">
        <cld-image public-id="OFReport/assets/steele-family-2018-12-6_sdixdx.jpg">
          <cld-transformation width="1000"
                              alt="The Steele Family, 2018"
                              crop="scale"
                              fetchFormat="auto"
                              quality="auto:best"
          />
        </cld-image>
        <figcaption class="mt-2 text-center font-semibold">
          The Steele Family<br>
          Joshua, Kelsie, Abigail, Rebekah, Hosanna, Kathryn, David, and
          <nuxt-link to="/blog/2019-10-14-meet-mia">
            Mia (not pictured)
          </nuxt-link>
        </figcaption>
      </figure>
    </section>

    <section class="container max-w-3xl mx-auto mt-6 sm:mt-8 md:mt-10 lg:mt-12">
      <DynamicMarkdown
        :render-fn="renderFn"
        :static-render-fns="staticRenderFns"
      />
    </section>
  </article>
</template>

<script>
import DynamicMarkdown from '~/components/DynamicMarkdown.vue';
import PageHeader from '~/components/PageHeader.vue';

export default {
  components: {
    DynamicMarkdown,
    PageHeader,
  },
  data() {
    return {
      description: 'Joshua and Kelsie are missionaries enjoying life as best friends, serving their Savior, and raising up their children to honor Him.',
      title: 'The Steele Family',
    };
  },
  head() {
    return {
      title: this.title,
      meta: [
        { hid: 'description', name: 'description', content: this.description },
        { hid: 'og:title', property: 'og:title', content: this.title },
        { hid: 'og:description', property: 'og:description', content: this.description },
        { hid: 'twitter:title', name: 'twitter:title', content: this.title },
        { hid: 'twitter:description', name: 'twitter:description', content: this.description },
      ],
    };
  },
  async asyncData() {
    const page = await import('~/content/pages/family.md');
    return {
      renderFn: page.vue.render,
      staticRenderFns: page.vue.staticRenderFns,
    };
  },
};
</script>

<style>
.steele-bio img {
  @apply rounded-lg;
}
</style>
