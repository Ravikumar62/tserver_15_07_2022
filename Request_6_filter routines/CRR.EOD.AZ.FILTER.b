*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE CRR.EOD.AZ.FILTER(TRANSACTION.ID)
*----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This is the COB FILTER routine which process the pre interest liquidation
*
* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:


    $INCLUDE GLOBUS.BP I_COMMON
    $INCLUDE GLOBUS.BP I_EQUATE
    $INCLUDE GLOBUS.BP I_F.FUNDS.TRANSFER
    $INCLUDE BPCR.BP I_CRR.EOD.AZ.COMMON

* NO NEED OF THIS PROCESS HERE SINCE READ STMT IS NOT ALLOWED IN FILTER ROUTINE
* HENCE THE LOGIC HAS BEEN MOVED TO MAIN ROUTINE ITSELF

*    Y.FT.HIS.ID = TRANSACTION.ID:';1'
*    CALL F.READ(FN.FT.HIS,Y.FT.HIS.ID, R.FUNDS.TRANSFER.HIS,F.FT.HIS,FT.HIS.ERR)

*    Y.COMPANY = R.FUNDS.TRANSFER.HIS<FT.CO.CODE>
*    IF Y.COMPANY NE ID.COMPANY THEN
*        TRANSACTION.ID = ''
*    END

    RETURN
END
updating by ravikumar