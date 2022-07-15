* @ValidationCode : Mjo0NjIyMjQ2ODk6Q3AxMjUyOjE2MDk3NTIzNjM0NDk6c2FuZ2F2aTotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MDkuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 04 Jan 2021 10:26:03
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sangavi
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201709.0
    SUBROUTINE BAN.B.CUST.FUND.RISE.ENTRY(Y.L.CUST.FUND.ID)
*------------------------------------------------------------------------------------------------------------
*Company   Name    : ITSS
*Developed By      : Sangavi V
*Program   Name    : BAN.B.CUST.FUND.RISE.ENTRY
*------------------------------------------------------------------------------------------------------------

*Description       : This is a Month-End Batch routine which will select BAN.L.CUSTODY.FUND based on the
*                    NEXT.CHARGE.DATE(Will be the last date of month) and raise the Charges and Tax amount
*                    for the closed accounts where Customer has not withdrawn the amount .

*
*Linked With       :
*In  Parameter     : Y.L.CUST.FUND.ID  --- @ID of BAN.L.CUSTODY.FUND template
*Out Parameter     : Nil
*-----------------------------------------------------------------------------
*Revision History:
* 28-Dec-20     Dev Ref : Custody of Funds
*               Initial Creation
*Modification History:
*---------------------
*
* 26-Mar-2021   - Ref : CR-Calculating charge amount by charge percentage
*               - Name : Saraswathi
*               - The custody fee for funds is calculated.
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BAN.B.CUST.FUND.RISE.ENTRY.COMMON
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.CATEG.ENTRY
    $INSERT I_F.BAN.L.CUSTODY.FUND
    $INSERT I_F.BAN.H.CUSTODY.FUND.PARAM
    $INSERT I_F.ACCOUNT


    GOSUB READ.L.CUST.FUND
    GOSUB READ.H.CUST.FUND.PARAM


    RETURN

*------------------------------------------------------------------------------
READ.L.CUST.FUND:
*------------------------------------------------------------------------------
*Get the Initial Balance and the Charge amount from BAN.L.CUSTODY.FUND template

    CALL F.READ(FN.BAN.L.CUSTODY.FUND,Y.L.CUST.FUND.ID,R.BAN.L.CUSTODY.FUND,F.BAN.L.CUSTODY.FUND,Y.L.CUST.FUND.ERR)

    Y.INITIAL.BALANCE = R.BAN.L.CUSTODY.FUND<BAN.CON.CURRENT.BALANCE>
    Y.NEXT.CHARGE.DATE = R.BAN.L.CUSTODY.FUND<BAN.CON.NEXT.CHARGE.DATE>
    Y.TOTAL.CHARGE = R.BAN.L.CUSTODY.FUND<BAN.CON.TOT.CHARGE.AMOUNT>
    Y.CUS.ACC.ID = Y.L.CUST.FUND.ID 

    GOSUB READ.CUSTOMER.ACCOUNT


    RETURN
*------------------------------------------------------------------------------
READ.CUSTOMER.ACCOUNT:
*------------------------------------------------------------------------------
*Get the Customer Currency and Customer ID values from ACCOUNT table

    CALL F.READ(FN.ACCOUNT,Y.CUS.ACC.ID,R.ACCOUNT,F.ACCOUNT,Y.CUS.ACC.ERR)

    IF Y.CUS.ACC.ERR THEN
        CALL EB.READ.HISTORY.REC(F.ACCOUNT.HIS,Y.CUS.ACC.ID,R.ACCOUNT.HIS,Y.ACCT.HIS.ERR)

        IF R.ACCOUNT.HIS THEN
            R.ACCOUNT = R.ACCOUNT.HIS
        END
    END

    Y.CUSTOMER.CURRENCY = R.ACCOUNT<AC.CURRENCY>
    Y.CUSTOMER.ID = R.ACCOUNT<AC.CUSTOMER>
    RETURN

