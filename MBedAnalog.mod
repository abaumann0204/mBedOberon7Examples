MODULE MBedAnalog;


IMPORT ADC,MCU,SYSTEM;

CONST
    ADC_Channel_Count = 8;

TYPE
  ADC_Sel = RECORD
              low: SET;
              high:SET;
            END;
            
  ADC_Channel_Selectors = ARRAY ADC_Channel_Count  OF  ADC_Sel;    


PROCEDURE DefineADCSelectors():ADC_Channel_Selectors;
VAR
  selectors : ADC_Channel_Selectors;
BEGIN


  RETURN selectors;
END DefineADCSelectors;

BEGIN

END MBedAnalog.

