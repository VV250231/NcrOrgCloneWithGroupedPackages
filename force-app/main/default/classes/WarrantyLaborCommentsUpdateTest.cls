/*
##################################################################################################                                                                   
# File............................: WarrantyLaborCommentsUpdateTest.cls                                                        
# Version.....................: 53.0
# Description.........: The test class is basically written to test the WarrantyLaborCommentsUpdate trigger .
################################################################################################
*/

@isTest
public class WarrantyLaborCommentsUpdateTest {
    public static testMethod void warrantyTest(){
        Warranty_Labor_Request__c wl = new Warranty_Labor_Request__c();
        
        wl.Status__c = 'New';
        insert wl;
        wl.Status__c ='Approved';
        update wl;
    }

}