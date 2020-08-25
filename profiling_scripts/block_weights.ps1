# Name: block_weights.ps1

# Extract text:
# 2020-08-27 17:20:06.850204200 [c::val::block_validators] TRACE SV - Block contents for block #1 : inputs 0; kernels 1; outputs 1; weight 16.

# Regex:
# Block contents for block #

param (
    # Path to log files, e.g. './log', or if used with filter, './log/base_layer_t*.log'
    [Parameter(Mandatory = $true)][string]$path, 
    # Non-csv log output file name, e.g. 'traces.log'
    [Parameter(Mandatory = $true)][string]$out_file, 
    # csv output file name, e.g. 'traces.csv'
    [Parameter(Mandatory = $true)][string]$csv_file 
)

$match_01 = 'Block contents for block #'

$script = Join-Path -Path $PSScriptRoot -ChildPath "extract_matching_lines_from_logs.ps1"
&$script -path $path -out_file $out_file -match_01 $match_01 -sort $true

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
        wsl lnav -n -q -c ":reset-session" -c ";select log_time, regexp_match('block.#(\d+)', log_text) as block, regexp_match('inputs.(\d+)', log_text) as inputs, regexp_match('kernels.(\d+)', log_text) as kernels, regexp_match('outputs.(\d+)', log_text) as outputs, regexp_match('weight.(\d+)', log_text) as weight, log_text from all_logs" -c $write_to_csv $log_file
    }
    else {
        lnav -n -q -c ":reset-session" -c ";select log_time, regexp_match('block.#(\d+)', log_text) as block, regexp_match('inputs.(\d+)', log_text) as inputs, regexp_match('kernels.(\d+)', log_text) as kernels, regexp_match('outputs.(\d+)', log_text) as outputs, regexp_match('weight.(\d+)', log_text) as weight, log_text from all_logs" -c $write_to_csv $log_file
    }
}

Write-Output "`n"
Write-Output $IsWindows $log_file $csv_out_file
Write-Output "`n"
