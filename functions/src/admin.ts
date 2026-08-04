import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import { log } from "./shared/logger";
import { CONFIG } from "./shared/config";

/**
 * Audit Log Trigger: Automatically records sensitive admin actions.
 * Listens to a generic 'audit_events' collection or specific triggers.
 */
export const onAdminAction = onDocumentCreated(`${CONFIG.collections.auditLogs}/{logId}`, async (event) => {
  const data = event.data?.data();
  if (!data) return;

  log.info(`Admin Audit: ${data.adminEmail} performed ${data.action} on ${data.targetId}`);
  
  // Potential logic: Trigger email alerts for sensitive actions like 'delete_all_users'
});

/**
 * Custom function to assign Admin privileges via UID.
 * This should be restricted to a Super Admin or automated deployment script.
 */
export const setAdminClaims = async (uid: string) => {
  try {
    await admin.auth().setCustomUserClaims(uid, { admin: true });
    log.info(`Admin claims set for user: ${uid}`);
    
    // Also update Firestore for easier querying in the Admin Panel
    await admin.firestore().collection(CONFIG.collections.users).doc(uid).update({
      isAdmin: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
  } catch (error) {
    log.error(`Failed to set admin claims for ${uid}`, error);
  }
};
