<template>
  <article class="mb-8 md:mb-12">
    <PageHeader title="Hello!" />

    <section class="container max-w-xl mx-auto mt-6 sm:mt-8 md:mt-10 lg:mt-12">
      <p class="mt-0 text-center">
        Need to get in touch? Drop us a line!
      </p>

      <div class="mt-6 p-4 bg-white rounded shadow-md">
        <form @submit.prevent="validateFinal">
          <div :class="{ 'invalid': $v.name.$error }">
            <label class="form-label" for="name">
              Your Name
            </label>
            <input v-model.trim="$v.name.$model"
                   maxlength="100"
                   name="name"
                   placeholder="Jane Doe"
                   type="text"
                   class="form-input placeholder-gray-600 focus:placeholder-gray-400"
            >
            <p v-if="$v.name.$error" class="invalid-hint">
              Please provide your name.
            </p>
          </div>

          <div :class="{ 'invalid': $v.email.$error }" class="mt-6">
            <label class="form-label" for="email">
              Your Email
            </label>
            <input v-model.lazy.trim="$v.email.$model"
                   maxlength="100"
                   name="email"
                   placeholder="you@example.com"
                   type="email"
                   class="form-input placeholder-gray-600 focus:placeholder-gray-400"
            >
            <p v-if="!$v.email.required && $v.email.$dirty" class="invalid-hint">
              Please enter an email.
            </p>
            <p v-if="!$v.email.email" class="invalid-hint">
              Please enter a valid email.
            </p>
          </div>

          <div :class="{ 'invalid': $v.message.$error }" class="mt-6">
            <label class="form-label" for="message">
              Your Message
            </label>
            <textarea v-model.trim="$v.message.$model"
                      cols="30"
                      rows="10"
                      maxlength="3000"
                      name="message"
                      placeholder="What would you like to say?"
                      class="form-input placeholder-gray-600 focus:placeholder-gray-400 resize-none"
            />
            <p v-if="$v.message.$error" class="invalid-hint">
              Please enter a message.
            </p>
          </div>

          <input name="_gotcha" style="display: none;" type="text">
          <input type="submit"
                 value="Send"
                 :disabled="submitStatus === 'PENDING'"
                 class="btn btn-blue btn-lg block mt-6 w-full sm:w-auto outline-none focus:shadow-outline"
          >
        </form>
        <p v-if="status" class="text-right">
          {{ status }}
        </p>
      </div>
    </section>
  </article>
</template>

<script>
import { required, email } from 'vuelidate/lib/validators';
import PageHeader from '~/components/PageHeader.vue';

export default {
  components: {
    PageHeader,
  },
  data() {
    return {
      name: '',
      email: '',
      message: '',
      status: '',
      submitStatus: null,
    };
  },
  methods: {
    async postMessage() {
      try {
        await this.$axios.$post('/email/send/json', {
          name: this.name,
          email: this.email,
          content: this.message,
        });
        this.$v.$reset();
        this.formReset();
        this.submitStatus = 'OK';
        this.status = 'Message sent!';
      } catch (error) {
        this.status = 'Oops, there was an error!';
      }
    },
    formReset() {
      this.name = '';
      this.email = '';
      this.message = '';
    },
    validateFinal() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = 'ERROR';
      } else {
        this.submitStatus = 'PENDING';
        this.postMessage();
      }
    },
  },
  validations: {
    name: {
      required,
    },
    email: {
      required,
      email,
    },
    message: {
      required,
    },
  },
};
</script>

<style scoped>
.form-input {
  @apply .mt-2 .py-3 .px-4 .appearance-none .block .w-full .bg-gray-200 .border-2 .border-gray-200 .rounded;
}

.form-input:focus {
  @apply .outline-none .bg-white .border-2 .border-blue-600;
}

.form-label {
  @apply .block .uppercase .tracking-wide .text-gray-700 .text-xs .font-bold;
}

.invalid input,
.invalid textarea {
  @apply .border-red-500;
}

.invalid-hint {
  @apply .text-red-500 .text-sm .mt-1 .mb-0;
}
</style>