*------------------------------------------------------------------------------
READ.H.CUST.FUND.PARAM:
*------------------------------------------------------------------------------
*Get the Charge Amount and Tax Percentage from BAN.H.CUSTODY.FUND.PARAM template, if
*charge amount is parameterised then respective charges needs to be calculated

    CHARGE.AMOUNT = R.BAN.H.CUSTODY.FUND.PARAM<BAN.CF.PARAM.CHARGE.AMOUNT>
    Y.TAX.PERCENTAGE = R.BAN.H.CUSTODY.FUND.PARAM<BAN.CF.PARAM.TAX.PERCENTAGE>

    ChargePercentage = R.BAN.H.CUSTODY.FUND.PARAM<BAN.CF.PARAM.CHARGE.PERCENTAGE>  ;* CR for the development

    IF ChargePercentage NE'' THEN
        CalculateChargeAmount  = Y.INITIAL.BALANCE*ChargePercentage/100
        IF CalculateChargeAmount GT CHARGE.AMOUNT THEN
            CHARGE.AMOUNT = CalculateChargeAmount
        END ELSE
            CHARGE.AMOUNT=R.BAN.H.CUSTODY.FUND.PARAM<BAN.CF.PARAM.CHARGE.AMOUNT>

        END

    END

*If account is not having enough balance to collect charge then the account balance is the charge amount.
    CHARGE.AMOUNT=DROUND(CHARGE.AMOUNT,2)


    TAX.AMOUNT = CHARGE.AMOUNT * Y.TAX.PERCENTAGE
    TAX.AMOUNT = TAX.AMOUNT/100

    TAX.AMOUNT=DROUND(TAX.AMOUNT,2)
    TOTAL.CHARGE.AMOUNT = CHARGE.AMOUNT + TAX.AMOUNT

    IF Y.INITIAL.BALANCE LT TOTAL.CHARGE.AMOUNT THEN

        TAX.AMOUNT=Y.INITIAL.BALANCE * Y.TAX.PERCENTAGE
        TAX.AMOUNT = TAX.AMOUNT/100
        TAX.AMOUNT=DROUND(TAX.AMOUNT,2)
        CHARGE.AMOUNT = Y.INITIAL.BALANCE - TAX.AMOUNT



        TOTAL.CHARGE.AMOUNT = CHARGE.AMOUNT + TAX.AMOUNT
    END



    IF CHARGE.AMOUNT GT 0 THEN
        GOSUB GET.INTERNAL.ACCOUNT
        GOSUB CALCULATE.CHARGES
    END

    RETURN
*-------------------------------------------------------------------------------------------------------------------
GET.INTERNAL.ACCOUNT:
*-------------------------------------------------------------------------------------------------------------------
*Get the necessary values such as Account,Category, Debit and credit Transaction code from BAN.H.CUSTODY.FUND.PARAM

    Y.DEBIT.TXN.CODE = R.BAN.H.CUSTODY.FUND.PARAM<BAN.CF.PARAM.TXN.CODE.DR>
    Y.CREDIT.TXN.CODE = R.BAN.H.CUSTODY.FUND.PARAM<BAN.CF.PARAM.TXN.CODE.CR>
    Y.PARAM.CURRENCY = R.BAN.H.CUSTODY.FUND.PARAM<BAN.CF.PARAM.CURRENCY>

    LOCATE Y.CUSTOMER.CURRENCY IN Y.PARAM.CURRENCY<1,1> SETTING CURR.POS THEN


    Y.INT.ACCT.DR = R.BAN.H.CUSTODY.FUND.PARAM<BAN.CF.PARAM.INT.ACCT.DR,CURR.POS>
    Y.INT.ACT.ID = Y.INT.ACCT.DR
    GOSUB READ.INTERNAL.ACCT

    Y.INT.DEBIT.ACCT.OFFICER = R.INTERNAL.ACCOUNT<AC.ACCOUNT.OFFICER>
    Y.INT.DEBIT.CURRENCY =  R.INTERNAL.ACCOUNT<AC.CURRENCY>
    Y.INT.ACCT.CR = R.BAN.H.CUSTODY.FUND.PARAM<BAN.CF.PARAM.INT.ACCT.CR,CURR.POS>

*    Y.INT.ACT.ID = Y.INT.ACCT.CR
*    GOSUB READ.INTERNAL.ACCT
*
*    Y.INT.CREDIT.ACCT.OFFICER = R.INTERNAL.ACCOUNT<AC.ACCOUNT.OFFICER>
*    Y.CATEGORY = R.BAN.H.CUSTODY.FUND.PARAM<BAN.CF.PARAM.CATEGORY.CR,CURR.POS>
*    Y.INT.CREDIT.CURRENCY =  R.INTERNAL.ACCOUNT<AC.CURRENCY>
    END
    RETURN

