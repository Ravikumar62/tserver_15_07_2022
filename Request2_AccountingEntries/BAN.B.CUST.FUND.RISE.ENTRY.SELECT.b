* @ValidationCode : MjoxMzk1MDgzODE0OkNwMTI1MjoxNjA5NDI1NTUzNDUxOnNhbmdhdmk6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzA5LjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 Dec 2020 15:39:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sangavi
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201709.0
SUBROUTINE BAN.B.CUST.FUND.RISE.ENTRY.SELECT
*-----------------------------------------------------------------------------
*Company   Name    : ITSS
*Developed By      : Sangavi V
*Program   Name    : BAN.B.CUST.FUND.RISE.ENTRY.SELECT
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

    GOSUB PROCESS
RETURN

*------------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------------
*
    
    SEL.CMD = "SELECT ":FN.BAN.L.CUSTODY.FUND: " WITH STATUS.FLAG EQ OPEN"
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.REC,Y.ERR)
    
    IF NO.OF.REC THEN
       
        CALL BATCH.BUILD.LIST('',SEL.LIST)
        
    END
   
RETURN
END

    