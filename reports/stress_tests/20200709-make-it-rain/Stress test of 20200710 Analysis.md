# Stress test of 2020/07/09: Analysis

## Test Summary

First Tx submitted at 14:10:56 UCT at block 50868.

Last Tx submitted at 14:56:49 UCT at block 50874.

Sending wallets were shut down at 18:49:00 UCT at block 50955.

| Node          | Txs to BN wallets | Txs to mobile wallets | Txs total | Txs neg.           | Txs in unconf.     pool | Txs detected as mined | Txs pending       | Direct send,  immediate S&F | S&F             | Re-subm.         |
| ------------- | ----------------- | --------------------- | --------- | ------------------ | ----------------------- | --------------------- | ----------------- | --------------------------- | --------------- | ---------------- |
| pluto win 01  | 6000              | 360                   | 6360      | 5521               | 5453                    | 5516                  | 840               | -------                     | ----            | -------          |
| pluto win 02  | 6000              | 360                   | 6360      | 5518               | 5403                    | 1436                  | 719               | -------                     | ----            | -------          |
| pluto win 03  | 6000              | 360                   | 6360      | 5642               | 5462                    | 5626                  | 842               | -------                     | ----            | -------          |
| hansie win 01 | 6000              | 360                   | 6360      | 5453               | 2993                    | 5442                  | 899               | -------                     | ----            | -------          |
| hansie win 02 | 6000              | 360                   | 6360      | 5330               | 3162                    | 5279                  | 1040              | -------                     | ----            | -------          |
| hansie win 03 | 6000              | 360                   | 6360      | 5472               | 4164                    | 5459                  | 871               | -------                     | ----            | -------          |
| Totals        | 36000             | 2160                  | 38160     | 32936<br />(86.3%) | 26637<br />(69.8%)      | 28758<br />(75.4%)    | 5211<br />(13.7%) | 31075<br />(81.4%)          | 342<br />(0.9%) | 1535<br />(4.0%) |

The estimated number of blocks at 650 Txs/block for all 36000 Txs would have been 59 at 5.42 Txs/s, in a design time of 01:58:00.

The actual number of blocks filled with direct send were 52 for 33007 Txs at 2.24 Txs/s, in a time of 03:51:15.

_**Notes:**_ 

_- Sender attempted Txs query [DEBUG log]:_
  `^.*?(?:\b|_)Prepared transaction(?:\b|_).*?(?:\b|_)to send(?:\b|_).*?$` 

_- Sender finalized Txs query (Txs negotiated) [DEBUG log]:_
  `^.*?(?:\b|_)Finalized Transaction(?:\b|_).*?(?:\b|_)queued with Message(?:\b|_).*?$` 

_- Receiver finalized Txs query (Txs negotiated) [INFO log]:_
  `^.*?(?:\b|_)Completed Transaction(?:\b|_).*?(?:\b|_)detected as Broadcast to Base Node Mempool in UnconfirmedPool(?:\b|_).*?$`

_- Receiver & Sender Txs mined [INFO log]:_
  `^.*?(?:\b|_)Transaction(?:\b|_).*?(?:\b|_)detected as mined on the Base Layer(?:\b|_).*?$`

_- Receiver & Sender Txs pending [console]:_
  `list-transactions`


## Tx Sending Errors, Replaced by Immediate S&F

Multiple direct send errors of the type `Failed to send message 'Tag#13998820017666663628' to peer 'fed623c9c3150dac' because 'Dial was attempted, but failed'` were seen, resulting in an immediate Tx send by S&F, which were usually finalized quickly after that.

| Node          | Txs submitted<br /> - total | Direct send errors<br /> -> Immediate S&F after |
| ------------- | --------------------------- | ----------------------------------------------- |
| pluto win 01  | 6360                        | 1248                                            |
| pluto win 02  | 6360                        | 531                                             |
| pluto win 03  | 6360                        | 716                                             |
| hansie win 01 | 6360                        | 528                                             |
| hansie win 02 | 6360                        | 486                                             |
| hansie win 03 | 6360                        | 540                                             |
| Totals        | 38160                       | 4049                                            |

