<template>
  <article>
    <section class="container max-w-5xl mx-auto md:px-6 lg:px-4">
      <div class="my-6 sm:my-8 lg:my-12 text-center">
        <h1 class="lg:text-6xl">
          Pleased to meet you!
        </h1>
      </div>
      <cld-image public-id="OFReport/assets/steele-family-2018-12-6_sdixdx.jpg">
        <cld-transformation width="2000"
                            alt="The Steele Family, 2018"
                            crop="scale"
                            fetch-format="auto"
                            quality="auto"
        />
      </cld-image>
    </section>

    <section class="container max-w-3xl mx-auto mt-6">
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
.cld-image img {
  @apply rounded-lg;
}
</style>
