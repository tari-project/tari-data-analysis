# Name: block_processing_profile.ps1

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
    [Parameter(Mandatory = $true)][string]$csv_file,
    # Return unique consecutive block logs only, e.g. '$true' or '$false', '1' or '0'
    [Parameter(Mandatory = $true)][bool]$validate_and_trim
)

# Parse log files
$match_string = New-Object Collections.Generic.List[String]
$match_string.add('received from local services')
$match_string.add('has PASSED stateless VALIDATION check')
$match_string.add('Accumulated difficulty validation PASSED for block')
$match_string.add('Block validation: All inputs and outputs are valid for block')
$match_string.add('Block validation: Block is VALID for block')
$match_string.add('successfully added to database')

$temp_file = New-Object Collections.Generic.List[String]
$temp_dir = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName())
New-Item -Path $temp_dir -ItemType Directory -Force | Out-Null
if (-not (Test-Path -Path (Split-Path $csv_file) -PathType leaf)) {
    New-Item -Path (Split-Path $csv_file) -ItemType Directory -Force | Out-Null
}
$csv_files = New-Object Collections.Generic.List[String]
$trim_index = New-Object 'Collections.Generic.List[Int32]'
foreach ($match in $match_string) {
    # Parse log file
    $temp_file = (Join-Path -Path $temp_dir -ChildPath ([System.IO.Path]::GetRandomFileName()))
    $script = Join-Path -Path $PSScriptRoot -ChildPath "extract_matching_lines_from_logs.ps1"
    &$script -path $path -out_file $temp_file -match_01 $match -sort $true

    # Create csv file
    if ((Test-Path -Path $temp_file -PathType leaf) -and ((Get-ChildItem $temp_file).length -gt 0)) {
        $csv_temp_file = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName())
        if ($IsWindows) {
            $log_dir = $temp_dir -replace "\\", "/" -replace "c:", "/mnt/c" -replace "d:", "/mnt/d" -replace "e:", "/mnt/e"
            $cvs_nix_name = $csv_temp_file -replace "\\", "/" -replace "c:", "/mnt/c" -replace "d:", "/mnt/d" -replace "e:", "/mnt/e"
        }
        else {
            $log_dir = $temp_dir
            $cvs_nix_name = $csv_temp_file
        }
        $write_to_csv = '":write-csv-to ' + $($cvs_nix_name) + '"'
        if ($IsWindows) {
            wsl lnav -n -q -c ":reset-session" -c ";select log_time, regexp_match('#(\d+)', log_text) as block, log_text from all_logs" -c $write_to_csv $log_dir
        }
        else {
            lnav -n -q -c ":reset-session" -c ";select log_time, regexp_match('#(\d+)', log_text) as block, log_text from all_logs" -c $write_to_csv $log_dir
        }
    }

    # Final sort csv file
    if (-not ([string]::IsNullOrWhiteSpace($csv_temp_file))) {
        if (Test-Path -Path $csv_temp_file -PathType leaf) {
            # Sort, then swap first and last line if headers are last
            $contents = Get-Content -Path $csv_temp_file
            $contents = $contents | Sort-Object
            if ($contents[-1] -like '*log_time,block,log_text*') {
                Set-Content $csv_temp_file -Value $contents[-1], $contents[0..($contents.length - 2)]
            }
            else {
                Set-Content $csv_temp_file -Value $contents[0..($contents.length - 1)]
            }
            # Increment file name & save non-trimmed output
            if ($csv_file.LastIndexOf('.') -ge 0) {
                $ext = $csv_file.substring($csv_file.LastIndexOf('.'), $csv_file.length - $csv_file.LastIndexOf('.'))
                $new_ext = '_' + ($match_string.IndexOf($match) + 1).ToString().padleft(2, '0') + $ext
                $csv_file_name = $csv_file -replace $ext, $new_ext
            }
            else {
                $new_ext = '_' + ($match_string.IndexOf($match) + 1).ToString().padleft(2, '0')
                $csv_file_name = $csv_file + $new_ext
            }
            Copy-Item $csv_temp_file -Destination $csv_file_name -Force
            # Validate contents
            if ($validate_and_trim) {
                $csv = Import-Csv $csv_temp_file
                # Add validation values
                $csv[0] | Add-Member -MemberType NoteProperty -Name 'ignore' -Value $false
                $block_count = [int]$csv[0].block
                for ($i = 1; $i -lt $csv.length; $i++) {
                    if ([int]$csv[$i].block -eq $block_count + 1) {
                        $csv[$i] | Add-Member -MemberType NoteProperty -Name 'ignore' -Value $false
                        $block_count = $block_count + 1
                    }
                    else {
                        $csv[$i] | Add-Member -MemberType NoteProperty -Name 'ignore' -Value $true
                    }
                }
                # Remove rows with out of order non-sync blocks
                $csv = $csv | Where-Object { $_.ignore -eq $false }
                $trim_index.add($csv.length)
                # Export csv
                $csv_file_name = $csv_file_name -replace $new_ext, ('_trimmed' + $new_ext)
                $csv | Select-Object log_time, block, log_text | Export-Csv $csv_file_name -NoTypeInformation -Force
                $csv_files.add($csv_file_name)
            }
            # Cleanup
            Remove-Item $csv_temp_file -Force 
        }
    }

    # User feedback
    if (-not ([string]::IsNullOrWhiteSpace($csv_file_name))) {
        if ((Test-Path -Path $csv_file_name -PathType leaf) -and ((Get-ChildItem $csv_file_name).length -gt 0)) {
            Write-Output "`nParsed matches for '$match'`nOutput written to '$csv_file_name'`n"
        }
        else {
            Write-Output "`nParsing did not find any matches for '$match'`n"
        }
    }
    else {
        Write-Output "`nParsing did not find any matches for '$match'`n"
    }

    # Cleanup temp_file in log_dir for next lnav round
    Remove-Item $temp_file -Force 
}

# Trim all csv files to consistent length based on validation values
if ($validate_and_trim) {
    Write-Output "`nTrim index(es): $trim_index"
    $trim_index = ($trim_index | Measure-Object -Minimum).Minimum
    foreach ($csv_temp_file in $csv_files) {
        $csv = Import-Csv $csv_temp_file
        if ($csv.length -gt $trim_index) {
            Write-Output " - Trimmed '$csv_temp_file'`n"
            $csv[0..($trim_index - 1)] | Export-Csv $csv_temp_file -NoTypeInformation -Force
        }
    }
    Write-Output "CSV file(s) trimmed at record: $trim_index"
}

# Cleanup
if (Test-Path -Path $temp_dir) {
    Remove-Item $temp_dir -Force -Recurse    
}

# User feedback
Write-Output "`nParsing completed`n"
