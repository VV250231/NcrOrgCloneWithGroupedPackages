/*
##################################################################################################
# Project Name && Request Num..........: NSC Sales Central
# File............................: Batch_SetUserDivision.class                                                        
# Created by................: Nagendra Singh                                                                                                                                               
# Last Modified by......:  Nagendra Singh 
# Last Modified Date..: 5/5/2017
# Description...............: This Batch is developed as part of NC_AGILE-425 to keeping historing trend of
                       user's owned opportunity product's division. This batch will update Division__c (multipicklist)
                       on User.It will run once in a day.
                             
#  Revision History
 Version     Modified By          Story No.
 

################################################################################################
*/
global class Batch_SetUserDivision implements Database.Batchable<sobject>,Database.Stateful{
    global  Map<Id,set<String>> mpOwnerToDivision = new Map<Id,set<String>>();
       global Database.QueryLocator start(Database.BatchableContext BC){
         
         return Database.getQueryLocator('Select id, ownerid ,(select id,Product2.Industry__c from OpportunityLineItems) from opportunity where IsClosed=false');
        }

       global void execute(Database.BatchableContext BC, List<sObject> scope){
           
           
           for(sObject objScope : scope){
               Opportunity newObjScope = (Opportunity)objScope ;
               
               if(newObjScope.OpportunityLineItems.size()>0){
                   for(OpportunityLineItem ObjOli : newObjScope.OpportunityLineItems){
                   
                   if((ObjOli.Product2.Industry__c !=null && !String.isBlank(ObjOli.Product2.Industry__c)) &&(ObjOli.Product2.Industry__c != 'Interactive Printer Services' && ObjOli.Product2.Industry__c !='Healthcare')){
                       if(!mpOwnerToDivision.containsKey(newObjScope.ownerid)){
                           
                               mpOwnerToDivision.put(newObjScope.ownerid, new set<String>{ObjOli.Product2.Industry__c});   
                       }
                       else{
                           
                           Set<string> obj = new Set<string>();
                           obj= mpOwnerToDivision.get(newObjScope.ownerid);
                           obj.add(ObjOli.Product2.Industry__c);
                           mpOwnerToDivision.put(newObjScope.ownerid, obj);
                       }
                   }
                 }
               }
               
           }
           
       }
     
       global void finish(Database.BatchableContext BC){
           
            List<User> AllUser = new list<user>();
               for(Id objScope2 : mpOwnerToDivision.keySet()){
                   User u;
                   Set<string> obj = new Set<string>();
                   if(mpOwnerToDivision.containsKey(objScope2)){
                      obj= mpOwnerToDivision.get(objScope2); 
                   }        
                   
                   //obj.remove(null);
                   if(obj.size()>0){
                       
                       string Div;
                       for(String str:obj){
                           if((!String.isBlank(str)) || str !='Interactive Printer Services' || str !='Healthcare'){
                               Div =Div+str +';';
                           }
                       }
                       Div= Div.removeEnd(';');
                       Div = Div.remove('null');
                       system.debug('Div'+Div);
                       if(!String.isBlank(Div)){
                            u = new user(id = objScope2,Division__c = Div);
                       }
                      AllUser.add(u); 
                   }
               }
               if(AllUser.size()>0){
                   database.update(AllUser);
               }
              
       }
}