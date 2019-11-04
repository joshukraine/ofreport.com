<template>
  <article class="mb-8 md:mb-12">
    <PageHeader title="Hello!" />

    <section class="container max-w-xl mx-auto mt-6 sm:mt-8 md:mt-10 lg:mt-12">
      <p class="mt-0 text-center">
        Need to get in touch? Drop us a line!
      </p>

      <div class="mt-6 p-4 bg-white rounded shadow-md">
        <form class="contact-form" @submit.prevent="validateFinal">
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

          <input type="submit"
                 value="Send"
                 :disabled="submitPending"
                 class="btn btn-blue btn-lg block mt-6 w-full sm:w-auto outline-none focus:shadow-outline"
          >
        </form>
      </div>
    </section>
  </article>
</template>

<script>
import { required, email } from 'vuelidate/lib/validators';
import PageHeader from '~/components/PageHeader.vue';

export default {
  head() {
    return {
      title: 'Contact',
      meta: [
        { hid: 'description', name: 'description', content: 'Need to get in touch? Drop us a line!' },
      ],
    };
  },
  components: {
    PageHeader,
  },
  data() {
    return {
      name: '',
      email: '',
      message: '',
      submitPending: false,
    };
  },
  methods: {
    validateFinal() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.toastInvalid('Please check the highlighted fields for errors.', 3000);
      } else {
        this.submitPending = true;
        this.postMessage();
      }
    },
    async postMessage() {
      try {
        await this.$axios.$post('/email/send/json', {
          name: this.name,
          email: this.email,
          content: this.message,
        });
        this.toastSuccess('Thank you! Your message was sent.', 5000);
        this.formReset();
      } catch (error) {
        this.toastError('Oops, something went wrong. Message not sent! Please try again in a little while.', 5000);
        this.$v.$reset();
        this.submitPending = false;
      }
    },
    formReset() {
      this.name = '';
      this.email = '';
      this.message = '';
      this.$v.$reset();
      this.submitPending = false;
    },
    toastSuccess(message, duration) {
      this.$toast.success(message, { icon: 'done' }).goAway(duration);
    },
    toastInvalid(message, duration) {
      this.$toast.error(message, {
        icon: 'error_outline',
      }).goAway(duration);
    },
    toastError(message, duration) {
      this.$toast.error(message, {
        icon: 'error_outline',
      }).goAway(duration);
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

<style>
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
  @apply .border-red-600;
}

.invalid-hint {
  @apply .text-red-600 .text-sm .mt-1 .mb-0;
}

.toasted.toasted-primary {
  @apply .font-normal .text-base;
}

.toasted.toasted-primary.success {
  @apply .bg-green-600;
}

.toasted.toasted-primary.error {
  @apply .bg-red-600;
}

.toasted.toasted-primary.success,
.toasted.toasted-primary.error {
  @apply .justify-start .pb-2;
}

@media (max-width: 600px) {
  .toasted.toasted-primary.success,
  .toasted.toasted-primary.error {
    @apply .pb-6;
  }
}

.contact-form .btn:disabled {
  @apply .cursor-wait;
}
</style>
