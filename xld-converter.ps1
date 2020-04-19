. ./xld-definitions.ps1
. ./write-in-colour.ps1
. ./xld-utils.ps1
. ./iterate.ps1


<#
.NAME
  run-batch

.SYNOPSIS
  Executes the conversion batch.

.PARAMETER $source
  The root of the source tree to traverse. (Must exist)

.PARAMETER $destination
  The root of the destination tree to mirror. (Does not need to exist prior to running)

.PARAMETER $from
  The audio format from which to convert. See xld help for supported formats. Only the files that match
  this format will be converted.

.PARAMETER $to
  The audio format to convert to. See xld help for supported formats.
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
  [scriptblock]$doAudioFileConversion = { param($underscore, $index, $properties, $trigger)

    $sourceFilename = $underscore.Name;
    $sourceFullname = $underscore.FullName;
    $conversionColour = "Cyan";
    $rootSource = $properties["ROOT-SOURCE"];
    $rootDestination = $properties["ROOT-DESTINATION"];
    $format = $properties["TO-FORMAT"];

    $destinationBranch = Subtract-First -target $sourceFullname -subtract $rootSource;
    $destinationAudioFilename = Join-Path -Path $rootDestination  -ChildPath $destinationBranch;
    $destinationAudioFilename = ((Truncate-Extension -path $destinationAudioFilename) + "." + $format);
    write-pair-in-colour @( ("destination audio file", "Yellow"), ($destinationAudioFilename, "Red") );

    $command = ("xld -f '" + $format + "' -o '" + $destinationAudioFilename + "' '" + $sourceFullname + "'");
    write-pair-in-colour @( ("command: ", "Red"), ($command, "Green") );
  
    $message = ("*** Convert source audio file: '" + $sourceFilename + "'");
    return @{ Message = $message; Product = $sourceFullname; Colour = $conversionColour; Trigger = $true };
  }

  # $propertyBag = @{ };

  $propertyBag = @{
    "ROOT-SOURCE" = $source;
    "ROOT-DESTINATION" = $destination;
    "TO-FORMAT" = $to;
  };
 
  traverse-directory -source $source -destination $destination `
    -suffix $from -block $doAudioFileConversion -propertyBag $propertyBag;
}

<#
.NAME
  xld-batch-convert

.SYNOPSIS
  The entry point into the converter

.PARAMETER $source
  The root of the source tree containing audio to convert. (Must exist)

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
