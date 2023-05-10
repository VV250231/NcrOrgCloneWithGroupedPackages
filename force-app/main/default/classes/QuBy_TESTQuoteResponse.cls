/*##################################################################################################
# Project Name..........: CPQ QuBy                                                                    
# File..................: QuBy_TESTQuoteResponse.cls                                  
# Version...............: 32.0 
# Created by............: Mudit Saxena
# Created Date..........: 23-08-2016                                                                              
# Last Modified by......: Mudit Saxena
# Last Modified Date....: 23-08-2016
# Description...........: This class is used as generalised class for QuBy quote creation.
                          This class is also used for opportunity search from QuBy.                          
##################################################################################################*/
@isTest
private class QuBy_TESTQuoteResponse {  
    
    static testMethod void UnitTestFirst() {
        QuoteResponse QR = new QuoteResponse ( 'SUCCESS','TEST SUCCESS' );
        QuoteResponse QR1 = new QuoteResponse ();
        System.assert(QR.status=='SUCCESS');
        
    }
}