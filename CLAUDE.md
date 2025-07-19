# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OFReport.com is a family blog documenting missionary work in Ukraine. It's built as a Vue.js application using Nuxt.js and deployed as a pre-generated static site on Netlify.

## Development Commands

### Environment Setup
```bash
# Install dependencies
yarn install

# Set up environment variables (required for pagination)
echo "PER_PAGE=8" >> .env
```

### Development Workflow
```bash
# Start development server (includes markdown processing)
yarn dev

# Build for production
yarn build

# Generate static site for deployment
yarn generate

# Lint and format code
yarn lint
yarn lint:fix
```

### Content Management
```bash
# Process markdown articles to JSON (automatically run by dev/generate)
yarn md2json
```

## Architecture Overview

### Core Technologies
- **Nuxt.js 2.x**: Vue.js framework configured for static site generation
- **Tailwind CSS v1**: Utility-first CSS framework with custom theme
- **Markdown-it**: Markdown processing with frontmatter-markdown-loader
- **Cloudinary**: Image hosting and optimization

### Directory Structure

#### Content System
- `content/articles/*.md`: Blog articles with frontmatter metadata
- `data/articles.json`: Generated JSON from markdown files (auto-created by `md2json`)
- `content/pages/*.md`: Static page content

#### Application Structure
- `pages/`: Nuxt.js file-based routing
  - `blog/_slug.vue`: Dynamic blog post pages
  - `blog/page/_id.vue`: Paginated blog index
  - `tags/_tag/`: Tag-based article filtering with pagination
- `components/`: Vue components for UI elements
- `layouts/`: Page layout templates
- `config/`: Nuxt configuration modules
  - `dynamic-routes.js`: Generates routes for static generation
  - `feed.js`: RSS feed configuration
  - `head.js`: Meta tags and SEO configuration

#### Build System
- `nuxt.config.js`: Main Nuxt configuration
- `tailwind.config.js`: Tailwind CSS customization
- `netlify.toml`: Netlify deployment configuration

### Content Workflow

1. Articles are written in Markdown with frontmatter in `content/articles/`
2. The `md2json` script processes markdown files into `data/articles.json`
3. Dynamic routes are generated based on article slugs and pagination
4. Static site generation creates pre-rendered HTML files

### Key Patterns

- **Pagination**: Configured via `PER_PAGE` environment variable (default: 8)
- **Tag System**: Articles can have multiple tags for categorization
- **Dynamic Routes**: Generated programmatically for articles, pagination, and tags
- **Static Generation**: Entire site pre-rendered for optimal performance

### Environment Variables
- `PER_PAGE`: Articles per page for pagination (required)
- `OFR_RECAPTCHA_SITE_KEY`: reCAPTCHA key for contact forms
- `NODE_ENV`: Controls robots.txt behavior

## Deployment

The site is deployed to Netlify with automatic builds triggered by git pushes. Static generation creates the `dist/` folder which is served by Netlify's CDN.

## Testing and Quality

- ESLint with Airbnb configuration for JavaScript
- eslint-plugin-vue for Vue.js specific linting
- Prettier for code formatting
- Husky and lint-staged for pre-commit hooks