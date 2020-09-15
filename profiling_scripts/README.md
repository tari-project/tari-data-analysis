# Profiling

## Prerequisites

All scripts must be run from PowerShell, which will extract earmarked data data into comma separated value (csv) format. Final presentation is done in Libre Office Calc or Microsoft Office Excel, after importing the csv data files.

- Linux:
  - `PowerShell` version 7.x.x
  - `lnav`
  - `ripgrep`
  - `Libre Office Calc` version 6.x.x
- Windows:
  - `PowerShell version 7.x.x`
  - `lnav`
  - `ripgrep`
  - `WSL` or `WSL 2` (preferred)
  - `Libre Office Calc version 6.x.x` or `Microsoft Office Excel version 2013` or later
- Access to scripts in `tari\scripts\profiling` (i.e. clone `https://github.com/tari-project/tari.git`)

To run the scripts, open a PowerShell terminal, or in a Linux terminal or Windows console, type:

```
pwsh
```

Scripts are executed as follows, form within the PowerShell terminal:

```
&'<script location and name>' -path '<path/filter to log files>' -csv_file '<output csv file location and name>' 
-other_options <value>
```

## Generic Script

All scripts makes use of initial parsing of data from log files, which makes use of `ripgrep`, where after the csv files are created and validated.

- **extract_matching_lines_from_logs.ps1**

  - Command line parameters:

  ```
  # Path to log files, e.g. './log', or if used with filter, './log/base_layer_t*.log'
  [Parameter(Mandatory = $true)][string]$path, 
  # output file name, e.g. 'traces.log'
  [Parameter(Mandatory = $true)][string]$out_file, 
  # 1st substring to match, e.g. 'add_block'
  [Parameter(Mandatory = $true)][string]$match_01, 
  # 2nd substring to match, e.g. 'blocking'
  [string]$match_02,
  # 3rd substring to match, e.g. 'after'
  [string]$match_03, 
  # sort output, e.g. '$true' or '$false', '1' or '0'
  [bool]$sort                                    
  ```

### Generic Logging Settings

Provision must be made for ample log files of sufficient size, depending on the current height of the blockchain. These minimum settings are recommended:

```
  # An appender named "network" that writes to a file with a custom pattern encoder
  network:
    kind: rolling_file
    path: "log/network.log"
    policy:
      kind: compound
      trigger:
        kind: size
        limit: 200mb
      roller:
        kind: fixed_window
        base: 1
        count: 100
        pattern: "log/network.{}.log"
    encoder:
      pattern: "{d(%Y-%m-%d %H:%M:%S.%f)} [{t}] {l:5} {m}{n}"

  # An appender named "core" that writes to a file with a custom pattern encoder
  core:
    kind: rolling_file
    path: "log/core.log"
    policy:
      kind: compound
      trigger:
        kind: size
        limit: 200mb
      roller:
        kind: fixed_window
        base: 1
        count: 50
        pattern: "log/core.{}.log"
    encoder:
      pattern: "{d(%Y-%m-%d %H:%M:%S.%f)} [{t}] {l:5} {m}{n}"

  # An appender named "base_layer" that writes to a file with a custom pattern encoder
  base_layer:
    kind: rolling_file
    path: "log/base_layer.log"
    policy:
      kind: compound
      trigger:
        kind: size
        limit: 200mb
      roller:
        kind: fixed_window
        base: 1
        count: 50
        pattern: "log/base_layer.{}.log"
    encoder:
      pattern: "{d(%Y-%m-%d %H:%M:%S.%f)} [{t}] {l:5} {m}{n}"
```

```
root:
  level: trace
  appenders:
    - base_layer
```

```
loggers:
  # Route log events sent to the "core" logger to the "base_layer_trace" appender
  c:
    level: trace
    appenders:
      - core
    additive: false
  base_node:
    level: info
    appenders:
      - stdout
    additive: false
  wallet:
    level: trace
    appenders:
      - base_layer
    additive: false
  comms:
    level: trace
    appenders:
      - network
    additive: false
```

**Note:** Exclusions for noisy log messages can be set to warning or error level, for example `comms::noise:`, `yamux:`, `mio:`, `tokio_util:` and `tari_broadcast_channel:`.

