import { auth } from "firebase-functions/v1";
import * as admin from "firebase-admin";
import { log } from "./shared/logger";
import { CONFIG } from "./shared/config";

/**
 * Triggered when a new user is created in Firebase Auth.
 * Initializes the user's Firestore profile with default values.
 */
export const onCreateUser = auth.user().onCreate(async (user) => {
  log.info(`Creating profile for new user: ${user.uid}`);

  const userProfile = {
    uid: user.uid,
    email: user.email || "",
    fullName: user.displayName || "OTT User",
    profileImage: user.photoURL || null,
    isAdmin: false,
    watchHistory: [],
    watchlist: [],
    downloads: [],
    preferredLanguage: "en",
    darkMode: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    lastLogin: admin.firestore.FieldValue.serverTimestamp(),
    isBlocked: false,
    deviceCount: 0,
    watchTimeMinutes: 0,
    downloadCount: 0,
  };

  try {
    await admin.firestore().collection(CONFIG.collections.users).doc(user.uid).set(userProfile);
    log.info(`User profile created successfully for ${user.uid}`);
  } catch (error) {
    log.error(`Failed to create user profile for ${user.uid}`, error);
  }
});

/**
 * Triggered when a user is deleted from Firebase Auth.
 * Cleans up user-specific data from Firestore.
 */
export const onDeleteUser = auth.user().onDelete(async (user) => {
  log.info(`Cleaning up data for deleted user: ${user.uid}`);

  try {
    await admin.firestore().collection(CONFIG.collections.users).doc(user.uid).delete();
    log.info(`User data cleanup completed for ${user.uid}`);
  } catch (error) {
    log.error(`Failed to cleanup user data for ${user.uid}`, error);
  }
});
