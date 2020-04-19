. ./xld-definitions.ps1
. ./write-in-colour.ps1
. ./xld-utils.ps1
. ./iterate.ps1

# To convert an individual file:
#
# xld -f <format> -o <fullpath of output file> <input-file>

<#
.NAME
  traverse-directory
#>
function traverse-directory {
  param
  (
    [parameter(Mandatory = $true)] [String]$source,
    [parameter(Mandatory = $true)] [String]$rootSource,
    [parameter(Mandatory = $true)] [String]$destination,
    [parameter(Mandatory = $true)] [String]$rootDestination,
    [parameter(Mandatory = $true)] [String]$from,
    [parameter(Mandatory = $true)] [String]$to,
    [parameter(Mandatory = $true)] [scriptblock]$block,

    [Switch]$WhatIf
  )

  # Convert source audio files
  #
  [scriptblock]$doFileConversion = { param($underscore, $index, $trigger)

    $sourceFilename = $underscore.Name;
    $sourceFullname = $underscore.FullName;
    $conversionColour = "Cyan";

    $destinationBranch = Subtract-First -target $sourceFullname -subtract $rootSource;
    $destinationAudioFilename = Join-Path -Path $rootDestination  -ChildPath $destinationBranch;
    $destinationAudioFilename = ((Truncate-Extension -path $destinationAudioFilename) + "." + $to);
    write-pair-in-colour @( ("destination audio file", "Yellow"), ($destinationAudioFilename, "Red") );

    $command = ("xld -f '" + $to + "' -o '" + $destinationAudioFilename + "' '" + $sourceFullname + "'");
    write-pair-in-colour @( ("command: ", "Red"), ($command, "Green") );
  
    $message = ("*** Convert source audio file: '" + $sourceFilename + "'");
    return @{ Message = $message; Product = $sourceFullname; Colour = $conversionColour; Trigger = $true };
  }

  $inclusions = "*." + $from;
  $summary = "<SUMMARY ...>";

  foreach-file -Directory $source -inclusions $inclusions -body $doFileConversion -summary $summary -Verb;

  # Convert directory contents
  #
  [scriptblock]$doConvertContents = { param($underscore, $index)

    $sourceDirectoryName = $underscore.Name;
    $sourceDirectoryFullName = $underscore.FullName;
    $contentsColour = "Green";

    $destinationBranch = Subtract-First -target $sourceDirectoryFullName -subtract $rootSource;
    $destinationDirectory = Join-Path -Path $rootDestination  -ChildPath $destinationBranch;
    write-pair-in-colour @( ("destination directory", "Yellow"), ($destinationDirectory, "Red") );

    traverse-directory -source $sourceDirectoryFullName -rootSource $rootSource `
      -destination $destinationDirectory -rootDestination $rootDestination `
        -from $from -to $to -block $block;

    return @{ Message = "*** Convert directory contents"; Product = $sourceDirectoryName; Colour = $contentsColour };
  }

  $null = foreach-directory -Directory $source -body $doConvertContents;
}

<#
.NAME
  run-batch

.SYNOPSIS
  Executes the conversion batch.
#>
function run-batch {
  param
  (
    [parameter(Mandatory = $true)] [String]$source,
    [parameter(Mandatory = $true)] [String]$destination,
    [parameter(Mandatory = $true)] [String]$from,
    [parameter(Mandatory = $true)] [String]$to,

    [Switch]$WhatIf
  )

  # Convert source audio files
  #
  [scriptblock]$doFileConversion = { param($underscore, $index, $trigger)

    $sourceFilename = $underscore.Name;
    $sourceFullname = $underscore.FullName;
    $conversionColour = "Cyan";

    $destinationBranch = Subtract-First -target $sourceFullname -subtract $rootSource;
    $destinationAudioFilename = Join-Path -Path $rootDestination  -ChildPath $destinationBranch;
    $destinationAudioFilename = ((Truncate-Extension -path $destinationAudioFilename) + "." + $to);
    Write-Host ("[destinationAudioFilename: .....'" + $destinationAudioFilename + "']");

    $message = ("*** Convert source audio file: '" + $sourceFilename + "'");
    return @{ Message = $message; Product = $sourceFullname; Colour = $conversionColour };
  }

  traverse-directory -source $source -rootSource $source `
    -destination $destination -rootDestination $destination -from $from -to $to -block $doFileConversion;
}

<#
.NAME
  xld-batch-convert

.SYNOPSIS
  The entry point into the converter

.PARAMETER $source
  The root of the source tree contain audio to convert. (Must exist)

.PARAMETER $destination
  The root of the destination tree contain where output audio will be written to. This does not
  have to exist prior to running. The source tree is mirrored here in the destination tree.

.PARAMETER $from
  The audio format from which to convert. See xld help for supported formats. Only the files that match
  this format will be converted.

.PARAMETER $to
  The audio format to convert to. See xld help for supported formats.
#>
function xld-batch-convert {
  param
  (
    [parameter(Mandatory = $true)] [String]$source,
    [parameter(Mandatory = $true)] [String]$destination,
    [parameter(Mandatory = $true)] [String]$from,
    [parameter(Mandatory = $true)] [String]$to,

    [Switch]$WhatIf
  )

  if ( !(Test-Path -Path $source -PathType Container) ) {
    $error_message = "'" + $source + "', does not exist!";
    Write-Error $error_message;
    return;
  }

  if ( !(Test-Path -Path $destination -PathType Container) ) {
    New-Item -Path $destination -ItemType "Directory" -WhatIf: $WhatIf;
  }

  if (!($Formats -contains $from)) {
    $error_message = "from - '" + $from + "': unsupported format!";
    Write-Error $error_message;
    return;
  }

  if (!($Formats -contains $to)) {
    $error_message = "to - '" + $to + "': unsupported format!";
    Write-Error $error_message;
    return;
  }

  run-batch -source $source -destination $destination -from $from -to $to
}