## Blockchain Sync Profiling

Blockchain sync profiling is done by starting a clean instance of the base node with no prior blockchain, peer or wallet data available. Actual profiling data is extracted form trace log files and the logging configuration in `log4rs.yml` must make provision for that, depending on the current height of the blockchain. Due to the sheer amount of data captured, usual tools used to manipulate log files and extract data tend to break. A series of PowerShell scripts, in combination with `lnav`, running in either Linux or Windows, have been created to parse the log files, create `csv` files and to perform basic processing on the data. Presentation is done in either Microsoft Excel or Libre Office Calc.

### Parsing Log Files

Blockchain sync profiling scripts are shown below. Note that due to changes that may happen to the tari code base, regex expressions used to extract the specific log lines may need to be adapted from time to time.

- **block_processing_profile.ps1**
  
  - Command line parameters:

  ```
  # Path to log files, e.g. './log', or if used with filter, './log/base_layer_t*.log'
  [Parameter(Mandatory = $true)][string]$path,
  # csv output file name, e.g. 'traces.csv'
  [Parameter(Mandatory = $true)][string]$csv_file,
  # Return unique consecutive block logs only, e.g. '$true' or '$false', '1' or '0'
  [Parameter(Mandatory = $true)][bool]$validate_and_trim
  ```

  - The following text is extracted, one csv file for each log entry type:

  ```
  2020-08-11 21:50:48.285954000 [c::bn::comms_interface::inbound_handler] DEBUG Block #1 (bfd4e51d...) received from 
    local services

  2020-08-11 21:50:48.291985200 [c::val::block_validators] DEBUG block #1 (bfd4e51d...) has PASSED stateless 
    VALIDATION check.

  2020-08-11 21:50:48.295985000 [c::cs::database] DEBUG Accumulated difficulty validation PASSED for block #1 (bfd4e51d...)

  2020-08-11 21:50:48.295985000 [c::val::block_validators] TRACE Block validation: All inputs and outputs are valid 
    for block #1 (bfd4e51d...)

  2020-08-11 21:50:48.416953800 [c::val::block_validators] DEBUG Block validation: Block is VALID for block #1 (bfd4e51d...)

  2020-08-11 21:50:48.440953400 [c::bn::states::block_sync] INFO  Block #1 (bfd4e51d...) successfully added to database
  ```

- **block_processing_profile_combined.ps1**

  - Command line parameters:

  ```
  # Path to log files, e.g. './log', or if used with filter, './log/base_layer_t*.log'
  [Parameter(Mandatory = $true)][string]$path, 
  # csv output file name, e.g. 'traces.csv'
  [Parameter(Mandatory = $true)][string]$csvfile   

  ```

  - The same text as for _block_processing_profile.ps1_ is extracted, except all data is combined into a single time sorted csv file.

- **block_processing_times.ps1**

  - Command line parameters:

  ```
  # Path to log files, e.g. './log', or if used with filter, './log/base_layer_t*.log'
  [Parameter(Mandatory = $true)][string]$path, 
  # Non-csv log output file name, e.g. 'traces.log'
  [Parameter(Mandatory = $true)][string]$out_file, 
  # csv output file name, e.g. 'traces.csv'
  [Parameter(Mandatory = $true)][string]$csv_file 
  ```

  - The following text is extracted into a single csv file:

  ```
  2020-08-11 21:50:48.440953400 [c::bn::async_db] TRACE [add_block] Exited blocking thread after 154ms. 
    trace_id: '4048701038'
  ```

- **block_weights.ps1**

  - Command line parameters:

  ```
  # Path to log files, e.g. './log', or if used with filter, './log/base_layer_t*.log'
  [Parameter(Mandatory = $true)][string]$path, 
  # Non-csv log output file name, e.g. 'traces.log'
  [Parameter(Mandatory = $true)][string]$out_file, 
  # csv output file name, e.g. 'traces.csv'
  [Parameter(Mandatory = $true)][string]$csv_file 
  ```

  - The following text is extracted into a single csv file:

  ```
  2020-08-27 17:20:06.850204200 [c::val::block_validators] TRACE SV - Block contents for block #1 : 
    inputs 0; kernels 1; outputs 1; weight 16.
  ```

