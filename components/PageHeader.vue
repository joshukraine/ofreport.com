<template>
  <section class="py-6 sm:py-8 lg:py-12 text-center">
    <!-- eslint-disable-next-line vue/no-v-html -->
    <h1 v-if="html" class="lg:text-6xl" v-html="title" />
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
