<template>
  <figure :class="verticalSpacing">
    <a v-if="link"
       :href="link"
       target="_blank"
    >
      <img :src="require(`../assets/svg/${name}.svg`)"
           :width="width"
           :alt="alt"
      >
    </a>
    <img v-else
         :src="require(`../assets/svg/${name}.svg`)"
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
    margin: {
      type: String,
      default: '',
    },
    link: {
      type: String,
      default: '',
    },
  },
  computed: {
    verticalSpacing() {
      const side = this.margin;
      const marginClasses = `m${side}-6 md:m${side}-8`;
      const options = ['t', 'b', 'y'];
      return options.includes(side) ? marginClasses : 'my-0';
    },
  },
};
</script>
