/* Cloudflare D1 SQLite */

/* Main user account information */
CREATE TABLE user_account (
    uuid TEXT PRIMARY KEY,
    nickname TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    organization TEXT,
    is_email_verified INTEGER NOT NULL DEFAULT 0,
    registered_at INTEGER NOT NULL,
    password_hash TEXT NOT NULL,
    updated_at INTEGER NOT NULL,

    -- Minimal KYC information
    ein TEXT, -- Employer Identification Number (EIN)
    business_address TEXT, -- Business address
    owner_name TEXT, -- Owner's full name
    phone_number TEXT, -- Contact phone number
    kyc_status TEXT NOT NULL DEFAULT 'pending', -- Status of KYC (e.g., 'pending', 'approved')
    kyc_verified_at INTEGER, -- Timestamp of KYC approval
    kyc_submitted_at INTEGER, -- Timestamp of KYC submission
    
    -- Optional: Business-related fields
    business_type TEXT, -- Type of business (e.g., LLC, Sole Proprietorship)
    industry TEXT -- Industry of the business (e.g., Tech, Retail)
);

/* Stripe customer data for payment processing */
CREATE TABLE stripe_customers (
    uuid TEXT PRIMARY KEY,
    email TEXT NOT NULL,
    stripe_customer_id TEXT NOT NULL UNIQUE,
    had_subscription_before INTEGER NOT NULL DEFAULT 0,
    current_product_id TEXT,
    current_period_end_at INTEGER,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (uuid) REFERENCES user_account (uuid) ON DELETE CASCADE
);

/* User activity tracking (e.g., actions, logins) */
CREATE TABLE activity_record (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    action_name TEXT NOT NULL,
    ip_address TEXT,
    country TEXT,
    ua_device TEXT,
    ua_os TEXT,
    ua_browser TEXT
);

/* Magic link login for passwordless authentication */
CREATE TABLE magic_link_login (
    login_token TEXT PRIMARY KEY UNIQUE,
    uuid TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    requested_at INTEGER NOT NULL,
    expire_at INTEGER NOT NULL,
    FOREIGN KEY (uuid) REFERENCES user_account (uuid) ON DELETE CASCADE
);

/* User session management (active sessions) */
CREATE TABLE login_session (
    session_id TEXT PRIMARY KEY,
    uuid TEXT NOT NULL,
    email TEXT NOT NULL,
    nickname TEXT NOT NULL,
    organization TEXT,
    stripe_customer_id TEXT,
    current_product_id TEXT,
    current_period_end_at INTEGER,
    had_subscription_before INTEGER,
    created_at INTEGER NOT NULL,
    expire_at INTEGER NOT NULL,
    ip_address TEXT,
    country TEXT,
    ua_device TEXT,
    ua_os TEXT,
    ua_browser TEXT,
    FOREIGN KEY (uuid) REFERENCES user_account (uuid) ON DELETE CASCADE
);

/* User registration records and referral tracking */
CREATE TABLE register_record (
    uuid TEXT PRIMARY KEY,
    email TEXT NOT NULL,
    referral_code TEXT,
    registered_at INTEGER NOT NULL,
    ip_address TEXT,
    country TEXT,
    ua_device TEXT,
    ua_os TEXT,
    ua_browser TEXT
);

/* Password reset token management */
CREATE TABLE password_reset_token (
    uuid TEXT PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    nickname TEXT,
    token TEXT NOT NULL,
    requested_at INTEGER NOT NULL,
    expire_at INTEGER NOT NULL,
    ip_address TEXT,
    FOREIGN KEY (uuid) REFERENCES user_account (uuid) ON DELETE CASCADE
);

/* Contact request management (for user inquiries) */
CREATE TABLE contact_requests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    contact_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    company TEXT,
    contact_message TEXT,
    ip_address TEXT,
    country TEXT,
    created_at INTEGER NOT NULL,
    is_replied TEXT NOT NULL DEFAULT 0,
    replied_at INTEGER
);
