* @ValidationCode : Mjo5ODgwODAwMzU6Q3AxMjUyOjE2MDk2NzU2OTU4NjA6c2FuZ2F2aTotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MDkuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 03 Jan 2021 13:08:15
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sangavi
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201709.0
SUBROUTINE BAN.B.CUST.FUND.RISE.ENTRY.LOAD
*-----------------------------------------------------------------------------
*Company   Name    : ITSS
*Developed By      : Sangavi V
*Program   Name    : BAN.B.CUST.FUND.RISE.ENTRY.LOAD
*-----------------------------------------------------------------------------

*Description       :
*

*
*Linked With       :
*In  Parameter     : Nil
*Out Parameter     : Nil
*-----------------------------------------------------------------------------
*Revision History:
* 28-Dec-20     Dev Ref : xxxx
*               Initial Creation
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BAN.B.CUST.FUND.RISE.ENTRY.COMMON
    
    GOSUB INITIALISE
    GOSUB PROCESS
RETURN
*------------------------------------------------------------------------------
INITIALISE:
*------------------------------------------------------------------------------
*

    FN.BAN.L.CUSTODY.FUND = 'F.BAN.L.CUSTODY.FUND'
    F.BAN.L.CUSTODY.FUND = ''
    R.BAN.L.CUSTODY.FUND = ''
    CALL OPF(FN.BAN.L.CUSTODY.FUND,F.BAN.L.CUSTODY.FUND)
    
    
    
    
    FN.BAN.H.CUSTODY.FUND.PARAM = 'F.BAN.H.CUSTODY.FUND.PARAM'
    F.BAN.H.CUSTODY.FUND.PARAM = ''
    R.BAN.H.CUSTODY.FUND.PARAM = ''
    CALL OPF(FN.BAN.H.CUSTODY.FUND.PARAM,F.BAN.H.CUSTODY.FUND.PARAM)
    
    FN.STMT.ENTRY = 'F.STMT.ENTRY'
    F.STMT.ENTRY = ''
    R.STMT.ENTRY = ''
    CALL OPF(FN.STMT.ENTRY,F.STMT.ENTRY)
    
    FN.CATEG.ENTRY = 'F.CATEG.ENTRY'
    F.CATEG.ENTRY = ''
    R.CATEG.ENTRY = ''
    CALL OPF(FN.CATEG.ENTRY,F.CATEG.ENTRY)
    
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    R.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
     
    FN.ACCOUNT.HIS = 'F.ACCOUNT$HIS'
    F.ACCOUNT.HIS = ''
    R.ACCOUNT.HIS = ''
    CALL OPF(FN.ACCOUNT.HIS,F.ACCOUNT.HIS)
RETURN
 
*------------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------------
*
    
    Y.PARAM.ID = "SYSTEM"

    CALL CACHE.READ(FN.BAN.H.CUSTODY.FUND.PARAM,Y.PARAM.ID,R.BAN.H.CUSTODY.FUND.PARAM,R.CUST.ERR)
 
    
RETURN



END
