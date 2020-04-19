
# Valid formats
#
$Formats = @("wav", "aif", "raw_big", "raw_little", "mp3", "aac", "flac", "alac", "vorbis", "wavpack", "opus")

# Line definitions
#
$LineLength = 121;
$UnderscoreLine = (New-Object String("_", $LineLength)); # end of processing
$EqualsLine = (New-Object String("=", $LineLength)); # main
$DotsLine = (New-Object String(".", $LineLength)); # lower order functions
$LightDotsLine = ((New-Object String(".", (($LineLength - 1) / 2))).Replace(".", ". ") + "."); # lower order functions
$TildeLine = (New-Object String("~", $LineLength)); # Used for xxxAll- higher order functions

# Colour definitions
#
$LineColour = "DarkGray";

$GeneralMessageDescColour = "White";
$GeneralMessageValueColour = "Cyan";
$GeneralMessageAffirmativeColour = "Green";
$GeneralMessageHesitantColour = "DarkGreen";

$OriginalItemColour = "Blue"
$NewItemColour = "Green";
$HighlightItemColour = "Yellow";
$RemoveItemColour = "DarkRed";
$AboutToDoColour = "DarkGray";

