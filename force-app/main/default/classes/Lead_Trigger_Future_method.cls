/****************************************************************************************************************
*   ClassName :   Lead_Trigger_Future_method
*   Description :   Leadtriggertest
*   Author      :   
*   Version     :   Initial
* Test Class : 
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1669       8th Dec 2021    Varsha Pal             Remove the testcoverage function which was already commented
****************************************************************************************************************/
public class Lead_Trigger_Future_method {
    
    @future
    public static void updatecontact(Set<id> lead_marketing_old){
        List<Contact> l_list = new List<Contact>();
        for(Contact l : [select id from contact where id in:lead_marketing_old limit 50000]){
            l.Marketing_Qualified_Contact_Date__c = datetime.now();
            l_list.add(l);
        }
        
        if(l_list.size()>0 || Test.isRunningTest()){
            update l_list ;
        }
    }
    
     @future
    public static void updatelead(Set<id> lead_marketing_old){
        List<Lead> l_list = new List<Lead>();
        for(Lead l : [select id from lead where id in:lead_marketing_old limit 50000]){
            l.Marketing_Qualified_Contact_Date__c = datetime.now();
            l_list.add(l);
        }
        
        if(l_list.size()>0 || Test.isRunningTest()){
            update l_list ;
        }
    }
}