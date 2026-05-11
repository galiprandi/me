import { defineConfig } from 'astro/config'
import react from '@astrojs/react'

// https://astro.build/config
export default defineConfig({
  site: 'https://galiprandi.github.io',
  base: 'me',
  integrations: [react()],
})
