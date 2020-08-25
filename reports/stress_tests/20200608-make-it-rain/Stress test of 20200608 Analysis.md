# Stress test of 2020/06/08: Analysis

## Test Summary

First Tx submitted at 14:59:55 UCT.

Last Tx submitted at 15:46:33 UCT.

Sending wallets were shut down at 19:18:00 UCT at block 29438.

| Sending Wallet | Txs to base node wallets | Txs to mobile wallets | Txs total | Txs in unconfirmed     pool | Txs detected as mined | Txs in actual  blockchain  @ 19:18 | Txs in actual blockchain  @ 21:36 |
| -------------- | ------------------------ | --------------------- | --------- | --------------------------- | --------------------- | ---------------------------------- | --------------------------------- |
| pluto win 01   | 6420                     | 480                   | 6900      | 3862                        | 1251                  | ----------                         | ----------                        |
| pluto win 02   | 6420                     | 480                   | 6900      | 4067                        | 1188                  | ----------                         | ----------                        |
| pluto win 03   | 6420                     | 210                   | 6630      | 4969                        | 1918                  | ----------                         | ----------                        |
| hansie win 01  | 6420                     | 390                   | 6810      | 4090                        | 1201                  | ----------                         | ----------                        |
| hansie win 02  | 6420                     | 480                   | 6900      | 5194                        | 2306                  | ----------                         | ----------                        |
| hansie win 03  | 6420                     | 210                   | 6630      | 4312                        | 863                   | ----------                         | ----------                        |
| Totals         | 38520                    | 2250                  | 40770     | 26494                       | 8727                  | 10716                              | 11789                             |

Estimated number of blocks at 650 Txs/block for all 38520 Txs would have been 63.


## Wallet size after the test

| Node          | Wallet size  after <br>the test - TXOs | Wallet size  after <br/>the test - UTXOs | Wallet size  after <br/>the test - STXOs |
| ------------- | -------------------------------------- | ---------------------------------------- | ---------------------------------------- |
| pluto win 01  | 30957                                  | 11779                                    | 8099                                     |
| pluto win 02  | 34897                                  | 15180                                    | 4705                                     |
| pluto win 03  | 32372                                  | 12446                                    | 9040                                     |
| hansie win 01 | 26750                                  | 14289                                    | 2967                                     |
| hansie win 02 | 32603                                  | 10360                                    | 4574                                     |
| hansie win 03 | 25951                                  | 9402                                     | 4773                                     |
| Totals        | 183530                                 | 73456                                    | 34158                                    |

## Actual blockchain data

Txs were mined for a duration of 54 blocks, including Store & Forward Txs. Blocks with 1 or more Txs totaled 41, as listed below:

| Block # | UCT      | Tx kernels | Tx inputs | Tx outputs |
| ------- | -------- | ---------- | --------- | ---------- |
| 29409   | 15:07:47 | 646        | 747       | 1293       |
| 29410   | 15:09:51 | 648        | 689       | 1297       |
| 29411   | 15:16:56 | 651        | 711       | 1294       |
| 29412   | 15:19:51 | 657        | 704       | 1293       |
| 29413   | 15:25:05 | 648        | 692       | 1297       |
| 29414   | 15:27:26 | 647        | 709       | 1295       |
| 29415   | 15:39:17 | 647        | 710       | 1295       |
| 29416   | 15:42:40 | 646        | 747       | 1293       |
| 29418   | 17:33:43 | 322        | 357       | 645        |
| 29419   | 17:35:18 | 56         | 58        | 113        |
| 29420   | 17:53:08 | 64         | 68        | 129        |
| 29421   | 17:58:17 | 647        | 711       | 1295       |
| 29422   | 17:59:28 | 462        | 495       | 925        |
| 29423   | 18:02:16 | 98         | 111       | 197        |
| 29424   | 18:03:04 | 119        | 133       | 239        |
| 29425   | 18:07:48 | 646        | 748       | 1293       |
| 29426   | 18:13:56 | 460        | 505       | 921        |
| 29427   | 18:15:01 | 646        | 741       | 1293       |
| 29428   | 18:17:58 | 642        | 862       | 1285       |
| 29429   | 18:19:37 | 379        | 401       | 759        |
| 29430   | 18:19:55 | 86         | 86        | 173        |
| 29431   | 18:30:47 | 636        | 677       | 1273       |
| 29434   | 19:03:48 | 205        | 205       | 411        |
| 29435   | 19:07:17 | 2          | 2         | 5          |
| 29436   | 19:08:52 | 12         | 12        | 25         |
| 29437   | 19:10:15 | 1          | 1         | 3          |
| 29438   | 19:11:43 | 43         | 43        | 87         |
| 29439   | 19:21:32 | 4          | 4         | 9          |
| 29440   | 19:22:50 | 131        | 131       | 263        |
| 29441   | 19:26:59 | 9          | 9         | 19         |
| 29442   | 19:27:03 | 44         | 44        | 89         |
| 29443   | 19:28:29 | 4          | 4         | 9          |
| 29444   | 19:33:57 | 23         | 23        | 74         |
| 29445   | 19:34:09 | 49         | 49        | 99         |
| 29446   | 19:39:08 | 5          | 5         | 11         |
| 29447   | 19:40:14 | 42         | 42        | 85         |
| 29448   | 19:44:45 | 14         | 14        | 29         |
| 29449   | 19:45:27 | 37         | 37        | 75         |
| 29451   | 20:04:29 | 62         | 173       | 125        |
| 29462   | 20:26:42 | 648        | 680       | 1297       |
| 29465   | 20:35:30 | 1          | 1         | 3          |

## Messages dropped

Many messages were dropped internal to the base node, between the communication messages and the domain layer. Amount of messages dropped in the publisher-subscriber channel `[comms::middleware::pubsub]` for `Transaction Service` from `17:01:32` to `17:20:08` (19 s):

| Topic                           | Amount |
| ------------------------------- | ------ |
| BaseNodeResponse                | 89880  |
| MempoolResponse                 | 90434  |
| ReceiverPartialTransactionReply | 6328   |


