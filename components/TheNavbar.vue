<template>
  <div>
    <header
      class="fixed z-50 flex items-center justify-between w-full h-16 px-4 bg-white border-b border-gray-200 lg:px-6"
      :class="{ 'open-nav': navOpen }"
    >
      <nuxt-link class="block" to="/">
        <img class="w-40 md:w-48" src="~/assets/svg/ofr-logo.svg" />
      </nuxt-link>
      <div class="relative -mr-4">
        <button class="hamburger" @click="navOpen = !navOpen">MENU</button>
      </div>
      <nav
        class="px-4 pt-4 nav-menu lg:pt-0"
        :class="{ 'reveal-nav': navOpen }"
      >
        <div class="nav-link-wrapper">
          <nuxt-link
            class="nav-link"
            :class="{ 'nav-link-fadein nav-link-1': navOpen }"
            to="/family/"
          >
            Family
          </nuxt-link>
          <nuxt-link
            class="nav-link"
            :class="{ 'nav-link-fadein nav-link-2': navOpen }"
            to="/ministry/"
          >
            Ministry
          </nuxt-link>
          <nuxt-link
            class="nav-link"
            :class="{ 'nav-link-fadein nav-link-3': navOpen }"
            to="/blog/"
          >
            Blog
          </nuxt-link>
          <nuxt-link
            class="nav-link"
            :class="{ 'nav-link-fadein nav-link-1': navOpen }"
            to="/podcast/"
          >
            Podcast
          </nuxt-link>
          <nuxt-link
            class="nav-link"
            :class="{ 'nav-link-fadein nav-link-3': navOpen }"
            to="/archives/"
          >
            Archives
          </nuxt-link>
          <nuxt-link
            class="nav-link"
            :class="{ 'nav-link-fadein nav-link-4': navOpen }"
            to="/contact/"
          >
            Contact
          </nuxt-link>
          <nuxt-link
            class="nav-link"
            :class="{ 'nav-link-fadein nav-link-5': navOpen }"
            to="/donate/"
          >
            Donate
          </nuxt-link>
        </div>
      </nav>
    </header>
  </div>
</template>

<script>
export default {
  data() {
    return {
      navOpen: false,
    };
  },
  watch: {
    $route() {
      this.navOpen = false;
    },
  },
};
</script>

<style scoped>
.nav-menu {
  @apply .absolute .pb-20 .h-screen .w-full .overflow-y-auto;
  background: linear-gradient(to bottom, #127fbf 0%, #035388 100%);
  left: 100%;
  top: 4rem;
  transition: transform 0.2s ease-in-out;
}

.nav-link-wrapper {
  @apply .flex .flex-col;
}

.reveal-nav {
  transform: translateX(-100%);
}

.nav-link {
  @apply .relative .inline-block .py-6 .text-xl .text-white .font-header .no-underline .opacity-0;
  line-height: 0.75;
}

.nav-link:not(:last-of-type) {
  @apply .border-b .border-white;
}

.nav-link-fadein {
  @apply .opacity-100;
  transition: opacity 0.3s ease-in-out;
}

.nav-link-1 {
  transition-delay: 0.08s;
}

.nav-link-2 {
  transition-delay: 0.12s;
}

.nav-link-3 {
  transition-delay: 0.16s;
}

.nav-link-4 {
  transition-delay: 0.2s;
}

.nav-link-5 {
  transition-delay: 0.24s;
}

@screen sm {
  .nav-link-wrapper {
    @apply .max-w-xl .my-0 .mx-auto;
  }
}

@screen md {
  .nav-menu {
    top: 4rem;
  }

  .nav-link-wrapper {
    @apply .max-w-3xl;
  }

  .nav-link {
    @apply .text-3xl .py-8;
  }
}

@screen lg {
  .hamburger {
    @apply .hidden;
  }

  .nav-menu {
    @apply .p-0 .relative;
    background: #fff;
    bottom: 0;
    height: initial;
    left: initial;
    right: 0;
    top: 0;
    transform: translateX(0);
    width: initial;
  }

  .nav-link-wrapper {
    @apply .py-4 .flex .flex-row;
  }

  .nav-link:not(:last-of-type) {
    border-bottom: none;
  }

  .nav-link {
    @apply .py-0 .text-xl .ml-8 .opacity-100 .text-gray-500 .font-semibold;
    transition: color 150ms ease;
  }

  .nav-link:hover {
    @apply .text-blue-600;
    transition: color 150ms ease;
  }

  .nav-link::before {
    @apply .absolute .left-0 .invisible .w-full .bg-blue-600;
    bottom: -5px;
    content: '';
    height: 2px;
    transform: scaleX(0);
    transition: all 0.2s ease-in-out 0s;
  }

  .nav-link:hover::before {
    @apply .visible;
    transform: scaleX(1);
  }
}
</style>
