<template>
  <div>
    <TheNavbar />
    <main class="pt-16 md:pt-20 lg:pt-24">
      <nuxt />
    </main>
  </div>
</template>

<script>
import TheNavbar from '~/components/TheNavbar';

export default {
  components: {
    TheNavbar,
  },
};
</script>
