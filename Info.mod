MODULE Info;
(* =========================================================================  
   Example Cortex-M3 Oberon Program  
  
   Description:
     Displays the linker and startup parameters used for the current 
     application.
  
   Target:
     All supported Cortex-M3 systems
     
   References: 
     NXP UM10375 LPC1311/13/42/43 User manual
     NXP UM10524 LPC1315/16/17/45/46/47 User manual
     NXP UM10360 LPC17xx User manual
     Oberon for Cortex-M3 Microcontrollers
   
   (c) 2012 CFB Software   
   http://www.astrobe.com  
 
 ========================================================================= *)

IMPORT Display, LCD := LCDST756R,LinkOptions, Main, MCU, Out, Storage;

PROCEDURE OutTitle(title: ARRAY OF CHAR);
CONST
  width = 20;
VAR 
  i, count: INTEGER;
BEGIN
  Out.String(title);
  count := width - STRLEN(title);
  FOR i := 1 TO count DO 
    Out.Char(" ")
  END
END OutTitle;
   
PROCEDURE OutFreq(title: ARRAY OF CHAR; item: INTEGER);
BEGIN
  OutTitle(title);
  Out.Int(item, 0);
  Out.String(" Hz");
  Out.Ln
END OutFreq;

PROCEDURE OutAddr(title: ARRAY OF CHAR; item: INTEGER);
BEGIN
  OutTitle(title);
  Out.Hex(item, 0);
  Out.Ln
END OutAddr;

PROCEDURE OutSize(title: ARRAY OF CHAR; item: INTEGER);
BEGIN
  OutTitle(title);
  Out.Int(item, 0);
  Out.String(" Bytes");
  Out.Ln
END OutSize;

PROCEDURE Run();
BEGIN
  Out.String("Target CPU: LPC"); Out.Int(LinkOptions.Target, 0); Out.Ln;
  OutFreq("Crystal Frequency:", LinkOptions.Fosc);
  OutFreq("CPU Clock:", MCU.CCLK);
  OutFreq("Peripheral Clock:", MCU.PCLK);
  OutAddr("Heap Start:", Storage.HeapStart());
  OutAddr("Heap Pointer:", Storage.HeapPtr());
  OutSize("Heap Available:", Storage.HeapAvailable());
  OutSize("Heap Used:", Storage.HeapUsed());
  OutAddr("Stack Start:", Storage.StackStart());
  OutAddr("Stack Pointer:", Storage.StackPtr());
  OutSize("Stack Available:", Storage.StackAvailable());
  OutSize("Stack Used:", Storage.StackUsed())
END Run;

BEGIN
  Out.Init(Display.Char);
  Display.Init();
  Run()
END Info.

