# Blockchain sync profiling 2020/08/18

## Test Description

Two fresh base nodes were started (using Tor) in order to profile blockchain sync from scratch with trace logs being captured for both; one running on Windows and the other in an Ubuntu Linux virtual machine on the same host. Test conditions were not favorable as the host machine was used for many other high intensity tasks during this time. However, overall measurements still proved to be good enough.

Sync started when the blockchain tip was at block 74392; overview shown below:

| Basenode | Sync start time   | Blockchain  synced time | Duration | Duration (s) | Synced at block | Blocks/s |
| -------- | ----------------- | ----------------------- | -------- | ------------ | --------------- | -------- |
| Windows  | 2020/08/11  21:50 | 2020/08/12  15:52       | 18:01:28 | 64887.71     | 74919           | 1.15     |
| Linux    | 2020/08/11  21:51 | 2020/08/12  15:05       | 17:14:53 | 62093.44     | 74893           | 1.21     |

## Analysis

Analysis is based on detail time measurements in the code as well as differential time between specific consecutive trace logs. Differential analysis only uses log entries received with blocks in chronological order, as new blocks that were mined were also received via broadcast from peers.

### General Profiling

These general profiling measurements are extracted form the logs.

| #    | Log Entry                                                    | Description               |
| ---- | ------------------------------------------------------------ | ------------------------- |
| 1    | Requesting blocks [1, 2, 3, 4, 5] from 6b4773e599143ba0f87db39da2. | Block request time        |
| 2    | Received 5 blocks from peer                                  | Block receive time        |
| 3    | Response for HistoricalBlocks (request key: 5564039840279151865) received  after 734ms | Network response (direct) |
| 4    | [add_block] Exited blocking thread after 154ms. trace_id: '4048701038' | Block processing time     |

### Block Processing Profile

The table below shows a typical trace log of a new block being received for processing after the previous block has been successfully added to the database. The numbers in `Diff. Time` indicate which log messages are extracted for differential time measurements to be done. The first measurement would be between `0` and `1`, the next one between `1` and  `2`, and so on for all blocks received as part of block sync.

| Diff. Time | Log Entry                                                    | Description                       |
| ---------- | ------------------------------------------------------------ | --------------------------------- |
| 0          | Block #50880 (1b474c9f...) successfully added to database    | Reference point                   |
|            |                                                              |                                   |
| 1          | Block #50881 (6b9670bb...) received from local services      | Waiting for next block            |
|            |                                                              |                                   |
|            | Entered blocking thread. trace_id: '330817698'               |                                   |
|            | SV - Coinbase output is ok for block #50881 (6b9670bb...)    |                                   |
|            | SV - Block weight is ok for block #50881 (6b9670bb...)       |                                   |
|            | SV - No duplicate inputs or outputs for block #50881 (6b9670bb...) |                                   |
|            | SV - Output constraints are ok for block #50881 (6b9670bb...) |                                   |
|            | SV - Cut-through is ok for block #50881 (6b9670bb...)        |                                   |
|            | SV - accounting balance correct for block #50881 (6b9670bb...) |                                   |
| 2          | block #50881 (6b9670bb...) has PASSED stateless VALIDATION check. | Stateless validation              |
|            |                                                              |                                   |
|            | Added candidate block #50881 (6b9670bb...) to the orphan database. Best  height is 50880. |                                   |
|            | Checking if block #50881 (6b9670bb...) is connected to the main chain. |                                   |
|            | Connection with main chain found at block #50880 (1b474c9f...) from block  #50881 (6b9670bb...). |                                   |
|            | Comparing candidate block #50881  (accum_diff:15683896, hash:6b9670bb...) to main chain #50880       (accum_diff: 15683572, hash:  (1b474c9f...)). |                                   |
| 3          | Accumulated difficulty validation PASSED for block #50881 (6b9670bb...) | Accumulated difficulty validation |
|            |                                                              |                                   |
| 4          | Block validation: All inputs and outputs are valid for block #50881  (6b9670bb...) | Input/output validation           |
|            |                                                              |                                   |
|            | Block validation: MMR roots are valid for block #50881 (6b9670bb...) |                                   |
|            | BlockHeader validation: FTL timestamp is ok for header #50881  (6b9670bb...) |                                   |
|            | BlockHeader validation: Median timestamp is ok for header #50881  (6b9670bb...) |                                   |
|            | BlockHeader validation: Achieved difficulty is ok for header #50881  (6b9670bb...) |                                   |
|            | Block header validation: BlockHeader is VALID for header #50881  (6b9670bb...) |                                   |
| 5          | Block validation: Block is VALID for block #50881 (6b9670bb...) | Block validation                  |
|            |                                                              |                                   |
|            | [add_block] Exited blocking thread after 22364ms. trace_id: '330817698' |                                   |
| 6          | Block #50881 (6b9670bb...) successfully added to database    | Updating LMBD database            |

