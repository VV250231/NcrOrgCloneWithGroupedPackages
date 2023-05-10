/**
* Class is used to TEST: credit_Activity_Controller, Schedule_Credit_Detail_clean, Credit_Detail_Clean
*
* @author  Ajay Dixit
* @Data   2020-04-28
*/
@IsTest
public class credit_Activity_ControllerTest  {
    @IsTest
    static void TestCreditActivity(){
        
        //when
        String allFields='';
        String excludeString='';
        Id creditId;
        String objName='Credit_Detail__c';
        
        //Then
        credit_Activity_Controller.getCreditDetail(allFields, creditId);
        credit_Activity_Controller.getFields(objName, excludeString);
        credit_Activity_Controller.getFieldsString(objName, excludeString);
        //When
        Account a = TestRecordsFactory.createAccount();
        Credit_Detail__c cd=new Credit_Detail__c(Account__c=a.id);
        insert cd;
        allFields='Id,Name,CreatedDate';
        excludeString='CreatedDate';
        creditId=cd.id;
        
        //Then
        Test.startTest(); 
			      
        //credit_Activity_Controller.getCreditDetail(allFields, creditId);
        Credit_Detail__c c = credit_Activity_Controller.getCreditDetail(allFields, creditId);
        //When
        creditId=a.id;
        c = credit_Activity_Controller.getCreditDetail(allFields, creditId);
        system.assertEquals(cd.id, c.Id);
        credit_Activity_Controller.getFields(objName, excludeString);
        credit_Activity_Controller.getFieldsString(objName, excludeString);
        
        //Covers Schedule_Credit_Detail_clean class
        Schedule_Credit_Detail_clean sc = new Schedule_Credit_Detail_clean(); 
		sc.execute(null);
       
        // Cover Credit_Detail_clean Class
        
            credit_Detail_Clean updater = new credit_Detail_Clean(true);
        //updater.failureCounter = 1;
        // startTest/stopTest block to force async processes to run
               database.executeBatch(updater);
       //System.enqueueJob(updater);
      // updater.sendEmail('test');
        Test.stopTest();
        
    }

}