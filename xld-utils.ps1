
# PowerShell on MacOS
# (https://wilsonmar.github.io/powershell-on-mac/)
#

function Get-DateOrdinalSuffix([datetime]$date) {
  switch -regex ($date.Day.ToString()) {
    '1(1|2|3)$' { 'th'; break }
    '.?1$' { 'st'; break }
    '.?2$' { 'nd'; break }
    '.?3$' { 'rd'; break }
    default { 'th'; break }
  }
}

function Get-FriendlyDate([datetime]$date) {

  [String]$suffix = Get-DateOrdinalSuffix($date);
  return  "{0}{1} {2:MMMM} {3}" -f $date.Day, $suffix, $date, $date.Year;
}

function Show-ConsoleColours {

  [Array]$colours = @("Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", `
      "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White");
  
  foreach ($col in $colours) {
    Write-Host -ForegroundColor $col $col;
  }
}

function Add-WildCard {
  param
  (
    [string]$directory
  )

  if ($directory -match "\*$") {
    return $directory;
  }
  else {

    return Join-Path $directory "*";
  }
}

# This method required because System.IO.Path.GetFileNameWithoutExtension does not seem to be available on macPS.
#
function Edit-TruncateExtension {
  param
  (
    [String]$path
  )

  $result = [String]::Empty;
  $index = $path.LastIndexOf(".");

  if ($index -ge 0) {
    
    $result = $path.Substring(0, $index);
  }

  return $result;
}

<#
.NAME
    Edit-SubtractFirst

.SYNOPSIS
    Given a target string, returns the result of removing a string from it
#>
function Edit-SubtractFirst {
  param
  (
    [String]$target,
    [String]$subtract
  )

  $result = $target;

  if (($subtract.Length -gt 0) -and ($target.Contains($subtract))) {
    $len = $subtract.Length;
    $foundAt = $target.IndexOf($subtract);

    if ($foundAt -eq 0) {
      $result = $target.Substring($len);
    } else {
      $result = $target.Substring(0, $foundAt);
      $result += $target.Substring($foundAt + $len);
    }
  }

  return $result;
}

<#
.NAME
    Get-SortedFilesNatural

.SYNOPSIS
  Sort a collection of files from the pipeline in natural order

.DESCRIPTION
  Sorts filenames in an order that makes sense to humans; ie 1 is followed by
	2 and not 10.

.PARAMETER $pipeline
    collection of files from pipeline to be sorted
#>
function Get-SortedFilesNatural {
  param
  (
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [System.Object[]]$pipeline
  )

  begin { $files = @() }

  process {
    foreach ($item in $pipeline) {
      $files += $item
    }
  }

  end { $files | Sort-Object { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) }) } }
}
