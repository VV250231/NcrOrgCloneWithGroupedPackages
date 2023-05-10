@isTest 
public class MissingAutoPaySetupControllerTest {
    
    @isTest  
    static void testm(){
        MissingAutoPaySetupDashBoardController.instantiate();
       
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        list<account> acc = new list<account>();
        account a = new account();
        a.name = 'TestAashirwaad';
        acc.add(a) ;
        System.runAs( Usr ){
            insert acc;
        }
        
    }
   
   
}