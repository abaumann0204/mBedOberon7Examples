MODULE LCDST756R;
(* =========================================================================  
   Example Cortex-M3 Oberon Module  
 
   Description:
     Sitronix ST756R LCD Controller Driver

   Target:
     mbed systems
     
   Tested on: 
     ARM mbed Application Board with a Newhaven C12832A1Z 128 x 32 LCD display 
   
   Reference:
     Sitronix ST756R DataSheet Ver 1.5 (10 Mar 2006).
     
   (c) 2013 CFB Software
   http://www.astrobe.com
   
   ========================================================================= *)

IMPORT Timer, MCU, ResData, SPI, SYSTEM;

CONST 
  Black*   = 0;
  White*   = 1;
  
  MaxX* = 127;
  MaxY* = 31;
  
  FontWidth = 6;
  FontHeight = 8;
  
  Cols* = (MaxX + 1) DIV FontWidth;
  Rows* = (MaxY + 1) DIV FontHeight;
  Pages* = (MaxY + 1) DIV 8;
  
  A0 = {6};    (* P0.6  = mbed P8 *)
  CS = {18};   (* P0.18 = mbed P11 *)
  Reset = {8}; (* P0.8  = mbed P6 *)

TYPE
  (* Each bit represents a pixel on the screen *)
  (* Each page can be refreshed invidually *)
  BitMap = ARRAY MaxX + 1 OF SET;
  (* 6 x 8 pixels *)
  FontPattern = ARRAY FontWidth OF BYTE;
  
