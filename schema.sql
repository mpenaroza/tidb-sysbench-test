USE transaction_demo;

-- Drop existing tables if they exist for a clean start
DROP TABLE IF EXISTS transaction_requests;
DROP TABLE IF EXISTS cards_on_file;
DROP TABLE IF EXISTS member_wallet_preferences;
DROP TABLE IF EXISTS api_requests;
DROP TABLE IF EXISTS stored_value_accounts;
DROP TABLE IF EXISTS funding_transactions;
DROP TABLE IF EXISTS transaction_outcomes;
DROP TABLE IF EXISTS recent_balance_activity;

-- Stores incoming API requests
CREATE TABLE transaction_requests (
    transaction_id INT PRIMARY KEY,
    member_id INT,
    api_message VARCHAR(255),
    request_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stores card details for members
CREATE TABLE cards_on_file (
    card_id INT PRIMARY KEY,
    member_id INT,
    card_number VARCHAR(16),
    expiration_date DATE,
    card_type VARCHAR(10)
);

-- Stores preferences for digital wallets of members
CREATE TABLE member_wallet_preferences (
    preference_id INT PRIMARY KEY,
    member_id INT,
    preference_name VARCHAR(50),
    preference_value VARCHAR(50)
);

-- Tracks API requests for customer profile setup
CREATE TABLE api_requests (
    transaction_id INT PRIMARY KEY,
    member_id INT,
    api_endpoint VARCHAR(100),
    request_payload TEXT,
    response_payload TEXT,
    request_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    response_time TIMESTAMP,
    status VARCHAR(20)
);

-- Manages stored value accounts for members
CREATE TABLE stored_value_accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    balance DECIMAL(10, 2) DEFAULT 0.00,
    currency_type VARCHAR(3) DEFAULT 'USD',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(10) DEFAULT 'inactive',
    available_balance DECIMAL(10, 2) DEFAULT 0.00,
    last_updated TIMESTAMP
);

-- Records funding transactions for accounts
CREATE TABLE funding_transactions (
    transaction_id INT PRIMARY KEY,
    member_id INT,
    account_id INT,
    amount DECIMAL(10, 2),
    transaction_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20),
    completion_time TIMESTAMP
);

-- Logs outcomes of transactions
CREATE TABLE transaction_outcomes (
    transaction_id INT PRIMARY KEY,
    final_balance DECIMAL(10, 2),
    outcome_status VARCHAR(20),
    completed_at TIMESTAMP
);

-- Records recent balance activity for members
CREATE TABLE recent_balance_activity (
    activity_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    transaction_type VARCHAR(20),
    amount DECIMAL(10, 2),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    summary_details TEXT
);


-- For "Card on File Lookup" query
CREATE INDEX idx_cards_on_file_member_id ON cards_on_file (member_id);

-- For "Digital Wallet Preferences Lookup" query
CREATE INDEX idx_member_wallet_preferences_member_id ON member_wallet_preferences (member_id);

-- For "Update API Response After Customer Profile Setup" query
CREATE INDEX idx_api_requests_transaction_id ON api_requests (transaction_id);

-- For "Update Stored Value Account for Account Setup Confirmation or Activation" query
CREATE INDEX idx_stored_value_accounts_member ON stored_value_accounts (member_id);

-- Index for Updating Funding Transaction Status
CREATE INDEX idx_transaction_id ON funding_transactions (transaction_id);

-- Index for Updating Available Balance in Stored Value Accounts
CREATE INDEX idx_member_id ON stored_value_accounts (member_id);
