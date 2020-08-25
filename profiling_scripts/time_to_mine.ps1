# Name: time_to_mine.ps1

# Extract text:

# 2020-09-10 19:44:01.636878800 [wallet::output_manager_service] DEBUG Prepared transaction (TxId: 16267210089698003344) to send

# 2020-09-10 19:45:09.525300500 [wallet::transaction_service::protocols::send_protocol] DEBUG Finalized Transaction (TxId: 16267210089698003344) Direct Send to d4f7ff9785c83016d47ff872776e14983443baf818b0dadec96b42dfbf7a7f74 queued with Message Tag#6670984547080916070

# 2020-09-10 20:06:19.818481300 [wallet::transaction_service::protocols::broadcast_protocol] INFO  Completed Transaction (TxId: 2075133539076166437 and Kernel Excess Sig: 0a36f97b30aea798ea99738e91d5a5445aa316ea0cf8a7204eb726340df59309) detected as Broadcast to Base Node Mempool in UnconfirmedPool

# 2020-09-11 08:07:58.603642100 [wallet::transaction_service::protocols::chain_monitoring_protocol] INFO  Transaction (TxId: 16267210089698003344) detected as mined on the Base Layer

param (
    # Path to log files, e.g. './log', or if used with filter, './log/base_layer_t*.log'
    [Parameter(Mandatory = $true)][string]$path,
    # csv output file name, e.g. 'traces.csv'
    [Parameter(Mandatory = $true)][string]$csv_file
)

$match_01 = New-Object Collections.Generic.List[String]
$match_02 = New-Object Collections.Generic.List[String]

# Prepared transaction (TxId: 16267210089698003344) to send
$match_01.add('Prepared transaction')
$match_02.add('to send')

# Finalized Transaction (TxId: 16267210089698003344) Direct Send to d4f7ff9... queued with Message Tag#6670984547080916070
$match_01.add('Finalized Transaction')
$match_02.add('queued with Message Tag')

# Completed Transaction (TxId: 2075133539076166437 and Kernel Excess Sig: 0a36f97b...) detected as Broadcast to Base Node Mempool in UnconfirmedPool
$match_01.add('Completed Transaction')
$match_02.add('detected as Broadcast to Base Node Mempool in UnconfirmedPool')

# Transaction (TxId: 16267210089698003344) detected as mined on the Base Layer
$match_01.add('Transaction')
$match_02.add('detected as mined')

$temp_file = New-Object Collections.Generic.List[String]
$temp_dir = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName())
New-Item -Path $temp_dir -ItemType Directory -Force | Out-Null
if (-not (Test-Path -Path (Split-Path $csv_file) -PathType leaf)) {
    New-Item -Path (Split-Path $csv_file) -ItemType Directory -Force | Out-Null
}
For ($i = 0; $i -lt $match_01.Count; $i++) {
    # Parse log file
    $temp_file = (Join-Path -Path $temp_dir -ChildPath ([System.IO.Path]::GetRandomFileName()))
    $script = Join-Path -Path $PSScriptRoot -ChildPath "extract_matching_lines_from_logs.ps1"
    &$script -path $path -out_file $temp_file -match_01 $match_01[$i] -match_02 $match_02[$i] -sort $true

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
            wsl lnav -n -q -c ":reset-session" -c ";select log_time, log_text from all_logs" -c $write_to_csv $log_dir
        }
        else {
            lnav -n -q -c ":reset-session" -c ";select log_time, log_text from all_logs" -c $write_to_csv $log_dir
        }
    }

    # Final sort csv file
    if (-not ([string]::IsNullOrWhiteSpace($csv_temp_file))) {
        if (Test-Path -Path $csv_temp_file -PathType leaf) {
            # Sort, then swap first and last line if headers are last
            $contents = Get-Content -Path $csv_temp_file
            $contents = $contents | Sort-Object
            if ($contents[-1] -like '*log_time,log_text*') {
                Set-Content $csv_temp_file -Value $contents[-1], $contents[0..($contents.length - 2)]
            }
            else {
                Set-Content $csv_temp_file -Value $contents[0..($contents.length - 1)]
            }
            # Increment file name & save output
            if ($csv_file.LastIndexOf('.') -ge 0) {
                $ext = $csv_file.substring($csv_file.LastIndexOf('.'), $csv_file.length - $csv_file.LastIndexOf('.'))
                $new_ext = '_' + ($i + 1).ToString().padleft(2, '0') + $ext
                $csv_file_name = $csv_file -replace $ext, $new_ext
            }
            else {
                $new_ext = '_' + ($i + 1).ToString().padleft(2, '0')
                $csv_file_name = $csv_file + $new_ext
            }
            Copy-Item $csv_temp_file -Destination $csv_file_name -Force
            # Validate contents
            $csv = Import-Csv $csv_temp_file
            for ($k = 0; $k -lt $csv.length; $k++) {
                if ($csv[$k].log_text -match "TxId: (\d+)" -eq $true) {
                    $TxId = $matches[1]
                }
                else {
                    $TxId = 0
                }
                $csv[$k] | Add-Member -MemberType NoteProperty -Name 'TxId' -Value $TxId
            }
            $csv_file_name = $csv_file_name -replace $new_ext, ('_trimmed' + $new_ext)
            $csv | Select-Object log_time, TxId, log_text | Export-Csv $csv_file_name -NoTypeInformation -Force
            # Cleanup
            Remove-Item $csv_temp_file -Force 
        }
    }

    # User feedback
    if (-not ([string]::IsNullOrWhiteSpace($csv_file_name))) {
        if ((Test-Path -Path $csv_file_name -PathType leaf) -and ((Get-ChildItem $csv_file_name).length -gt 0)) {
            $temp_str = "`nParsed matches for '" + $match_01[$i] + "' + '" + $match_02[$i] + "'`nOutput written to '" + $csv_file_name + "'`n"
            Write-Output $temp_str
        }
        else {
            $temp_str = "`nParsing did not find any matches for '" + $match_01[$i] + "' + '" + $match_02[$i] + "'`n"
            Write-Output $temp_str
        }
    }
    else {
        $temp_str = "`nParsing did not find any matches for '" + $match_01[$i] + "' + '" + $match_02[$i] + "'`n"
        Write-Output $temp_str
    }

    # Cleanup temp_file in log_dir for next lnav round
    Remove-Item $temp_file -Force 
}

# Cleanup
if (Test-Path -Path $temp_dir) {
    Remove-Item $temp_dir -Force -Recurse    
}

# User feedback
Write-Output "`nParsing completed`n"
