import rss from "@astrojs/rss";
import { getCollection } from "astro:content";

const base = import.meta.env.BASE_URL.replace(/\/$/, "");

export async function GET(context) {
  const posts = await getCollection("blog");
  const esPosts = posts
    .filter((p) => p.data.lang === "es" && !p.data.draft)
    .sort((a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf());

  return rss({
    title: "Germán Aliprandi — Blog",
    description: "Artículos sobre ingeniería de software, inteligencia artificial y arquitectura de sistemas.",
    site: context.site + base,
    items: esPosts.map((post) => ({
      title: post.data.title,
      pubDate: post.data.pubDate,
      description: post.data.description,
      link: `/blog/${post.data.postSlug}/es`,
    })),
    customData: `<language>es-ES</language>`,
  });
}
