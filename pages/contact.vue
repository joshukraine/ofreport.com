<template>
  <article class="mb-8 md:mb-12">
    <PageHeader title="Hello!" />

    <section class="container max-w-xl mx-auto mt-6 sm:mt-8 md:mt-10 lg:mt-12">
      <p class="mt-0 text-center">
        Need to get in touch? Drop us a line!
      </p>

      <div class="mt-6 p-4 bg-white rounded shadow-md">
        <form>
          <label class="form-label" for="name">
            Your Name
          </label>
          <input maxlength="100"
                 name="name"
                 placeholder="Jane Doe"
                 type="text"
                 class="form-input placeholder-gray-600 focus:placeholder-gray-400"
          >

          <label class="form-label" for="email">
            Your Email
          </label>
          <input maxlength="100"
                 name="email"
                 placeholder="you@example.com"
                 type="email"
                 class="form-input placeholder-gray-600 focus:placeholder-gray-400"
          >
          <label class="form-label" for="message">
            Your Message
          </label>
          <textarea cols="30"
                    rows="10"
                    maxlength="3000"
                    name="message"
                    placeholder="What would you like to say?"
                    class="form-input placeholder-gray-600 focus:placeholder-gray-400 resize-none"
          />
          <input name="_gotcha" style="display: none;" type="text">
          <input type="submit" value="Send" class="btn btn-blue btn-lg block mt-6 w-full sm:w-auto">
        </form>
      </div>
    </section>
  </article>
</template>

<script>
import PageHeader from '~/components/PageHeader.vue';

export default {
  components: {
    PageHeader,
  },
};
</script>

<style scoped>
.form-input {
  @apply .mt-2 .mb-6 .py-3 .px-4 .appearance-none .block .w-full .bg-gray-200 .border-2 .border-gray-200 .rounded;
}

.form-input:focus {
  @apply .outline-none .bg-white .border-2 .border-blue-600;
}

.form-label {
  @apply .mb-2 .block .uppercase .tracking-wide .text-gray-700 .text-xs .font-bold;
}
</style>
