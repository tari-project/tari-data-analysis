# Name: extract_matching_lines_from_logs.ps1

param (
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
)

# Scratch file
if (Test-Path -Path $out_file -PathType leaf) {
   Remove-Item $out_file -force
}
if ($sort) {
   $temp_file_01 = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName())
}
else {
   $temp_file_01 = $out_file
}

# Regex patten
if (-not ([string]::IsNullOrWhiteSpace($match_02)) -and -not ([string]::IsNullOrWhiteSpace($match_03))) {
   $regex = '"^.*?(?:\b|_)' + $($match_01) + '(?:\b|_).*?(?:\b|_)' + $($match_02) + '(?:\b|_).*?(?:\b|_)' + $($match_03) + '(?:\b|_).*?$"'
}
elseif (-not ([string]::IsNullOrWhiteSpace($match_02))) {
   $regex = '"^.*?(?:\b|_)' + $($match_01) + '(?:\b|_).*?(?:\b|_)' + $($match_02) + '(?:\b|_).*?$"'
}
else {
   $regex = '"^.*?(?:\b|_)' + $($match_01) + '(?:\b|_).*?$"'
}

# Regex with ripgrep
if ($IsWindows) {
   $path_nix_name = $path -replace "\\", "/" -replace "c:", "/mnt/c" -replace "d:", "/mnt/d" -replace "e:", "/mnt/e"
   wsl rg --no-filename --no-line-number --crlf $regex $path_nix_name > $temp_file_01
}
else {
   rg --no-filename --no-line-number --crlf $regex $path > $temp_file_01
}

# Sort output & cleanup
if (Test-Path -Path $temp_file_01 -PathType leaf) {
   if ($sort) {
      Get-Content -Path $temp_file_01 | Sort-Object > $out_file
      Remove-Item $temp_file_01 -force
   }
}

# User feedback
$file = Get-ChildItem $out_file
if ((Test-Path -Path $out_file -PathType leaf) -and ($file.length -gt 0)) {
   Write-Output "`nData found for:`n"
}
else {
   Write-Output "`nNo data found:`n"
}
Write-Output "path: $path`n - regex search criteria:`n   $regex`n - output:`n   $out_file"
