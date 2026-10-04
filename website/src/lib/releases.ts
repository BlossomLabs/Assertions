import type { CollectionEntry } from "astro:content";

/** Statuses the site publishes. Releases still in progress or only planned stay in the repo, unbuilt. */
const PUBLISHED = ["released", "upcoming"];

export const isPublished = (release: CollectionEntry<"releases">) =>
  PUBLISHED.includes(release.data.status);
