
<#
.NAME
    write-host-in-colour

.SYNOPSIS
    The user passes in an array of 1,2 or 3 element arrays, which contains any number of text fragments
    with an optional colour specification (ConsoleColor enumeration). The function will then write a
    multi coloured text line to the console. 

    Element 0: text
    Element 1: foreground colour
    Element 2: background colour

    If the background colour is required, then the foreground colour must also be specified.

    write-host-in-colour -colouredTextLine  @( ("some text", "Blue"),  ("some more text", "Red", "White") )
    write-host-in-colour -colouredTextLine  @( ("some text", "Blue"),  ("some more text", "Red") )
    write-host-in-colour -colouredTextLine  @( ("some text", "Blue"),  ("some more text") )

    If you only need to write a single element, use an extra , preceding the array eg:

    write-host-in-colour -colouredTextLine  @( ,@("some text", "Blue") )

#>
function write-host-in-colour {
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
    write-pair-in-colour

.SYNOPSIS
    Writes a key value pair in colour; array size should be 2.

.EXAMPLE                    1                   2
    write-pair-in-colour @( ("Artist", "BLUE"), ("Garbage", "Red") )

    prints:
    Artist: 'Garbage'
#>
function write-pair-in-colour {
  param
  (
    $colouredText
  )

  if ($colouredText.Length -eq 2) {

    write-host-in-colour -colouredTextLine @( ($colouredText[0]), (": '", "White"), ($colouredText[1]), ("'", "White"));
  }
  else {

    Write-Warning "";
  }
}

<#
.NAME
    write-message-and-pair-in-colour

.SYNOPSIS
    Writes a body message followed by a key value pair in colour; array size should be 3.

.EXAMPLE                                0                         1                   2
    write-message-and-pair-in-colour @( ("Hello world", "Green"), ("Artist", "Blue"), ("Garbage", "Cyan") )

    prints:
    Hello world ==> Artist: 'Garbage'.
#>
function write-message-and-pair-in-colour {
  param
  (
    $colouredText
  )

  if ($colouredText.Length -eq 3) {

    # TODO (BUG in write-host-in-colour): Shouldn't need to specify the White Colour here
    #
    write-host-in-colour -colouredTextLine @(
      ($colouredText[0]), (" ==> ", "White"),
      ($colouredText[1]), (": '", "White"), ($colouredText[2]), ("'.", "White")
    );
  }
  else {

    $len = $colouredText.Length;
    Write-Warning "write-2pair-in-colour: Malformed message, Field length: $len";
  }
}

<#
.NAME
    write-2pair-in-colour

.SYNOPSIS
    Writes 2 key value pairs in colour; array size should be 4.

.EXAMPLE                     0                   1                    2                        3
    write-2pair-in-colour @( ("Artist", "Blue"), ("Garbage", "Cyan"), ("Song", "DarkYellow"),  ("Supervixen", "Yellow") )

    prints:
    Artist: 'Garbage', Song: 'Supervixen'.
#>
function write-2pair-in-colour {
  param
  (
    $colouredText
  )

  if ($colouredText.Length -eq 4) {

    write-host-in-colour -colouredTextLine @(
      ($colouredText[0]), (": '", "White"), ($colouredText[1]), ("', ", "White"),
      ($colouredText[2]), (": '", "White"), ($colouredText[3]), ("'.", "White")
    );
  }
  else {

    $len = $colouredText.Length;
    Write-Warning "write-2pair-in-colour: Malformed message, Field length: $len";
  }
}

<#
.NAME
    write-message-and-2pair-in-colour

.SYNOPSIS
    Writes 2 key value pairs in colour; array size should be 5.

.EXAMPLE                                 0                         1                   2                    3                        4
    write-message-and-2pair-in-colour @( ("Hello World", "Green"), ("Artist", "Blue"), ("Garbage", "Cyan"), ("Song", "DarkYellow"),  ("Supervixen", "Yellow") )

    prints:
    Hello World ==> Artist: 'Garbage', Song: 'Supervixen'.
#>
function write-message-and-2pair-in-colour {
  param
  (
    $colouredText
  )

  if ($colouredText.Length -eq 5) {

    write-host-in-colour -colouredTextLine @(
      ($colouredText[0]), (" ==> ", "White"),
      ($colouredText[1]), (": '", "White"), ($colouredText[2]), ("', ", "White"),
      ($colouredText[3]), (": '", "White"), ($colouredText[4]), ("'.", "White")
    );
  }
  else {

    $len = $colouredText.Length;
    Write-Warning "write-message-and-2pair-in-colour: Malformed message, Field length: $len";
  }
}

<#
.NAME
    write-3pair-in-colour

.SYNOPSIS
    Writes 3 key value pairs in colour; array size should be 6.

.EXAMPLE                     0                   1                    2                  3                           4                        5
    write-3pair-in-colour @( ("Artist", "Blue"), ("Garbage", "Cyan"), ("Album", "Blue"), ("Deluxe Edition", "Cyan"), ("Song", "DarkYellow"),  ("Supervixen", "Yellow"))

    prints:
    Artist: 'Garbage', Album: 'Deluxe Edition', Song: 'Supervixen'.
#>
function write-3pair-in-colour {
  param
  (
    $colouredText
  )

  if ($colouredText.Length -eq 6) {

    write-host-in-colour -colouredTextLine @(
      ($colouredText[0]), (": '", "White"), ($colouredText[1]), ("', ", "White"),
      ($colouredText[2]), (": '", "White"), ($colouredText[3]), ("', ", "White"),
      ($colouredText[4]), (": '", "White"), ($colouredText[5]), ("'.", "White")
    );
  }
  else {

    $len = $colouredText.Length;
    Write-Warning "write-3pair-in-colour: Malformed message, Field length: $len";
  }
}

<#
.NAME
    write-message-and-3pair-in-colour

.SYNOPSIS
    Writes a message body and 3 key value pairs in colour; array size should be 7.

.EXAMPLE                                 0                         1                   2                    3                    4                           5                         6
    write-message-and-3pair-in-colour @( ("Hello World", "Green"), ("Artist", "Blue"), ("Garbage", "Cyan"), ("Album", "Blue"), ("Deluxe Edition", "Cyan"), ("Song", "DarkYellow"),  ("Supervixen", "Yellow"))

    prints:
    Hello World ==> Artist: 'Garbage', Album: 'Deluxe Edition', Song: 'Supervixen'.
#>
function write-message-and-3pair-in-colour {
  param
  (
    $colouredText
  )

  if ($colouredText.Length -eq 7) {

    write-host-in-colour -colouredTextLine @(
      ($colouredText[0]), (" ==> ", "White"),
      ($colouredText[1]), (": '", "White"), ($colouredText[2]), ("', ", "White"),
      ($colouredText[3]), (": '", "White"), ($colouredText[4]), ("', ", "White"),
      ($colouredText[5]), (": '", "White"), ($colouredText[6]), ("'.", "White")
    );
  }
  else {

    $len = $colouredText.Length;
    Write-Warning "write-message-and-3pair-in-colour: Malformed message, Field length: $len";
  }
}
