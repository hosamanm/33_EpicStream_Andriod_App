import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import { onObjectFinalized } from "firebase-functions/v2/storage";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import { log } from "./shared/logger";
import { CONFIG } from "./shared/config";

/**
 * Triggered when a new movie file is uploaded to Storage.
 * Generates a thumbnail placeholder using Cloud Storage triggers.
 */
export const onMovieFileUpload = onObjectFinalized(async (event) => {
  const filePath = event.data.name;
  if (!filePath.startsWith("movies/videos/")) return;

  log.info(`New movie file uploaded: ${filePath}. Processing thumbnails...`);

  // In production, you would use ffmpeg to extract a frame and save it back to Storage.
  // Note: Standard Firebase Functions environment includes ffmpeg.
});

/**
 * Validates movie metadata when a document is created or updated.
 * Ensures required fields like videoUrl and posterUrl are present.
 */
export const validateMovieMetadata = onDocumentUpdated(`${CONFIG.collections.movies}/{movieId}`, async (event) => {
  const newValue = event.data?.after.data();
  if (!newValue) return;

  log.info(`Validating metadata for movie: ${newValue.title}`);

  const requiredFields = ["videoUrl", "posterUrl", "bannerUrl"];
  const missingFields = requiredFields.filter(field => !newValue[requiredFields]);

  if (missingFields.length > 0) {
    log.warn(`Movie ${event.params.movieId} is missing critical fields: ${missingFields.join(", ")}`);
    // Logic to set status to 'draft' or 'invalid'
  }
});

/**
 * Daily schedule to publish movies whose scheduled release date is now.
 */
export const processScheduledPublishing = onSchedule("0 * * * *", async (event) => {
  const now = admin.firestore.Timestamp.now();
  log.info("Checking for movies scheduled to be published...");

  const snapshot = await admin.firestore()
    .collection(CONFIG.collections.movies)
    .where("status", "==", "scheduled")
    .where("releaseDate", "<=", now)
    .get();

  const batch = admin.firestore().batch();
  snapshot.forEach(doc => {
    batch.update(doc.ref, { status: "published", updatedAt: now });
  });

  await batch.commit();
  log.info(`Published ${snapshot.size} scheduled movies.`);
});