*------------------------------------------------------------------------------
READ.INTERNAL.ACCT:
*------------------------------------------------------------------------------
*Get the informations of Internal Account Details

    R.INTERNAL.ACCOUNT = ''
    CALL F.READ(FN.ACCOUNT,Y.INT.ACT.ID,R.INTERNAL.ACCOUNT,F.ACCOUNT,INT.ACC.ERR)

    RETURN
*----------------------------------------------------------------------------------------------
CALCULATE.CHARGES:
*----------------------------------------------------------------------------------------------
*Calculating Tax Amount and Total Charge amount & Raise the respective Credit and Debit Entries



    YMULTI.ENTRY<-1> = ''
    IF TOTAL.CHARGE.AMOUNT LE Y.INITIAL.BALANCE THEN
        GOSUB RAISE.CHARGE.AMOUNT.ENTRIES
        GOSUB RAISE.TAX.AMOUNT.ENTRIES
        GOSUB RAISE.STMT.ENTRY
        GOSUB UPDATE.L.CUST.FUND
    END
    RETURN
*------------------------------------------------------------------------------
RAISE.CHARGE.AMOUNT.ENTRIES:
*------------------------------------------------------------------------------
*Raising Credit and Debit Charge amount entries

    Y.DEBIT.ACCT.NO = Y.INT.ACCT.DR
    Y.DEBIT.AMOUNT = (-1)*CHARGE.AMOUNT
    Y.TRANS.REFERENCE = Y.CUS.ACC.ID


    GOSUB RAISE.DEBIT.ENTRIES

    Y.CREDIT.ACCT.NO = Y.INT.ACCT.CR

*If the calculated charge amount is greater than minimum value then the calculated value has to be used.



    Y.CREDIT.AMOUNT = CHARGE.AMOUNT

    GOSUB RAISE.CREDIT.CATEG.ENTRIES
*   GOSUB RAISE.CREDIT.ENTRIES

    RETURN
*------------------------------------------------------------------------------
RAISE.DEBIT.ENTRIES:
*------------------------------------------------------------------------------
*Raising Statement entries for Debit

    R.STMT.ENT.DR<AC.STE.TRANS.REFERENCE> = Y.TRANS.REFERENCE
    R.STMT.ENT.DR<AC.STE.OUR.REFERENCE>= Y.TRANS.REFERENCE

    R.STMT.ENT.DR<AC.STE.VALUE.DATE> = TODAY
    R.STMT.ENT.DR<AC.STE.BOOKING.DATE> = TODAY
    R.STMT.ENT.DR<AC.STE.EXPOSURE.DATE> = TODAY

    R.STMT.ENT.DR<AC.STE.TRANSACTION.CODE> = Y.DEBIT.TXN.CODE

    R.STMT.ENT.DR<AC.STE.CURRENCY> = Y.INT.DEBIT.CURRENCY
    IF Y.INT.DEBIT.CURRENCY NE LCCY THEN
        Y.INT.CURRENCY = Y.INT.DEBIT.CURRENCY
        Y.INT.AMT = Y.DEBIT.AMOUNT
        GOSUB CHECK.CURR.WITH.LCCY
        R.STMT.ENT.DR<AC.STE.AMOUNT.LCY> = Y.DEBIT.AMOUNT
        R.STMT.ENT.DR<AC.STE.AMOUNT.FCY> = Y.AMT.FCY
        R.STMT.ENT.DR<AC.STE.EXCHANGE.RATE> = EXCHANGE.RATE
    END ELSE
        R.STMT.ENT.DR<AC.STE.AMOUNT.LCY> = Y.DEBIT.AMOUNT
    END
    R.STMT.ENT.DR<AC.STE.ACCOUNT.NUMBER> = Y.DEBIT.ACCT.NO
    R.STMT.ENT.DR<AC.STE.COMPANY.CODE>  = ID.COMPANY


    Y.DEBIT.ENTRY = R.STMT.ENT.DR
    Y.DEBIT.ENTRY = LOWER(Y.DEBIT.ENTRY)
    YMULTI.ENTRY<-1> = Y.DEBIT.ENTRY


    RETURN
