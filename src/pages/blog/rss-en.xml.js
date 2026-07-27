import rss from "@astrojs/rss";
import { getCollection } from "astro:content";

const base = import.meta.env.BASE_URL.replace(/\/$/, "");

export async function GET(context) {
  const posts = await getCollection("blog");
  const enPosts = posts
    .filter((p) => p.data.lang === "en" && !p.data.draft)
    .sort((a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf());

  return rss({
    title: "Germán Aliprandi — Blog",
    description: "Articles on software engineering, artificial intelligence, and system architecture.",
    site: context.site + base,
    items: enPosts.map((post) => ({
      title: post.data.title,
      pubDate: post.data.pubDate,
      description: post.data.description,
      link: `/blog/${post.data.postSlug}/en`,
    })),
    customData: `<language>en-US</language>`,
  });
}
