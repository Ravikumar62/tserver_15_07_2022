* @ValidationCode : Mjo5ODIwMDcyOTI6Q3AxMjUyOjE1OTc3MDY2MjMxODc6c3NhbnQ6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA1LjE6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 Aug 2020 17:23:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ssant
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202005.1
$PACKAGE GMCAC.GL004AccountingEntries
SUBROUTINE GMC.MAP.DFF.CODE(A1,A2,A3,A4,A5,A6,A7)
*-------------------------------------------------------------------------
*Description:This routine is to map the local field value to the stmt @ re console entry.
*---------------------------------------------------------------------
* Modification History :
*-------------------------------------------------------------------------
*Developed by:Saraswathi D Date:20.07.2020
*attached to ACCOUNT.PARAMETER>Local Ref Subrtn
*--------------------------------------------------------------------------
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING AC.EntryCreation

    GOSUB INITIALISE
    GOSUB PROCESS
RETURN

INITIALISE:
    
    FN.EB.GMC.DFF.CODE.PARAM = 'F.EB.GMC.DFF.CODE.PARAM'
    F.EB.GMC.DFF.CODE.PARAM = ''
    EB.DataAccess.Opf(FN.EB.GMC.DFF.CODE.PARAM, F.EB.GMC.DFF.CODE.PARAM)
RETURN

PROCESS:
  
  
    IF A1 EQ "PP" THEN
        Y.CHK = A3<AC.EntryCreation.StmtEntry.SteTransactionCode>
    END ELSE
        Y.CHK = A3<AC.EntryCreation.StmtEntry.SteTransactionCode>
    END
  

    Y.CHECK3=A3<37>
    IF Y.CHK EQ "" THEN
        Y.CHK=Y.CHECK3
    END
    
    EB.DataAccess.CacheRead(FN.EB.GMC.DFF.CODE.PARAM, 'SYSTEM', Rec, Er)
    Y.TXN.ARR = Rec<GMCAC.GL004AccountingEntries.ebGmcDffCodeParam.ebGmcDffCodeParamGmcTransactionCode>
    FIND Y.CHK IN Y.TXN.ARR SETTING FM.POS, VM.POS, SM.POS THEN
        Y.CODE = Rec<GMCAC.GL004AccountingEntries.ebGmcDffCodeParam.ebGmcDffCodeParamGmcDffCode><1,VM.POS>

    END
     
    A5 = 'L.DFF.CODE'
    A6 = Y.CODE
RETURN
END
