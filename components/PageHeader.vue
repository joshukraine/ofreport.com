<template>
  <section class="py-6 text-center sm:py-8 lg:pt-10 lg:pb-12">
    <!-- eslint-disable vue/no-v-html -->
    <h1 v-if="html"
        class="lg:text-6xl"
        v-html="title"
    />
    <!-- eslint-enable vue/no-v-html -->
    <h1 v-else class="lg:text-6xl">
      {{ title }}
    </h1>
  </section>
</template>

<script>
export default {
  props: {
    title: {
      type: String,
      required: true,
    },
    html: {
      type: Boolean,
      default: false,
    },
  },
};
</script>
