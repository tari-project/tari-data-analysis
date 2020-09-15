# Name: block_processing_profile_combined.ps1

# Extract text:

# 2020-08-11 21:50:48.285954000 [c::bn::comms_interface::inbound_handler] DEBUG Block #1 (bfd4e51d3494c01d7a7ea36225466e9b61d74e502647b53dd444d7d9d7786f1f) received from local services

# 2020-08-11 21:50:48.291985200 [c::val::block_validators] DEBUG block #1 (bfd4e51d3494c01d7a7ea36225466e9b61d74e502647b53dd444d7d9d7786f1f) has PASSED stateless VALIDATION check.

# 2020-08-11 21:50:48.295985000 [c::cs::database] DEBUG Accumulated difficulty validation PASSED for block #1 (bfd4e51d3494c01d7a7ea36225466e9b61d74e502647b53dd444d7d9d7786f1f)

# 2020-08-11 21:50:48.295985000 [c::val::block_validators] TRACE Block validation: All inputs and outputs are valid for block #1 (bfd4e51d3494c01d7a7ea36225466e9b61d74e502647b53dd444d7d9d7786f1f)

# 2020-08-11 21:50:48.416953800 [c::val::block_validators] DEBUG Block validation: Block is VALID for block #1 (bfd4e51d3494c01d7a7ea36225466e9b61d74e502647b53dd444d7d9d7786f1f)

# 2020-08-11 21:50:48.440953400 [c::bn::states::block_sync] INFO  Block #1 (bfd4e51d3494c01d7a7ea36225466e9b61d74e502647b53dd444d7d9d7786f1f) successfully added to database

param (
    # Path to log files, e.g. './log', or if used with filter, './log/base_layer_t*.log'
    [Parameter(Mandatory = $true)][string]$path, 
    # csv output file name, e.g. 'traces.csv'
    [Parameter(Mandatory = $true)][string]$csvfile   
)

# Parse log files
$match_string = New-Object Collections.Generic.List[String]
$match_string.add('received from local services')
$match_string.add('has PASSED stateless VALIDATION check')
$match_string.add('Accumulated difficulty validation PASSED for block')
$match_string.add('Block validation: All inputs and outputs are valid for block')
$match_string.add('Block validation: Block is VALID for block')
$match_string.add('successfully added to database')

$tempfile = New-Object Collections.Generic.List[String]
$tempdir = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName())
New-Item -Path $tempdir -ItemType Directory -Force | Out-Null
foreach ($match in $match_string) {
    $tempfile.add((Join-Path -Path $tempdir -ChildPath ([System.IO.Path]::GetRandomFileName())))
    $script = Join-Path -Path $PSScriptRoot -ChildPath "extract_matching_lines_from_logs.ps1"
    &$script -path $path -outfile $($tempfile | Select-Object -Last 1) -match_01 $match -sort $true
}

# Create combined csv file
if ((Test-Path -Path $tempfile[0] -PathType leaf) -and ((Get-ChildItem $tempfile[0]).length -gt 0)) {
    $csv_temp_file = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName())
    if ($IsWindows) {
        $logdir = $tempdir -replace "\\", "/" -replace "c:", "/mnt/c" -replace "d:", "/mnt/d" -replace "e:", "/mnt/e"
        $cvs_nix_name = $csv_temp_file -replace "\\", "/" -replace "c:", "/mnt/c" -replace "d:", "/mnt/d" -replace "e:", "/mnt/e"
    }
    else {
        $logdir = $tempdir
        $cvs_nix_name = $csv_temp_file
    }
    $write_to_csv = '":write-csv-to ' + $($cvs_nix_name) + '"'
    if ($IsWindows) {
        wsl lnav -n -q -c ":reset-session" -c ";select log_time, regexp_match('#(\d+)', log_text) as block, log_text from all_logs" -c $write_to_csv $logdir
    }
    else {
        lnav -n -q -c ":reset-session" -c ";select log_time, regexp_match('#(\d+)', log_text) as block, log_text from all_logs" -c $write_to_csv $logdir
    }
}

# Final sort
if (-not ([string]::IsNullOrWhiteSpace($csv_temp_file))) {
    if (Test-Path -Path $csv_temp_file -PathType leaf) {
        Get-Content -Path $csv_temp_file | Sort-Object > $csvfile
        Remove-Item $csv_temp_file -Force 
    }
}

# Cleanup
if (Test-Path -Path $tempdir) {
    Remove-Item $tempdir -Force -Recurse    
}

# User feedback
if (-not ([string]::IsNullOrWhiteSpace($csvfile))) {
    if ((Test-Path -Path $csvfile -PathType leaf) -and ((Get-ChildItem $csvfile).length -gt 0)) {
        Write-Output "`nParsing completed, results written to '$csvfile'`n"
    }
    else {
        Write-Output "`nParsing completed, no results found`n"
    }
}
else {
    Write-Output "`nParsing completed, no results found`n"
}
