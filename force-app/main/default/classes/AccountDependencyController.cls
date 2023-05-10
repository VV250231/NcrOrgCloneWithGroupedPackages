global class AccountDependencyController implements  Database.Batchable<sObject> {
    
    Boolean isProcessed;
    global Set<String> objectFieldSet;
    
    global AccountDependencyController() {
        this.isProcessed = false;
        
        
        objectFieldSet = new  Set<String> {'Account.ParentId','Account.Primary_Partner__c', 
            'Case.AccountId', 'Case.HOSPD_Account_Name__c',
            'Campaign_Activity__c.Account_Name__c', 'Contract.AccountId',
            'Credit_Detail__c.Account__c',
            'Contact.AccountId', 'Partner_Maturity_Level__c.Account__c',      
            'zqu__Quote__c.zqu__Account__c',               
            //'Customer_Linkage__c.Account__c',
            'zqu__QuoteRatePlanCharge__c.SupportChannelPartnerLkp__c',
            'zqu__QuoteRatePlanCharge__c.ChannelPartner_Lkp__c',
            'zqu__QuoteCharge__c.ChannelPartner_Lkp__c',
            'prmtsf__Pramata_Contract__c.prmtsf__Account__c',
            'prmtsf__Pramata_Contract_Account_Assoc__c.prmtsf__Account__c',
            'echosign_dev1__SIGN_Recipients__c.echosign_dev1__Person_Account__c',
            'echosign_dev1__SIGN_Agreement__c.echosign_dev1__Account__c',
            'Zuora__ZInvoice__c.Zuora__Account__c',
            'Zuora__Subscription__c.Zuora__Account__c',
            'Zuora__SubscriptionRatePlan__c.Zuora__Account__c',
            'Provisioning__c.Account__c',
            //'Project__c.Accounts__c',
            'Presales_Engineer_Activity__c.PSE_Account__c',
            'Zuora__CustomerAccount__c.Zuora__Account__c',
            'Zuora__CustomerAccount__c.Channel_Office__c',
            'User.AccountId', 
            'Support_Desk__c.Master_Customer_Name__c',
            'Support_Desk__c.Account_Name_2__c',
            'Support_Desk__c.Account_Name3__c',
            'Support_Desk__c.Account_Name_4__c',
            'Support_Desk__c.Account_Name_5__c',
            'Opportunity.Channel_Office__c',
            'Opportunity.End_Customer__c',
            // 'Opportunity.Master_Distributor__c',
            'Opportunity.Reseller__c',
            'Solution_Provider_Relationship__c.Account_Id__c',
            'QuBy_Detail__c.Account__c' ,
            'Pricing_Bid_Log__c.Customer__c',
            'PRM_Services__c.Account_Name__c',
            'Performance_Scoreboard__c.Account__c',
            'Engineers__c.Partner_Account__c',
            'SFDC_MDF__c.Account__c',
            'Equipment_Declaration__c.Partner_Account__c',
            'Deal_Registration__c.Partner_Company_Name__c',
            'Expansion_Request__c.Account_Name__c',
            'Incentive_Program_Enrollment__c.Account__c',
            'Incentive_Program_Exception_Account__c.Account__c',
            'Marketing_Concierge__c.Partner_Company__c',
            'Partner_Opportunity__c.Partner_Account__c',
            'RMA__c.Account__c',
            'SFDC_MDF_Claim__c.Account__c',
            'Demo_Program__c.Partner_Account__c',
            'Co_Op__c.Account__c',
            'Certification__c.Account__c',
            'Account_Exception__c.Partner_Account_Name__c',
            'Task.AccountId',
            'Event.AccountId'
            }; 
                }
    
    global AccountDependencyController(Boolean isProcessed){
        this.isProcessed = isProcessed;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {  
        if(Test.isRunningTest()) {
            return Database.getQueryLocator([SELECT Id,Account_Created_Date__c,Pricing_Bid_Log_Count__c,Account_Owner__c,Account_Team_Member_Count__c,Account_User_Count__c,Active_Account__c,Billing_Account1__c,Billing_Account2__c,Campaign_Activity_Count__c,Case_Count__c,Case_HOSP_Count__c,CFS_Contract_Count__c,Channel_Office_Opp_Count__c,Closed_Opp_Max_Created_Date__c,Closed_Opportunity_Count__c,Comments__c,Contact_Count__c,Credit_Detail_Count__c,Customer_Linkage_Count__c,Customer_Temp_Count__c,End_Customer_Opp_Count__c,Esign_Agreement_Count__c,Esign_Agreement_Max_CreatedDate__c,Esign_Recipient_Count__c,Input_Account_Id__c,Input_Account_Record_Type__c,Input_Master_Customer_Number__c,Input_Operating_Unit__c,Input_Party_Name__c,Master_Distributor_Opp_Count__c,Max_Date_Quby_Quote_No__c,Max_Modification_Date_Quby_Quote__c,Need_Help_Account1_Count__c,Need_Help_Account2_Count__c,Need_Help_Account3_Count__c,Need_Help_Account4_Count__c,Need_Help_Account5_Count__c,No_of_ParentId_Childs__c,Open_Opp_Max_Created_Date__c,Open_Opportunity_Count__c,Owner_Active__c,Partner_Maturity_Count__c,Pramata_Contract_Assoc_Count__c,Pramata_Contract_Count__c,PresalesEngineerActivity_Count__c,Primary_Partner_Child_Account_Count__c,Project_Count__c,Provisioning_Count__c,QRPC_ChannelPartner_Count__c,QRPC_SupportChannelPartner_Count__c,Quby_Quote_Count__c,
                                             Quby_Quote_Opportunities__c,Quote_Charge_Channel_Partner_Count__c,Reseller_Opp_Count__c,SF_RecordType__c,Solution_Provider_Relationship_Count__c,Verify_Related_Record__c,ZInvoice_Count__c,ZQuote_Count__c,ZSubscription_Count__c,ZSubscription_RP_Count__c,Zuora_Objects_Comments__c, Related_Opp_Record__c, 
                                             PRM_Account_Exception_Count__c,PRM_Certification_Count__c,PRM_Co_OP_Count__c,PRM_Deal_Registration_Count__c,PRM_Demo_Program_Count__c,PRM_Enginner_Count__c,PRM_Equipment_Count__c,PRM_Expansion_Request_Count__c,PRM_Incentive_Program_Count__c,PRM_Incentive_Program_Exception_Count__c,PRM_Marketing_Concierge_Count__c,
                                             PRM_MDF_Claim_Count__c,PRM_MDF_Request_Count__c,PRM_Partner_Opportunity_Count__c,PRM_RMA_Count__c,PRM_Services_Count__c,PRM_SFDC_Budget_Count__c,Performance_Scorebaord_Count__c,PRM_Comments__c,Data_Source__c, Billing_Address__c,Open_Task_Count__c,Open_Event_Count__c
                                             FROM Analysis_Acc_Master__c]);
        } else {
            
            
            
            return Database.getQueryLocator([SELECT Id,Account_Created_Date__c,Pricing_Bid_Log_Count__c,Account_Owner__c,Account_Team_Member_Count__c,Account_User_Count__c,Active_Account__c,Billing_Account1__c,Billing_Account2__c,Campaign_Activity_Count__c,Case_Count__c,Case_HOSP_Count__c,CFS_Contract_Count__c,Channel_Office_Opp_Count__c,Closed_Opp_Max_Created_Date__c,Closed_Opportunity_Count__c,Comments__c,Contact_Count__c,Credit_Detail_Count__c,Customer_Linkage_Count__c,Customer_Temp_Count__c,End_Customer_Opp_Count__c,Esign_Agreement_Count__c,Esign_Agreement_Max_CreatedDate__c,Esign_Recipient_Count__c,Input_Account_Id__c,Input_Account_Record_Type__c,Input_Master_Customer_Number__c,Input_Operating_Unit__c,Input_Party_Name__c,Master_Distributor_Opp_Count__c,Max_Date_Quby_Quote_No__c,Max_Modification_Date_Quby_Quote__c,Need_Help_Account1_Count__c,Need_Help_Account2_Count__c,Need_Help_Account3_Count__c,Need_Help_Account4_Count__c,Need_Help_Account5_Count__c,No_of_ParentId_Childs__c,Open_Opp_Max_Created_Date__c,Open_Opportunity_Count__c,Owner_Active__c,Partner_Maturity_Count__c,Pramata_Contract_Assoc_Count__c,Pramata_Contract_Count__c,PresalesEngineerActivity_Count__c,Primary_Partner_Child_Account_Count__c,Project_Count__c,Provisioning_Count__c,QRPC_ChannelPartner_Count__c,QRPC_SupportChannelPartner_Count__c,Quby_Quote_Count__c,
                                             Quby_Quote_Opportunities__c,Quote_Charge_Channel_Partner_Count__c,Reseller_Opp_Count__c,SF_RecordType__c,Solution_Provider_Relationship_Count__c,Verify_Related_Record__c,ZInvoice_Count__c,ZQuote_Count__c,ZSubscription_Count__c,ZSubscription_RP_Count__c,Zuora_Objects_Comments__c, Related_Opp_Record__c, 
                                             PRM_Account_Exception_Count__c,PRM_Certification_Count__c,PRM_Co_OP_Count__c,PRM_Deal_Registration_Count__c,PRM_Demo_Program_Count__c,PRM_Enginner_Count__c,PRM_Equipment_Count__c,PRM_Expansion_Request_Count__c,PRM_Incentive_Program_Count__c,PRM_Incentive_Program_Exception_Count__c,PRM_Marketing_Concierge_Count__c,
                                             PRM_MDF_Claim_Count__c,PRM_MDF_Request_Count__c,PRM_Partner_Opportunity_Count__c,PRM_RMA_Count__c,PRM_Services_Count__c,PRM_SFDC_Budget_Count__c,Performance_Scorebaord_Count__c,PRM_Comments__c,Data_Source__c, Billing_Address__c,Open_Task_Count__c,Open_Event_Count__c
                                             FROM Analysis_Acc_Master__c WHERE isProcessed__c = false]);
            
        }
        /* WHERE isProcessed__c = :isProcessed */
    }
    
    
    global void execute(Database.BatchableContext BC, List<Analysis_Acc_Master__c> accMasterList) {
        Set<String> inputAccountIds = new Set<String>();
        
        for(Analysis_Acc_Master__c am : accMasterList) {
            inputAccountIds.add(am.Input_Account_Id__c);
        }
        
        //1. ACTUAL ACCOUNT
        Map<Id, Account> AccountMap = new Map<Id, Account> ([SELECT Id, Owner.Name, Owner.isActive,RecordType.Name, Active_Account__c , CreatedDate,MDM_Data_Source_Code__c,Interface_Source__c,BillingStreet, BillingCity, BillingState,BillingPostalCode,BillingCountry FROM Account WHERE Id IN :inputAccountIds ]);
        
        //2. CLOSED OPPORTUNITY - AccountId
        Map<String, List<Object>> closedOppMap = getClosedOpptyMap(inputAccountIds);
        
        //3. OPEN OPPORTUNITY - Account Id
        Map<String, List<Object>> openOppMap = getOpenOpptyMap(inputAccountIds);
        
        //4.ACCOUNT TEAM MEMBER 
        Map<Id, List<AccountTeamMember>> accountTeamMap = getAccountTeamMap(inputAccountIds);
        
        //MAP DYNAMIC QUERY
        //sObject  Name => sObject data map, Account Id => sObject list map 
        
        Map<String, Map<String, List<sObject>>> sObjectandAccountIdMap = new Map<String, Map<String, List<sObject>>>();
        
        for(String objectFieldName : objectFieldSet) {
            Map<String, List<sObject>> AccountIdMap = new Map<String, List<sObject>>();
            String objectName =  (objectFieldName.split('\\.'))[0]; 
            String fieldName =  (objectFieldName.split('\\.'))[1]; 
            String dynamicQuery = 'SELECT Id,';
            
            if(objectFieldName == 'QuBy_Detail__c.Account__c') {                
                dynamicQuery +=  'Quote_Number__c,Solution_Modification_Date__c,Opportunity__c, Opportunity__r.Opportunity_Number__c,Opportunity__r.StageName, Opportunity__r.CloseDate,';   
                
            } else if(objectFieldName == 'zqu__QuoteRatePlanCharge__c.SupportChannelPartnerLkp__c'
                      || objectFieldName == 'zqu__QuoteRatePlanCharge__c.ChannelPartner_Lkp__c'
                      || objectFieldName == 'zqu__QuoteCharge__c.ChannelPartner_Lkp__c'
                      || objectFieldName == 'echosign_dev1__SIGN_Recipients__c.echosign_dev1__Person_Account__c'
                      || objectFieldName == 'echosign_dev1__SIGN_Agreement__c.echosign_dev1__Account__c'
                      || objectFieldName == 'zqu__Quote__c.zqu__Account__c') {
                          
                          dynamicQuery += 'CreatedDate,';  
                      } else if (objectFieldName == 'Opportunity.Channel_Office__c'
                                 || objectFieldName == 'Opportunity.End_Customer__c'
                                 // || objectFieldName =='Opportunity.Master_Distributor__c'
                                 || objectFieldName == 'Opportunity.Reseller__c') {
                                     
                                     dynamicQuery += 'Closedate,'; 
                                     
                                 }
            dynamicQuery += fieldName  + ' FROM ' + objectName + ' WHERE '+ fieldName + ' IN :inputAccountIds ';  
            
            if (objectFieldName == 'Task.AccountId') {
                dynamicQuery += ' AND isClosed = false';
            } else if(objectFieldName  == 'Event.AccountId') {
                dynamicQuery += ' AND ActivityDate >=2020-12-01' ;    
                
            }
            
            dynamicQuery +=' ORDER BY CREATEDDATE DESC';          
            List<sObject> sobjList = Database.query(dynamicQuery);
            
            for(sObject sObjrec : sobjList) {
                List<sObject> tempList = AccountIdMap.get((String)sObjrec.get(fieldName)); 
                if(tempList ==  NUll)  tempList = new List<sObject>();
                tempList.add(sObjrec);
                AccountIdMap.put((String)sObjrec.get(fieldName), tempList);    
            }
            
            sObjectandAccountIdMap.put(objectFieldName, AccountIdMap);
        }
        
        for(String objectName : sObjectandAccountIdMap.keySet()) {
            System.debug(objectName);
            System.debug(sObjectandAccountIdMap.get(objectName));
        }
        
        
        // final field population for all input customers
        for(Analysis_Acc_Master__c am : accMasterList) {
            
            Account actualAcc = AccountMap.get(am.Input_Account_Id__c);
            integer childRecordCount = 0;
            String summComments = '';
            
            
            if(actualAcc != NULL) {
                am.Account_Owner__c = actualAcc.Owner.Name;
                am.Owner_Active__c = actualAcc.Owner.isActive;
                am.SF_RecordType__c = actualAcc.RecordType.Name;
                am.Account_Created_Date__c = actualAcc.CreatedDate.date();
                am.Active_Account__c = actualAcc.Active_Account__c;
                am.Data_Source__c = (String.isNotBlank(actualAcc.Interface_Source__c) && actualAcc.Interface_Source__c.toUpperCase() == 'ERP') ? actualAcc.Interface_Source__c : actualAcc.MDM_Data_Source_Code__c;
                am.Billing_Address__c = actualAcc.BillingStreet + ',' + actualAcc.BillingCity + ',' + actualAcc.BillingState + ',' + actualAcc.BillingPostalCode + ',' + actualAcc.BillingCountry ;
                
                
                // summComments
                summComments += 'Account Owner-' +  actualAcc.Owner.Name + ';';
                
                if(actualAcc.Owner.Name != 'NSC ADMIN' && actualAcc.Owner.Name != 'ADMIN NSC') {
                    summComments += 'Owner Active-' + actualAcc.Owner.isActive + ';';
                }
            } 
            
            
            List<Object> closeOppDetail = closedOppMap.get(am.Input_Account_Id__c);
            List<Object> openOppDetail = openOppMap.get(am.Input_Account_Id__c);  
            
            if(closeOppDetail != null && closeOppDetail.size() > 0) {
                Object closeOppCount = closeOppDetail.get(0);
                Object  maxOppEBD = closeOppDetail.get(1);
                am.Closed_Opportunity_Count__c = (closeOppCount != NULL) ? integer.valueOf(closeOppCount) : 0;
                
                am.Closed_Opp_Max_Created_Date__c = (maxOppEBD != NULL) ? Date.valueOf(maxOppEBD) : null;
                childRecordCount += (integer)am.Closed_Opportunity_Count__c;  
                
                if(am.Closed_Opportunity_Count__c > 0) {
                    summComments += 'Closed Opp Count-' +  am.Closed_Opportunity_Count__c + ';' + 'Closed Opp Max EBD-' + Datetime.newInstance(am.Closed_Opp_Max_Created_Date__c.year(), am.Closed_Opp_Max_Created_Date__c.month(),am.Closed_Opp_Max_Created_Date__c.day()).format('yyyy-MM-dd') + ';';
                }
            }
            
            if(openOppDetail != null && openOppDetail.size() > 0) {
                Object openOppCount = openOppDetail.get(0);    
                Object maxOppEBD = openOppDetail.get(1);
                
                am.Open_Opportunity_Count__c = (openOppCount != NULL) ? integer.valueOf(openOppCount) : 0;
                am.Open_Opp_Max_Created_Date__c = (maxOppEBD != NULL) ? Date.valueOf(maxOppEBD) : null;
                childRecordCount += (integer)am.Open_Opportunity_Count__c; 
                
                if(am.Open_Opportunity_Count__c > 0) {
                    summComments += 'Open Opp Count-' +  am.Open_Opportunity_Count__c + ';' + 'Open Opp Max EBD-' + Datetime.newInstance(am.Open_Opp_Max_Created_Date__c.year(), am.Open_Opp_Max_Created_Date__c.month(),am.Open_Opp_Max_Created_Date__c.day()).format('yyyy-MM-dd') + ';';
                }
            }
            
            List<AccountTeamMember> atmList = accountTeamMap.get(am.Input_Account_Id__c);
            
            
            am.Account_Team_Member_Count__c = (atmList != NULL) ? atmList.size() : 0; 
            //am.Zuora_Objects_Comments__c = '';
            //am.PRM_Comments__c = '';
            am.Related_Opp_Record__c = '';
            
            //childRecordCount += (integer)am.Account_Team_Member_Count__c;
            
            for(String objectFieldName : sObjectandAccountIdMap.keySet()) {
                Map<String, List<sObject>> AccountIdMap = sObjectandAccountIdMap.get(objectFieldName);
                List<sObject> childRecList = AccountIdMap.get(am.Input_Account_Id__c);
                childRecordCount += (childRecList != null) ? childRecList.size() : 0;               
                
                switch on objectFieldName {
                    
                    when 'Account.ParentId' {
                        List<sObject> parentchildAccList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.No_of_ParentId_Childs__c  = (parentchildAccList!= null) ? parentchildAccList.size() : 0;
                        
                        if(am.No_of_ParentId_Childs__c > 0) {
                            summComments += 'Child Accts Count-' + am.No_of_ParentId_Childs__c + ';';
                        }
                    }
                    
                    when 'Task.AccountId' {
                        List<sObject> openTaskList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Open_Task_Count__c  = (openTaskList!= null) ? openTaskList.size() : 0;
                        
                        if(am.Open_Task_Count__c > 0) {
                            summComments += 'Open Tasks Count-' + am.Open_Task_Count__c + ';';
                        }
                    }
                    
                    when 'Event.AccountId' {
                        List<sObject> openEventList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Open_Event_Count__c  = (openEventList!= null) ? openEventList.size() : 0;
                        
                        if(am.Open_Event_Count__c > 0) {
                            summComments += 'Open Events Count-' + am.Open_Event_Count__c + ';';
                        }
                    }
                    
                    
                    when  'Account.Primary_Partner__c' {
                        List<sObject> primaryPartnerChildList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Primary_Partner_Child_Account_Count__c  = (primaryPartnerChildList!= null) ? primaryPartnerChildList.size() : 0; 
                        
                        if(am.Primary_Partner_Child_Account_Count__c > 0) {
                            summComments += 'Primary Partnr Contact Count-' + am.Primary_Partner_Child_Account_Count__c + ';';
                        }
                    }
                    
                    when 'Case.AccountId' {
                        List<sObject> childCaseList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Case_Count__c = (childCaseList != NULL) ? childCaseList.size() : 0;    
                        
                        if( am.Case_Count__c > 0) {
                            summComments += 'Direct Case Count-' + am.Case_Count__c + ';';
                        }
                    }
                    when 'Case.HOSPD_Account_Name__c' {
                        List<sObject> HOSPCaseChildCount = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Case_HOSP_Count__c = (HOSPCaseChildCount != NULL) ? HOSPCaseChildCount.size() : 0;    
                        
                        if(am.Case_HOSP_Count__c  > 0) {
                            summComments += 'Indirect Case Count-' + am.Case_HOSP_Count__c + ';';
                        }
                    }
                    when 'Campaign_Activity__c.Account_Name__c' {
                        List<sObject> campActivityList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Campaign_Activity_Count__c = (campActivityList != NULL) ? campActivityList.size() : 0;
                        
                        if(am.Campaign_Activity_Count__c  > 0) {
                            summComments += 'Campaign Activity Count-' + am.Campaign_Activity_Count__c + ';';
                        }
                    }
                    when 'Contract.AccountId' {
                        List<sObject> CFSContractList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.CFS_Contract_Count__c = (CFSContractList != NULL) ? CFSContractList.size() : 0;
                        
                        if(am.CFS_Contract_Count__c > 0) {
                            summComments += 'CFS Contract Count-' + am.CFS_Contract_Count__c + ';';
                        }
                        
                    }
                    when 'Contact.AccountId' {
                        List<sObject> contactList = AccountIdMap.get(am.Input_Account_Id__c);                        
                        am.Contact_Count__c = (contactList != NULL) ? contactList.size() : 0;  
                        
                        if(am.Contact_Count__c > 0) {
                            summComments += 'Contact Count-' + am.Contact_Count__c + ';';
                        }
                    }
                    when  'Partner_Maturity_Level__c.Account__c' {
                        List<sObject> partnerMatList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Partner_Maturity_Count__c = (partnerMatList != NULL) ? partnerMatList.size() : 0;  
                        
                        if(am.Partner_Maturity_Count__c > 0) {
                            summComments += 'Partner Maturuty Count-' + am.Partner_Maturity_Count__c + ';';
                        }
                    }  
                    when  'Credit_Detail__c.Account__c' {
                        List<sObject> crdDetailList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Credit_Detail_Count__c = (crdDetailList != NULL) ? crdDetailList.size() : 0; 
                        
                        if(am.Credit_Detail_Count__c > 0) {
                            summComments += 'Credit Detail Count-' + am.Credit_Detail_Count__c + ';';
                        }
                    }    
                    /*when  'Customer_Temperature__c.Account__c' {
                        List<sObject> custTempList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Customer_Temp_Count__c = (custTempList != NULL) ? custTempList.size() : 0;  
                        
                        if(am.Customer_Temp_Count__c > 0) {
                            summComments += 'Customer Temp Count-' + am.Customer_Temp_Count__c + ';';
                        }
                    }*/   
                    when 'zqu__Quote__c.zqu__Account__c' {
                        List<zqu__Quote__c> quoteList = (List<zqu__Quote__c>) AccountIdMap.get(am.Input_Account_Id__c);
                        am.ZQuote_Count__c = (quoteList != NULL) ? quoteList.size() : 0;  
                        
                        if(quoteList != NULL) {
                            Date maxCreatedDate = NULL;                           
                            for(zqu__Quote__c quote : quoteList) {                           
                                if(maxCreatedDate == NULL || quote.CreatedDate.date() > maxCreatedDate) {
                                    maxCreatedDate =  quote.CreatedDate.date();   
                                }     
                            }  
                            am.Zuora_Objects_Comments__c += 'ZQuote:' + Datetime.newInstance(maxCreatedDate.year(), maxCreatedDate.month(),maxCreatedDate.day()).format('yyyy-MM-dd') + ';';
                        }
                    } 
                    /*when 'Customer_Linkage__c.Account__c' {
                        List<sObject> custLinkageList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Customer_Linkage_Count__c = (custLinkageList != NULL) ? custLinkageList.size() : 0;     
                    }*/
                    when 'zqu__QuoteRatePlanCharge__c.SupportChannelPartnerLkp__c' {
                        List<zqu__QuoteRatePlanCharge__c> QRPC_SCPList = (List<zqu__QuoteRatePlanCharge__c>) AccountIdMap.get(am.Input_Account_Id__c);
                        am.QRPC_SupportChannelPartner_Count__c = (QRPC_SCPList != NULL) ? QRPC_SCPList.size() : 0;     
                        
                        if(QRPC_SCPList != NULL) {
                            Date maxCreatedDate = NULL; 
                            for(zqu__QuoteRatePlanCharge__c qrpc : QRPC_SCPList) {                           
                                if(maxCreatedDate == NULL || qrpc.CreatedDate.date() > maxCreatedDate) {
                                    maxCreatedDate =  qrpc.CreatedDate.date();   
                                }     
                            } 
                            am.Zuora_Objects_Comments__c += 'ZQRPC Support Partner:' + Datetime.newInstance(maxCreatedDate.year(), maxCreatedDate.month(),maxCreatedDate.day()).format('yyyy-MM-dd') + ';';
                        }
                    } 
                    when  'zqu__QuoteRatePlanCharge__c.ChannelPartner_Lkp__c' {
                        List<zqu__QuoteRatePlanCharge__c> QRPC_CPList =  (List<zqu__QuoteRatePlanCharge__c>) AccountIdMap.get(am.Input_Account_Id__c);
                        am.QRPC_ChannelPartner_Count__c = (QRPC_CPList != NULL) ? QRPC_CPList.size() : 0;  
                        
                        if(QRPC_CPList != NULL) {
                            Date maxCreatedDate = NULL;                          
                            for(zqu__QuoteRatePlanCharge__c qrpc : QRPC_CPList) {                           
                                if(maxCreatedDate == NULL || qrpc.CreatedDate.date() > maxCreatedDate) {
                                    maxCreatedDate =  qrpc.CreatedDate.date();   
                                }     
                            }
                            am.Zuora_Objects_Comments__c += 'ZQRPC Sales Partner:' + Datetime.newInstance(maxCreatedDate.year(), maxCreatedDate.month(),maxCreatedDate.day()).format('yyyy-MM-dd') + ';';
                        }
                    } 
                    when 'zqu__QuoteCharge__c.ChannelPartner_Lkp__c' {
                        List<zqu__QuoteCharge__c> QC_CPList = (List<zqu__QuoteCharge__c>) AccountIdMap.get(am.Input_Account_Id__c);
                        am.Quote_Charge_Channel_Partner_Count__c = (QC_CPList != NULL) ? QC_CPList.size() : 0;     
                        
                        if(QC_CPList != NULL) {
                            Date maxCreatedDate = NULL;                           
                            for(zqu__QuoteCharge__c qrpc : QC_CPList) {                           
                                if(maxCreatedDate == NULL || qrpc.CreatedDate.date() > maxCreatedDate) {
                                    maxCreatedDate =  qrpc.CreatedDate.date();   
                                }     
                            } 
                            am.Zuora_Objects_Comments__c += 'ZQC Channel Partner:' + Datetime.newInstance(maxCreatedDate.year(), maxCreatedDate.month(),maxCreatedDate.day()).format('yyyy-MM-dd') + ';';
                        }
                        
                        if(String.isNotBlank(am.Zuora_Objects_Comments__c )) {
                            summComments += 'Zuora Comments-' + am.Zuora_Objects_Comments__c + ';';
                        }
                    } 
                    
                    
                    
                    when 'prmsf__Pramata_Contract__c.prmsf__Account__c' {
                        List<sObject> PrmContList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Pramata_Contract_Count__c = (PrmContList != NULL) ? PrmContList.size() : 0;  
                        
                        if(am.Pramata_Contract_Count__c > 0) {
                            summComments += 'Pramata Contract Count-' + am.Pramata_Contract_Count__c + ';';
                        }                       
                    }
                    when  'prmsf__Pramata_Contract_Account_Assoc__c.prmsf__Account__c' {
                        List<sObject> PrmAssContList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Pramata_Contract_Assoc_Count__c = (PrmAssContList != NULL) ? PrmAssContList.size() : 0;
                        
                        if(am.Pramata_Contract_Assoc_Count__c > 0) {
                            summComments += 'Pramata Contract Assoc count-' + am.Pramata_Contract_Assoc_Count__c + ';';
                        }   
                    } 
                    when 'echosign_dev1__SIGN_Recipients__c.echosign_dev1__Person_Account__c'{
                        List<sObject> recpentList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Esign_Recipient_Count__c = (recpentList != NULL) ? recpentList.size() : 0; 
                        
                        if(am.Esign_Recipient_Count__c > 0) {
                            summComments += 'Esign_Recipient_Count-' + am.Esign_Recipient_Count__c + ';';
                        }
                    } 
                    when 'echosign_dev1__SIGN_Agreement__c.echosign_dev1__Account__c' {
                        List<echosign_dev1__SIGN_Agreement__c> agreementList = (List<echosign_dev1__SIGN_Agreement__c>) AccountIdMap.get(am.Input_Account_Id__c);
                        am.Esign_Agreement_Count__c = (agreementList != NULL) ? agreementList.size() : 0;  
                        
                        
                        if(am.Esign_Agreement_Count__c > 0) {
                            summComments += 'Esign Agreement Count -' + am.Esign_Agreement_Count__c + ';';
                        }
                        
                        if(agreementList != NULL) {
                            Date maxCreatedDate = NULL;                           
                            for(echosign_dev1__SIGN_Agreement__c agreement : agreementList) {                           
                                if(maxCreatedDate == NULL || agreement.CreatedDate.date() > maxCreatedDate) {
                                    maxCreatedDate =  agreement.CreatedDate.date();   
                                }     
                            } 
                            am.Esign_Agreement_Max_CreatedDate__c = Datetime.newInstance(maxCreatedDate.year(), maxCreatedDate.month(),maxCreatedDate.day()).format('yyyy-MM-dd');  
                        }
                    }
                    when 'Zuora__ZInvoice__c.Zuora__Account__c' {
                        List<sObject> invoiceList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.ZInvoice_Count__c = (invoiceList != NULL) ? invoiceList.size() : 0;    
                        
                        if(am.ZInvoice_Count__c > 0) {
                            summComments += 'Zuora Invoice Count -' + am.ZInvoice_Count__c + ';';
                        }
                    }
                    when 'Zuora__Subscription__c.Zuora__Account__c' {
                        List<sObject> subscrpList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.ZSubscription_Count__c  = (subscrpList != NULL) ? subscrpList.size() : 0;   
                        
                        if(am.ZSubscription_Count__c > 0) {
                            summComments += 'Zuora Subscription  Count -' + am.ZSubscription_Count__c + ';';
                        }
                    }
                    when  'Zuora__SubscriptionRatePlan__c.Zuora__Account__c' {
                        List<sObject> SubRPList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.ZSubscription_RP_Count__c = (SubRPList != NULL) ? SubRPList.size() : 0;
                        
                        if(am.ZSubscription_RP_Count__c > 0) {
                            summComments += 'Zuora Subscription Rate Plan Count -' + am.ZSubscription_RP_Count__c + ';';
                        }
                    }
                    when  'Provisioning__c.Account__c' {
                        List<sObject> ProvList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Provisioning_Count__c = (ProvList != NULL) ? ProvList.size() : 0;     
                        
                        if(am.Provisioning_Count__c > 0) {
                            summComments += 'Provisioning Count -' + am.Provisioning_Count__c + ';';
                        }
                    }
                    
                    when 'Pricing_Bid_Log__c.Customer__c' {
                        List<sObject> PblList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Pricing_Bid_Log_Count__c = (PblList != NULL) ? PblList.size() : 0;
                        
                        if(am.Pricing_Bid_Log_Count__c > 0) {
                            summComments += 'Pricing_Bid_Log  Count -' + am.Pricing_Bid_Log_Count__c + ';';
                        }
                    }
                    /*when 'Project__c.Accounts__c' { 
                        List<sObject> projectList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Project_Count__c = (projectList != NULL) ? projectList.size() : 0;        
                    }*/
                    
                    when 'Presales_Engineer_Activity__c.PSE_Account__c' { 
                        List<sObject> PSEList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.PresalesEngineerActivity_Count__c = (PSEList != NULL) ? PSEList.size() : 0;
                        
                        if(am.PresalesEngineerActivity_Count__c > 0) {
                            summComments += 'PresalesEngineerActivity Count -' + am.PresalesEngineerActivity_Count__c + ';';
                        }
                    }
                    when 'Zuora__CustomerAccount__c.Zuora__Account__c' { 
                        List<sObject> BillAccList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Billing_Account1__c = (BillAccList != NULL) ? BillAccList.size() : 0;
                        
                        if(am.Billing_Account1__c > 0) {
                            summComments += 'Direct Bill_Account Count -' + am.Billing_Account1__c + ';';
                        }
                    }
                    when 'Zuora__CustomerAccount__c.Channel_Office__c' { 
                        List<sObject> BillAccList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Billing_Account2__c = (BillAccList != NULL) ? BillAccList.size() : 0; 
                        
                        if(am.Billing_Account2__c > 0) {
                            summComments += 'Indirect Bill_Account Count -' + am.Billing_Account2__c + ';';
                        }
                    }
                    when 'User.AccountId' { 
                        List<sObject> UserList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Account_User_Count__c = (UserList != NULL) ? UserList.size() : 0; 
                        
                        if(am.Account_User_Count__c > 0) {
                            summComments += 'Related User Count -' + am.Account_User_Count__c + ';';
                        }
                    }
                    when 'Support_Desk__c.Master_Customer_Name__c'{ 
                        List<sObject> NeedHelpList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Need_Help_Account1_Count__c = (NeedHelpList != NULL) ? NeedHelpList.size() : 0; 
                        
                        if(am.Need_Help_Account1_Count__c > 0) {
                            summComments += 'Need Help1 Count -' + am.Need_Help_Account1_Count__c + ';';
                        }
                    }
                    when 'Support_Desk__c.Account_Name_2__c' { 
                        List<sObject> NeedHelpList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Need_Help_Account2_Count__c = (NeedHelpList != NULL) ? NeedHelpList.size() : 0;
                        
                        if(am.Need_Help_Account2_Count__c > 0) {
                            summComments += 'Need Help2 Count -' + am.Need_Help_Account2_Count__c + ';';
                        }
                    }
                    when 'Support_Desk__c.Account_Name3__c' { 
                        List<sObject> NeedHelpList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Need_Help_Account3_Count__c = (NeedHelpList != NULL) ? NeedHelpList.size() : 0; 
                        
                        if(am.Need_Help_Account3_Count__c > 0) {
                            summComments += 'Need Help3 Count -' + am.Need_Help_Account3_Count__c + ';';
                        }
                    }
                    when  'Support_Desk__c.Account_Name_4__c' {
                        List<sObject> NeedHelpList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Need_Help_Account4_Count__c = (NeedHelpList != NULL) ? NeedHelpList.size() : 0; 
                        
                        if(am.Need_Help_Account4_Count__c > 0) {
                            summComments += 'Need Help4 Count -' + am.Need_Help_Account4_Count__c + ';';
                        }
                    }
                    when 'Support_Desk__c.Account_Name_5__c' { 
                        List<sObject> NeedHelpList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Need_Help_Account5_Count__c = (NeedHelpList != NULL) ? NeedHelpList.size() : 0;
                        
                        if(am.Need_Help_Account5_Count__c > 0) {
                            summComments += 'Need Help5 Count -' + am.Need_Help_Account5_Count__c + ';';
                        }
                        
                    }
                    when 'Opportunity.Channel_Office__c' { 
                        List<Opportunity> ChOff_OppList = (List<Opportunity>) AccountIdMap.get(am.Input_Account_Id__c);
                        am.Channel_Office_Opp_Count__c = (ChOff_OppList != NULL) ? ChOff_OppList.size() : 0; 
                        
                        
                        if(ChOff_OppList != NULL) {
                            Date oppMaxEBD = NULL;                           
                            for(Opportunity opp : ChOff_OppList) {                           
                                if(oppMaxEBD == NULL || opp.CloseDate > oppMaxEBD) {
                                    oppMaxEBD =  opp.CloseDate;   
                                }     
                            } 
                            am.Related_Opp_Record__c += 'Channel Office :' + Datetime.newInstance(oppMaxEBD.year(), oppMaxEBD.month(),oppMaxEBD.day()).format('yyyy-MM-dd') + ';';  
                        }
                        
                        
                    }
                    when 'Opportunity.End_Customer__c' { 
                        List<Opportunity> EndCustAccList = (List<Opportunity>)AccountIdMap.get(am.Input_Account_Id__c);
                        am.End_Customer_Opp_Count__c = (EndCustAccList != NULL) ? EndCustAccList.size() : 0; 
                        
                        if(EndCustAccList != NULL) {
                            Date oppMaxEBD = NULL;                           
                            for(Opportunity opp : EndCustAccList) {                           
                                if(oppMaxEBD == NULL || opp.CloseDate > oppMaxEBD) {
                                    oppMaxEBD =  opp.CloseDate;   
                                }     
                            } 
                            am.Related_Opp_Record__c += 'End Customer :'+ Datetime.newInstance(oppMaxEBD.year(), oppMaxEBD.month(),oppMaxEBD.day()).format('yyyy-MM-dd') + ';';  
                        }
                    }
                    when 'Opportunity.Master_Distributor__c' { 
                        List<Opportunity> MD_AccList = (List<Opportunity>)AccountIdMap.get(am.Input_Account_Id__c);
                        am.Master_Distributor_Opp_Count__c = (MD_AccList != NULL) ? MD_AccList.size() : 0; 
                        
                        if(MD_AccList != NULL) {
                            Date oppMaxEBD = NULL;                           
                            for(Opportunity opp : MD_AccList) {                           
                                if(oppMaxEBD == NULL || opp.CloseDate > oppMaxEBD) {
                                    oppMaxEBD =  opp.CloseDate;   
                                }     
                            } 
                            am.Related_Opp_Record__c += 'Master Distributor:' + Datetime.newInstance(oppMaxEBD.year(), oppMaxEBD.month(),oppMaxEBD.day()).format('yyyy-MM-dd') + ';';  
                        }
                    }
                    when 'Opportunity.Reseller__c' { 
                        List<Opportunity> resellOppList = (List<Opportunity>)AccountIdMap.get(am.Input_Account_Id__c);
                        am.Reseller_Opp_Count__c = (resellOppList != NULL) ? resellOppList.size() : 0; 
                        
                        if(resellOppList != NULL) {
                            Date oppMaxEBD = NULL;                           
                            for(Opportunity opp : resellOppList) {                           
                                if(oppMaxEBD == NULL || opp.CloseDate > oppMaxEBD) {
                                    oppMaxEBD =  opp.CloseDate;   
                                }     
                            } 
                            am.Related_Opp_Record__c += 'Reseller:' + Datetime.newInstance(oppMaxEBD.year(), oppMaxEBD.month(),oppMaxEBD.day()).format('yyyy-MM-dd') + ';';  
                        }
                        
                        if(String.isNotBlank(am.Related_Opp_Record__c )) {
                            summComments += 'Related Opp Record-' + am.Related_Opp_Record__c + ';';
                        }
                    }
                    
                    
                    
                    when 'Solution_Provider_Relationship__c.Account_Id__c' { 
                        List<sObject> sprList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Solution_Provider_Relationship_Count__c = (sprList != NULL) ? sprList.size() : 0; 
                        
                        if(am.Solution_Provider_Relationship_Count__c > 0) {
                            summComments += 'Sol Prov Rel Count -' + am.Solution_Provider_Relationship_Count__c + ';';
                        }
                        
                    }     
                    When 'QuBy_Detail__c.Account__c' {
                        List<QuBy_Detail__c> QubyQuoteList = (List<QuBy_Detail__c>) AccountIdMap.get(am.Input_Account_Id__c);
                        am.Quby_Quote_Count__c = (QubyQuoteList  != NULL) ? QubyQuoteList .size() : 0; 
                        
                        if(am.Quby_Quote_Count__c > 0) {
                            summComments += 'Quby Quote Count -' + am.Quby_Quote_Count__c + ';';
                        }
                        
                        
                        //GET MAX QUBY QUOTE MODIFICATION DATE
                        Datetime maxSolModDate = NULL;
                        String maxModQubyQuoteNo=''; 
                        String QubyOppDetail='';
                        
                        if(QubyQuoteList  != NULL) {
                            for(QuBy_Detail__c qt : QubyQuoteList) {
                                String quoteNbr = qt.Quote_Number__c; String AccountId = qt.Account__c;
                                Datetime solModDate = qt.Solution_Modification_Date__c;String OppNumber = qt.Opportunity__r.Opportunity_Number__c;
                                String oppStageName = qt.Opportunity__r.StageName; Date oppEBD = qt.Opportunity__r.CloseDate;
                                
                                if(OppNumber != NULL) {
                                    String oppDetail =  (quoteNbr +  '-Opp:' + OppNumber + '-EBD:' + oppEBD + ';');
                                    QubyOppDetail += oppDetail;
                                }
                                
                                
                                if(solModDate != null) {
                                    if((maxSolModDate == null) || (solModDate > maxSolModDate)) {
                                        maxSolModDate = solModDate;
                                        maxModQubyQuoteNo = quoteNbr;
                                    }                   
                                }
                            }      
                        }
                        
                        if(maxSolModDate != NULL) {
                            am.Max_Modification_Date_Quby_Quote__c = maxSolModDate;
                            am.Max_Date_Quby_Quote_No__c = maxModQubyQuoteNo;
                        }
                        
                        if(QubyOppDetail != null) {
                            am.Quby_Quote_Opportunities__c = QubyOppDetail;
                        }
                    } 
                    
                    when  'PRM_Services__c.Account_Name__c' {
                        List<sObject> prmServicesList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.PRM_Services_Count__c = (prmServicesList != null) ? prmServicesList.size() : 0;
                        
                        if (prmServicesList != NULL && prmServicesList.size() > 0) {
                            am.PRM_Comments__c += 'PRM Services Count -' + prmServicesList.size() + ';';
                        }
                        
                    }   
                    
                    When  'Performance_Scoreboard__c.Account__c' {
                        List<sObject> prmScoresList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.Performance_Scorebaord_Count__c = (prmScoresList != null) ? prmScoresList.size() : 0;
                        
                        if (prmScoresList != NULL && prmScoresList.size() > 0) {
                            am.PRM_Comments__c +='Performance Scoreboard Count -' + prmScoresList.size() + ';';
                        }
                    }
                    
                    When  'Engineers__c.Partner_Account__c' {
                        List<sObject> engnrList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.PRM_Enginner_Count__c = (engnrList != null) ? engnrList.size() : 0;
                        
                        if (engnrList != NULL && engnrList.size() > 0) {
                            am.PRM_Comments__c +='PRM Engineer Count -' + engnrList.size() + ';';
                        }
                        
                        
                    }
                    
                    When  'SFDC_MDF__c.Account__c' {
                        List<sObject> fundReqList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.PRM_MDF_Request_Count__c = (fundReqList != null) ? fundReqList.size() : 0;
                        
                        
                        if (fundReqList != NULL && fundReqList.size() > 0) {
                            am.PRM_Comments__c += 'MDF Fund Request Count -' + fundReqList.size() + ';';
                        }
                    }
                    
                    When  'Equipment_Declaration__c.Partner_Account__c' {
                        List<sObject> EqDecList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.PRM_Equipment_Count__c = (EqDecList != null) ? EqDecList.size() : 0;
                        
                        if (EqDecList != NULL && EqDecList.size() > 0) {
                            am.PRM_Comments__c += 'Equipment Declaration Count -' + EqDecList.size() + ';';
                        }
                    }
                    
                    When   'Deal_Registration__c.Partner_Company_Name__c' {
                        List<sObject> DealRegList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.PRM_Deal_Registration_Count__c= (DealRegList != null) ? DealRegList.size() : 0;
                        
                        if (DealRegList != NULL && DealRegList.size() > 0) {
                            am.PRM_Comments__c += 'Deal Registration Count -' + DealRegList.size() + ';';
                        }
                    }
                    
                    When   'Expansion_Request__c.Account_Name__c' {
                        List<sObject> ExpansionReqList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.PRM_Expansion_Request_Count__c = (ExpansionReqList != null) ? ExpansionReqList.size() : 0;
                        
                        if (ExpansionReqList != NULL && ExpansionReqList.size() > 0) {
                            am.PRM_Comments__c += 'Expansion Request Count -' + ExpansionReqList.size() + ';';
                        }
                        
                    }
                    
                    When   'Incentive_Program_Enrollment__c.Account__c' {
                        List<sObject> IncenProgEnrollList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.PRM_Incentive_Program_Count__c = (IncenProgEnrollList != null) ? IncenProgEnrollList.size() : 0;
                        
                        if (IncenProgEnrollList != NULL && IncenProgEnrollList.size() > 0) {
                            am.PRM_Comments__c += 'Incentive_Program_Enrollment__c Count -' + IncenProgEnrollList.size() + ';';
                        }
                        
                    }
                    
                    When   'Incentive_Program_Exception_Account__c.Account__c' {
                        List<sObject> IncenProgExcepActList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.PRM_Incentive_Program_Exception_Count__c = (IncenProgExcepActList != null) ? IncenProgExcepActList.size() : 0;
                        
                        if (IncenProgExcepActList != NULL && IncenProgExcepActList.size() > 0) {
                            am.PRM_Comments__c += 'Incentive_Program_Exception_Account__c Count -' + IncenProgExcepActList.size() + ';';
                        }
                        
                    }
                    
                    When   'Marketing_Concierge__c.Partner_Company__c' {
                        List<sObject> markConList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.PRM_Marketing_Concierge_Count__c = (markConList != null) ? markConList.size() : 0;
                        
                        if (markConList != NULL && markConList.size() > 0) {
                            am.PRM_Comments__c += 'Marketing_Concierge__c Count -' + markConList.size() + ';';
                        }
                        
                    }
                    
                    When   'Partner_Opportunity__c.Partner_Account__c' {
                        List<sObject> partOppList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.PRM_Partner_Opportunity_Count__c = (partOppList != null) ? partOppList.size() : 0;
                        
                        if (partOppList != NULL && partOppList.size() > 0) {
                            am.PRM_Comments__c += 'Partner_Opportunity__c Count -' + partOppList.size() + ';';
                        }
                        
                    }
                    
                    When   'RMA__c.Account__c' {
                        List<sObject> rmaList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.PRM_RMA_Count__c = (rmaList != null) ? rmaList.size() : 0;
                        
                        if (rmaList != NULL && rmaList.size() > 0) {
                            am.PRM_Comments__c += 'RMA__c Count -' + rmaList.size() + ';';
                        }
                        
                    }
                    
                    When   'SFDC_Budget__c.Account__c' {
                        List<sObject> budgetList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.PRM_SFDC_Budget_Count__c = (budgetList != null) ? budgetList.size() : 0;
                        
                        if (budgetList != NULL && budgetList.size() > 0) {
                            am.PRM_Comments__c += 'SFDC_Budget__c count -' + budgetList.size() + ';';
                        }
                    }
                    
                    When   'SFDC_MDF_Claim__c.Account__c' {
                        List<sObject> claimList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.PRM_MDF_Claim_Count__c = (claimList != null) ? claimList.size() : 0;
                        
                        if (claimList != NULL && claimList.size() > 0) {
                            am.PRM_Comments__c += 'MDF Claim Count -' + claimList.size() + ';';
                        }
                        
                    }
                    
                    When   'Demo_Program__c.Partner_Account__c' {
                        List<sObject> demoList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.PRM_Demo_Program_Count__c = (demoList != null) ? demoList.size() : 0;
                        
                        if (demoList != NULL && demoList.size() > 0) {
                            am.PRM_Comments__c += 'Demo List Count -' + demoList.size() + ';';
                        }
                        
                    }
                    
                    When   'Co_Op__c.Account__c' {
                        List<sObject> coOpList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.PRM_Co_OP_Count__c = (coOpList != null) ? coOpList.size() : 0;
                        
                        if (coOpList != NULL && coOpList.size() > 0) {
                            am.PRM_Comments__c += 'Co Op Count -' + coOpList.size() + ';';
                        }
                        
                    }
                    
                    When   'Certification__c.Account__c' {
                        List<sObject> certList = AccountIdMap.get(am.Input_Account_Id__c);
                        am.PRM_Certification_Count__c = (certList != null) ? certList.size() : 0;                        
                        
                        if (certList != NULL && certList.size() > 0) {
                            am.PRM_Comments__c += 'Partner Certification -' + certList.size() + ';';
                        }
                    }
                    
                    When   'Account_Exception__c.Partner_Account_Name__c' {
                        List<sObject> actExcepLst = AccountIdMap.get(am.Input_Account_Id__c);
                        am.PRM_Account_Exception_Count__c = (actExcepLst != null) ? actExcepLst.size() : 0;
                        
                        if (actExcepLst != NULL && actExcepLst.size() > 0) {
                            am.PRM_Comments__c += 'Account Exception Count -' + actExcepLst.size() + ';';
                        }
                        
                        
                        if(String.isNotBlank(am.PRM_Comments__c )) {
                            summComments += 'PRM Comments-' + am.PRM_Comments__c + ';';
                        }
                    }
                    
                    
                } // switch - case
                
                
            } //  out relationship name
            
            if(childRecordCount == 0) {
                am.Comments__c = summComments + 'No Related Record found';
            } else {
                am.Comments__c = summComments;
            }
            
        } // out account 
        
        
        // FINAL update
        update accMasterList;
        
    }
    
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    
    global  Map<String, List<Object>> getClosedOpptyMap(Set<String> inputAccountIds) {
        //4. CLOSED OPPORTUNITY - AccountId
        Map<String, List<Object>> closedOppMap = new Map<String, List<Object>>();
        List<AggregateResult> closedOppResult = [SELECT count(Id) oppCount, Max(Closedate) maxEBD, AccountId  from Opportunity where isClosed = true AND AccountId IN :inputAccountIds group by AccountId];
        
        for(AggregateResult agg : closedOppResult) {
            Object oppcount = agg.get('oppCount');
            String AccId = (String )agg.get('AccountId');
            Object oppMaxEBD =  agg.get('maxEBD');
            List<Object> tempList = new List<Object>{oppcount, oppMaxEBD};
                closedOppMap.put(AccId, tempList);
        }
        return closedOppMap;
    }
    
    
    global  Map<String,  List<Object>> getOpenOpptyMap(Set<String> inputAccountIds) {
        Map<String, List<Object>> openOppMap = new Map<String, List<Object>> ();
        List<AggregateResult> openOppResult = [SELECT count(Id) oppCount, Max(Closedate) maxEBD, AccountId  from Opportunity where isClosed = false  AND AccountId IN :inputAccountIds group by AccountId];
        
        for(AggregateResult agg : openOppResult) {
            Object oppcount = agg.get('oppCount');
            String AccId = (String )agg.get('AccountId');
            Object oppMaxEBD =  agg.get('maxEBD');
            List<Object> tempList = new List<Object>{oppcount, oppMaxEBD};
                openOppMap.put(AccId, tempList);
        }
        return openOppMap;
    }
    
    global Map<Id, List<AccountTeamMember>> getAccountTeamMap(Set<String> inputAccountIds) {
        Map<Id, List<AccountTeamMember>> accountTeamMap = new Map<Id, List<AccountTeamMember>>();       
        for(AccountTeamMember atm :[SELECT Id, AccountId FROM AccountTeamMember WHERE AccountId IN :inputAccountIds and UserId != NULL ]) {
            List<AccountTeamMember> tempList = accountTeamMap.get(atm.AccountId);
            
            if(tempList ==  NUll) {
                tempList = new List<AccountTeamMember>();  
            } 
            tempList.add(atm);
            accountTeamMap.put(atm.AccountId, tempList);
        }
        return accountTeamMap;
    }
    
    
    
}