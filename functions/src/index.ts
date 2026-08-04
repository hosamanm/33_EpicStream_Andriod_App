import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK
admin.initializeApp();

// Exporting functions from sub-modules
export * from "./users";
export * from "./notifications";
export * from "./movies";
export * from "./analytics";
export * from "./admin";
