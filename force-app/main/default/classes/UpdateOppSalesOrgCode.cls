public class UpdateOppSalesOrgCode implements Database.Batchable<SObject>, Database.Stateful {
    Set<String> updatedGblSlsOrgAccIds = new Set<String>();
    Map<String, String> slsOrgCodeAndIdMap = new Map<String, String>();
    Map<String, String> retrySlsOrgCodeIdMap = new Map<String, String>();
    List <String> errLst=new List<string>();
    Set<String> retryAccIds = new Set<String>();
    final String src;
   
        
    public UpdateOppSalesOrgCode(Set<String> updatedGblSlsOrgAccIds, String src) {
        this.updatedGblSlsOrgAccIds = updatedGblSlsOrgAccIds;
        this.src = src;
    }
    
    public UpdateOppSalesOrgCode(Map<String, String> slsOrgCodeAndIdMap, String src) {
        this.slsOrgCodeAndIdMap = slsOrgCodeAndIdMap;
        this.src = src;
    }
    
    public Database.queryLocator start(Database.BatchableContext bc) {
        if (src == 'Account') {
            return Database.getqueryLocator([SELECT Id, AccountId, Opportunity_Number__c, Sales_Org__c, Account_Global_Sales_Org_Code__c,Sales_Org_Code__c 
                                         FROM Opportunity WHERE AccountId IN :updatedGblSlsOrgAccIds AND Org_Code_Diff__c = true Order by Opportunity_Number__c]);
        } else {// Source = Salesorg
            return Database.getqueryLocator([SELECT Id, AccountId, Opportunity_Number__c, Sales_Org__c, Account_Global_Sales_Org_Code__c,Sales_Org_Code__c 
                                         FROM Opportunity WHERE Account_Global_Sales_Org_Code__c IN :slsOrgCodeAndIdMap.keySet() AND Sales_Org__c = NULL Order by Opportunity_Number__c]);    
         
        }
    }
    
    public void execute(Database.BatchableContext bc, List<Opportunity> oppLst) {
        try {
            CheckRecursive.checkOppOrgUpdtBtchRun(); 
            
            Database.SaveResult[] results = Database.update(oppLst,false);
            integer j=0;
            
            if (results != null) {
                for (Database.SaveResult sr : results) {
                    if (!sr.isSuccess()) {
                        Database.Error[] errs = sr.getErrors();
                        for(Database.Error err : errs) {
                            if (err.getStatusCode() == System.StatusCode.UNABLE_TO_LOCK_ROW) {
                                 if (this.src == 'Account') {
                                    retryAccIds.add(oppLst[j].AccountId);
                                 } else if(this.src == 'SalesOrg') {
                                    retrySlsOrgCodeIdMap.put(oppLst[j].Account_Global_Sales_Org_Code__c, slsOrgCodeAndIdMap.get(oppLst[j].Account_Global_Sales_Org_Code__c));
                                 }
                            } else {  
                                if (this.src == 'Account') {
                                    errLst.add('Sales Org update From Account Global Sales Org Change failed for Opportunity :' + oppLst[j].Opportunity_Number__c +' due to Error: '+err.getStatusCode() + ': ' + err.getMessage());
                                } else if(this.src == 'SalesOrg') {
                                    errLst.add('Sales Org update From Master Sales Org Create failed for Opportunity :' + oppLst[j].Opportunity_Number__c +' due to Error: '+err.getStatusCode() + ': ' + err.getMessage());    
                                }
                            }
                        }
                    }
                    j++;
                }
            }
            
            if(Test.isRunningTest()) throw new CustomException('Testing error');
        } catch (Exception e) {
            System.debug('Excpetion occurred in Opportunity Sales Org Code Update From '+ src + ': ' + e.getMessage() + '<br/>' + e.getStackTraceString());
            
            
            String err = 'Excetion occurred in Opportunity Sales Org Update From: ' + src;
            for(Opportunity opp : oppLst) {
                err += '<br/>' + opp.Opportunity_Number__c ;            
            }
            errLst.add(err);
        }   
    }
    
    public void finish(Database.BatchableContext bc) {
        if(Test.isRunningTest()) {
           if (this.src == 'Account') {
               retryAccIds.add(new List<String>(updatedGblSlsOrgAccIds).get(0));
           } 
        }
    
        if(!retryAccIds.isEmpty() || !retrySlsOrgCodeIdMap.isEmpty()) {
            List<CronTrigger> crnJobLst = [SELECT  NextFireTime,State, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType 
                      FROM CronTrigger 
                      WHERE CronJobDetail.JobType = '7' and CronJobDetail.Name like '%Update_Opp_Org_Code%' 
                      order by NextFireTime desc limit 1];
            
            String crnID;
            
            
            
            if(!crnJobLst.isEmpty()) {
                Datetime nextJobSchdtime = crnJobLst.get(0).NextFireTime;   
                Integer diffmins = Integer.valueOf((nextJobschdtime.getTime() - Datetime.now().getTime())/1000/60) + 5;
                
                if (this.src == 'Account') {
                    crnID = System.scheduleBatch(new UpdateOppSalesOrgCode(retryAccIds, 'Account'), 'Update_Opp_Org_Code ' + String.valueOf(nextJobSchdtime.addMinutes(diffmins)), diffmins, 20);                     
                } else if(this.src == 'SalesOrg') {
                    crnID = System.scheduleBatch(new UpdateOppSalesOrgCode(retrySlsOrgCodeIdMap, 'Sales Org'), 'Update_Opp_Org_Code ' + String.valueOf(nextJobSchdtime.addMinutes(diffmins)), diffmins, 20);     
                } 
            } else {
                 if (this.src == 'Account') {
                    crnID = System.scheduleBatch(new UpdateOppSalesOrgCode(retryAccIds, 'Account'), 'Update_Opp_Org_Code', 5, 20);                         
                 } else if(this.src == 'SalesOrg') {
                    crnID = System.scheduleBatch(new UpdateOppSalesOrgCode(retrySlsOrgCodeIdMap, 'SalesOrg'), 'Update_Opp_Org_Code', 5, 20);        
                 }
                
            }
            
        }
        
        String mailBdy = '';
        String mailSub = 'Error in updating Sales Org Code for ' + errLst.size() + ' Opportunities';
        
        if(!errLst.isEmpty()) {
            for (String err : errLst) {
                mailBdy += err + '<br/>';    
            }
            CDMUtil.notifySupportTeam(mailSub, mailBdy);            
        } 
    }
    
    public class CustomException extends Exception {}  
}