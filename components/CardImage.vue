<!-- eslint-disable vue/attribute-hyphenation -->
<template>
  <figure class="mt-4">
    <cld-image :public-id="`OFReport/${publicId}`">
      <cld-transformation :width="width"
                          :alt="alt"
                          crop="scale"
                          fetchFormat="auto"
                          quality="auto:best"
      />
    </cld-image>
  </figure>
</template>

<script>
export default {
  props: {
    articleCover: {
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
  computed: {
    publicId() {
      return this.articleCover.split('OFReport/')[1];
    },
  },
};
</script>
