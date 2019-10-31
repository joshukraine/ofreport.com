<template>
  <section class="my-6 sm:my-8 lg:my-12 text-center">
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
