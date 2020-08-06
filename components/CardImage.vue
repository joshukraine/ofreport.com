<template>
  <figure>
    <client-only>
      <cld-image
        :public-id="`OFReport/${publicId}`"
        loading="lazy"
        :width="width"
        :alt="alt"
      >
        <cld-transformation
          :width="width"
          crop="scale"
          fetchFormat="auto"
          quality="auto"
        />
      </cld-image>
    </client-only>
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
      default: '',
    },
  },
  computed: {
    publicId() {
      return this.articleCover.split('OFReport/')[1];
    },
  },
};
</script>