## Messages Dropped & Configurable Limits

Due to configurable buffer sizes and rate limits for the base node and base node wallet respectively (see PR#2044), no messages were dropped in the sending wallets. 

Limits used are set out below. The sending wallets need more resources and thus their buffers were doubled.

|              | buffer_size_ base_node | buffer_size_ base_node_wallet | buffer_rate_ limit_base_node | buffer_rate_ limit_base_node_wallet |
| ------------ | ---------------------- | ----------------------------- | ---------------------------- | ----------------------------------- |
| Sending BN   | 1500                   | 100000                        | 50                           | 80                                  |
| Receiving BN | 1500                   | 50000                         | 50                           | 80                                  |

Due to a spelling mistake in the configuration file setting distributed early on, `transacion_` instead of `transaction_`, many of the participating nodes may have used too aggressive polling intervals from the wallet to the base node. The intentionally configured settings would have reduced polling messages between the wallet and base node by a factor of 4. Busy base nodes also need more time to send Txs directly.

|                               | transaction_base_node_ monitoring_timeout | transaction_direct_ send_timeout | transaction_broadcast_ send_timeout |
| ----------------------------- | ----------------------------------------- | -------------------------------- | ----------------------------------- |
| Intentionally configured      | 120                                       | 180                              | 60                                  |
| Actual, due to spelling error | 30                                        | 20                               | 30                                  |



## Actual Blockchain Data

A total of 82.3% of the submitted Txs were mined. Of those 81.4% were mined as direct Txs (or immediate S&F if there was a direct send failure) in 49 consecutive blocks. After the initial mining epoch, an additional 0.9% Store & Forward Txs were mined. The next morning, after the sending wallets were restarted, another 4.0% Txs were mined due to those being re-submitted to the miners. Blocks with 1 or more Txs totaled 105, as listed below. The hugely delayed block times, during the 49 block full block epoch, can be attributed to only a portion of the miners running the fix that whereby full blocks are mined but rejected by the network because they exceed the block weight (PR#2038).

| Block # | UCT      | Blocktime | Tx kernels | Tx inputs | Tx outputs |
| ------- | -------- | --------- | ---------- | --------- | ---------- |
| 50870   | 14:14:20 | 00:02:13  | 614        | 1697      | 1227       |
| 50871   | 14:24:48 | 00:10:28  | 643        | 855       | 1285       |
| 50872   | 14:40:43 | 00:15:55  | 644        | 812       | 1287       |
| 50873   | 14:48:16 | 00:07:33  | 643        | 854       | 1285       |
| 50874   | 14:56:21 | 00:08:05  | 645        | 806       | 1289       |
| 50875   | 15:30:59 | 00:34:38  | 646        | 763       | 1291       |
| 50876   | 15:38:30 | 00:07:31  | 643        | 862       | 1284       |
| 50877   | 15:44:57 | 00:06:27  | 647        | 762       | 1292       |
| 50878   | 15:48:27 | 00:03:30  | 646        | 771       | 1291       |
| 50879   | 15:51:39 | 00:03:12  | 642        | 894       | 1283       |
| 50880   | 15:54:16 | 00:02:37  | 646        | 771       | 1291       |
| 50881   | 15:57:21 | 00:03:05  | 648        | 720       | 1295       |
| 50882   | 16:02:22 | 00:05:01  | 645        | 800       | 1289       |
| 50883   | 16:08:21 | 00:05:59  | 647        | 727       | 1293       |
| 50884   | 16:12:15 | 00:03:54  | 647        | 748       | 1293       |
| 50885   | 16:15:18 | 00:03:03  | 645        | 800       | 1289       |
| 50886   | 16:15:58 | 00:00:40  | 647        | 736       | 1293       |
| 50887   | 16:20:10 | 00:04:12  | 645        | 802       | 1289       |
| 50888   | 16:24:28 | 00:04:18  | 647        | 750       | 1293       |
| 50889   | 16:28:14 | 00:03:46  | 644        | 812       | 1287       |
| 50890   | 16:34:44 | 00:06:30  | 646        | 750       | 1291       |
| 50891   | 16:37:47 | 00:03:03  | 645        | 793       | 1288       |
| 50892   | 16:39:58 | 00:02:11  | 647        | 726       | 1293       |
| 50893   | 16:41:48 | 00:01:50  | 647        | 739       | 1293       |
| 50894   | 16:46:46 | 00:04:58  | 645        | 782       | 1289       |
| 50895   | 16:48:57 | 00:02:11  | 645        | 789       | 1289       |
| 50896   | 16:55:12 | 00:06:15  | 646        | 764       | 1291       |
| 50897   | 16:57:08 | 00:01:56  | 646        | 766       | 1291       |
| 50898   | 17:00:17 | 00:03:09  | 645        | 808       | 1289       |
| 50899   | 17:05:48 | 00:05:31  | 646        | 767       | 1291       |
| 50900   | 17:06:21 | 00:00:33  | 645        | 786       | 1289       |
| 50901   | 17:08:09 | 00:01:48  | 646        | 779       | 1291       |
| 50902   | 17:14:04 | 00:05:55  | 644        | 817       | 1287       |
| 50903   | 17:14:59 | 00:00:55  | 647        | 727       | 1293       |
| 50904   | 17:20:18 | 00:05:19  | 645        | 807       | 1289       |
| 50905   | 17:23:55 | 00:03:37  | 644        | 837       | 1287       |
| 50906   | 17:32:10 | 00:08:15  | 645        | 808       | 1289       |
| 50907   | 17:38:58 | 00:06:48  | 648        | 715       | 1295       |
| 50908   | 17:43:10 | 00:04:12  | 647        | 736       | 1293       |
| 50909   | 17:44:41 | 00:01:31  | 645        | 807       | 1289       |
| 50910   | 17:47:01 | 00:02:20  | 646        | 770       | 1291       |
| 50911   | 17:50:19 | 00:03:18  | 638        | 992       | 1275       |
| 50912   | 17:53:18 | 00:02:59  | 644        | 834       | 1287       |
| 50913   | 17:54:46 | 00:01:28  | 647        | 725       | 1293       |
| 50914   | 17:56:12 | 00:01:26  | 645        | 784       | 1289       |
| 50915   | 17:58:49 | 00:02:37  | 645        | 781       | 1289       |
| 50916   | 18:00:00 | 00:01:11  | 647        | 743       | 1293       |
| 50917   | 18:01:01 | 00:01:01  | 645        | 794       | 1289       |
| 50918   | 18:03:22 | 00:02:21  | 179        | 252       | 357        |
| 50919   | 18:03:40 | 00:00:18  | 10         | 9         | 19         |
| 50921   | 18:05:49 | 00:00:26  | 176        | 186       | 351        |
| 50922   | 18:08:27 | 00:02:38  | 8          | 10        | 15         |
| 50923   | 18:08:42 | 00:00:15  | 19         | 18        | 37         |
| 50924   | 18:08:59 | 00:00:17  | 7          | 6         | 13         |
| 50925   | 18:09:51 | 00:00:52  | 3          | 2         | 5          |
| 50927   | 18:11:23 | 00:01:30  | 11         | 10        | 21         |
| 50929   | 18:12:55 | 00:01:11  | 7          | 6         | 13         |
| 50932   | 18:17:51 | 00:02:10  | 7          | 6         | 13         |
| 50933   | 18:19:12 | 00:01:21  | 5          | 4         | 9          |
| 50936   | 18:23:33 | 00:01:30  | 3          | 2         | 5          |
| 50937   | 18:24:02 | 00:00:29  | 2          | 1         | 3          |
| 50939   | 18:25:57 | 00:00:33  | 9          | 48        | 17         |
| 50942   | 18:30:34 | 00:00:18  | 2          | 26        | 3          |
| 50944   | 18:34:19 | 00:00:48  | 4          | 3         | 7          |
| 50945   | 18:37:51 | 00:03:32  | 6          | 5         | 11         |
| 50946   | 18:38:27 | 00:00:36  | 2          | 1         | 3          |
| 50948   | 18:42:09 | 00:00:39  | 3          | 3         | 5          |
| 50949   | 18:43:58 | 00:01:49  | 8          | 7         | 15         |
| 50950   | 18:44:50 | 00:00:52  | 11         | 18        | 21         |
| 50952   | 18:46:51 | 00:00:40  | 10         | 18        | 19         |
| 50954   | 18:47:21 | 00:00:20  | 11         | 20        | 21         |
| 50956   | 18:49:34 | 00:01:00  | 7          | 10        | 13         |
| 50957   | 18:50:16 | 00:00:42  | 8          | 7         | 15         |
| 50968   | 19:07:34 | 00:00:39  | 2          | 141       | 3          |
| 50977   | 19:30:52 | 00:12:41  | 2          | 1         | 3          |
| 50978   | 19:31:16 | 00:00:24  | 2          | 1         | 3          |
| 50982   | 19:41:48 | 00:03:50  | 2          | 1         | 3          |
| 50984   | 19:43:53 | 00:00:38  | 2          | 1         | 3          |
| 50989   | 19:51:55 | 00:02:55  | 2          | 1         | 3          |
| 50999   | 20:06:19 | 00:02:31  | 2          | 1         | 3          |
| 51007   | 20:17:43 | 00:00:53  | 3          | 11        | 5          |
| 51010   | 20:24:33 | 00:01:32  | 2          | 3         | 3          |
| 51020   | 20:38:30 | 00:00:56  | 2          | 3         | 3          |
| 51025   | 20:44:23 | 00:00:18  | 2          | 2         | 3          |
| 51027   | 20:54:09 | 00:02:55  | 3          | 2         | 5          |
| 51034   | 21:06:59 | 00:01:07  | 2          | 1         | 3          |
| 51049   | 21:38:07 | 00:02:13  | 2          | 92        | 3          |
| 51051   | 21:41:36 | 00:00:55  | 2          | 1         | 3          |
| 51065   | 22:22:08 | 00:03:13  | 2          | 26        | 3          |
| 51069   | 22:27:42 | 00:02:02  | 2          | 2         | 3          |
| 51070   | 22:30:40 | 00:02:58  | 3          | 4         | 5          |
| 51152   | 01:39:18 | 00:00:25  | 2          | 3         | 3          |
| 51200   | 03:10:40 | 00:01:02  | 330        | 480       | 659        |
| 51202   | 03:13:38 | 00:02:04  | 33         | 48        | 65         |
| 51203   | 03:17:13 | 00:03:35  | 643        | 861       | 1285       |
| 51204   | 03:17:53 | 00:00:40  | 405        | 539       | 809        |
| 51206   | 03:21:23 | 00:00:26  | 129        | 173       | 257        |
| 51210   | 03:25:36 | 00:00:45  | 5          | 6         | 9          |
| 51211   | 03:25:50 | 00:00:14  | 2          | 1         | 3          |
| 51235   | 04:15:46 | 00:00:51  | 3          | 4         | 5          |
| 51245   | 04:31:15 | 00:00:16  | 2          | 1         | 3          |
| 51271   | 05:14:48 | 00:08:39  | 2          | 1         | 3          |
| 51276   | 05:24:41 | 00:00:58  | 2          | 157       | 3          |
| 51278   | 05:26:24 | 00:00:17  | 2          | 157       | 3          |
| 51280   | 05:33:22 | 00:06:30  | 2          | 191       | 3          |