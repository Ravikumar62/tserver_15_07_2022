*-----------------------------------------------------------------------------
* <Rating>-11</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE CRR.ACCT.PARAM.RTN(APPL.TYPE,OPERATION.TYPE,STMT.ENT.ID,STMT.RECORD)
*-----------------------------------------------------------------------------
*DESCRIPTIONS:
*-------------
*This generic parameter routine is needed for calling all the routines that has been parameterized in CRR.PARAMETER table. This routine will be attached in ACCOUNT.PARAMETER table’s ACCOUNTING.SUBRTN field.
*

    $INCLUDE GLOBUS.BP I_COMMON
    $INCLUDE GLOBUS.BP I_EQUATE
    $INCLUDE GLOBUS.BP I_GTS.COMMON

    $INCLUDE BPCR.BP I_F.CRR.PARAMETER


    GOSUB INIT

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

    FN.CRR.PARAMETER='F.CRR.PARAMETER'
    F.CRR.PARAMETER=''
    CALL OPF(FN.CRR.PARAMETER,F.CRR.PARAMETER)

    Y.SYS.ID='SYSTEM'



    CALL CACHE.READ(FN.CRR.PARAMETER,Y.SYS.ID,R.CRR.PARAMETER,Y.ERR.ID)
    IF R.CRR.PARAMETER THEN

        Y.ACC.PARAM.RTN.ARRAY=R.CRR.PARAMETER<CRR.PA.ACC.PARAM.RTN>

    END
    LOOP
        REMOVE Y.RTN.NAME FROM Y.ACC.PARAM.RTN.ARRAY SETTING Y.ACC.POS

    WHILE Y.RTN.NAME :Y.ACC.POS
        CALL @Y.RTN.NAME(APPL.TYPE,OPERATION.TYPE,STMT.ENT.ID,STMT.RECORD)
    REPEAT


    RETURN

*-----------------------------------------------------------------------------
END
