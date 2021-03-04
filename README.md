![OFReport.com][screenshot]

# OFReport.com

> Our family blog, documenting our work in Ukraine

[![Netlify Status](https://api.netlify.com/api/v1/badges/69a46dc9-827c-4b08-8b75-0164feb31dce/deploy-status)](https://app.netlify.com/sites/ofreport/deploys)

## Overview

OFReport.com is a [Vue.js][vue] application built with [Nuxt.js][nuxt], and is deployed as a pre-generated static site on [Netlify][netlify]. In addition to Vue and Nuxt, several noteworthy supporting technologies have been used, including the following:

* [Tailwind CSS (v1)][tailwind]
* [markdown-it][markdown-it]
* [frontmatter-markdown-loader][fml]
* [Cloudinary][cloudinary]
* [Vuelidate][vuelidate]
* [vuejs-paginate][vuejs-paginate]

## Requirements

* [Node >= 14.x][node]
* [Yarn 1.x][yarn]

## Setup

To get started, clone/fork the repo, cd into it, and install the dependencies.

``` bash
$ yarn install
```

Pagination depends on the presence of the `PER_PAGE` environment variable, so make sure this is set on your system. One easy way to handle this is with a local `.env` file in the root of the project:

``` bash
$ echo "PER_PAGE=8" >> .env
```

## Development

Nuxt uses [Webpack as its build tool][nuxt-assets], and is also pre-configured for [hot module replacement][hmr]. To begin, start the development server on `localhost:3000`:

```bash
$ yarn dev
```

## Static Build

In addition to deploying server-rendered apps, Nuxt also works great as a [static site generator][static-gen]. That's how we're using it here. To pre-render the entire site as static HTML, CSS, and JavaScript files, run this command:

```bash
$ yarn generate
```

## Local HTTP Server

Sometimes in development it can be helpful to run the statically generated site with a local web server, simulating a production environment. I have found [http-server][] to be a great choice. Here's how I build and serve the static site on my local machine.

First, install http-server globally if you don't already have it.

```bash
$ npm install -g http-server
```

Next, build the site as explained in the previous section.

```bash
$ yarn generate
```

Finally, serve the site from the `dist/` folder.

```bash
$ http-server dist/ -p 8080
```

Visit `http://localhost:8080` and check out the site!

The generated site will be output to the `dist/` folder.

## Deployment

My preferred deployment solution for static sites is [Netlify][netlify]. It's ~~super cheap~~ FREE, and provides lots of nice extras like a CDN with [Netlify Edge][netlify-edge] and a [free SSL certificate][netlify-ssl]. The Nuxt docs provide a brief guide to [deployment with Netlify][nuxt-netlify-deploy].

For more information on deployment solutions for Nuxt, [visit their FAQ page][nuxt-faq].

## Webpack Bundle Analyzer

Nuxt provides a nice cli interface to [analyze the size of webpack output files][nuxt-analyze]. Run the following command to generate an interactive zoomable treemap.

```bash
$ yarn build --analyze
```

Output at `.nuxt/stats/client.html`:

![treemap][bundle-treemap]

## Code Style, Linting and Formatting

Project-specific JavaScript conforms to the [Airbnb][airbnb] code style.

JS linting is done with ESLint and extended with [eslint-plugin-vue][eslint-vue] and [eslint-config-airbnb-base][eslint-config-airbnb-base].

Code formatting is done with [Prettier][prettier].

I use [Neovim][neovim] as my editor along with the [coc.nvim][coc-nvim] plugin for code completion and asynchronous linting.

## Legal

Copyright © 2003–2021 Joshua and Kelsie Steele. Software is licensed under [MIT][license].

[airbnb]: https://github.com/airbnb/javascript
[bundle-treemap]: https://res.cloudinary.com/dnkvsijzu/image/upload/c_scale,f_auto,q_auto,w_1000/v1573627005/OFReport/assets/nuxt_stats_client.html_wpbbpp.png
[cloudinary]: https://cloudinary.com/invites/lpov9zyyucivvxsnalc5/ck3hvrdcnvaeftjds7ep
[coc-nvim]: https://github.com/neoclide/coc.nvim
[env-property]: https://nuxtjs.org/api/configuration-env#the-env-property
[eslint-config-airbnb-base]: https://yarnpkg.com/en/package/eslint-config-airbnb-base
[eslint-vue]: https://yarnpkg.com/en/package/eslint-plugin-vue
[fml]: https://hmsk.github.io/frontmatter-markdown-loader/
[hmr]: https://webpack.js.org/concepts/hot-module-replacement/
[http-server]: https://yarnpkg.com/en/package/http-server
[license]: https://github.com/joshukraine/ofreport.com/blob/master/LICENSE
[markdown-it]: https://yarnpkg.com/en/package/markdown-it
[neovim]: https://neovim.io/
[netlify]: https://www.netlify.com/
[node]: https://nodejs.org/en/
[nuxt-analyze]: https://nuxtjs.org/api/configuration-build/#analyze
[nuxt-assets]: https://nuxtjs.org/guide/assets
[nuxt-faq]: https://nuxtjs.org/faq
[nuxt-netlify-deploy]: https://nuxtjs.org/faq/netlify-deployment
[nuxt]: https://nuxtjs.org/
[prettier]: https://prettier.io/
[screenshot]: https://res.cloudinary.com/dnkvsijzu/image/upload/bo_1px_solid_rgb:e2e8f0,c_scale,f_auto,q_auto,w_1000/v1596887906/OFReport/assets/ofreport.com_screenshot_ejueay.png
[static-gen]: https://www.staticgen.com/nuxt
[tailwind]: https://v1.tailwindcss.com/
[vue]: https://vuejs.org/
[vuejs-paginate]: https://yarnpkg.com/en/package/vuejs-paginate
[vuelidate]: https://vuelidate.netlify.com/
[yarn]: https://yarnpkg.com/en/docs/install
[netlify-edge]: https://www.netlify.com/products/edge/
[netlify-ssl]: https://docs.netlify.com/domains-https/https-ssl/
