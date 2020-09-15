# Stress test planned for 2020/09/10

The next stress test is planned for the 10th of September 2020 at 16:00:00 UCT, after a stress test "break" of just over 2 months, in which time many system level improvements have been made. We are feeling confident :-).

## Test format

The format of the test will be to send 3600 transactions to 10 base node wallets and 216 transactions to 10 mobile wallets each. This will be sent from 6 sending base node wallets running on 2 computers. The estimated transaction submission time of all transactions will be approximately 46 minutes, which is the time it will take for 1 base node wallet to submit 6360 transactions, as this will run in parallel. The first full block is expected to be mined within 4 minutes after the test starts, with a theoretical minimum of 59 consecutive blocks to be filled after that to mine all the transactions, which will take at least 2 hours to complete. With the previous stress test, this proved to be closer to 4 hours, but we expect it to be better this time round!

See summary below.

| Node          | Txs submitted  -     base node wallets | Txs submitted  -     mobile wallets | Txs submitted  -     total |
| ------------- | -------------------------------------- | ----------------------------------- | -------------------------- |
| pluto win 01  | 6000                                   | 360                                 | 6360                       |
| pluto win 02  | 6000                                   | 360                                 | 6360                       |
| pluto win 03  | 6000                                   | 360                                 | 6360                       |
| hansie win 01 | 6000                                   | 360                                 | 6360                       |
| hansie win 02 | 6000                                   | 360                                 | 6360                       |
| hansie win 03 | 6000                                   | 360                                 | 6360                       |
| Totals        | 36000                                  | 2160                                | 38160                      |


|                                                              | blocks | Txs/s       | total time |
| ------------------------------------------------------------ | ------ | ----------- | ---------- |
| Theoretical limits at 650 Txs/block:                         | 59     | 5.416666667 | 01:58:00   |
| Estimated time to submit all transactions:                   | -      | -           | 00:45:53   |
| Previous stress test time to complete 81% of all transactions: | -      | -           | 03:51:15   |


## Invite to join or monitor the testing

Any Tari supporter can participate, either by providing a base node or mobile wallet to receive transactions, by running a base node to mine transactions, by running a base node to monitor the action in the mempool and on the blockchain, or just by running the Tari blockchain explorer in a browser to see the action.

Details of configuration settings, base node release version and mobile wallet release version required to join the testing will be communicated in due coarse.

