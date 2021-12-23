-- pub enum TransactionStatus {
--     0 - Completed,
--     1 - Broadcast,
--     2 - MinedUnconfirmed,
--     3 - Imported,
--     4 - Pending,
--     5 - Coinbase,
--     6 - MinedConfirmed,
-- }

SELECT amount, fee, status, message, timestamp, cancelled, direction, send_count, valid, confirmations, mined_height, lower(hex(transaction_signature_key))
FROM completed_transactions 
ORDER BY timestamp
