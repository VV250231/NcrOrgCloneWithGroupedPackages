/*************************************************************************************************
* Author        :   SANTOSH JHA  
* Date          :   27-08-2020
* Param         :   
* Return        :   
* Description   :   This Trigger will update NPS score field in Account object by taking latest survey
*************************************************************************************************/


trigger NPSScoreCalc on Survey_Result__c (after insert, after update) {
    Set<String> inputContIds = new Set<String>();
    Set<String> inputAcctIds = new Set<String>();
    
    List<Account> updateAccList = new List<Account>();
    List<Account> updateAccList1 = new List<Account>();
    List<Contact> updateConList = new List<Contact>();
    //String NPS_Year = Label.NPS_Year+'%';
    String NPS_Year  = '%'+String.valueOf(System.Today().year())+'%';
    
    for(Survey_Result__c result : Trigger.new) 
    {
        
        if(result.Contact__c != NULL) 
        {
            inputContIds.add(result.Contact__c); 
        }
    }
    if(!inputContIds.isEmpty()) 
    {
        
        
        for(Contact con: [SELECT Id,AccountId from Contact WHERE Id IN :inputContIds]) 
        {
            
            inputAcctIds.add(con.AccountId);    
            
        }
    }  
    
    
    
    if(!inputAcctIds.isEmpty()) 
    {
        
        List<AggregateResult> MaxRespondentEndDate=
            //AggregateResult [] MaxRespondentEndDate=  
            [ SELECT max(Respondent_End_Date__c) maxdate, 
             Contact__c contactId 
             FROM Survey_Result__c WHERE  Contact__r.AccountId IN :inputAcctIds and name like : NPS_Year
             group by Contact__c];
        
        for (AggregateResult ar1: MaxRespondentEndDate) 
        {
            
            String cnId = (string)ar1.get('contactId');
            Datetime cnLatestSurvey = (DateTime)ar1.get('maxdate');
            
            Contact cn = new Contact(id = cnId,LatestSurveyDateTime__c=cnLatestSurvey);
            updateConList.add(cn);
            
        }
        
        if(!updateConList.isEmpty()) update updateConList; 
        
        //////************************************************************** *//////////
        
        for(Account acc2 : [Select Id, NPS__c FROM Account Where Id IN : inputAcctIds ])
        {
            Account acc1 = new Account(Id = acc2.id, NPS__c = NULL); 
            updateAccList1.add(acc1);
            
        }
        if(!updateAccList1.isEmpty()) update updateAccList1; 
        //////************************************************************** *//////////
        
        AggregateResult[] AvgSurveyResults = 
            [select count(id) totalcount,sum(Promoter__c) promoterscount,sum(Detractor__c) detractorscount, Contact__r.AccountId accId from Survey_Result__c  WHERE Contact__r.AccountId IN :inputAcctIds 
             and IsLatest__c= 1 and name like : NPS_Year group by Contact__r.AccountId ];     
        
        for (AggregateResult ar: AvgSurveyResults) 
        {
            String accId = (String)ar.get('accId');
            
            decimal avgNPSScore = ((Decimal)ar.get('promoterscount')/(Decimal)ar.get('totalcount')-(Decimal)ar.get('detractorscount')/(Decimal)ar.get('totalcount'))*100; 
            
            
            Account acc = new Account(Id = accId, NPS__c = avgNPSScore); 
            updateAccList.add(acc);
            
        }
        
        if(!updateAccList.isEmpty()) update updateAccList; 
        
        
        
    }
}