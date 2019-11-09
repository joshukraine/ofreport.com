<template>
  <figure class="my-10 md:my-16">
    <cld-image :public-id="publicId">
      <cld-transformation :width="width"
                          :height="height"
                          :alt="caption"
                          crop="scale"
                          fetchFormat="auto"
                          quality="auto"
      />
    </cld-image>
    <figcaption v-if="caption" class="mt-2 text-center font-semibold">
      {{ caption }}
    </figcaption>
  </figure>
</template>

<script>
export default {
  props: {
    publicId: {
      type: String,
      required: true,
    },
    width: {
      type: String,
      default: '',
    },
    height: {
      type: String,
      default: '',
    },
    alt: {
      type: String,
      required: true,
    },
    caption: {
      type: String,
      default: null,
    },
  },
};
</script>

<style>
figure img {
  @apply .mx-auto;
}
</style>
