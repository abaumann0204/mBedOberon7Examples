MODULE Display;
(* =========================================================================
   Example Cortex-M3 Oberon Module

   Description:
     Write line-oriented output to an LCD display

   Target:
     Dependent on the imported module: LCD

   Tested on:
     ARM mbed Application Board with a Newhaven C12832A1Z 128 x 32 LCD display 

   (c) 2011-2013 CFB Software
   http://www.astrobe.com

   ========================================================================= *)

IMPORT LCD := LCDST756R, Fonts := Fonts6x8;

CONST
  LF = 0AX;
  Cols* = LCD.Cols;
  Rows* = LCD.Rows;

TYPE
  Row = ARRAY Cols OF CHAR;
  Screen = ARRAY Rows + 1 OF Row;

VAR
  rowNo*, colNo*: INTEGER;
  screen: Screen;
  blankRow: Row;
  Refresh*: PROCEDURE;


PROCEDURE WriteChar(ch: CHAR; r, c: INTEGER);
BEGIN
  LCD.DrawChar(LCD.Black, ch, c, r)
END WriteChar;


PROCEDURE WriteRow(row: Row);
VAR
  c: INTEGER;
BEGIN
  FOR c := 0 TO Cols - 1 DO
    WriteChar(row[c], rowNo, c)
  END;
  Refresh()
END WriteRow;


PROCEDURE* NewRow();
BEGIN
  INC(rowNo);
  colNo := 0;
  screen[rowNo] := blankRow
END NewRow;


PROCEDURE ScrollUp;
VAR
  r: INTEGER;
BEGIN
  (* Move rows up *)
  FOR r := 1 TO Rows DO
    rowNo := r - 1;
    screen[rowNo] := screen[r];
    WriteRow(screen[rowNo])
  END;
  NewRow()
END ScrollUp;


PROCEDURE Ln*();
BEGIN
  IF rowNo < Rows THEN
    WriteRow(screen[rowNo]);
    NewRow()
  ELSE
    ScrollUp
  END
END Ln;


PROCEDURE Char*(ch: CHAR);
BEGIN
  IF ch = LF THEN
    Ln
  ELSIF ch >= " " THEN
    screen[rowNo, colNo] := ch;
    INC(colNo);
    IF colNo = Cols THEN Ln END
  END
END Char;


PROCEDURE String*(s: ARRAY OF CHAR);
VAR
  i: INTEGER;
BEGIN
  i := 0;
  WHILE (i < LEN(s)) & (s[i] # 0X) DO Char(s[i]); INC(i) END
END String;


PROCEDURE Init*();
VAR
  ok: BOOLEAN;
BEGIN
  LCD.Init();
  ok := LCD.LoadFont("Fonts6x8");
  ASSERT(ok, 100);
END Init;


BEGIN
  (* Initialise the memory representation of the screen *)
  FOR colNo := 0 TO Cols - 1 DO blankRow[colNo] := " " END;
  FOR rowNo := 0 TO Rows - 1 DO screen[rowNo] := blankRow END;
  rowNo := 0;
  colNo := 0;
  Refresh := LCD.Refresh;
END Display.
