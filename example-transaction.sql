--Record Incoming API Request
INSERT INTO transaction_requests (transaction_id, member_id, api_message, request_time)
VALUES (?, ?, ?, CURRENT_TIMESTAMP);

--Card on File Lookup
SELECT card_id, card_number, expiration_date, card_type
FROM cards_on_file
WHERE member_id = ?;

--Digital Wallet Preferences Lookup
SELECT preference_name, preference_value
FROM member_wallet_preferences
WHERE member_id = ?;

--Record Initial API Request to Set Up Customer Profile
INSERT INTO api_requests (transaction_id, member_id, api_endpoint, request_payload, request_time)
VALUES (?, ?, '/setup_customer_profile', ?, CURRENT_TIMESTAMP);

--Update API Response After Customer Profile Setup
UPDATE api_requests
SET response_payload = ?, response_time = CURRENT_TIMESTAMP, status = 'completed'
WHERE transaction_id = ?;

--Insert Record for Creating Stored Value Account
INSERT INTO stored_value_accounts (member_id, balance, currency_type, created_at)
VALUES (?, ?, 0.00, 'USD', CURRENT_TIMESTAMP);

--Update Stored Value Account for Account Setup Confirmation or Activation
UPDATE stored_value_accounts
SET status = 'active', last_updated = CURRENT_TIMESTAMP
WHERE member_id = ?;

--Insert for Recording the Funding Transaction
INSERT INTO funding_transactions (transaction_id, member_id, account_id, amount, transaction_time, status)
VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP, 'initiated');

--Update Funding Transaction Status
UPDATE funding_transactions
SET status = 'completed', completion_time = CURRENT_TIMESTAMP
WHERE transaction_id = ?;

--Update for Recalculating and Finalizing the Available Balance
UPDATE stored_value_accounts
SET available_balance = balance - pending_amounts, last_updated = CURRENT_TIMESTAMP
WHERE member_id = ?;

--Insert for Logging the Transaction Outcome
INSERT INTO transaction_outcomes (transaction_id, final_balance, outcome_status, completed_at)
VALUES (?, ?, 'completed', CURRENT_TIMESTAMP);

--Insert for Summarized Transaction Record
INSERT INTO recent_balance_activity (member_id, transaction_type, amount, transaction_date, summary_details)
VALUES (?, 'reload', ?, CURRENT_TIMESTAMP, ?);


--Delete for Voided Transactions
DELETE FROM recent_balance_activity
WHERE transaction_id = ?;

--Insert or Update for Occasional Adjustments
UPDATE recent_balance_activity
SET amount = ?, summary_details = ?, last_updated = CURRENT_TIMESTAMP
WHERE transaction_id = ?;
