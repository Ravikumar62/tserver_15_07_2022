*-----------------------------------------------------------------------------
* <Rating>-40</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE CRR.AA.CHARGE.PER.AMOUNT(FUTURE.1,R.DES.CHARGE,FUTURE.3,CHGAMT)
*-----------------------------------------------------------------------------
* Description
*-------------
* Its a charge routine getting triggered on each repayment schedule
* get triggered
*

* --------------------------------------------------------------------------

    $INCLUDE GLOBUS.BP I_COMMON
    $INCLUDE GLOBUS.BP I_EQUATE
    $INCLUDE GLOBUS.BP I_GTS.COMMON
    $INCLUDE GLOBUS.BP I_AA.LOCAL.COMMON
    $INCLUDE GLOBUS.BP I_F.AA.CHARGE
    $INCLUDE GLOBUS.BP I_F.AA.ARRANGEMENT
    $INCLUDE GLOBUS.BP I_AA.APP.COMMON
    $INCLUDE GLOBUS.BP I_AA.CONTRACT.DETAILS
    $INCLUDE GLOBUS.BP I_AA.ACCRUAL.DATA
    $INCLUDE GLOBUS.BP I_F.AA.ACCOUNT.DETAILS

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB CHECK.PAYOFF.DATE
    IF EXIT.FLAG NE 'TRUE' THEN
        GOSUB PROCESS
    END


    RETURN
*---------------------------------------------------------------------------------
INIT:
*---------
    ArrangementId = R.DES.CHARGE<AA.CHG.ID.COMP.1>
    AA.ID = R.DES.CHARGE<AA.CHG.ID.COMP.1>
    EXIT.FLAG = 'FALSE'
    RETURN
*---------------------------------------------------------------------------------
OPENFILES:
*---------
    FN.AA.ACC = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACC = ''
    CALL OPF(FN.AA.ACC,F.AA.ACC)

    RETURN
*---------------------------------------------------------------------------------
PROCESS:
*----------
    LOC.REF.APPLICATION='AA.PRD.DES.CHARGE':FM:'AA.PRD.DES.ACCOUNT'
    LOC.REF.FIELDS='CH.RATE':FM:'BENEFIT.AMT'
    LOC.REF.POS=''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    CH.RATE.POS=LOC.REF.POS<1,1>
    Y.CH.RATE=R.DES.CHARGE<AA.CHG.LOCAL.REF><1,CH.RATE.POS>

    Y.SCH.INFO = AA$CONTRACT.DETAILS

    BALANCE.TO.CHECK = 'CURACCOUNT'
    LOCATE BALANCE.TO.CHECK IN AA$CONTRACT.DETAILS<AA.CD.BASE.BALANCE,1> SETTING BAL.POS THEN
        LAST.MV = DCOUNT(AA$CONTRACT.DETAILS<AA.CD.BAL.EFF.DT,BAL.POS>,SM)
        PRESENT.DATE = AA$CONTRACT.DETAILS<AA.CD.BAL.EFF.DT,BAL.POS,LAST.MV>
        PRESENT.VALUE = ABS(AA$CONTRACT.DETAILS<AA.CD.BAL.AMOUNT,BAL.POS,LAST.MV>)

        CHGAMT = PRESENT.VALUE * Y.CH.RATE / 100.0
        RETURN
    END
    RETURN
*-------------------------------------------------------------------------------------------
CHECK.PAYOFF.DATE:
*-----------------
    Y.CURR.ACT = c_aalocCurrActivity
    IF Y.CURR.ACT EQ 'LENDING-SETTLE-PAYOFF' OR Y.CURR.ACT EQ 'LENDING-CALCULATE-PAYOFF' THEN
        CALL F.READ(FN.AA.ACC,AA.ID,R.AA.ACC,F.AA.ACC,ERR.AA.ACC)
        Y.BILL.PAY.DT = R.AA.ACC<AA.AD.BILL.PAY.DATE>
        LOCATE TODAY IN Y.BILL.PAY.DT<1,1> SETTING PAY.DT.POS THEN
            CHGAMT = 0
            EXIT.FLAG = 'TRUE'
        END ELSE
            EXIT.FLAG = 'FALSE'
        END
    END
    RETURN
*---------------------Final.End-------------------------------------------------------------

END
