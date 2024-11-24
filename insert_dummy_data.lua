local block_size = 20000  -- Number of IDs each thread will use
local current_member_id
local current_card_id
local current_preference_id
local con  -- Define the connection variable for use in thread_init and event functions

function thread_init()
  -- Establish a database connection for each thread
  drv = sysbench.sql.driver()
  con = drv:connect({
    host = "tidb.hzgtyt1hqvvt.clusters.tidb-cloud.com",
    user = "root",
    password = "rootadmin",
    database = "transaction_demo",
    ssl_ca = "/home/m/Documents/code/costco/ca.cer"
  })
  -- Calculate unique starting IDs for each thread based on the thread ID
  local thread_id = sysbench.tid  -- Access thread-specific ID
  current_member_id = thread_id * block_size + 1
  current_card_id = thread_id * block_size + 1
  current_preference_id = thread_id * block_size + 1
end

function event()
  -- Generate the SQL query string for cards_on_file
  local cards_insert_query = string.format([[
    INSERT INTO cards_on_file (card_id, member_id, card_number, expiration_date, card_type)
    VALUES (%d, %d, "4111111111111111", "2025-12-31", "VISA")
  ]], current_card_id, current_member_id)

  -- Execute the insert for cards_on_file
  con:query(cards_insert_query)

  -- Generate the SQL query string for member_wallet_preferences
  local wallet_insert_query = string.format([[
    INSERT INTO member_wallet_preferences (preference_id, member_id, preference_name, preference_value)
    VALUES (%d, %d, "default_payment_method", "VISA")
  ]], current_preference_id, current_member_id)

  -- Execute the insert for member_wallet_preferences
  con:query(wallet_insert_query)

  -- Increment IDs for the next event within this thread's range
  current_member_id = current_member_id + 1
  current_card_id = current_card_id + 1
  current_preference_id = current_preference_id + 1
end

function thread_done()
  con:disconnect()
end