VAR
  font: ResData.Resource;
  fontPattern: FontPattern;
  (* In-memory representation of the screen *)
  bitMap0, bitMap: BitMap;
    

  PROCEDURE LoadFont*(name: ARRAY OF CHAR): BOOLEAN;
  BEGIN
    ResData.Open(font, name);
    RETURN ResData.Size(font) > 0 
  END LoadFont;
    

  (* Store the font data for a character in a 2-D pixel array *) 
  PROCEDURE CharToFontPattern(ch: CHAR; VAR fontPattern: FontPattern);
  VAR
    i, index: INTEGER;
  BEGIN
    IF (ORD(ch) < ORD(" ")) OR (ORD(ch) > ORD("~")) THEN ch := "." END;
    index := (ORD(ch) - ORD(" ")) * 8;
    FOR i := 0 TO FontWidth - 1 DO  
      ResData.GetByte(font, index + i, fontPattern[i]);
    END 
  END CharToFontPattern;
  
   
  PROCEDURE SendData(data: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.FIO0SET, A0);
    SYSTEM.PUT(MCU.FIO0CLR, CS);
    SPI.SendData(data);
    SYSTEM.PUT(MCU.FIO0SET, CS);
  END SendData;
  
   
  PROCEDURE SendCommand(data: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.FIO0CLR, A0);
    SYSTEM.PUT(MCU.FIO0CLR, CS);
    SPI.SendData(data);
    SYSTEM.PUT(MCU.FIO0SET, CS)
  END SendCommand;

   
  PROCEDURE SetColumnAddr(x: INTEGER);
  CONST 
    ColumnAddrLo = 000H; 
    ColumnAddrHi = 010H; 
  BEGIN
    SendCommand(ColumnAddrLo + x MOD 16);
    SendCommand(ColumnAddrHi + x DIV 16)
  END SetColumnAddr;

   
  PROCEDURE SetPageAddr(n: INTEGER);
  CONST 
    PageAddrSet  = 0B0H; 
  BEGIN
    SendCommand(PageAddrSet + n)
  END SetPageAddr;

  
  PROCEDURE* DrawDot*(colour, x, y: INTEGER);
  BEGIN
    ASSERT((x <= MaxX) & (y <= MaxY) & (x >= 0) & (y >= 0), 100); 
    IF colour = Black THEN 
      bitMap[x] := bitMap[x] + {y}
    ELSE 
      bitMap[x] := bitMap[x] - {y}
    END
  END DrawDot;


  PROCEDURE* DrawVerticalLine*(colour: INTEGER; x, y1, y2: INTEGER);
  VAR 
    yBits: SET;
  BEGIN
    ASSERT((x >= 0) & (y1 >= 0) & (y2 >= y1) & (y2 <= MaxY), 100);
    yBits := {y1..y2};
    IF colour = Black THEN 
      bitMap[x] := bitMap[x] + yBits
    ELSE 
      bitMap[x] := bitMap[x] - yBits
    END
  END DrawVerticalLine;
     
   
  PROCEDURE* FillRectangle*(colour, x1, y1, x2, y2: INTEGER);
  VAR
    x: INTEGER;
    yBits: SET;
  BEGIN
    ASSERT((x >= 0) & (x2 > x1) & (x2 <= MaxX) & (y1 >= 0) & (y2 >= y1) & (y2 <= MaxY), 100);
    yBits := {y1..y2};
    IF colour = Black THEN 
      FOR x := x1 TO x2 DO bitMap[x] := bitMap[x] + yBits END 
    ELSE 
      FOR x := x1 TO x2 DO bitMap[x] := bitMap[x] - yBits END 
    END 
  END FillRectangle;
    
 
  PROCEDURE* DrawFontChar(fontPattern: FontPattern; col, row: INTEGER);
  VAR
    i, x, adr, fontAdr: INTEGER;
    fontData: BYTE;
  BEGIN
    ASSERT((col >= 0) & (col < Cols) & (row >= 0) & (row < Rows), 100);
    x := (col * FontWidth);
    adr := SYSTEM.ADR(bitMap[x]) + row;
    fontAdr := SYSTEM.ADR(fontPattern);
    FOR i := 0 TO FontWidth - 1  DO
      SYSTEM.GET(fontAdr, fontData, 1);
      SYSTEM.PUT(adr, fontData, 4) 
    END 
  END DrawFontChar;
  
   
  PROCEDURE DrawChar*(colour: INTEGER; ch: CHAR; col, row: INTEGER);
  VAR
    fontPattern: FontPattern;
  BEGIN
    CharToFontPattern(ch, fontPattern);
    DrawFontChar(fontPattern, col, row)
  END DrawChar;

  
  PROCEDURE Refresh*();
  (* Only write the pixel columns that have changed since the last refresh *)
  VAR
    pageNo, x, adr0, adr: INTEGER;
    data0, data: BYTE;
    col: INTEGER;
  BEGIN
    FOR pageNo := 0 TO Pages - 1 DO
      SetPageAddr(pageNo);
      col := -1;
      adr0 := SYSTEM.ADR(bitMap0) + pageNo;
      adr := SYSTEM.ADR(bitMap) + pageNo;
      FOR x := 0 TO MaxX DO 
        SYSTEM.GET(adr0, data0, 4);
        SYSTEM.GET(adr, data, 4);
        IF data # data0 THEN 
          IF col # x THEN 
            SetColumnAddr(x);
            col := x
          END;
          SendData(data);
          INC(col)
        END 
      END 
    END;
    bitMap0 := bitMap 
  END Refresh;

   
  PROCEDURE* ClearScreen*(colour: INTEGER);
  VAR
    x: INTEGER;
  BEGIN
    IF colour = White THEN 
      FOR x := 0 TO MaxX DO 
        bitMap[x] := {}
      END
    ELSE
      FOR x := 0 TO MaxX DO 
        bitMap[x] := {0..31}
      END
    END
  END ClearScreen;

   
  PROCEDURE* ConfigurePins;
  VAR
    s: SET;
  BEGIN
    (* P0.6, P0.8 are GPIO ports *)
    SYSTEM.GET(MCU.PINSEL0, s);
    s := s - {12, 13, 16, 17};
    SYSTEM.PUT(MCU.PINSEL0, s);

    (* P0.18 is GPIO port *)
    SYSTEM.GET(MCU.PINSEL1, s);
    s := s - {4, 5};
    SYSTEM.PUT(MCU.PINSEL1, s);

    (* P0.6, 0.8 and 0.18 are outputs *)
    SYSTEM.GET(MCU.FIO0DIR, s);
    SYSTEM.PUT(MCU.FIO0DIR, s + A0 + CS + Reset)
  END ConfigurePins;

   
  PROCEDURE Init*;
  CONST
    SPIBus = 1;
    nBits = 8;
    useSSEL = FALSE;
  VAR
    i: INTEGER;
  BEGIN
    SPI.Init(SPIBus, nBits, useSSEL);
    ConfigurePins();
    SYSTEM.PUT(MCU.FIO0CLR, A0); 
    SYSTEM.PUT(MCU.FIO0SET, CS); 
    SYSTEM.PUT(MCU.FIO0CLR, Reset); 
    Timer.uSecDelay(100);
    SYSTEM.PUT(MCU.FIO0SET, Reset); 
    Timer.uSecDelay(100);

    SendCommand(0AEH); (* Display off *)
    SendCommand(0A2H); (* Bias voltage *)
 
    SendCommand(0A0H); (* ADC Normal *)
    SendCommand(0C8H); (* COM Scan normal *)
 
    SendCommand(022H); (* Resistor ratio *)
    SendCommand(02FH); (* Power on *)
    SendCommand(040H); (* Display start line 0 *)
 
    SendCommand(081H); (* Set contrast *)
    SendCommand(017H);
 
    SendCommand(0A6H); (* Display normal *)
    ClearScreen(Black);
    bitMap0 := bitMap;
    ClearScreen(White);
    Refresh();
    SendCommand(0AFH); (* DisplayOn *);

  END Init;

END LCDST756R.
