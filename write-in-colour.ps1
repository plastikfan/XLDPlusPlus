
<#
.NAME
    Write-InColour

.SYNOPSIS
    The user passes in an array of 1,2 or 3 element arrays, which contains any number of text fragments
    with an optional colour specification (ConsoleColor enumeration). The function will then write a
    multi coloured text line to the console. 

    Element 0: text
    Element 1: foreground colour
    Element 2: background colour

    If the background colour is required, then the foreground colour must also be specified.

    Write-InColour -colouredTextLine  @( ("some text", "Blue"),  ("some more text", "Red", "White") )
    Write-InColour -colouredTextLine  @( ("some text", "Blue"),  ("some more text", "Red") )
    Write-InColour -colouredTextLine  @( ("some text", "Blue"),  ("some more text") )

    If you only need to write a single element, use an extra , preceding the array eg:

    Write-InColour -colouredTextLine  @( ,@("some text", "Blue") )

#>
function Write-InColour {
  param
  (
    $colouredTextLine,

    [Switch]$NoNewLine
  )

  foreach ($snippet in $colouredTextLine) {

    if ($snippet.Length -eq 2) {

      if ($null -eq $snippet[1]) {
        continue;
      }

      # Foreground colour specified
      #
      Write-Host $snippet[0] -NoNewline -ForegroundColor $snippet[1];
    }
    elseif ($snippet.Length -eq 1) {

      # No colours specified
      #
      Write-Host $snippet[0] -NoNewline;
    }
    else {

      if ($null -eq $snippet[1]) {
        continue;
      }

      # Foreground and background colours specified
      #
      Write-Host $snippet[0] -NoNewline -ForegroundColor $snippet[1] -BackgroundColor $snippet[2];
    }
  }

  if (-not ($NoNewLine.ToBool())) {
    Write-Host "";
  }
}

<#
.NAME
    Write-PairInColour

.SYNOPSIS
    Writes a key value pair in colour; array size should be 2.

.EXAMPLE                    1                   2
    Write-PairInColour @( ("Artist", "BLUE"), ("Garbage", "Red") )

    prints:
    Artist: 'Garbage'
#>
function Write-PairInColour {
  param
  (
    $colouredText
  )

  if ($colouredText.Length -eq 2) {

    Write-InColour -colouredTextLine @( ($colouredText[0]), (": '", "White"), ($colouredText[1]), ("'", "White"));
  }
  else {

    Write-Warning "";
  }
}

<#
.NAME
    Write-MessageAndPairInColour

.SYNOPSIS
    Writes a body message followed by a key value pair in colour; array size should be 3.

.EXAMPLE                                0                         1                   2
    Write-MessageAndPairInColour @( ("Hello world", "Green"), ("Artist", "Blue"), ("Garbage", "Cyan") )

    prints:
    Hello world ==> Artist: 'Garbage'.
#>
function Write-MessageAndPairInColour {
  param
  (
    $colouredText
  )

  if ($colouredText.Length -eq 3) {

    # TODO (BUG in Write-InColour): Shouldn't need to specify the White Colour here
    #
    Write-InColour -colouredTextLine @(
      ($colouredText[0]), (" ==> ", "White"),
      ($colouredText[1]), (": '", "White"), ($colouredText[2]), ("'.", "White")
    );
  }
  else {

    $len = $colouredText.Length;
    Write-Warning "Write-MessageAndPairInColour: Malformed message, Field length: $len";
  }
}

<#
.NAME
    Write-2PairInColour

.SYNOPSIS
    Writes 2 key value pairs in colour; array size should be 4.

.EXAMPLE                     0                   1                    2                        3
    Write-2PairInColour @( ("Artist", "Blue"), ("Garbage", "Cyan"), ("Song", "DarkYellow"),  ("Supervixen", "Yellow") )

    prints:
    Artist: 'Garbage', Song: 'Supervixen'.
