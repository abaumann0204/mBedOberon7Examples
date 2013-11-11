MODULE JoystickInt;

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
 
 PROCEDURE pressedButtonInfo(status : SET);
 BEGIN
  IF CENTER IN status THEN Out.String("CENTER") END;
  IF UP IN status THEN Out.String("UP") END;
  IF DOWN IN status THEN Out.String("DOWN") END;
  IF LEFT IN status THEN Out.String("LEFT") END;
  IF RIGHT IN status THEN Out.String("RIGHT") END;
  Out.String(" pressed !"); Out.Ln();
 END pressedButtonInfo;
 
 PROCEDURE GPIO_CENTER_IntHandler[0];
 VAR
   register : SET;
   status : SET;
 BEGIN
  SYSTEM.GET(IO0IntStatR,status);
  pressedButtonInfo(status);
  SYSTEM.GET(IO0IntClr,register);
  SYSTEM.PUT(IO0IntClr,register+{CENTER,LEFT,UP,DOWN,RIGHT});
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
PROCEDURE SetGPIOPinFunc(pin : INTEGER;pinSelection : SET);
VAR
   pinMode: SET;
   PinSelReg : INTEGER;
BEGIN
  PinSelReg := MCU.PINSEL0;
  IF pin > 15 THEN PinSelReg := MCU.PINSEL1 END;
  SYSTEM.GET(PinSelReg, pinMode); 
  SYSTEM.PUT(PinSelReg, pinMode - pinSelection ); 
END SetGPIOPinFunc;

PROCEDURE SetPullDownMode(pin : INTEGER;pinSelection : SET);
VAR
   pinMode: SET;
   PinModeReg : INTEGER;
BEGIN
  PinModeReg := MCU.PINMODE0;
  IF pin > 15 THEN PinModeReg := MCU.PINMODE1 END;
  SYSTEM.GET(PinModeReg, pinMode); 
  SYSTEM.PUT(PinModeReg, pinMode + pinSelection ); 
END SetPullDownMode;


   
PROCEDURE ConfigJoystickPin(pin : INTEGER;pinSelection : SET);
VAR
  direction: SET;
  pinMode: SET;
  mask: SET;
  pinBit: INTEGER;
BEGIN

   mask := {pin};

  (* set pin to GPIO Mode *)
   SetGPIOPinFunc(pin,pinSelection);
    
  (* set pin to input mode *) 
  SYSTEM.GET(MCU.FIO0DIR, direction);
  direction:= direction - mask;
  SYSTEM.PUT(MCU.FIO0DIR, direction); 
  SetPullDownMode(pin,pinSelection);

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
  
  ConfigJoystickPin(CENTER,CENTER_SEL);
  ConfigJoystickPin(DOWN,DOWN_SEL);
  ConfigJoystickPin(LEFT,LEFT_SEL);
  ConfigJoystickPin(UP,UP_SEL);
  ConfigJoystickPin(RIGHT,RIGHT_SEL);
  
  EnableREInt(CENTER);
  EnableREInt(DOWN);
  EnableREInt(LEFT);
  EnableREInt(UP);
  EnableREInt(RIGHT);
  
  InstallGPIOIntHandler();


END JoystickInt.
