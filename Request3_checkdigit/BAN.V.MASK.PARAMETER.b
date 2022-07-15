*-----------------------------------------------------------------------------
* <Rating>-25</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE 	BAN.V.MASK.PARAMETER
*-----------------------------------------------------------------------------

* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    
    $INSERT I_F.BAN.REFER.PARAMETER
    $INSERT I_F.BAN.REFER.REQUEST

    GOSUB INIT
    GOSUB PROCESS
    RETURN
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------

*** <region name= INSERT>
INIT:
*** <desc> </desc>
 
    
    FN.BAN.REFER.PARAMETER = "F.BAN.REFER.PARAMETER"
    F.BAN.REFER.PARAMETER = ""
    CALL OPF(FN.BAN.REFER.PARAMETER,F.BAN.REFER.PARAMETER)

    FN.BAN.REFER.REQUEST = "F.BAN.REFER.REQUEST"
    F.BAN.REFER.REQUEST = ""
    CALL OPF(FN.BAN.REFER.REQUEST,F.BAN.REFER.REQUEST)
    

    Y.SPC.CHAR = ""
    Y.START.POS = 0

    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
	

    CALL F.READ(FN.BAN.REFER.PARAMETER,ID.COMPANY,R.BAN.REFER.PARAMETER,F.BAN.REFER.PARAMETER,Y.ERROR.BRPM)
    IF Y.ERROR.BRPM THEN
    	RETURN
    END
  
    Y.ALTERNATE.ACCT.V = R.BAN.REFER.PARAMETER<BAN.REFP.ALTERNATE.ACCT.V>
    
    Y.STR.CNT = LEN(Y.ALTERNATE.ACCT.V)
	Y.CONTA=1

	LOOP
    	WHILE Y.CONTA LE Y.STR.CNT
        Y.CHAR.CHECK = Y.ALTERNATE.ACCT.V[Y.CONTA,1]
        Y.DIGIT.CHECK = ISDIGIT(Y.CHAR.CHECK)

        IF Y.DIGIT.CHECK EQ 0 THEN
            Y.SPC.CHAR := Y.CHAR.CHECK
            IF Y.START.POS = 0 THEN
                Y.START.POS = Y.CONTA
            END
        END
        Y.CONTA++
   REPEAT
   
   Y.COMP.MNEMONIC = ID.COMPANY[1,2]
   Y.ALTERNATE.ACCT = R.NEW(BAN.RR.ALTERNATE.ACCT)
   I=1
   LOOP
    REMOVE Y.ALTERNATE FROM Y.ALTERNATE.ACCT SETTING ID.POS
		WHILE Y.ALTERNATE : ID.POS
   
		    
		    Y.SPC.CHAR.LEN = LEN(Y.SPC.CHAR)
		    Y.END.POS = Y.START.POS + Y.SPC.CHAR.LEN - 1
		
		    Y.ALT.ACCT.LEN = LEN(Y.ALTERNATE)
		    Y.ALT.ACCT.FIRST.PART = Y.ALTERNATE[1,Y.START.POS-1]
		    Y.ALT.ACCT.LAST.PART = Y.ALTERNATE[Y.START.POS,Y.ALT.ACCT.LEN]
		    Y.ALT.ACCT.FIRST.PART = Y.ALT.ACCT.FIRST.PART:Y.SPC.CHAR

		    BEGIN CASE
		        CASE Y.COMP.MNEMONIC EQ "VE"
		            Y.ALT.ACCT.LAST.PART = Y.ALTERNATE[14,20]
		            Y.ALT.ACCT.FINAL.MASK = Y.ALT.ACCT.FIRST.PART:Y.ALT.ACCT.LAST.PART
		
		        CASE Y.COMP.MNEMONIC EQ "PA"
		            Y.ALT.ACCT.LAST.PART = Y.ALTERNATE[8,12]
		            Y.ALT.ACCT.FINAL.MASK = Y.ALT.ACCT.FIRST.PART:Y.ALT.ACCT.LAST.PART
		
		        CASE Y.COMP.MNEMONIC EQ "DO"
		            Y.ALT.ACCT.FINAL.MASK = Y.ALT.ACCT.FIRST.PART
		    END CASE
		
		    R.NEW(BAN.RR.MASK.ALTERNATE.ACCT)<1,I> = Y.ALT.ACCT.FINAL.MASK
		    I++
		     
	REPEAT
	
    RETURN
*** </region>

    END
