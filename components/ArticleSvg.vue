<template>
  <figure class="mb-8">
    <img :src="require(`../assets/svg/${name}.svg`)"
         :width="width"
         :alt="alt"
    >
  </figure>
</template>

<script>
export default {
  props: {
    name: {
      type: String,
      required: true,
    },
    width: {
      type: String,
      default: '',
    },
    alt: {
      type: String,
      required: true,
    },
  },
};
</script>
