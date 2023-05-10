@isTest
public class populateOCRCommitDateTest{
    public static testMethod void myTest(){
       OCR_Commit__c  obj1 = new OCR_Commit__c();
       obj1.Quarter__c='1';
       obj1.Quarter_Week__c= '10';
       obj1.Year__c= '18';
       obj1.Industry__c= 'GS:Retail';
       
       insert obj1;
       
       Ocr_calender__c obj2 = new Ocr_calender__c();
       obj2.Quarter__c ='1';
       obj2.Quarter_Week_Number__c=10;
       obj2.Year__c = 2018;
       
       insert obj2;
       
       OCR_Commit__c  obj3 = new OCR_Commit__c();
       obj3.Quarter__c='1';
       obj3.Quarter_Week__c= '10';
       obj3.Year__c= '18';
       obj3.Industry__c= 'GS:FS';
       
       insert obj3;       
       
       OCR_Commit__c  obj4 = new OCR_Commit__c();
       obj4.Quarter__c='1';
       obj4.Quarter_Week__c= '10';
       obj4.Year__c= '18';
       obj4.Industry__c= 'GS:Hosp';
       
       insert obj4;       
       
       OCR_Commit__c  obj5 = new OCR_Commit__c();
       obj5.Quarter__c='1';
       obj5.Quarter_Week__c= '10';
       obj5.Year__c= '18';
       obj5.Industry__c= 'TNT:Sales';
       
       insert obj5;
        system.assertNotEquals(obj5.id,null);
       }
    
}