# Blockchain sync profiling 2020/08/27

## Test Description

Two fresh base nodes [version ~`0.5.3-3fc542d-release`] were started (using Tor) in order to profile blockchain sync from scratch with trace logs being captured for both; both running on Windows on two different hosts. Test conditions were favorable as the host machines were not used for other high intensity tasks during this time. Overall measurements proved to be good.

Sync started when the blockchain tip was at block 85168; overview shown below:

| Basenode   | Sync start time   | Blockchain sync  stopped time | Duration | Duration (s) | Sync stopped at  block | Blocks/s |
| ---------- | ----------------- | ----------------------------- | -------- | ------------ | ---------------------- | -------- |
| Windows 01 | 2020/08/27  17:20 | 2020/08/28  04:13             | 10:53:20 | 39200.00     | 76329                  | 1.95     |
| Windows 02 | 2020/08/27  17:20 | 2020/08/28  03:54             | 10:34:45 | 38085.00     | 76329                  | 2.00     |

Analysis is based on detail time measurements in the code as well as differential time between specific consecutive trace logs. Differential analysis only uses log entries received with blocks in chronological order.

_**Note:** The sync process could not complete as the database grew beyond its initialized environment size limit of 1GB ([issue logged in GitHub](https://github.com/tari-project/tari/issues/2181))._


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

| Diff. Time | Log Entry                                                    | Description                                   |
| ---------- | ------------------------------------------------------------ | --------------------------------------------- |
| 0          | Block #50880 (1b474c9f...) successfully added to database    | Reference point                               |
|            |                                                              |                                               |
| 1          | Block #50881 (6b9670bb...) received from local services      | Waiting for next block                        |
|            |                                                              |                                               |
|            | Entered blocking thread. trace_id: '330817698'               | Stateless validation                          |
|            | SV - Coinbase output is ok for block #50881 (6b9670bb...)    | Stateless validation                          |
|            | SV - Block contents for block #50881 : inputs 720; kernels 648; outputs 1295; weight 19499. | Stateless validation                          |
|            | SV - Block weight is ok for block #50881 (6b9670bb...)       | Stateless validation                          |
|            | SV - No duplicate inputs or outputs for block #50881 (6b9670bb...) | Stateless validation                          |
|            | SV - Output constraints are ok for block #50881 (6b9670bb...) | Stateless validation                          |
|            | SV - Cut-through is ok for block #50881 (6b9670bb...)        | Stateless validation                          |
|            | SV - accounting balance correct for block #50881 (6b9670bb...) | Stateless validation                          |
| 2          | block #50881 (6b9670bb...) has PASSED stateless VALIDATION check. | Stateless validation                          |
|            |                                                              |                                               |
|            | [add_block] acquired write access db lock for block #50881   | Blockchain integrity                          |
|            | Added candidate block #50881 (6b9670bb...) to the orphan database. Best height is 50880. | Blockchain integrity                          |
|            | Checking if block #50881 (6b9670bb...) is connected to the main chain. | Blockchain integrity                          |
|            | Connection with main chain found at block #50880 (1b474c9f...) from block #50881 (6b9670bb...). | Blockchain integrity                          |
|            | Search for orphan tips linked to block #50881 complete.      | Blockchain integrity                          |
|            | Comparing candidate block #50881  (accum_diff:15683896, hash:6b9670bb...) to main chain #50880 (accum_diff: 15683572, hash:  (1b474c9f...)). | Blockchain integrity                          |
| 3          | Accumulated difficulty validation PASSED for block #50881 (6b9670bb...) | Blockchain integrity (Difficulty  validation) |
|            |                                                              |                                               |
| 4          | Block validation: All inputs and outputs are valid for block #50881  (6b9670bb...) | Input/output validation                       |
|            |                                                              |                                               |
|            | Block validation: MMR roots are valid for block #50881 (6b9670bb...) | Block validation                              |
|            | BlockHeader validation: FTL timestamp is ok for header #50881  (6b9670bb...) | Block validation                              |
|            | BlockHeader validation: Median timestamp is ok for header #50881  (6b9670bb...) | Block validation                              |
|            | BlockHeader validation: Achieved difficulty is ok for header #50881  (6b9670bb...) | Block validation                              |
|            | Block header validation: BlockHeader is VALID for header #50881  (6b9670bb...) | Block validation                              |
| 5          | Block validation: Block is VALID for block #50881 (6b9670bb...) | Block validation                              |
|            |                                                              |                                               |
|            | [add_block] released write access db lock for block #50881   | Updating LMBD database                        |
|            | [add_block] Exited blocking thread after 22364ms. trace_id: '330817698' | Updating LMBD database                        |
| 6          | Block #50881 (6b9670bb...) successfully added to database    | Updating LMBD database                        |


## Results

**Note:** Processed data with plots can be downloaded from [Google Drive (_Engineering:Testnet-Rincewind:Profiling:blockchain_sync_20200827_)](https://drive.google.com/drive/folders/1-T5PRWUsPCIP7VJzu9VwxtNoeHxD13aq) and opened with Microsoft Excel or Libre Office Calc.


### General Profiling

Currently requesting blocks and waiting for them to be received happens in series with block processing; new blocks are only requested after the previous blocks have been processed successfully.

| Basenode   | Network response  (s) | Block processing  (s) |
| ---------- | --------------------- | --------------------- |
| Windows 01 | 21489.745             | 15604                 |
| - Average  | 1.407                 | 0.204                 |
| - Ratio    | 57.93%                | 42.07%                |
| Windows 02 | 19797.746             | 14402.793             |
| - Average  | 1.297                 | 0.189                 |
| - Ratio    | 57.89%                | 42.11%                |


### Block Processing Profile

Log entries used for profiling were:

- Windows 01 - Blocks 1 through 76329
- Windows 02 - Blocks 1 through 76329



| Basenode   | Next block  receive (s) | Stateless  validation (s) | Blockchain integrity (Difficulty  validation) (s) | I/O validation  (s) | Block validation  (s) | Add block to db  (s) | Totals   |
| ---------- | ----------------------- | ------------------------- | ------------------------------------------------- | ------------------- | --------------------- | -------------------- | -------- |
| Windows 01 | 23511.50                | 1955.82                   | 326.13                                            | 3894.85             | 8022.16               | 1488.17              | 39198.63 |
| - Average  | 0.308065                | 0.025627                  | 0.004273                                          | 0.051033            | 0.105112              | 0.019499             | 0.513609 |
| - Ratio    | 59.98%                  | 4.99%                     | 0.83%                                             | 9.94%               | 20.47%                | 3.80%                | 100.00%  |
| Windows 02 | 23609.80                | 1618.20                   | 590.13                                            | 2588.87             | 6728.02               | 2946.97              | 38081.99 |
| - Average  | 0.309353                | 0.021203                  | 0.007732                                          | 0.033921            | 0.088155              | 0.038613             | 0.498978 |
| - Ratio    | 62.00%                  | 4.25%                     | 1.55%                                             | 6.80%               | 17.67%                | 7.74%                | 100.00%  |


### Comparison with Previous Test

Performance improvement when comparing the same node on the the same host is shown below:

| Basenode                  | Next block  receive (s) | Stateless  validation (s) | Blockchain integrity (Difficulty  validation) (s) | I/O validation  (s) | Block validation  (s) | Add block to db  (s) | Totals |
| ------------------------- | ----------------------- | ------------------------- | ------------------------------------------------- | ------------------- | --------------------- | -------------------- | ------ |
| Windows 01 vs. Windows 01 | 26.29%                  | 65.05%                    | 5543.93%                                          | -0.48%              | 10.80%                | 10.94%               | 67.72% |

Network performance is measured with `Next block  receive time`, however, this average value may be slightly warped as blocks are received in groups. The table below shows average for groups of blocks.

|                                                | Windows 01 | Windows 02 | Windows 01  (previous) | Linux (previous) |
| ---------------------------------------------- | ---------- | ---------- | ---------------------- | ---------------- |
| Next block receive time, group of 5 blocks (s) | 1.537      | 1.546      | 1.944                  | 1.773            |
| Average (s)                                    | 1.542      | 1.542      | 1.859                  | 1.859            |
| Improvement                                    | 20.56%     | 20.56%     | 0.00%                  | 0.00%            |

### Average vs. Maximum

| Basenode   | Aspect  | Next block  receive (s) | Stateless  validation (s) | Difficulty  validation (s) | I/O validation  (s) | Block validation  (s) | Add block to db  (s) |
| ---------- | ------- | ----------------------- | ------------------------- | -------------------------- | ------------------- | --------------------- | -------------------- |
| Windows 01 | Average | 0.308065                | 0.025627                  | 0.004273                   | 0.051033            | 0.105112              | 0.019499             |
| Windows 01 | Max     | 663.346000              | 11.504000                 | 0.147000                   | 27.919000           | 0.498000              | 0.811000             |
| Windows 01 | Factor  | 2153.27                 | 448.91                    | 34.40                      | 547.08              | 4.74                  | 41.59                |
| Windows 02 | Average | 0.309353                | 0.021203                  | 0.007732                   | 0.033921            | 0.088155              | 0.038613             |
| Windows 02 | Max     | 662.601000              | 10.706000                 | 0.177000                   | 19.020000           | 0.168000              | 0.859000             |
| Windows 02 | Factor  | 2141.90                 | 504.93                    | 22.89                      | 560.71              | 1.91                  | 22.25                |
| Average    | Factor  | 2147.58                 | 476.92                    | 28.65                      | 553.89              | 3.32                  | 31.92                |

### Other Observations

- While the basenode was syncing, it was actively processing transactions and performing all other basenode tasks.

- Some times the base node would wait for extended periods of time, up to 11 minutes, after the request for more blocks before they would be received.

- Database write times are dependent on the underlying storage media performance; base node Windows 01 is twice as fast with a high performance NVMe compared to a much slower SSD for base node Windows 02.

- The `write access db lock` is acquired after _Stateless validation_ and released after the new block has been added to the database. This does not seem to have any adverse effect on processing, apart from where the database is updated.

- Block size correlation:

  - _Block validation_ seem to be unaffected by block size (~ x3.3 above average)
  - _Blockchain integrity (Difficulty  validation)_ and _Add block to db_ are only moderately affected by block size (~ x30 above average)

  - _Stateless validation_ and _I/O validation_ are strongly affected by block size (~ x515 above average)


## Conclusions

These results were discussed and the following conclusions were drawn: 

- The message protocol change, maybe other changes as well, seem to have improved the blockchain sync considerably, when comparing the same Windows node this time round with the previous profile test. Overall network speed improved ~20%, with a remarkable network time vs. block processing time swap of 45-55% to 60-40%
  
- Areas for improvement:
  - Stream all block requests, without waiting for validation to be concluded for the next round to start. If a block in a group cannot be added to the database successfully, that group can be re-requested from a different host.
  - Do not accept transactions and broadcast blocks from peers until the blockchain has been synced fully. 
- Block processing bottlenecks, in order of time taken:
  - Block validation
  - I/O validation
  - Stateless validation

