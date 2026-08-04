import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import { log } from "./shared/logger";
import { CONFIG } from "./shared/config";

/**
 * Triggered when a user starts watching a movie.
 * Increments the global and per-movie view counts.
 */
export const onWatchEvent = onDocumentCreated("users/{uid}/watch_history/{historyId}", async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const movieId = data.movieId;
    log.info(`User ${event.params.uid} started watching movie ${movieId}`);

    const movieRef = admin.firestore().collection(CONFIG.collections.movies).doc(movieId);
    const platformStatsRef = admin.firestore().collection('dashboard_metrics').doc('latest');

    try {
        await admin.firestore().runTransaction(async (transaction) => {
            // Increment movie specific view count
            transaction.update(movieRef, {
                viewCount: admin.firestore.FieldValue.increment(1),
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
            });

            // Increment platform-wide watch hours (simplified)
            transaction.update(platformStatsRef, {
                totalWatchTimeMinutes: admin.firestore.FieldValue.increment(data.durationMinutes || 0),
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
            });
        });
    } catch (error) {
        log.error("Failed to update watch analytics", error);
    }
});

/**
 * Triggered when a user performs a search.
 * Aggregates popular search terms for the Trending Searches feature.
 */
export const onSearchEvent = onDocumentCreated("users/{uid}/search_history/{searchId}", async (event) => {
    const data = event.data?.data();
    if (!data || !data.query) return;

    const query = data.query.toLowerCase().trim();
    log.info(`User ${event.params.uid} searched for: ${query}`);

    const trendingRef = admin.firestore().collection('trending_searches').doc(query);

    try {
        await trendingRef.set({
            term: query,
            count: admin.firestore.FieldValue.increment(1),
            lastSearched: admin.firestore.FieldValue.serverTimestamp()
        }, { merge: true });
    } catch (error) {
        log.error("Failed to update search analytics", error);
    }
});