#>
function Write-2PairInColour {
  param
  (
    $colouredText
  )

  if ($colouredText.Length -eq 4) {

    Write-InColour -colouredTextLine @(
      ($colouredText[0]), (": '", "White"), ($colouredText[1]), ("', ", "White"),
      ($colouredText[2]), (": '", "White"), ($colouredText[3]), ("'.", "White")
    );
  }
  else {

    $len = $colouredText.Length;
    Write-Warning "Write-2PairInColour: Malformed message, Field length: $len";
  }
}

<#
.NAME
    Write-MessageAnd2pairInColour

.SYNOPSIS
    Writes 2 key value pairs in colour; array size should be 5.

.EXAMPLE                                 0                         1                   2                    3                        4
    Write-MessageAnd2pairInColour @( ("Hello World", "Green"), ("Artist", "Blue"), ("Garbage", "Cyan"), ("Song", "DarkYellow"),  ("Supervixen", "Yellow") )

    prints:
    Hello World ==> Artist: 'Garbage', Song: 'Supervixen'.
#>
function Write-MessageAnd2pairInColour {
  param
  (
    $colouredText
  )

  if ($colouredText.Length -eq 5) {

    Write-InColour -colouredTextLine @(
      ($colouredText[0]), (" ==> ", "White"),
      ($colouredText[1]), (": '", "White"), ($colouredText[2]), ("', ", "White"),
      ($colouredText[3]), (": '", "White"), ($colouredText[4]), ("'.", "White")
    );
  }
  else {

    $len = $colouredText.Length;
    Write-Warning "Write-MessageAnd2pairInColour: Malformed message, Field length: $len";
  }
}

<#
.NAME
    Write-3PairInColour

.SYNOPSIS
    Writes 3 key value pairs in colour; array size should be 6.

.EXAMPLE                     0                   1                    2                  3                           4                        5
    Write-3PairInColour @( ("Artist", "Blue"), ("Garbage", "Cyan"), ("Album", "Blue"), ("Deluxe Edition", "Cyan"), ("Song", "DarkYellow"),  ("Supervixen", "Yellow"))

    prints:
    Artist: 'Garbage', Album: 'Deluxe Edition', Song: 'Supervixen'.
#>
function Write-3PairInColour {
  param
  (
    $colouredText
  )

  if ($colouredText.Length -eq 6) {

    Write-InColour -colouredTextLine @(
      ($colouredText[0]), (": '", "White"), ($colouredText[1]), ("', ", "White"),
      ($colouredText[2]), (": '", "White"), ($colouredText[3]), ("', ", "White"),
      ($colouredText[4]), (": '", "White"), ($colouredText[5]), ("'.", "White")
    );
  }
  else {

    $len = $colouredText.Length;
    Write-Warning "Write-3PairInColour: Malformed message, Field length: $len";
  }
}

<#
.NAME
    Write-MessageAnd3PairInColour

.SYNOPSIS
    Writes a message body and 3 key value pairs in colour; array size should be 7.

.EXAMPLE                                 0                         1                   2                    3                    4                           5                         6
    Write-MessageAnd3PairInColour @( ("Hello World", "Green"), ("Artist", "Blue"), ("Garbage", "Cyan"), ("Album", "Blue"), ("Deluxe Edition", "Cyan"), ("Song", "DarkYellow"),  ("Supervixen", "Yellow"))

    prints:
    Hello World ==> Artist: 'Garbage', Album: 'Deluxe Edition', Song: 'Supervixen'.
#>
function Write-MessageAnd3PairInColour {
  param
  (
    $colouredText
  )

  if ($colouredText.Length -eq 7) {

    Write-InColour -colouredTextLine @(
      ($colouredText[0]), (" ==> ", "White"),
      ($colouredText[1]), (": '", "White"), ($colouredText[2]), ("', ", "White"),
      ($colouredText[3]), (": '", "White"), ($colouredText[4]), ("', ", "White"),
      ($colouredText[5]), (": '", "White"), ($colouredText[6]), ("'.", "White")
    );
  }
  else {

    $len = $colouredText.Length;
    Write-Warning "Write-MessageAnd3PairInColour: Malformed message, Field length: $len";
  }
}
