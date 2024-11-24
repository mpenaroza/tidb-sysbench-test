local block_size = 10000000  -- Block size per thread for unique IDs

function thread_init()
    -- Establish a secure database connection for each thread only once
    drv = sysbench.sql.driver()
    con = drv:connect("host=tidb.hzgtyt1hqvvt.clusters.tidb-cloud.com", 
                      "user=root", 
                      "password=rootadmin", 
                      "database=transaction_demo", 
                      "ssl-ca=/home/m/Documents/code/costco/ca.cer")  -- Path to your CA certificate

     -- Set starting point for each thread's counter to its unique range
    thread_member_counter = sysbench.tid * block_size
    thread_transaction_counter = sysbench.tid * block_size
end

-- Generates a unique member_id based on the thread ID
function generate_sequential_member_id()
    thread_member_counter = thread_member_counter + 1
    return thread_member_counter
end

-- Generates a unique transaction_id, incrementing by 1 each time it’s called
function generate_sequential_transaction_id()
    thread_transaction_counter = thread_transaction_counter + 1
    return thread_transaction_counter
end

function execute_transaction(member_id, transaction_id)
    -- Begin the transaction
    con:query("BEGIN;")

    -- Record Incoming API Request
    con:query(string.format([[
        INSERT INTO transaction_requests (transaction_id, member_id, api_message)
        VALUES ('%s', '%s', '{"api_message": "incoming_request"}');
    ]], transaction_id, member_id))

    -- Card on File Lookup
    con:query(string.format([[
        SELECT card_id, card_number, expiration_date, card_type
        FROM cards_on_file
        WHERE member_id = '%s';
    ]], member_id))

    -- Digital Wallet Preferences Lookup
    con:query(string.format([[
        SELECT preference_name, preference_value
        FROM member_wallet_preferences
        WHERE member_id = '%s';
    ]], member_id))

    -- Record Initial API Request to Set Up Customer Profile
    con:query(string.format([[
        INSERT INTO api_requests (transaction_id, member_id, api_endpoint, request_payload, request_time)
        VALUES ('%s', '%s', '/setup_customer_profile', '{"payload": "setup_profile"}', CURRENT_TIMESTAMP);
    ]], transaction_id, member_id))

    -- Update API Response After Customer Profile Setup
    con:query(string.format([[
        UPDATE api_requests
        SET response_payload = '{"response": "profile_created"}', status = 'completed'
        WHERE transaction_id = '%s';
    ]], transaction_id))

    -- Insert Record for Creating Stored Value Account
    con:query(string.format([[
        INSERT INTO stored_value_accounts (member_id, balance, currency_type)
        VALUES ('%s', 0.00, 'USD');
    ]], member_id))

    -- Update Stored Value Account for Account Setup Confirmation or Activation
    con:query(string.format([[
        UPDATE stored_value_accounts
        SET status = 'active'
        WHERE member_id = '%s';
    ]], member_id))

    -- Insert for Recording the Funding Transaction
    con:query(string.format([[
        INSERT INTO funding_transactions (transaction_id, member_id, account_id, amount, status)
        VALUES ('%s', '%s', '100', 100.00, 'initiated');
    ]], transaction_id, member_id))

    -- Update Funding Transaction Status
    con:query(string.format([[
        UPDATE funding_transactions
        SET status = 'completed'
        WHERE transaction_id = '%s';
    ]], transaction_id))

    -- Update for Recalculating and Finalizing the Available Balance
    con:query(string.format([[
        UPDATE stored_value_accounts
        SET available_balance = balance
        WHERE member_id = '%s';
    ]], member_id))

    -- Insert for Logging the Transaction Outcome
    con:query(string.format([[
        INSERT INTO transaction_outcomes (transaction_id, final_balance, outcome_status)
        VALUES ('%s', 100.00, 'completed');
    ]], transaction_id))

    -- Insert for Summarized Transaction Record
    con:query(string.format([[
        INSERT INTO recent_balance_activity (member_id, transaction_type, amount, summary_details)
        VALUES ('%s', 'reload', 100.00, 'Reloaded $100');
    ]], member_id))

    -- Commit the transaction
    con:query("COMMIT;")
end

function event()
    -- Generate a unique member ID and transaction ID for each transaction
    local member_id = generate_sequential_member_id()
    local transaction_id = generate_sequential_transaction_id()
    execute_transaction(member_id, transaction_id)
end
