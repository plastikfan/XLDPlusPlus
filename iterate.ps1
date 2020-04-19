
$ImageFileExclusions = "*.db,*.txt";

<#
.NAME
  foreach-directory

.SYNOPSIS
  Performs iteration over a collection of directories which are children of the directory
  specified by the caller.

.PARAMETER $directory
  The parent directory to iterate
.PARAMETER $filter
  The filter to apply to Get-ChildItem
.PARAMETER $condition
  The result of Get-ChildItem is piped to a where statement whose condition is specified by
  this parameter. The (optional) scriptblock specified must be a predicate script block.
.PARAMETER $body
  The implementation script block that is to be implemented for each child directory. The
  script block can either return $null or a psobject with fields Message(string) giving an
  indication of what was implemented, Product (string) which represents the item in question
  (ie the processed item as approriapte) and Colour(string) which is the console colour
  applied to the Product.
.PARAMETER $eachItemLine
  The line type to display after each directory iteration.
.PARAMETER $endOfProcessingLine
  The line type to display at the end of the directory iteration.
#>
function foreach-directory {
  param
  (
    [parameter(Mandatory = $true)]
    [string]$directory,
    [string]$filter = "*",
    [scriptblock]$condition = ({ return $true; }),
    [scriptblock]$body,
    [string]$eachItemLine = $EqualsLine,
    [string]$endOfProcessingLine = $UnderscoreLine
  )

  if ( !(Test-Path -LiteralPath $directory -PathType Container) ) {
    $error_message = "'" + $directory + "', does not exist!";
    Write-Host $error_message;
    return;
  }
  [int]$index = 0;

  $collection = Get-ChildItem -LiteralPath $directory -Directory -Filter $filter | Where-Object {
    $condition.Invoke($_);
  };
  
  $collection | ForEach-Object {

    $index++;
    Write-Host $eachItemLine -ForegroundColor $LineColour;

    $name = $_.Name;

    write-pair-in-colour @( (">>> Original directory name", $GeneralMessageDescColour), `
      ($name, $OriginalItemColour) );

    $result = $body.Invoke($_, $index);

    if (($null -ne $result) -and (-not [string]::IsNullOrEmpty($result.Message))) {

      write-pair-in-colour @( ($result.Message, $GeneralMessageDescColour), `
        ($result.Product, $result.Colour) );
    }
  } # ForEach-Object

  write-pair-in-colour @( ("••• Directory count", $GeneralMessageDescColour), `
    ($index, "Red") );

  Write-Host "$endOfProcessingLine" -ForegroundColor $LineColour;

  return $collection;
}

<#
.NAME
  foreach-file

.SYNOPSIS
  Performs iteration over a collection of files which are children of the directory
  specified by the caller.

.PARAMETER $directory
  The parent directory to iterate
.PARAMETER $filter
  The filter to apply to Get-ChildItem
.PARAMETER $condition
  The result of Get-ChildItem is piped to a where statement whose condition is specified by
  this parameter. The (optional) scriptblock specified must be a predicate script block.
.PARAMETER $body
  The implementation script block that is to be implemented for each child file. The
  script block can either return $null or a psobject with fields Message(string) giving an
  indication of what was implemented, Product (string) which represents the item in question
  (ie the processed item as approriapte) and Colour(string) which is the console colour
  applied to the Product. Also, the Trigger should be set to true, if an action has been taken
  for any of the files iterated. This is so because if we iterate a collection of files, but the
  operation doesnt do anything to any of the files, then the whole operation should be considered
  a no-op, so we can keep output to a minimum.
.PARAMETER $summary
  A summary message to be displayed at the end of processing. Because using this command can be
  very verbose, the caller can use this in non Verbose mode and choose to summarise the operation
  with the summary.  
.PARAMETER $eachItemLine
  The line type to display after each directory iteration.
.PARAMETER $endOfProcessingLine
  The line type to display at the end of the directory iteration.
.PARAMETER $Verb (THIS IS SUPOSED TO BE VERBOSE)
  Flag to indicate wether any output is generated for each file. Any output generated at a
  file level may become too much depending on the compound functionality implemented.

.RETURNS
  Number of files found.
#>

function foreach-file {
  param
  (
    [parameter(Mandatory = $true)]
    [string]$directory,
    [string]$filter = "*",
    [string]$inclusions,
    [scriptblock]$condition = ( { return $true; }),
    [scriptblock]$body,
    [String]$summary,
    [string]$eachItemLine = $LightDotsLine,
    [string]$endOfProcessingLine = $UnderscoreLine,
    [Switch]$Verb
  )

  if ( !(Test-Path -LiteralPath $directory -PathType Container) ) {
    $error_message = "'" + $directory + "', does not exist!";
    Write-Host $error_message;
    return;
  }
  [int]$index = 0;
  [boolean]$isVerbose = $Verb.ToBool();
  [boolean]$trigger = $false;

  $collection = Get-ChildItem -Path (Add-Wildcard($directory)) -File -Filter $filter -Include $inclusions | Sort-FilesNatural | Where-Object {
    $condition.Invoke($_);
  } | ForEach-Object {

    $index++;

    if ($isVerbose) {
      Write-Host $eachItemLine -ForegroundColor $LineColour;
    }

    $name = $_.Name;

    if ($isVerbose) {
      write-pair-in-colour @( (">>> Original file name", $GeneralMessageDescColour), `
        ($name, $OriginalItemColour) );
    }

    # Do the invoke
    #
    $result = $body.Invoke($_, $index, $trigger);

    # Hande the result
    #
    if ($result) {
      if ($isVerbose) {

        write-pair-in-colour @( ($result.Message, $GeneralMessageDescColour), `
          ($result.Product, $result.Colour) );
      }

      if ($result.Contains("Trigger") -and $result.Trigger) {
        $trigger = $true;
      }

      if ($result.Contains("Break") -and $result.Break) {
        break;
      }
    }
  } # ForEach-Object

  if ($trigger -and (-not ([String]::IsNullOrEmpty($summary)))) {
    Write-Host "$endOfProcessingLine" -ForegroundColor $LineColour;

    write-2pair-in-colour @(
      ("Summary", $GeneralMessageDescColour), ($summary, "Yellow"),
      ("No of files", $GeneralMessageDescColour), ($index.ToString(), $GeneralMessageValueColour)
    );
  
    Write-Host "$endOfProcessingLine" -ForegroundColor $LineColour;
  }

  return $collection;
}
