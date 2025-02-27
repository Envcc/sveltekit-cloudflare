import { dev } from "$app/environment";

function get_turnstile_sitekey() {
  if (dev) {
    // in development mode, use a dummy site key
    // This is a dummy site key for turnstile development purposes
    // The corresponding secret key is "1x0000000000000000000000000000000AA"
    return "1x00000000000000000000AA"; // no need to change this
  } else {
    // in production mode, use your own site key
    // This is the site key for the Turnstile service on Cloudflare,
    // which is okay to be public.
    return "0x4AAAAAAAVwJHWDABkhqpto"; // change this to your own site key
  }
}

export const TURNSTILE_SITEKEY = get_turnstile_sitekey();
export const WEBSITE_NAME = "MyNET30"; // change this to your own website name
export const APP_DOMAIN = "WWW.MyNET30.COM/"; // change this to your own domain
export const WEBSITE_DESCRIPTION =
  "MYNET30 is a trusted business credit builder that helps entrepreneurs and small businesses establish and strengthen their business credit profiles. Through our unique subscription-based service, we report your on-time payments to major credit bureaus such as Dun & Bradstreet, Experian Business, and Equifax Business, helping you build a solid foundation for future financing opportunities.";

export const LOGIN_TOKEN_TTL = 1 * 24 * (60 * 60); // the login token (cookie) will last for 1 day, in seconds
export const MAGIC_LINK_TOKEN_TTL = 1 * 1 * (30 * 60); // the magic login link will last for 30 mins, in seconds
export const EMAIL_VERIFY_TOKEN_TTL = 1 * 24 * (60 * 60); // the email verification token will last for 1 day, in seconds
export const RESET_PWD_TOKEN_TTL = 1 * 1 * (60 * 60); // the password reset token will last for 1 hour, in seconds
export const SUBSCRIPTION_PERIOD_LEEWAY = 2 * 24 * (60 * 60) * 1000 // give 2 days leeway for subscription period end time, in milliseconds

export const ENABLE_ERROR_LOGGING = true; // if true, error logs will be stored in R2 and sent to Lark group chat, check `src/lib/server/log.js` for more details
