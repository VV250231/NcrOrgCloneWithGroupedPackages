/*
##################################################################################################
# Project Name..........: NSC Mobility                                                                      
# File..................: OppContactRoleCtrl.cls                                                        
# Version...............: 32.0 
# Created by............: Puneet Bhatia                                                                  
# Created Date..........: 07-05-2015                                                                               
# Last Modified by......: Puneet Bhatia
# Last Modified Date....: 07-05-2015 
# Description...........: The test class is used as controller for OppContactRole page.
################################################################################################
*/
global with sharing class OppContactRoleCtrl {

    public  List<OpportunityContactRole> oppContactRole{get;set;}
    public OpportunityContactRole crole{get;set;}
    public string country{get;set;}
    
    private final Opportunity oppObj;
    
    public OppContactRoleCtrl(ApexPages.StandardController stdController) {
        oppObj = (Opportunity)stdController.getRecord();
        
        oppContactRole = [SELECT Id, ContactId, Contact.Name, 
                            OpportunityId, Role, IsPrimary  
                            FROM OpportunityContactRole 
                            WHERE OpportunityId = :oppObj.Id
                            ORDER BY Contact.Name];
                            
        oppContactRole.add(new OpportunityContactRole(OpportunityId  = oppObj.id));
        oppContactRole.add(new OpportunityContactRole(OpportunityId  = oppObj.id));
    }
    
    public void saveConRoles() {
        List<OpportunityContactRole> insertConRoleList = new List<OpportunityContactRole>(); 
        for(OpportunityContactRole opr :oppContactRole){
            if(opr.ContactId != null && opr.Role != null && opr.Role != '') {
                insertConRoleList.add(opr);    
            }    
        }
        
        if(!insertConRoleList.isEmpty()){
            try {
                upsert insertConRoleList;
            } catch(Exception e){
                System.debug('Error: '+e.getMessage());            }
        }
    
    }
    
    @RemoteAction
    global static List<Contact> searchContact(String searchstr){
       List<Contact> conList = new List<Contact>();
       
       if(!String.isEmpty(searchstr)){
           String searchtxt = searchstr + '%';
           conList = [SELECT Id, Name FROM Contact WHERE Name LIKE :searchtxt LIMIT 20];
       } 
       return conList;     
    } 
    
    @RemoteAction
    global static List<Contact> loadContact(){
       List<Contact> conList = [SELECT Id, Name FROM Contact ORDER BY CreatedDate LIMIT 15];
       return conList;     
    } 
    
    
   
}