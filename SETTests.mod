MODULE SETTests;

IMPORT Out,Display, LCD := LCDST756R, Main;


CONST
    
  ININT_VALUE = {1,2,3,4};  (*  30 o. 1E  *)
  MASK  = {2,3};
  PIN16 = {16};

VAR
  masked_IV : SET;
  pin,pinBit : INTEGER;
  pinSET: SET;
BEGIN
  Out.Init(Display.Char);
  Display.Init();
  Out.String("SET Tests");Out.Ln;
  Out.String("iv: ");Out.Hex(ORD(ININT_VALUE),2);Out.Ln;
  
  (* Bit Nummer 3 und 4 sollen auf 0 gesetzt werden --> erste Bit ist Bit 0 
  
     Der resultierende Wert sollte 12 (Hex) sein
  *)
  
  masked_IV:= ININT_VALUE - MASK;
  Out.String("miv: ");Out.Hex(ORD(masked_IV),2);Out.Ln;
  
(*
  -------------------------------------------------------
  
  Tests mit Bit and LSL
  
  -------------------------------------------------------
*)
  
  pin := 16;
  pinBit:= LSL(1,pin);
  pinSET:= BITS(pinBit);
  Out.String("PinSET: ");Out.Hex(ORD(pinSET),2);Out.Ln;
  Out.String("PIN16: ");Out.Hex(ORD(PIN16),2);Out.Ln;
END SETTests.