*------------------------------------------------------------------------------
RAISE.CREDIT.ENTRIES:
*------------------------------------------------------------------------------
*Raising Statement entries for Credit

    R.STMT.ENT.CR<AC.STE.TRANS.REFERENCE> = Y.TRANS.REFERENCE
    R.STMT.ENT.CR<AC.STE.OUR.REFERENCE>= Y.TRANS.REFERENCE

    R.STMT.ENT.CR<AC.STE.VALUE.DATE> = TODAY
    R.STMT.ENT.CR<AC.STE.BOOKING.DATE> = TODAY
    R.STMT.ENT.CR<AC.STE.EXPOSURE.DATE> = TODAY

    R.STMT.ENT.CR<AC.STE.TRANSACTION.CODE> = Y.CREDIT.TXN.CODE

    R.STMT.ENT.CR<AC.STE.CURRENCY> = Y.INT.CREDIT.CURRENCY

    IF Y.INT.CREDIT.CURRENCY NE LCCY THEN
        Y.INT.CURRENCY = Y.INT.CREDIT.CURRENCY
        Y.INT.AMT = Y.CREDIT.AMOUNT
        GOSUB CHECK.CURR.WITH.LCCY
        R.STMT.ENT.CR<AC.STE.AMOUNT.LCY> = Y.CREDIT.AMOUNT
        R.STMT.ENT.CR<AC.STE.AMOUNT.FCY> = Y.AMT.FCY
        R.STMT.ENT.CR<AC.STE.EXCHANGE.RATE> = EXCHANGE.RATE
    END ELSE
        R.STMT.ENT.CR<AC.STE.AMOUNT.LCY> = Y.CREDIT.AMOUNT
    END

    R.STMT.ENT.CR<AC.STE.ACCOUNT.NUMBER> = Y.CREDIT.ACCT.NO
    R.STMT.ENT.CR<AC.STE.COMPANY.CODE>  = ID.COMPANY
    R.STMT.ENT.CR<AC.STE.AMOUNT.LCY> = Y.CREDIT.AMOUNT

    Y.CREDIT.ENTRY = R.STMT.ENT.CR
    Y.CREDIT.ENTRY = LOWER(Y.CREDIT.ENTRY)
    YMULTI.ENTRY<-1> = Y.CREDIT.ENTRY

    RETURN

*------------------------------------------------------------------------------
RAISE.TAX.AMOUNT.ENTRIES:
*------------------------------------------------------------------------------
*Raising Credit and Debit Entries for Tax Charges

    Y.DEBIT.ACCT.NO = Y.INT.ACCT.DR
    Y.DEBIT.AMOUNT = (-1)*TAX.AMOUNT
    Y.TRANS.REFERENCE = Y.CUS.ACC.ID


    GOSUB RAISE.DEBIT.ENTRIES

    Y.CREDIT.CATEGORY = Y.CATEGORY
    Y.CREDIT.AMOUNT = TAX.AMOUNT

    GOSUB RAISE.CREDIT.CATEG.ENTRIES

    RETURN
*------------------------------------------------------------------------------
RAISE.CREDIT.CATEG.ENTRIES:
*------------------------------------------------------------------------------
*  Raising Credit categ Entries

    R.STMT.ENT.CATEG.CR<AC.STE.TRANS.REFERENCE> = Y.TRANS.REFERENCE
    R.STMT.ENT.CATEG.CR<AC.STE.OUR.REFERENCE>= Y.TRANS.REFERENCE

    R.STMT.ENT.CATEG.CR<AC.STE.VALUE.DATE> = TODAY
    R.STMT.ENT.CATEG.CR<AC.STE.BOOKING.DATE> = TODAY
    R.STMT.ENT.CATEG.CR<AC.STE.EXPOSURE.DATE> = TODAY

    R.STMT.ENT.CATEG.CR<AC.STE.TRANSACTION.CODE> = Y.CREDIT.TXN.CODE

    R.STMT.ENT.CATEG.CR<AC.STE.CURRENCY> = Y.INT.CREDIT.CURRENCY

    IF Y.INT.CREDIT.CURRENCY NE LCCY THEN
        Y.INT.CURRENCY = Y.INT.CREDIT.CURRENCY
        Y.INT.AMT = Y.CREDIT.AMOUNT
        GOSUB CHECK.CURR.WITH.LCCY
        R.STMT.ENT.CATEG.CR<AC.STE.AMOUNT.LCY> = Y.CREDIT.AMOUNT
        R.STMT.ENT.CATEG.CR<AC.STE.AMOUNT.FCY> = Y.AMT.FCY
        R.STMT.ENT.CATEG.CR<AC.STE.EXCHANGE.RATE> = EXCHANGE.RATE
    END ELSE
        R.STMT.ENT.CATEG.CR<AC.STE.AMOUNT.LCY> = Y.CREDIT.AMOUNT
    END

    R.STMT.ENT.CATEG.CR<AC.STE.PL.CATEGORY> = Y.CREDIT.CATEGORY
    R.STMT.ENT.CATEG.CR<AC.STE.COMPANY.CODE>  = ID.COMPANY
    R.STMT.ENT.CATEG.CR<AC.STE.AMOUNT.LCY> = Y.CREDIT.AMOUNT

    Y.CREDIT.ENTRY = R.STMT.ENT.CATEG.CR
    Y.CREDIT.ENTRY = LOWER(Y.CREDIT.ENTRY)
    YMULTI.ENTRY<-1> = Y.CREDIT.ENTRY
    RETURN
