/*##################################################################################################
# Project Name..........: CPQ QuBy                                                                    
# File..................: QuBy_TESTQuoteObject.cls                                  
# Version...............: 32.0 
# Created by............: Mudit Saxena
# Created Date..........: 23-08-2016                                                                              
# Last Modified by......: Mudit Saxena
# Last Modified Date....: 23-08-2016
# Description...........: This class is used as generalised class for QuBy quote creation.
                          This class is also used for opportunity search from QuBy.                          
##################################################################################################*/
@isTest
private class QuBy_TESTQuoteObject {  
    
    static testMethod void UnitTestFirst() {
        QuoteObject QO = new QuoteObject ();
        //QO.appName = 'TEST APP';
        string str = QO.AccountId;
        string str2 = QO.orderDetailId;
        
        QO.AccountId = 'TEST';
        QO.orderDetailId = 'TEST';
        system.assert(QO !=null);
    }
}