- **network_response_times.ps1**

  - Command line parameters:

  ```
  # Path to log files, e.g. './log', or if used with filter, './log/base_layer_t*.log'
  [Parameter(Mandatory = $true)][string]$path, 
  # Non-csv log output file name, e.g. 'traces.log'
  [Parameter(Mandatory = $true)][string]$out_file, 
  # csv output file name, e.g. 'traces.csv'
  [Parameter(Mandatory = $true)][string]$csv_file 
  ```

  - The following text is extracted into a single csv file:

  ```
  2020-08-11 21:50:48.285954000 [c::bn::base_node_service::service] TRACE Response for HistoricalBlocks (request key: 
    5564039840279151865) received after 734ms
  ```

- **receive_blocks.ps1**

  - Command line parameters:

  ```
  # Path to log files, e.g. './log', or if used with filter, './log/base_layer_t*.log'
  [Parameter(Mandatory = $true)][string]$path, 
  # Non-csv log output file name, e.g. 'traces.log'
  [Parameter(Mandatory = $true)][string]$out_file, 
  # csv output file name, e.g. 'traces.csv'
  [Parameter(Mandatory = $true)][string]$csv_file 
  ```

  - The following text is extracted into a single csv file:

  ```
  2020-08-11 21:50:48.285954000 [c::bn::states::block_sync] DEBUG Received 5 blocks from peer
  ```

- **request_blocks.ps1**

  - Command line parameters:

  ```
  # Path to log files, e.g. './log', or if used with filter, './log/base_layer_t*.log'
  [Parameter(Mandatory = $true)][string]$path, 
  # Non-csv log output file name, e.g. 'traces.log'
  [Parameter(Mandatory = $true)][string]$out_file, 
  # csv output file name, e.g. 'traces.csv'
  [Parameter(Mandatory = $true)][string]$csv_file 
  ```

  - The following text is extracted into a single csv file:

  ```
  2020-08-11 21:50:47.550951800 [c::bn::states::block_sync] DEBUG Requesting blocks [1, 2, 3, 4, 5] 
    from 6b4773e599143ba0f87db39da2.
  ```

### Presenting Data

The spreadsheets below contains 100 rows of sample data with pre-configured formatting, formulae where required and graphs. The corresponding csv files must be imported into the spreadsheets as values only. Formatting and formulae must then be copied down till the end of the data rows.

- block_processing_profile.xlsx
- block_processing_times.xlsx
- network_response_times.xlsx
- receive_blocks.xlsx
- request_blocks.xlsx

## Transaction Monitoring (during stress tests)

### Parsing Log Files

Blockchain sync profiling scripts are shown below. Note that due to changes that may happen to the tari code base, regex expressions used to extract the specific log lines may need to be adapted from time to time.

- **time_to_mine.ps1**

  - Command line parameters:
  
  ```
  # Path to log files, e.g. './log', or if used with filter, './log/base_layer_t*.log'
  [Parameter(Mandatory = $true)][string]$path,
  # csv output file name, e.g. 'traces.csv'
  [Parameter(Mandatory = $true)][string]$csv_file
  ```

  - The following text is extracted, one csv file for each log entry type:

  ```
  2020-09-10 19:44:01.636878800 [wallet::output_manager_service] DEBUG Prepared transaction (TxId: 16267210089698003344) 
    to send

  2020-09-10 19:45:09.525300500 [wallet::transaction_service::protocols::send_protocol] DEBUG Finalized Transaction 
    (TxId: 16267210089698003344) Direct Send to d4f7ff97... queued with Message Tag#6670984547080916070

  2020-09-10 20:06:19.818481300 [wallet::transaction_service::protocols::broadcast_protocol] INFO Completed Transaction 
    (TxId: 2075133539076166437 and Kernel Excess Sig: 0a36f97b...) detected as Broadcast to Base Node Mempool 
    in UnconfirmedPool

  2020-09-11 08:07:58.603642100 [wallet::transaction_service::protocols::chain_monitoring_protocol] INFO  Transaction 
    (TxId: 16267210089698003344) detected as mined on the Base Layer
  ```