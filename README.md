# :musical_score: XLDPlusPlus
*Batch conversion helper for 'X Lossless Decoder'*

:warning: Warning: do not use until this message has been removed.

### Introduction

[**XLD**](https://tmkk.undo.jp/xld/index_e.html) is a :rocket: great tool for performing lossless audio conversion. However, using the GUI tool, it quickly became apparent, for large audio collections there was a need to perform a batch run of conversions. The GUI tool is not well suited to this task since there is no way to specify different output paths for each individual source file. The only thing you can do is to opt to produce the output file in the same as the source and this restriction also applies to the command line. Wouldn't it be great if we could mirror the source directory tree into a new destination tree, producing the result of converted audio files in the corresponding output path.

Enter, **XLDPlusPlus**!! This is a suite of powershell scripts that performs just this function. Powershell, I hear you scoff. Fear not since those fellows at Microsoft have made Powershell a truly multi-platform scripting environment.

Using the script, is pretty simple, all you need to provide is the root directory of the audio library that needs to be converted, the root directory where the converted library is to be produced, the file suffix of the original audio files and the format that they should be converted to. Please note that during a single batch run, only one source format and destination format can be specified. The user should refer to the documentation of XLD to find supported audio formats.

### Prerequisites

- The recommended way to install Powershell would be to use [:beer: homebrew](https://brew.sh/), please see [this](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos?view=powershell-7) for more info.
- If this is the first time you're using Powershell on a Mac, then you will need to ensure that script execution is enabled, see [this](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7) for more info. In essence, to achieve this you'll need to run this command in a powershell session: *"Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine"*)

### Setup

- Currently, there is no installer for this script. Users who are familiar with git can acquire the repo via the *git clone* command on [this](https://github.com/plastikfan/XLDPlusPlus) url. Users who are not developers and unlikely to be familiar with git, can just click [:arrow_down:here](https://github.com/plastikfan/XLDPlusPlus/archive/master.zip), and save the resultant zip file to local drive and extract the archive to a location of choice.
- To make this script available without having to manually source the script for every new PowerShell session, add it to your [PowerShell Profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7).

### The command line

Before the command can be invoked, the script should be sourced in a powershell session (unless this has been done automatically via the PowerShell profile as previously mentioned) as follows

> . ./XLDPlusPlus.psm1

This will make the command *Convert-Audio* available to use and is commonly invoked as follows:

> $ Convert-Audio -source \<source\> -destination \<destination\> -from \<from\> -to \<to\>

The source directory tree is replicated in the destination with the result of converting audio files of the type indicated by \<from\> to the format specified by \<to\>.

For example:

> Convert-Audio -source '/Volumes/Envy/Music/HI-RES' -destination '/Users/Plastikfan/Music/HI-RES' -from "wav" -to "flac"

will perform a *.wav* file to *.flac* file conversion replicating the whole directory structure from *'/Volumes/Envy/Music/HI-RES/'* to location '/Users/Plastikfan/Music/HI-RES/' (which will be created if it doesn't already exist prior to the batch run).

### Optional extras

#### ~ Copy additional files

Use the *-copyFiles* argument

- Denotes which other files to copy over from the source tree to the destination expressed as a csv of file suffixes. The copied files will not include any files whose suffix match either $from or $to, in order to avoid the potential for name clashes. This is really meant for auxiliary files like cover art jpg images and text files, or any other such meta data. The default is "*" meaning that all files are copied over subject to the caveats just mentioned. (To disable the copying of any other files to the destination, use *-copyFiles=""*)

Eg: to copy over just text files (\*.txt) and jpeg images (\*.jp\*g), specify: -copyFiles "\*.txt,\*.jp\*g"

#### ~ Skip files if they already exist in the destination

Use the *-Skip* switch argument

- Skip existing audio file conversion if it already exists in the destination. This makes the script
  re-runnable if for any reason, a previous run had to be aborted; leaving the destination tree
  incomplete. Use the *-Skip* option, if you want to resume a previous batch run without re-converting files that have already been converted.

#### ~ Perform a dry run without audio conversion

Use the *-WhatIf* switch argument

- Dry-run the operation, to see which files would be converted during the batch process.

#### ~ Command alias

An alias has been defined the *Convert-Audio* command as *cvaudio* for further convenience so the generic example shown previously could be invoked as:

> cvaudio -source '/Volumes/Envy/Music/HI-RES' -destination '/Users/Plastikfan/Music/HI-RES' -from "wav" -to "flac"

### And finally ...

This tool was created to fulfil a personal need to batch convert a large digital audio collection. Not all capabilities of XLD are invoked by this script, but hopefully it is useful enough to other like-minded folk. Feel free to raise new issues [here](https://github.com/plastikfan/XLDPlusPlus/issues) and depending on the request, I'll be :smiley: to oblige by making :hammer:enhancements/:bug:bug fixes.
