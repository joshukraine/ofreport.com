<template>
  <div :class="heightClasses" />
</template>

<script>
export default {
  props: {
    height: {
      type: String,
      default: '10',
    },
    heightSm: {
      type: String,
      default: '10',
    },
  },
  computed: {
    heightClasses() {
      return `h-${this.height} sm:h-${this.heightSm}`;
    },
  },
};
</script>
