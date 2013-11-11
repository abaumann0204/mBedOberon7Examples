MODULE Joystick;

(*

 example program for mbed 1768 + mbed application board


*)


IMPORT Out,Display, LCD := LCDST756R,SYSTEM,MCU,Traps, Main;


(* Joystick constants are the numbers of Port P0
    DOWN = P0.17
*)
CONST 
 DOWN     = 17;
 LEFT     = 15;
 CENTER   = 16;
 UP       = 23;
 RIGHT    = 24;
 
 DOWN_SEL     = {2,3};   (* PINSEL1 *)
 LEFT_SEL     = {30,31}; (* PINSEL0 *)
 CENTER_SEL   = {0,1};   (* PINSEL1 *)
 UP_SEL       = {14,15}; (* PINSEL1 *)
 RIGHT_SEL    = {16,17}; (* PINSEL1 *)
 
JOYSTICK_PINS = {15,16,17,23,24};

(*
--------------------------------------------------------------

  Interrupt Support
  NXP Semiconductors UM10360
  User manual Rev. 2 — 19 August 2010 page 131 of 840

-------------------------------------------------------------
*)

 IOIntStatus  = 040028080H;   (* GPIO overall Interrupt Status register *)

 IO0IntEnR =    040028090H;  (* GPIO Interrupt Enable for port 0 Rising Edge *)
 
 IO0IntClr =    04002808CH;  (* GPIO Interrupt Clear register for port 0  *)
 
 IO0IntStatR  = 040028084H;  (* GPIO Interrupt Status for port 0 Rising Edge Interrupt *)

 
 
 GPIO_P0_ExceptionVector = 010000094H;
 
 (*
  Table 645. Mapping of interrupts to the interrupt variables
  User manual Rev. 2 — 19 August 2010 761
 
  GPIO's are handled through External Interrupt 3 (EINT3). 
  Table 50. Connection of interrupt sources to the Vectored Interrupt Controller
  User manual Rev. 2 — 19 August 2010 page 74
  
  External Interrupt 3 (EINT3) has Interrupt ID 21  ==> Bit 21 in MCU.NVICISER0
 
 *)
 
 GPIO_ENABLE = {21};
 
 
 
 PROCEDURE EnableREInt(pin : INTEGER);
 VAR 
    register : SET;  
 BEGIN
    SYSTEM.GET(IO0IntEnR,register);
    SYSTEM.PUT(IO0IntEnR,register + {pin});
 
 END EnableREInt;
 
 PROCEDURE GPIO_CENTER_IntHandler[0];
 VAR
   register : SET;
 BEGIN
  Out.String("CENTER Interrupt !");Out.Ln();
  SYSTEM.GET(IO0IntClr,register);
  SYSTEM.PUT(IO0IntClr,register+{CENTER});
 END GPIO_CENTER_IntHandler;
 
 
 PROCEDURE InstallGPIOIntHandler();
 VAR
     register : SET;
 BEGIN
  (* Assign the handler *)
  Traps.Assign(GPIO_P0_ExceptionVector, GPIO_CENTER_IntHandler);
  SYSTEM.GET(MCU.NVICISER0,register);
  SYSTEM.PUT(MCU.NVICISER0,register+GPIO_ENABLE);
 END InstallGPIOIntHandler;
 
 
 
(* ++++++++++++++++++ END OF  Interrupt Support ++++++++++++++++++++++++  *)
 
 
 
(*
    Input Configuration

*) 
PROCEDURE SetGPIOPinFunc(pin : BYTE);
VAR
   pinMode,newPinMode: SET;
   PinSelReg : INTEGER;
BEGIN
  PinSelReg := MCU.PINSEL0;
  IF pin > 15 THEN PinSelReg := MCU.PINSEL1 END;
  SYSTEM.GET(PinSelReg, pinMode); 
  CASE pin OF
    DOWN: newPinMode:= pinMode - DOWN_SEL
    |LEFT:newPinMode:= pinMode - LEFT_SEL
    |CENTER:newPinMode:= pinMode - CENTER_SEL
    |UP:newPinMode:= pinMode - UP_SEL
    |RIGHT:newPinMode:= pinMode - RIGHT_SEL
  END;
  SYSTEM.PUT(PinSelReg, newPinMode); 
END SetGPIOPinFunc;

PROCEDURE SetPullDownMode(pin : BYTE);
VAR
   pinMode,newPinMode: SET;
   PinModeReg : INTEGER;
BEGIN
  PinModeReg := MCU.PINMODE0;
  IF pin > 15 THEN PinModeReg := MCU.PINMODE1 END;
  SYSTEM.GET(PinModeReg, pinMode); 
  CASE pin OF
    DOWN: newPinMode:= pinMode + DOWN_SEL
    |LEFT:newPinMode:= pinMode + LEFT_SEL
    |CENTER:newPinMode:= pinMode + CENTER_SEL
    |UP:newPinMode:= pinMode + UP_SEL
    |RIGHT:newPinMode:= pinMode + RIGHT_SEL
  END;
  SYSTEM.PUT(PinModeReg, newPinMode); 
END SetPullDownMode;


   
PROCEDURE ConfigJoystickPin(pin : INTEGER);
VAR
  direction: SET;
  pinMode: SET;
  mask: SET;
  pinBit: INTEGER;
BEGIN
(*
   pinBit:= LSL(1,pin);
   mask:= BITS(pinBit);
*)
   mask := {pin};

  (* 
      SET Pins to GPIO Mode
  *)
   SetGPIOPinFunc(CENTER);
    
  (*
  SET Pins to input mode 
  *) 
  SYSTEM.GET(MCU.FIO0DIR, direction);
  direction:= direction - mask;
  SYSTEM.PUT(MCU.FIO0DIR, direction);
  
  SetPullDownMode(pin);

END ConfigJoystickPin;

 
PROCEDURE Read(pin : INTEGER): BOOLEAN;
VAR
  pins : SET;
  result : BOOLEAN;
  pinBit : INTEGER;
BEGIN
  SYSTEM.GET(MCU.FIO0PIN, pins);
  result:= pin IN pins;
  RETURN result
END Read;

  
BEGIN
  
  Out.Init(Display.Char);
  Display.Init();
  Out.String("Das ist ein Test");Out.Ln;
  
  ConfigJoystickPin(CENTER);
  
  EnableREInt(CENTER);
  InstallGPIOIntHandler();

  (*  
  
  Polling based processing
  
  ConfigJoystickPin(DOWN);
  ConfigJoystickPin(LEFT);
  ConfigJoystickPin(UP);
  ConfigJoystickPin(RIGHT);
   
  WHILE TRUE DO
    IF Read(CENTER) THEN
       Out.String("CENTER PRESSED");Out.Ln; 
    END;
    IF Read(DOWN) THEN
       Out.String("DOWN PRESSED");Out.Ln; 
    END;
    IF Read(LEFT) THEN
       Out.String("LEFT PRESSED");Out.Ln; 
    END;
    IF Read(RIGHT) THEN
       Out.String("RIGHT PRESSED");Out.Ln; 
    END;
    IF Read(UP) THEN
       Out.String("UP PRESSED");Out.Ln; 
    END;
  END;
  *)

END Joystick.
