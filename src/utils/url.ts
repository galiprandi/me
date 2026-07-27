/**
 * Base URL without trailing slash for safe path concatenation.
 * With `base: 'me'` in astro.config, `import.meta.env.BASE_URL` returns `/me/`.
 * This utility returns `/me` so you can write `${base}/blog/en` safely.
 */
export const base = import.meta.env.BASE_URL.replace(/\/$/, "");
