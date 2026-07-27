import { getCollection, type CollectionEntry } from "astro:content";

/**
 * Get published posts for a given language, sorted by pubDate descending.
 */
export async function getPostsByLang(
  lang: "en" | "es",
): Promise<CollectionEntry<"blog">[]> {
  const allPosts = await getCollection("blog");
  return allPosts
    .filter((p) => p.data.lang === lang && !p.data.draft)
    .sort(
      (a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf(),
    );
}
