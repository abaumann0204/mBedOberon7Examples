MODULE ReadAnalogPoti;

IMPORT Out,Display, LCD := LCDST756R,ADC,MCU,SYSTEM, Main;


CONST 

  POTI_CHANNEL = 4;   (*  DIP pin 19 is connected with left Poti 
                          pin 19 is related to P1.30 which is channel 4 of ADC *)

  ADC4_SEL = {28,29};  
  
VAR 
  data : INTEGER;                        
                          
PROCEDURE ConfigureADCPin;
VAR
  s: SET;
BEGIN
  (* Configure pin connected to potentiometer as ADC input *)
  (* P1.30 = AD0.4, PINSEL3 Bits 29:28 = 11 *)
  SYSTEM.GET(MCU.PINSEL3, s);
  SYSTEM.PUT(MCU.PINSEL3, s + ADC4_SEL);
  (* Neither pull-up nor pull-down, PINMODE1 Bits 29:28 = 10 *) 
  SYSTEM.GET(MCU.PINMODE3, s);
  SYSTEM.PUT(MCU.PINMODE3, s + {29} - {28})
END ConfigureADCPin;
                         
PROCEDURE* ADCPowerUp*();
CONST
  PCADC = {12};
  PDN = {21};
  (* clock divider = 1 + 1 *)
  CLKDIV = {8};
VAR
  s: SET;
BEGIN
  SYSTEM.GET(MCU.PCONP, s);
  SYSTEM.PUT(MCU.PCONP, s + PCADC);
  SYSTEM.GET(MCU.ADC0CR, s);
  SYSTEM.PUT(MCU.ADC0CR, s + PDN - {9..15} + CLKDIV);
  (* ADC Clock = CCLK / 4 *)
  SYSTEM.GET(MCU.PCLKSEL0, s);
  SYSTEM.PUT(MCU.PCLKSEL0, s - {24, 25})
END ADCPowerUp;                                                  
 
  
BEGIN
  ConfigureADCPin();
  ADCPowerUp();
  Out.Init(Display.Char);
  Display.Init();
  Out.String("ADC Test !!!");Out.Ln;
  ADC.Init();
  
  WHILE TRUE DO
    ADC.Read(POTI_CHANNEL, data);
    Out.String("Poti: ");Out.Int(data,3);Out.Ln();
  END;
 
END ReadAnalogPoti.
