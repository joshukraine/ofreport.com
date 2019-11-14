<template>
  <div class="article-divider bg-gray-300" :class="marginClasses" />
</template>

<script>
export default {
  props: {
    mt: {
      type: String,
      default: '8',
    },
    mb: {
      type: String,
      default: '8',
    },
  },
  computed: {
    marginClasses() {
      return `mt-${this.mt} mb-${this.mb}`;
    },
  },
};
</script>

<style scoped>
.article-divider {
  height: 4px;
}
</style>
