import * as logger from "firebase-functions/logger";

/**
 * Centralized logging utility for production monitoring.
 */
export const log = {
  info: (message: string, data?: any) => logger.info(message, data),
  warn: (message: string, data?: any) => logger.warn(message, data),
  error: (message: string, error?: any) => logger.error(message, error),
  debug: (message: string, data?: any) => logger.debug(message, data),
};
