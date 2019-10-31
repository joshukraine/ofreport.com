<template>
  <div>
    <a v-if="external"
       :href="path"
       :class="[bgStyle, verticalSpacing]"
       class="article-button btn md:btn-lg"
       target="_blank"
       rel="noopener noreferrer"
    >
      {{ text }}
    </a>
    <nuxt-link v-else
               :to="path"
               :class="[bgStyle, verticalSpacing]"
               class="article-button btn md:btn-lg"
    >
      {{ text }}
    </nuxt-link>
  </div>
</template>

<script>
export default {
  props: {
    text: {
      type: String,
      required: true,
    },
    path: {
      type: String,
      default: '',
    },
    external: {
      type: Boolean,
      required: true,
    },
    outline: {
      type: Boolean,
      required: true,
    },
    margin: {
      type: String,
      default: '',
    },
  },
  computed: {
    bgStyle() {
      return this.outline ? 'btn-blue-outline' : 'btn-blue';
    },
    verticalSpacing() {
      const side = this.margin;
      const marginClasses = `m${side}-6 md:m${side}-8`;
      const options = ['t', 'b', 'y'];
      return options.includes(side) ? marginClasses : 'my-0';
    },
  },
};
</script>

<style scoped>
.article-button {
  @apply .inline-block .text-sm;
}

@screen xs {
  .article-button {
    @apply .text-base;
  }
}
</style>
