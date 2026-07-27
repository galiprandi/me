import { defineConfig } from 'astro/config'
import react from '@astrojs/react'
import sitemap from '@astrojs/sitemap'

// https://astro.build/config
export default defineConfig({
  site: 'https://galiprandi.github.io',
  base: 'me',
  image: {
    formats: ['avif', 'webp'],
  },
  integrations: [react(), sitemap()],
  redirects: {
    '/blog': '/blog/en',
  },
})
