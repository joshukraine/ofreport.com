<template>
  <article class="pb-8 subscribe md:pb-20">
    <PageHeader title="Subscribe" />

    <section class="container flex justify-between max-w-3xl">
      <figure class="hidden ofr-cover sm:block">
        <client-only>
          <cld-image public-id="OFReport/assets/OFR-Aug-Dec-2020_dxpdvm.jpg">
            <cld-transformation
              width="200"
              alt="Overseas Field Report"
              crop="scale"
              fetchFormat="auto"
              quality="auto:best"
            />
          </cld-image>
        </client-only>
      </figure>
      <div class="flex-1 sm:ml-6 md:ml-10 lg:ml-12">
        <div class="flex mb-6">
          <figure class="mr-4 ofr-cover sm:hidden">
            <client-only>
              <cld-image
                public-id="OFReport/assets/OFR-Aug-Dec-2020_dxpdvm.jpg"
              >
                <cld-transformation
                  width="100"
                  alt="Overseas Field Report"
                  crop="scale"
                  fetchFormat="auto"
                  quality="auto:best"
                />
              </cld-image>
            </client-only>
          </figure>
          <div class="flex-1 md:pr-6">
            <p class="mt-0 font-serif xs:text-lg">
              <em>Overseas Field Report</em> is our bi-monthly newsletter
              containing updates on our family and ministry here in Ukraine.
              We’d be tickled if you’d subscribe and pray for us!
            </p>
          </div>
        </div>
        <McSubscribeForm />
        <p class="font-serif">
          You can also access previous issues in our
          <nuxt-link to="/archives/">Archives.</nuxt-link>
        </p>

        <hr class="my-8 font-serif" />

        <p class="mt-0 font-serif">
          Don't want to receive emails from us anymore?
        </p>
        <p class="font-serif">
          <a
            href="https://OFReport.us6.list-manage.com/unsubscribe?u=1e0c65850b60905f65b151819&id=97b9f6a559"
            >Unsubscribe</a
          >
        </p>
      </div>
    </section>
  </article>
</template>

<script>
import McSubscribeForm from '~/components/McSubscribeForm.vue';
import PageHeader from '~/components/PageHeader.vue';

export default {
  components: {
    McSubscribeForm,
    PageHeader,
  },
};
</script>

<style scoped>
.ofr-cover img {
  @apply shadow-md;
  width: 70px;
}

@screen xs {
  .ofr-cover img {
    @apply shadow-lg;
    width: 100px;
  }
}

@screen sm {
  .ofr-cover img {
    width: 150px;
  }
}

@screen md {
  .ofr-cover img {
    width: inherit;
  }
}
</style>
