<template>
  <article>
    <section class="container max-w-5xl mx-auto md:px-6 lg:px-4">
      <div class="my-6 sm:my-8 lg:my-12 text-center">
        <h1 class="lg:text-6xl">
          Pleased to meet you!
        </h1>
      </div>
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

export default {
  components: {
    DynamicMarkdown,
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
