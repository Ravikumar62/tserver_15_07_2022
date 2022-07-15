    SUBROUTINE BAN.A.CHQ.CANCEL.FT
*-----------------------------------------------------------------------------
* Description     : Genera automï¿½ticamente FONDOS.TRANSFER cuando se inicia la suspensiï¿½n de pago.
* Type            : AUTHORIZATION Routine
* Linked As       : AUTHORIZATION Routine
* Linked With     : PAYMENT.STOP,BAPA.GCIA.GIRO & PAYMENT.STOP,BAPA.CHEQUES.CANCEL.CERT
* In Parameter    : NA
* Out Parameter   : NA
* Variables       :
*-----------------------------------------------------------------------------
* Revision History:
*-----------------------------------------------------------------------------
* Date         - 24/12/2020
* Done By      - BALABHARATHI KARTHIKEYAN
* Reference.#  -
* Description  - Initial Creation
*-----------------------------------------------------------------------------
* Modification History :
*   #DATE                   #DESCRIPTION                    #CHANGES DONE BY
*
*-----------------------------------------------------------------------------
     
  $PACKAGE BAN.CHEQUE
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.PAYMENT.STOP
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.CHEQUE.REGISTER.SUPPLEMENT
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB PROCESS
    RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
    FN.CHQ.REG.SUPPL = "F.CHEQUE.REGISTER.SUPPLEMENT"
    F.CHQ.REG.SUPPL = ""
    CALL OPF(FN.CHQ.REG.SUPPL,F.CHQ.REG.SUPPL)
;*Get the local field values for credit account and commission type
    LOCAL.APPLICATION = "PAYMENT.STOP":@FM:"CHEQUE.REGISTER.SUPPLEMENT"
    LOCAL.FIELD = "LT.CREDIT.ACCT":@VM:"LT.COMM.TYPE":@FM:"LT.CH.C.CTA.INT"
    LOCAL.POSITION = ""
    CALL MULTI.GET.LOC.REF(LOCAL.APPLICATION, LOCAL.FIELD, LOCAL.POSITION)
    LT.CREDIT.ACCT.POS = LOCAL.POSITION<1,1>
    LT.COMM.TYPE.POS = LOCAL.POSITION<1,2>
    LT.CH.C.CTA.INT.POS = LOCAL.POSITION<2,1>

    LT.CREDIT.ACCT = R.NEW(AC.PAY.LOCAL.REF)<1,LT.CREDIT.ACCT.POS>
    LT.COMM.TYPE = R.NEW(AC.PAY.LOCAL.REF)<1,LT.COMM.TYPE.POS>
;*Get the transaction details from CHEQUE.REGISTER.SUPPLEMENT application
    PAYMENT.STOP.ID = ID.NEW
    PAYMENT.STOP.DEBIT.CCY = "USD"
    FIRST.CHQ.NO = R.NEW(AC.PAY.FIRST.CHEQUE.NO)
    CHQ.TYPE = R.NEW(AC.PAY.CHEQUE.TYPE)
    CHQ.REG.SUPPL.ID = CHQ.TYPE:".":PAYMENT.STOP.ID:".":FIRST.CHQ.NO
    R.CHQ.REG.SUPPL = "" ; R.CHQ.REG.SUPPL.ERR = ""


    CALL F.READ(FN.CHQ.REG.SUPPL,CHQ.REG.SUPPL.ID,R.CHQ.REG.SUPPL,F.CHQ.REG.SUPPL,R.CHQ.REG.SUPPL.ERR)

    IF R.CHQ.REG.SUPPL THEN
        CHQ.AMOUNT = R.CHQ.REG.SUPPL<CC.CRS.AMOUNT>
        CHQ.CURRENCY = R.CHQ.REG.SUPPL<CC.CRS.CURRENCY>
        LT.CH.C.CTA.INT.MULTI = R.CHQ.REG.SUPPL<CC.CRS.LOCAL.REF,LT.CH.C.CTA.INT.POS>
        CHANGE @SM TO @FM IN LT.CH.C.CTA.INT.MULTI
        CHANGE @VM TO @FM IN LT.CH.C.CTA.INT.MULTI
        LT.CH.C.CTA.INT.VAL = LT.CH.C.CTA.INT.MULTI<1>

    END
    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
;*Create OFS string with the version FUNDS.TRANSFER,BAPA.CANCEL.GG and update the fields

    PAYMENT.STOP.VERSION = PGM.VERSION
    IF PAYMENT.STOP.VERSION EQ ",BAPA.CHEQUES.CANCEL.CERT" THEN

        GOSUB GET.COMMISTION.LOGIC
        Y.STRING.OFS = "FUNDS.TRANSFER,BAPA.ACTR.CANCEL.CERT/I/PROCESS,,,DEBIT.THEIR.REF:1:1=":FIRST.CHQ.NO:",CREDIT.THEIR.REF:1:1=":FIRST.CHQ.NO:",DEBIT.ACCT.NO:1:1=":LT.CH.C.CTA.INT.VAL:",DEBIT.CURRENCY:1:1=":PAYMENT.STOP.DEBIT.CCY:",CREDIT.AMOUNT:1:1=":CHQ.AMOUNT:",CREDIT.ACCT.NO:1:1=":LT.CREDIT.ACCT:",CREDIT.CURRENCY:1:1=":CHQ.CURRENCY:APPEND.CHG.VALUE.OFS
    END
    IF PAYMENT.STOP.VERSION EQ ",BAPA.GCIA.GIRO" THEN

        GOSUB GET.COMMISTION.LOGIC
        Y.STRING.OFS = "FUNDS.TRANSFER,BAPA.CANCEL.GG/I/PROCESS,,,DEBIT.THEIR.REF:1:1=":FIRST.CHQ.NO:",CREDIT.THEIR.REF:1:1=":FIRST.CHQ.NO:",DEBIT.ACCT.NO:1:1=":PAYMENT.STOP.ID:",DEBIT.CURRENCY:1:1=":PAYMENT.STOP.DEBIT.CCY:",CREDIT.AMOUNT:1:1=":CHQ.AMOUNT:",CREDIT.ACCT.NO:1:1=":LT.CREDIT.ACCT:",CREDIT.CURRENCY:1:1=":CHQ.CURRENCY:APPEND.CHG.VALUE.OFS
    END
    GOSUB STRINGOFS
    RETURN
*-----------------------------------------------------------------------------
STRINGOFS:
*** <region name= STRINGOFS>
*** <desc>GENERA LA CADENA OFS </desc>
    OFS.MSG.ID  = ""
    OFS.SOURCE.ID = "FT.BULK.PROCESS"
    OFS.OPTIONS = ""
*OFS.ERR = ""
    CALL ofs.addLocalRequest(Y.STRING.OFS,"add",OFS.ERR)
*  CALL OFS.POST.MESSAGE(Y.STRING.OFS, OFS.MSG.ID, OFS.SOURCE.ID, OFS.OPTIONS)
    TST.VAL1 = OFS.OPTIONS
*** </region>
    RETURN
*-----------------------------------------------------------------------------
GET.COMMISTION.LOGIC:

    COD.VALUE='D'

    CHECK.INTERNAL=LT.CREDIT.ACCT[1,3]

    IF CHECK.INTERNAL EQ "USD" OR LT.COMM.TYPE EQ ""  THEN

        COD.VALUE='W'
        LT.COMM.TYPE=''

    END



    APPEND.CHG.VALUE.OFS= ",COMMISSION.CODE:1:1=":COD.VALUE:",COMMISSION.TYPE:1:1=":LT.COMM.TYPE
 

    RETURN
*-----------------------------------------------------------------------------

    END
