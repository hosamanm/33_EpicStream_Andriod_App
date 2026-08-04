import { Timestamp } from "firebase-admin/firestore";

/**
 * Shared utility functions for the OTT backend.
 */
export const Utils = {
  /**
   * Generates a standardized timestamp.
   */
  now: () => Timestamp.now(),

  /**
   * Standardized error response for HTTPS callables.
   */
  errorResponse: (message: string) => ({
    success: false,
    message,
  }),

  /**
   * Standardized success response for HTTPS callables.
   */
  successResponse: (data?: any) => ({
    success: true,
    data,
  }),
};
