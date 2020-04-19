
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

# function Get-FormattedDateWithOrdinalSuffix([datetime]$date, [String]$format) {

#   [String]$result = $date.ToString($format);
#   [String]$suffix = Get-DateOrdinalSuffix($date);

#   $suffix = $date.Day.ToString() + $suffix;
#   $result = $result -replace "\d{,2}",$suffix;

#   return $result;
# }

function Get-FriendlyDate([datetime]$date) {

  [String]$suffix = Get-DateOrdinalSuffix($date);
  return  "{0}{1} {2:MMMM} {3}" -f $date.Day, $suffix, $date, $date.Year;
}

function Show-Console-Colours {

  [Array]$colours = @("Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", `
      "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White");
  
  foreach ($col in $colours) {
    Write-Host -ForegroundColor $col $col;
  }
}

# https://stackoverflow.com/questions/26997511/how-can-you-test-if-an-object-has-a-specific-property
#
# https://powertoe.wordpress.com/2011/03/31/combining-objects-efficiently-use-a-hash-table-to-index-a-collection-of-objects/
#
function Has-Property($obj, $propertyName) {
  return $propertyName -in $obj.properties;
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

function Replace-First {
  param
  (
    [string]$source,
    [string]$target,
    [string]$with
  )

  [string]$result = $source;
  [int]$foundAt = $source.IndexOf($target, 0);

  if ($foundAt -ge 0) {
    $result = $result.Substring(0, $foundAt) + $with + $result.Substring($foundAt + $target.Length);
  }

  return $result;
}

# This methods required because System.IO.Path.GetFileNameWithoutExtension does not seem to be available on macPS.
#
function Truncate-Extension {
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
    Subtract-First

.SYNOPSIS
    Given a target string, returns the result of removing a string from it
#>
function Subtract-First {
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
.SYNOPSIS
  Sort a collection of files from the pipeline in natural order

.DESCRIPTION
  Sorts filenames in an order that makes sense to humans; ie 1 is followed by
	2 and not 10.

.PARAMETER $pipeline
    collection of files from pipeline to be sorted
#>
function Sort-FilesNatural {
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
