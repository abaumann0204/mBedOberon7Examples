MODULE Blinker;
(* =========================================================================  
   Example Oberon ARM Cortex-M3 Program  
 
   Description:
     Led connected to P1.18 blinking approx. once per second

   Target:
     NXP LPC1768
     
   Tested on: 
     ARM mbed
   
   References: 
     NXP UM10360 LPC17xx User manual
     Oberon for Cortex-M3 Microcontrollers
   
   (c) 2012-2013 CFB Software   
   http://www.astrobe.com  
   
   ========================================================================= *)

IMPORT Main, MCU, SYSTEM, Timer;

PROCEDURE Run();
CONST
  (* led connected to pin P1.18 *)
  ledBit = {18};
VAR
  direction: SET;
BEGIN
  (* Set led pin as output by setting the direction bit *)
  SYSTEM.GET(MCU.FIO1DIR, direction);
  SYSTEM.PUT(MCU.FIO1DIR, direction + ledBit);
  
  WHILE TRUE DO
    SYSTEM.PUT(MCU.FIO1SET, ledBit);
    Timer.MSecDelay(50);
    SYSTEM.PUT(MCU.FIO1CLR, ledBit);
    Timer.MSecDelay(50)
  END
END Run;

BEGIN
  Run()
END Blinker.
