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

    -- Minimal KYC information integrated into the user account table
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

/* Payment history for tracking financial transactions */
CREATE TABLE payment_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT NOT NULL,
    transaction_id TEXT NOT NULL UNIQUE,
    amount REAL NOT NULL,
    payment_status TEXT NOT NULL, -- Payment success/failure status
    transaction_date INTEGER NOT NULL, -- Payment timestamp
    FOREIGN KEY (uuid) REFERENCES user_account (uuid) ON DELETE CASCADE
);

/* User activity tracking (e.g., actions, logins) */
CREATE TABLE activity_record (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    action_name TEXT NOT NULL,
    event_category TEXT, -- Categorize the action (e.g., 'login', 'payment')
    metadata TEXT, -- Store extra context for actions (e.g., URL visited)
    ip_address TEXT,
    country TEXT,
    ua_device TEXT,
    ua_os TEXT,
    ua_browser TEXT,
    FOREIGN KEY (uuid) REFERENCES user_account (uuid) ON DELETE CASCADE
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
    created_at INTEGER NOT NULL,
    expire_at INTEGER NOT NULL,
    session_revoked INTEGER NOT NULL DEFAULT 0, -- Flag to revoke sessions
    refresh_token TEXT, -- Store refresh token for secure session management
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
    lead_status TEXT DEFAULT 'new', -- Manage lead status (e.g., 'new', 'follow_up')
    priority INTEGER DEFAULT 3, -- Set priority (1-High, 2-Medium, 3-Low)
    follow_up_date INTEGER, -- Set follow-up date
    ip_address TEXT,
    country TEXT,
    created_at INTEGER NOT NULL,
    is_replied INTEGER NOT NULL DEFAULT 0,
    replied_at INTEGER
);

/* KYC Approval and Documentation */
CREATE TABLE kyc_approval (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT NOT NULL,
    ein TEXT, 
    business_address TEXT, 
    owner_name TEXT, 
    phone_number TEXT, 
    email TEXT,
    verification_status TEXT NOT NULL DEFAULT 'pending', -- More granular status tracking
    documents_verified INTEGER NOT NULL DEFAULT 0, -- Flag for document verification
    verification_timestamp INTEGER,
    aml_check INTEGER NOT NULL DEFAULT 0, -- Flag for AML check
    kyc_verified_at INTEGER, 
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (uuid) REFERENCES user_account (uuid) ON DELETE CASCADE
);

/* Referral System for tracking user referrals */
CREATE TABLE referrals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    referrer_uuid TEXT NOT NULL,
    referred_uuid TEXT NOT NULL,
    referral_date INTEGER NOT NULL,
    reward_earned REAL,
    FOREIGN KEY (referrer_uuid) REFERENCES user_account (uuid) ON DELETE CASCADE,
    FOREIGN KEY (referred_uuid) REFERENCES user_account (uuid) ON DELETE CASCADE
);
