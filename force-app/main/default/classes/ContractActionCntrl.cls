/*
##################################################################################################
# Project Name..........: CLM
# File............................: ContractActionCntrl.cls                                                        
# Created by................: Varsha Pal                                                                   
# Created Date...........: 27/08/2021 (MM/DD/YYYY)                                                                             
# Last Modified by......:  Varsha Pal
# Last Modified Date..: 31/08/2021 (MM/DD/YYYY)
# Description...............: This class will track the history of contract actions button usage per user per day limit and
it will be called from two flows(Contract Action) and Contract Action on Account(EBA_SF-1481)
History #
LastModifiedBy         LastModifiedDate                  Story#
Varsha                 03/10/2022(MM/DD/YYYY)            
##################################################################################################
*/
public class ContractActionCntrl {
    public PageReference urlRedirection() {
       //Changes done by Yogesh - EBA_SF-1732
        /*	String obj = apexpages.currentpage().getparameters().get('obj');
        String  pName = apexpages.currentpage().getparameters().get('page');
        System.debug('object'+obj);
        system.debug('pname'+pName);
        string url = apexpages.currentpage().getparameters().get('url');
        System.debug('url'+url);*/
        String obj = String.escapeSingleQuotes(apexpages.currentpage().getparameters().get('obj'));
        String  pName = String.escapeSingleQuotes(apexpages.currentpage().getparameters().get('page'));
        string url = String.escapeSingleQuotes(apexpages.currentpage().getparameters().get('url'));  
       	String aid = String.escapeSingleQuotes(apexpages.currentpage().getparameters().get('acid'));  
        //End Changes 
        if(obj!=null&&pName!=null) {
            String tabAccssUniqueId = pName + obj + Userinfo.getUserId() + String.valueOf(Datetime.now().format('yyMMdd'));
            
            List<Tab_Access__c > tabAccList = [Select UniqueId__c, Daily_View_Count__c  from Tab_Access__c where UniqueId__c = :tabAccssUniqueId LIMIT 1];
            
            Tab_Access__c ta;
            if (tabAccList != null && tabAccList.size() > 0) {
                ta =  tabAccList.get(0);
                ta.Daily_View_Count__c  = ta.Daily_View_Count__c + 1;    
            } else {
                ta = new Tab_Access__c(Name = 'Contract Action', Source_Object__c=obj,PageName__c = pName, Metrics_Date__c = Date.today(), User__c= Userinfo.getUserId(), UniqueId__c= tabAccssUniqueId, Daily_View_Count__c  = 1);        
            }
           	upsert ta UniqueId__c; 
            
        }
        PageReference page = null;
        if(url!=null){
            url = EncodingUtil.urlDecode(url,'UTF-8');
            if(aid!=null){
                Account a = [Select Name, Master_Customer_Number__c from Account where id =:aid];
                url = url.replace('accName',EncodingUtil.urlEncode(a.Name,'UTF-8'));
                url = url.replace('accMCN',EncodingUtil.urlEncode(a.Master_Customer_Number__c,'UTF-8'));
            }
           	page = new PageReference(url);
            System.debug('final url'+EncodingUtil.urlDecode(url,'UTF-8'));
            page.setRedirect(true);
        }
        return page;
    }
    
}