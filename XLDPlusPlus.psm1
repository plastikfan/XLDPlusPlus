<#
.NAME
  Invoke-ConversionBatch

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

.PARAMETER $copyFiles
  Denotes which other files to copy over from the source tree to the destination expressed as a
  csv of wildcard file suffixes. The copied files will not include any files whose suffix match either
  $from or $to, in order to avoid the potential for name clashes. This is really meant for
  auxilliary files like cover art jpg images and text files, or any other such meta data. The
  default is "*" meaning that all files are copied over subject to the caveats just mentioned.

.PARAMETER $Skip
  Skip existing audio file version if it already exists in the destination. This makes the script
  re-runable if for any reason, a previous run had to be aborted; leaving the destination tree
  incomplete.

.PARAMETER $WhatIf
  Dry-run the operation.
#>
function Invoke-ConversionBatch {
  param
  (
    [parameter(Mandatory = $true)] [String]$source,
    [parameter(Mandatory = $true)] [String]$destination,
    [parameter(Mandatory = $true)] [String]$from,
    [parameter(Mandatory = $true)] [String]$to,
    [String]$copyFiles = "*",

    [Switch]$Skip,
    [Switch]$WhatIf
  )

  # Convert source audio files
  #
  [scriptblock]$doAudioFileConversion = { param($underscore, $index, $properties, $trigger)

    [string]$sourceFilename = $underscore.Name;
    [string]$sourceFullname = $underscore.FullName;
    [string]$conversionColour = "Cyan";
    [string]$rootSource = $properties["ROOT-SOURCE"];
    [string]$rootDestination = $properties["ROOT-DESTINATION"];
    [string]$format = $properties["TO-FORMAT"];
    [boolean]$skipExisting = $properties.ContainsKey("SKIP");

    [string]$destinationBranch = Edit-SubtractFirst -target $sourceFullname -subtract $rootSource;
    [string]$destinationAudioFilename = Join-Path -Path $rootDestination -ChildPath $destinationBranch;
    $destinationAudioFilename = ((Edit-TruncateExtension -path $destinationAudioFilename) + "." + $format);
    Write-PairInColour @( ("destination audio file", "Yellow"), ($destinationAudioFilename, "Red") );

    [string]$command = ("xld -f '" + $format + "' -o '" + $destinationAudioFilename + "' '" + $sourceFullname + "'");
    [boolean]$doConversion = $true;

    if (Test-Path -Path $destinationAudioFilename) {
      if ($skipExisting) {
        Write-Warning ("!!! Skipping existing file: '" + $destinationAudioFilename + "'");
        $doConversion = $false;
      }
      else {
        Write-Warning ("!!! Overwriting existing file: '" + $destinationAudioFilename + "'");
      }
    }
  
    if ($doConversion) {
      Write-PairInColour @( ("command: ", "Red"), ($command, "Green") );
      # TODO: invoke the command
      #
      # Invoke-Expression -Command $command
    }
  
    [string]$message = ("*** Convert source audio file: '" + $sourceFilename + "'");
    return @{ Message = $message; Product = $sourceFullname; Colour = $conversionColour; Trigger = $true };
  }

  $propertyBag = @{
    "ROOT-SOURCE"      = $source;
    "ROOT-DESTINATION" = $destination;
    "TO-FORMAT"        = $to;
    "FROM-SUFFIX"      = $from;
    "COPY-FILES"       = $copyFiles;
  };

  if ($Skip.ToBool()) {
    $propertyBag["SKIP"] = $true;
  }
 
  # Copy over other files
  #
  [scriptblock] $doCopyFiles = { param($source, $properties)
    [string]$suffix = $properties["FROM-SUFFIX"];
    [string]$includes = $properties["COPY-FILES"];
    [string]$format = $properties["TO-FORMAT"];
    Write-PairInColour @( ("Copy files ...", "Blue"), ($includes, "Red") );

    [scriptblock]$isCopyCandidate = { param($underscore)
      [string]$filename = $underscore.Name;
      [boolean]$result = (!($filename.EndsWith($suffix)) -and (!($filename.EndsWith($format))));
      return $result;
    }

    [scriptblock]$doCopySingleFile = { param($underscore, $index, $properties, $trigger)
      [string]$sourceFullname = $underscore.FullName;

      [string]$rootSource = $properties["ROOT-SOURCE"];
      [string]$rootDestination = $properties["ROOT-DESTINATION"];


      [string]$destinationBranch = Edit-SubtractFirst -target $sourceFullname -subtract $rootSource;
      [string]$copyToDestinationFullName = Join-Path -Path $rootDestination -ChildPath $destinationBranch;

      Copy-Item -LiteralPath $sourceFullname -Destination $copyToDestinationFullName -WhatIf;
    }

    Invoke-ForeachFile -Directory $source -inclusions $includes -condition $isCopyCandidate -body $doCopySingleFile `
      -propertyBag $propertyBag -Verb;
  }

  Invoke-TraverseDirectory -source $source -destination $destination -suffix $from `
    -onSourceFile $doAudioFileConversion -propertyBag $propertyBag -onSourceDirectory $doCopyFiles;
}

<#
.SEE
  https://tmkk.undo.jp/xld/index_e.html

.NAME
  Convert-Audio

.SYNOPSIS
  The entry point into the converter

.PARAMETER $source
  The root of the source tree containing audio to convert. (Must exist)

.PARAMETER $destination
  The root of the destination tree contain where output audio will be written to. This does not
  have to exist prior to running. The source tree is mirrored here in the destination tree.

.PARAMETER $from
  The audio format from which to convert. See xld help for supported formats. Only the files
  that match this format will be converted.

.PARAMETER $to
  The audio format to convert to. See xld help for supported formats.

.PARAMETER $copyFiles
  Denotes which other files to copy over from the source tree to the destination expressed as a
  csv of file suffixes. The copied files will not include any files whose suffix match either
  $from or $to, in order to avoid the potential for name clashes. This is really meant for
  auxilliary files like cover art jpg images and text files, or any other such meta data. The
  default is "*" meaning that all files are copied over subject to the caveats just mentioned.

.PARAMETER $Skip
  Skip existing audio file version if it already exists in the destination. This makes the script
  re-runable if for any reason, a previous run had to be aborted; leaving the destination tree
  incomplete.

.PARAMETER $WhatIf
  Dry-run the operation.
#>
function Convert-Audio {
  param
  (
    [parameter(Mandatory = $true)] [String]$source,
    [parameter(Mandatory = $true)] [String]$destination,
    [parameter(Mandatory = $true)] [String]$from,
    [parameter(Mandatory = $true)] [String]$to,
    [String]$copyFiles = "*",

    [Switch]$Skip,
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

  Invoke-ConversionBatch -source $source -destination $destination -from $from -to $to -copyFiles $copyFiles
}

Set-Alias -Name cvaudio -Value Convert-Audio
