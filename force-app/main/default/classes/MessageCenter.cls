/* Class Name : Message Center 
* Date : 05/09/19 
* Description : This Class  is used in Partner Portal for displaying Message for 
*               Channel Partner under 2020 Program
* DeveloperName : Deeksharth Sriwastava
*/
public with sharing class MessageCenter {

    @AuraEnabled(cacheable = true)
    public static List<Message_Center__c>  getMessageInfo(String AccId){
        String aReason ;
        String pPrgrmLvl;
        String queryString;
        //User u = [SELECT Id, Name, AccountId, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        List<Account> tempList  = New List<Account>();
        List<Message_Center__c> messageCntrlst = new List<Message_Center__c>();
     if(AccId != null) {
            tempList = [SELECT Id, Name, Master_Customer_Number__c, Partner_Program_Level__c,
                        Account_Region__c,Partner_Industry__c FROM Account WHERE Id =: AccId LIMIT 1];
     }
        if(tempList.size()>0){
            List<String> includesList = new List<String>{};
            system.debug('partner industry >>'+tempList[0].Partner_Industry__c);
            String[] pIndustry = new String[]{};
            if(tempList[0].Partner_Industry__c != null)
            	pIndustry = tempList[0].Partner_Industry__c.split(';');
            if(!pIndustry.isEmpty() && pIndustry != NULL){
                for(string str:pIndustry){
                    system.debug('str >>'+'\''+ str + '\'');
                    String newString = '\''+ str + '\'';
                    includesList.add(newString);
                }
            }
            // Account reason field 
            system.debug('account reason >>'+tempList[0].Account_Region__c);
            if(tempList[0].Account_Region__c != NULL)
                aReason = '\''+ tempList[0].Account_Region__c + '\'';

            // Partner program level data 
            system.debug('Partner program level >>'+tempList[0].Partner_Program_Level__c);
			if(tempList[0].Partner_Program_Level__c != NULL)
				pPrgrmLvl = '\''+ tempList[0].Partner_Program_Level__c + '\'';

            // query string creation
            queryString=String.escapeSingleQuotes('SELECT Id,Description_box_1__c,Description_box_2__c,Description_box_3__c,Description_box_4__c,Industry__c,Region__c,Tier_Level__c,Active_From__c,Active_To__c FROM Message_Center__c WHERE Is_Active__c =TRUE ');
            if(includesList != NULL && includesList.size()>0){
				queryString +=' and Industry__c includes( ';
				for(String includeValue :includesList){
					queryString += includeValue + ',';
				}
				queryString = queryString.removeEnd(',') +')';
			}
			if(aReason != NULL){
				queryString +=' and Region__c includes (';
				queryString +=aReason+')';
			}
            if(pPrgrmLvl!= NULL){
				queryString +=' and Tier_Level__c includes (';
				queryString +=pPrgrmLvl+')';
			}
            system.debug('queryString---->'+queryString);
            String activeDate = String.valueOf(system.today());
            queryString +=' and Active_From__c  <='+activeDate;
            queryString +=' and Active_To__c  >='+activeDate;
            messageCntrlst = database.query((queryString));
        }
    
        if(messageCntrlst.size()>0){
            return messageCntrlst;
        }else       
            return new List<Message_Center__c>();                                  
    }
}