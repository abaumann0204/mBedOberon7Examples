MODULE DisplayDemo;
(* =========================================================================  
   Example Cortex-M3 Oberon Program  
 
   Description:
     Demonstrate text and graphics capabilities of an LCD display.
     
   Target:
     Dependent on the imported modules: Display -> LCDST756R 
     
   Tested on: 
     ARM mbed Application Board with a Newhaven C12832A1Z 128 x 32 LCD display 
   
   (c) 2013 CFB Software   
   http://www.astrobe.com  
   
   ========================================================================= *)

IMPORT Display, LCD := LCDST756R, Main, Out, Random, Timer, Traps;


PROCEDURE DisplayChars;
(* Display all the printable characters in the character set 
   implemented in the font used *)
VAR
  i: INTEGER;
BEGIN
  FOR i := ORD(" ") TO ORD("~") DO 
    Out.Char(CHR(i));
    (* Pause for a second at the start of a 
       new line to allow time to read it
       before the screen scrolls *)
    IF Display.colNo = 0 THEN 
      Timer.MSecDelay(1000)
    END;
  END;
  Out.Ln();
  Timer.MSecDelay(1000)
END DisplayChars;


PROCEDURE DisplayText;
(* Display 500 scrolling lines of text *)
VAR
  count: INTEGER;
BEGIN
  FOR count := 1 TO 500 DO 
    Out.String("Line ");
    Out.Int(count, 0);
    Out.Ln()
  END
END DisplayText;


PROCEDURE DisplayDots;
(* Randomly display / clear pixels *)
VAR
  i, x, y: INTEGER;
  black: BOOLEAN;
BEGIN
  LCD.ClearScreen(LCD.White);
  black := TRUE;
  FOR i := 0 TO 100000 DO 
    x := Random.Next(LCD.MaxX);
    y := Random.Next(LCD.MaxY);
    IF black THEN 
      LCD.DrawDot(LCD.Black, x, y)
    ELSE
      LCD.DrawDot(LCD.White, x, y)
    END;
    black := ~black;
    IF i MOD 32 = 0 THEN 
      LCD.Refresh()
    END
  END
END DisplayDots;


PROCEDURE MoveBox(x, y: INTEGER);
(* Display a black square for 1/10th second 
   and then erase it *) 
BEGIN
  LCD.FillRectangle(LCD.Black, x, y, x + 7, y + 7);
  LCD.Refresh();
  Timer.MSecDelay(100);
  LCD.FillRectangle(LCD.White, x, y, x + 7, y + 7)
END MoveBox;
 

PROCEDURE DisplayBoxes;
(* Display a black square at random positions *)
VAR
  i, x, y: INTEGER;
BEGIN
  LCD.ClearScreen(LCD.White);
  FOR i := 0 TO 50 DO 
    x := Random.Next(LCD.MaxX - 7);
    y := Random.Next(LCD.MaxY - 7);
    MoveBox(x, y)
  END
END DisplayBoxes;


PROCEDURE DisplayMovingBox;
(* Move a box from left to right along a row and 
   then return in the opposite direction on the
   next row, continuing until all rows 
   is reached *)
VAR
  pageNo, xLimit, yLimit, pageLimit, x, y: INTEGER;
BEGIN
  pageLimit := LCD.Pages - 1;
  xLimit := LCD.MaxX - 7;
  FOR pageNo := 0 TO pageLimit DO 
    y := pageNo * 8;
    yLimit := y + 7;
    IF ODD(pageNo) THEN
      FOR x := xLimit TO 0 BY - 1 DO MoveBox(x, y) END; 
      IF pageNo < pageLimit THEN 
        FOR y := y TO yLimit DO MoveBox(0, y) END  
      END 
    ELSE 
      FOR x := 0 TO xLimit DO MoveBox(x, y) END;
      FOR y := y TO yLimit DO MoveBox(xLimit, y) END  
    END
  END 
END DisplayMovingBox;


PROCEDURE Run;
CONST
  Delay = 4000; (* 4 secs *)
BEGIN
  Traps.ShowRegs(FALSE);
  (* Redirect all output to the display *)
  Out.Init(Display.Char);
  Display.Init();
  DisplayChars();
  Timer.MSecDelay(Delay);
  DisplayText();
  Timer.MSecDelay(Delay);
  DisplayDots();
  Timer.MSecDelay(Delay); 
  DisplayBoxes();
  Timer.MSecDelay(Delay); 
  DisplayMovingBox();
END Run;


BEGIN
  Run
END DisplayDemo.
    
