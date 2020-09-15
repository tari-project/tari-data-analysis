# Name: block_processing_times.ps1

# Extract text:
# 2020-08-11 21:50:48.440953400 [c::bn::async_db] TRACE [add_block] Exited blocking thread after 154ms. trace_id: '4048701038'

# Regex:
# ^.*?(?:\b|_)add_block(?:\b|_).*?(?:\b|_)Exited blocking thread after(?:\b|_).*?$

param (
    # Path to log files, e.g. './log', or if used with filter, './log/base_layer_t*.log'
    [Parameter(Mandatory = $true)][string]$path, 
    # Non-csv log output file name, e.g. 'traces.log'
    [Parameter(Mandatory = $true)][string]$out_file, 
    # csv output file name, e.g. 'traces.csv'
    [Parameter(Mandatory = $true)][string]$csv_file 
)

$match_01 = 'add_block'
$match_02 = 'Exited blocking thread after'

$script = Join-Path -Path $PSScriptRoot -ChildPath "extract_matching_lines_from_logs.ps1"
&$script -path $path -out_file $out_file -match_01 $match_01 -match_02 $match_02 -sort $true

if (Test-Path -Path $out_file -PathType leaf) {
    if ($IsWindows) {
        $log_file = $out_file -replace "\\", "/" -replace "c:", "/mnt/c" -replace "d:", "/mnt/d" -replace "e:", "/mnt/e"
        $csv_out_file = $csv_file -replace "\\", "/" -replace "c:", "/mnt/c" -replace "d:", "/mnt/d" -replace "e:", "/mnt/e"
    }
    else {
        $log_file = $out_file
        $csv_out_file = $csv_file
    }
    $write_to_csv = '":write-csv-to ' + $($csv_out_file) + '"'
    if ($IsWindows) {
        wsl lnav -n -q -c ":reset-session" -c ";select log_time, regexp_match('(\d+)ms', log_text) as time, log_text from all_logs" -c $write_to_csv $log_file
    }
    else {
        lnav -n -q -c ":reset-session" -c ";select log_time, regexp_match('(\d+)ms', log_text) as time, log_text from all_logs" -c $write_to_csv $log_file
    }
}
