<template>
  <figure class="my-10">
    <cld-image
      :public-id="publicId"
      :width="width"
      :height="height"
      :alt="alt"
      crop="scale"
      quality="auto"
    />
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