## Results

**Note:** Processed data with plots can be downloaded from [Google Drive (_Engineering:Testnet-Rincewind:Profiling:blockchain_sync_20200818_)](https://drive.google.com/drive/folders/1tTkM_8QjIS08-ZmbV9kQrDExno28MW4V) and opened with Microsoft Excel or Libre Office Calc.

### General Profiling

Currently requesting blocks and waiting for them to be received happens in series with block processing; new blocks are only requested after the previous blocks have been processed successfully.

| Basenode  | Network response  (s) | Block processing  (s) |
| --------- | --------------------- | --------------------- |
| Windows   | 25495.554             | 34634.559             |
| - Average | 1.640                 | 0.459                 |
| - Ratio   | 42.4%                 | 57.6%                 |
| Linux     | 23578.703             | 29698.778             |
| - Average | 1.519                 | 0.394                 |
| - Ratio   | 44.3%                 | 55.7%                 |

### Block Processing Profile

Log entries used for profiling were:

- Windows - Blocks 1 through 74392
- Linux - Blocks 1 through 74393

| Basenode | Next block  receive (s) | Stateless  validation (s) | Difficulty  validation (s) | I/O validation  (s) | Block validation  (s) | Add block to db  (s) | Totals  |
| -------- | ----------------------- | ------------------------- | -------------------------- | ------------------- | --------------------- | -------------------- | ------- |
| Windows  | 28943.1                 | 3146.6                    | 17941.7                    | 3778.1              | 8664.3                | 1609.3               | 64083.0 |
| - Avg.   | 0.389                   | 0.042                     | 0.241                      | 0.051               | 0.116                 | 0.022                | 0.861   |
| - Ratio  | 45.2%                   | 4.9%                      | 28.0%                      | 5.9%                | 13.5%                 | 2.5%                 | 100%    |
| Linux    | 26386.1                 | 4531.0                    | 14477.1                    | 3078.4              | 8060.4                | 2021.2               | 58554.1 |
| - Avg.   | 0.355                   | 0.061                     | 0.195                      | 0.041               | 0.108                 | 0.027                | 0.787   |
| - Ratio  | 45.1%                   | 7.7%                      | 24.7%                      | 5.3%                | 13.8%                 | 3.5%                 | 100%    |

### Other Observations

- While the basenode was syncing, the following also happened:
  - New blocks that were mined were also received via broadcast from peers, processed, and later on discarded for blocks requested via the sync process.
  - The basenode was actively processing transactions and performing all other basenode tasks.
- Some times the base node would wait for extended periods of time, up to 20 minutes, after the request for more blocks before they would be received.
- Accumulated difficulty validation shows increasing step-wise processing time as time goes on:
  - Block 1 to 2000, minimum time ~0.003 s, average variation ~ +0.020 s
  - Block 2001 to 10000, minimum time ~0.075 s, average variation ~ +0.040 s
  - Block 10000 to 55000, minimum time ~0.130 s, average variation ~ +0.060 s
  - Block 55000 to tip, minimum time ~0.290 s, average variation ~ +0.070 s

## Conclusions

These results were discussed and the following conclusions were drawn: 

- Stateless validation
  - Could optimize order n^2 type loops, some things may be done twice
- Accumulated difficulty validation
  - Shows increasing step-wise time, algo?
- Block I/O validation
  - Investigate read/write lock inside code block
- Add more log messages as required, e.g. before and after read/write locks