*------------------------------------------------------------------------------
RAISE.STMT.ENTRY:
*------------------------------------------------------------------------------
* Raising Statement Entries

    PGM = "FT"
    TYPE = "SAO"
    FORWARD = ''
    CALL EB.ACCOUNTING(PGM,TYPE,YMULTI.ENTRY,FORWARD)

    RETURN
*-----------------------------------------------------------------------------------
UPDATE.L.CUST.FUND:
*-----------------------------------------------------------------------------------
*Updating the Current Balance and total Charge amount in BAN.L.CUSTODY.FUND template

    Y.INITIAL.BALANCE = Y.INITIAL.BALANCE - TOTAL.CHARGE.AMOUNT

    IF Y.INITIAL.BALANCE LE 0 THEN
        Y.CLOSE="CLOSED"
        R.BAN.L.CUSTODY.FUND<BAN.CON.STATUS.FLAG>=Y.CLOSE
        R.BAN.L.CUSTODY.FUND<BAN.CON.CUSTODY.END.DATE>=TODAY
        Y.INITIAL.BALANCE=0
    END

    Y.TOTAL.CHARGE = Y.TOTAL.CHARGE + TOTAL.CHARGE.AMOUNT

    NEXT.MONTH.DATE = Y.NEXT.CHARGE.DATE
    CALL CDT('',NEXT.MONTH.DATE,"+1C")  ;*Next month first day

    COMI = NEXT.MONTH.DATE
    CALL LAST.DAY.OF.THIS.MONTH

    NEXT.MONTH.END.DATE = COMI               ;*Next month end date

    R.BAN.L.CUSTODY.FUND<BAN.CON.NEXT.CHARGE.DATE> = NEXT.MONTH.END.DATE

    R.BAN.L.CUSTODY.FUND<BAN.CON.CURRENT.BALANCE> = Y.INITIAL.BALANCE
    R.BAN.L.CUSTODY.FUND<BAN.CON.TOT.CHARGE.AMOUNT> = Y.TOTAL.CHARGE

    CALL F.WRITE(FN.BAN.L.CUSTODY.FUND,Y.L.CUST.FUND.ID,R.BAN.L.CUSTODY.FUND)

    RETURN
*-----------------------------------------------------------------------------------
CHECK.CURR.WITH.LCCY:
*-----------------------------------------------------------------------------------
*


    BUY.CCY = Y.INT.CURRENCY
    SELL.CCY = LCCY
    SELL.AMT = ''
    BASE.CCY = ''
    Y.CCY.MRKT = '1'
    BUY.AMT = Y.INT.AMT
    EXCHANGE.RATE = ''
    DIFFERENCE = ''
    LCY.AMT = ''
    RETURN.CODE = ''
    CALL EXCHRATE(Y.CCY.MRKT,BUY.CCY,BUY.AMT,SELL.CCY,SELL.AMT,BASE.CCY,EXCHANGE.RATE,DIFFERENCE,LCY.AMT,RETURN.CODE)

    Y.AMT.FCY = SELL.AMT


    RETURN

    END

