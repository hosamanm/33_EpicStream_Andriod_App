import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { log } from "./shared/logger";

/**
 * Sends a push notification to a specific target audience.
 * Used by the Admin Panel to broadcast messages.
 */
export const sendAdminNotification = onCall(async (request) => {
  const { title, body, imageUrl, target, type, deepLinkType, deepLinkValue } = request.data;

  // Security: Check if caller is admin
  if (!request.auth?.token.admin) {
    throw new HttpsError("permission-denied", "Only admins can send notifications.");
  }

  log.info(`Sending notification: ${title} to target: ${target}`);

  const message: admin.messaging.MulticastMessage = {
    notification: {
      title,
      body,
      imageUrl,
    },
    data: {
      type,
      deepLinkType: deepLinkType || "",
      deepLinkValue: deepLinkValue || "",
    },
    tokens: [],
  };

  try {
    if (target === "all") {
      await admin.messaging().sendToTopic("all_users", {
        notification: { title, body, imageUrl },
        data: message.data,
      });
      return { success: true, message: "Notification sent to topic." };
    }

    // Since the platform is now fully free, specific targets like 'premium' are removed.
    // Logic for other custom segments can be added here in the future.

    return { success: true };
  } catch (error) {
    log.error("Failed to send notification", error);
    throw new HttpsError("internal", "Failed to send notification.");
  }
});
