
<#
.NAME
  Invoke-ForeachDirectory

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
function Invoke-ForeachDirectory {
  param
  (
    [parameter(Mandatory = $true)]
    [string]$directory,
    [string]$filter = "*",
    [scriptblock]$condition = ({ return $true; }),
    [scriptblock]$body,
    [System.Collections.Hashtable]$propertyBag = @{ },
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

    Write-PairInColour @( (">>> Original directory name", $GeneralMessageDescColour), `
      ($name, $OriginalItemColour) );

    $result = $body.Invoke($_, $index, $propertyBag);

    if (($null -ne $result) -and (-not [string]::IsNullOrEmpty($result.Message))) {

      Write-PairInColour @( ($result.Message, $GeneralMessageDescColour), `
        ($result.Product, $result.Colour) );
    }
  } # ForEach-Object

  Write-PairInColour @( ("••• Directory count", $GeneralMessageDescColour), `
    ($index, "Red") );

  Write-Host "$endOfProcessingLine" -ForegroundColor $LineColour;

  return $collection;
}

<#
.NAME
  Invoke-ForeachFile

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

function Invoke-ForeachFile {
  param
  (
    [parameter(Mandatory = $true)]
    [string]$directory,
    [string]$filter = "*",
    [string]$inclusions,
    [scriptblock]$condition = ( { return $true; }),
    [scriptblock]$body,
    [System.Collections.Hashtable]$propertyBag = @{ },
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

  $collection = Get-ChildItem -Path (Add-Wildcard($directory)) -File -Filter $filter -Include $inclusions `
    | Get-SortedFilesNatural | Where-Object {
    $condition.Invoke($_);
  } | ForEach-Object {

    $index++;

    if ($isVerbose) {
      Write-Host $eachItemLine -ForegroundColor $LineColour;
    }

    $name = $_.Name;

    if ($isVerbose) {
      Write-PairInColour @( (">>> Original file name", $GeneralMessageDescColour), `
        ($name, $OriginalItemColour) );
    }

    # Do the invoke
    #
    $result = $body.Invoke($_, $index, $propertyBag, $trigger);

    # Hande the result
    #
    if ($result) {
      if ($isVerbose) {

        Write-PairInColour @( ($result.Message, $GeneralMessageDescColour), `
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

    Write-2PairInColour @(
      ("Summary", $GeneralMessageDescColour), ($summary, "Yellow"),
      ("No of files", $GeneralMessageDescColour), ($index.ToString(), $GeneralMessageValueColour)
    );
  
    Write-Host "$endOfProcessingLine" -ForegroundColor $LineColour;
  }

  return $collection;
}

<#
.NAME
  Invoke-TraverseDirectory
.SYNOPSIS
  Peforms a recursive traversal of the source directory tree specified. The source tree
  is mirrored in the destination and invokes the script block for all the files found
  in the source tree in the corresponding location in the destination tree.

.PARAMETER $source
  The root of the source tree to traverse. (Must exist)

.PARAMETER $destination
  The root of the destination tree to traverse. (Does not need to exist prior to running)

.PARAMETER $suffix
  The file suffix in the source tree to which the script block is to be applied.

.PARAMETER $onSourceFile
  The custom script block, which contains the implementation invoked for each file with
  the suffix specified in the source tree.

.PARAMETER $propertyBag
  A hashtable containing custom properties required by the script block. This property bag
  must also include properties named "ROOT-SOURCE" and "ROOT-DESTINATION" which specify
  the root paths of the source and destination file system locations respectively.

.PARAMETER $onSourceDirectory
  The custom script block, which contains the implementation invoked for each source directory.
  The $onSourceDirectory script block takes 2 parameters, $source; the source directory and
  a custom property bag $propertyBag

.PARAMETER $WhatIf
  Perform a dry run of the operation.
#>
function Invoke-TraverseDirectory {
  param
  (
    [parameter(Mandatory = $true)] [String]$source,
    [parameter(Mandatory = $true)] [String]$destination,
    [parameter(Mandatory = $true)] [String]$suffix,
    [parameter(Mandatory = $true)] [scriptblock]$onSourceFile,
    [parameter(Mandatory = $true)] [System.Collections.Hashtable]$propertyBag,
    [scriptblock]$onSourceDirectory = ({ return $true; }),
    [Switch]$WhatIf
  )

  $inclusions = "*." + $suffix;
  $summary = "<SUMMARY ...>";

  Invoke-ForeachFile -Directory $source -inclusions $inclusions -body $onSourceFile -propertyBag $propertyBag `
    -summary $summary -Verb;

  # Convert directory contents
  #
  [scriptblock]$doTraversal = { param($underscore, $index, $properties)

    $rootSource = $properties["ROOT-SOURCE"];
    $rootDestination = $properties["ROOT-DESTINATION"];

    $sourceDirectoryName = $underscore.Name;
    $sourceDirectoryFullName = $underscore.FullName;
    $contentsColour = "Green";

    $destinationBranch = Edit-SubtractFirst -target $sourceDirectoryFullName -subtract $rootSource;
    $destinationDirectory = Join-Path -Path $rootDestination  -ChildPath $destinationBranch;
    Write-PairInColour @( ("destination directory", "Yellow"), ($destinationDirectory, "Red") );

    Invoke-TraverseDirectory -source $sourceDirectoryFullName -destination $destinationDirectory `
      -suffix $suffix -onSourceFile $onSourceFile -propertyBag $propertyBag -onSourceDirectory $onSourceDirectory;

    return @{ Message = "*** Convert directory contents"; Product = $sourceDirectoryName; Colour = $contentsColour };
  }

  $null = Invoke-ForeachDirectory -Directory $source -body $doTraversal -propertyBag $propertyBag;

  # Invoke the source directory block
  #
  $null = $onSourceDirectory.Invoke($source, $propertyBag);
}
