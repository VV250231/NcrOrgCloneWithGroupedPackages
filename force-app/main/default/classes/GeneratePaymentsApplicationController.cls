/*************************************************************************************************
*   ClassName :   GeneratePaymentsApplicationController
*   Description : This is controller class of LWC component GeneratePaymentsApplicationButton
*   Author      : Monika
# Modification History.: 
Story No#       Date            DevName            Description
EBA_SF-2024		9-9-2022		Monika	   Payment Processing: Option to Withdraw Payments Application (Non-CPQ) 
*************************************************************************************************/

public without sharing class GeneratePaymentsApplicationController{
    @AuraEnabled
    public static OpportunityLineItem getOpportunity(String oppId){
        
        Set<String> JPUserSet = new Set<String>();
        Set<String> JPProfileSet = new Set<String>();
        Set<String> JPRoleSet = new Set<String>();
        String currentUserId = '';
        String currentUserProfile = '';
        String currentUserRole = ''; 
        Boolean validJPUser = false;
        Boolean allowAllUser = false; 
        
        //system.debug('OppId ---->'+oppId);
        JetPay_Access__c JPAccessObj = JetPay_Access__c.getValues('Record1');
        List<JetPay_Access__c> JPAccessObjL = JetPay_Access__c.getall().values();

        
        if(JPAccessObjL.size()>0){
            for(JetPay_Access__c jpa:JPAccessObjL){
                if(String.isNotBlank(jpa.Specific_Users__c)){
                    for(String JPUser : jpa.Specific_Users__c.split(',')){
                        JPUserSet.add(JPUser.trim().toUpperCase());                    
                    }
                }
                
                if(String.isNotBlank(jpa.Specific_Profiles__c)){
                    for(String JPProfile : jpa.Specific_Profiles__c.split(',')){
                        JPProfileSet.add(JPProfile.trim().toUpperCase());                    
                    }
                }
                
                if(String.isNotBlank(jpa.Specific_Roles__c)){
                    for(String JPRole : jpa.Specific_Roles__c.split(',')){
                        JPRoleSet.add(JPRole.trim().toUpperCase());                    
                    }
                } 
                // if any of the record has flag true set it true.
                if(jpa.Allow_All_Users__c)
                    allowAllUser = true;
            }            
            ////system.debug('Allo All'+allowAllUser);
            ////system.debug('user Set'+JPUserSet.size());        
            if(!allowAllUser){
                
                if(!JPUserSet.isEmpty() || !JPProfileSet.isEmpty() || !JPRoleSet.isEmpty() ){
                    Id userId = userinfo.getUserId();
                    User userDetails =[SELECT Id, Name,Quicklook_ID__c,Profile.Name, UserRole.Name FROM User where Id=:userId ];
                    if(String.isNotBlank(userDetails.Quicklook_ID__c)){
                        currentUserId = userDetails.Quicklook_ID__c.toUpperCase();   
                    }
                    if(String.isNotBlank(userDetails.Profile.Name)){
                        currentUserProfile = userDetails.Profile.Name.toUpperCase();
                    }
                    if(String.isNotBlank(userDetails.UserRole.Name)){
                        currentUserRole = userDetails.UserRole.Name.toUpperCase();      
                    }                   
                    //system.debug('___currentUserId__'+currentUserId+'__currentUserProfile__'+currentUserProfile+'__currentUserRole__'+currentUserRole); 
                    if(!JPUserSet.isEmpty()){
                        //system.debug('here1');
                        if(JPUserSet.contains(currentUserId)){
                            validJPUser= true;  
                            //system.debug('---1');
                        }
                    }
                    if(!validJPUser && !JPProfileSet.isEmpty()){
                        if(JPProfileSet.contains(currentUserProfile)){
                            validJPUser= true; 
                            //system.debug('---2');
                        }
                    }
                    if(!validJPUser && !JPRoleSet.isEmpty()){
                        if(JPRoleSet.contains(currentUserRole)){
                            validJPUser= true;  
                            //system.debug('---3');
                        }
                    }
                }
            }
        }
        else{
            validJPUser = true;
            
        }
        
        Set<String> NcrPaymentPrcessingProductSet = new Set<String>();
        NCR_Payments_Processing__mdt paymentProcessingProducts = new NCR_Payments_Processing__mdt();
        if(validJPUser){
            paymentProcessingProducts =[select id, ProductId__c, FieldApi__c  from NCR_Payments_Processing__mdt limit 1];  
            //Ajay
            if(String.isNotBlank(paymentProcessingProducts.Id)){
                if(paymentProcessingProducts.ProductId__c != null && String.isNotBlank(paymentProcessingProducts.ProductId__c)){
                    for(String PId : paymentProcessingProducts.ProductId__c.split(',')){
                        NcrPaymentPrcessingProductSet.add(PId.trim().toUpperCase());
                    }
                }
            }  
        }
        
        OpportunityLineItem OppLineItemOb = new OpportunityLineItem();
        //system.debug('_____NcrPaymentPrcessingProductSet'+NcrPaymentPrcessingProductSet+'_____oppId'+oppId);
        //OppLineItemOb = [SELECT id, Opportunity.AccountId, Opportunity.NCR_Payment_Pricing_Approve__c, Opportunity.Pricing_Review_Request_Status__c FROM OpportunityLineItem WHERE Revenue_Type__c IN : NcrPaymentPrcessingProductSet AND OpportunityId =: oppId][0];
        if(!NcrPaymentPrcessingProductSet.isEmpty()){
            OppLineItemOb = [SELECT id,Opportunity.CloseDate, Opportunity.AccountId, Opportunity.Pricing_Review_Request_Status__c FROM OpportunityLineItem WHERE Revenue_Type__c IN : NcrPaymentPrcessingProductSet AND OpportunityId =: oppId AND Opportunity.RecordType.Name='Include in Funnel'][0];
        }
        return OppLineItemOb; 
    }
    @AuraEnabled(cacheable=true)
    public static List<BillingSitesWrapper> getSearchBillingList(string searchKey,String accntId) {
        string sTempSearchKey = '%' + searchKey + '%';
        
        //system.debug('___in get billing sites'+accntId);
        if(String.isNotBlank(accntId)){
            Account acc = [Select Master_Customer_Number__c FROM Account where Id =: accntId];
            if(acc.Master_Customer_Number__c != null){
                List<BillingSitesWrapper> wrapsiteWrapList = new List<BillingSitesWrapper>();
                if(String.isNotBlank(searchKey)){
                    /*for(Zuora__CustomerAccount__c obj : [Select Id, Name,Address__c,City__c,State__c,Zuora__BillToState__c,Zuora__BillToPostalCode__c,Zuora__BillToCountry__c, ERPSiteNumber__c, Zuora__Status__c,cdm_Store_Branch_Number__c FROM Zuora__CustomerAccount__c where Zuora__Account__c =: acc.Id and (Name like :sTempSearchKey or State__c like :sTempSearchKey or City__c like :sTempSearchKey)  order by Name limit 500]){
BillingSitesWrapper wrapObj = new BillingSitesWrapper(obj, false);
wrapsiteWrapList.add(wrapObj);
} */
                    
                    for(Account obj : [Select Id, Name,BillingAddress,BillingStreet,BillingCity,BillingCountry,BillingState,
                                       BillingPostalCode,Site_Number__c,cdm_Store_Branch_Number__c FROM Account 
                                       where ParentId =: acc.Id and Recordtype.Name='Site'
                                       and (Name like :sTempSearchKey or BillingState like :sTempSearchKey or BillingCity like :sTempSearchKey)  
                                       order by Name limit 500]){
                                           BillingSitesWrapper wrapObj = new BillingSitesWrapper(obj, false);
                                           wrapsiteWrapList.add(wrapObj);
                                       } 
                }
                else{
                    for(Account obj : [Select Id, Name,BillingAddress,BillingStreet,BillingCity,BillingState,BillingPostalCode,Site_Number__c,cdm_Store_Branch_Number__c FROM Account
                                       where ParentId =: acc.Id and Recordtype.Name='Site' order by Name limit 500]){
                                           BillingSitesWrapper wrapObj = new BillingSitesWrapper(obj, false);
                                           wrapsiteWrapList.add(wrapObj);
                                       }   
                }
                return wrapsiteWrapList;
            }
            //system.debug('Master Customer Number is Null For Account');
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer getTotalBillingSites(String accId){
        Integer totalSites= [Select count() FROM Account where Id =: accId and Recordtype.Name='Site'];
        return totalSites;
    }
    @AuraEnabled(cacheable=true)
    public static List<BillingSitesWrapper> getBillingSites(String accId){
        //system.debug('___in get billing sites'+accId);
        if(String.isNotBlank(accId)){
            Account acc = [Select Master_Customer_Number__c FROM Account where Id =: accId];
            if(acc.Master_Customer_Number__c != null){
                List<BillingSitesWrapper> wrapsiteWrapList = new List<BillingSitesWrapper>();
                
                
                /*for(Zuora__CustomerAccount__c obj : [Select Id, Name,Address__c,City__c,State__c,Zuora__BillToState__c,
Zuora__BillToPostalCode__c,Zuora__BillToCountry__c, ERPSiteNumber__c, //sitenumber
Zuora__Status__c,cdm_Store_Branch_Number__c FROM Zuora__CustomerAccount__c //stor 
where Zuora__Account__c =: acc.Id order by Name limit 500]){    // Account */
                
                for(Account obj : [Select Id, Name,BillingAddress,BillingStreet,BillingCity,BillingCountry,BillingState,
                                   BillingPostalCode,Site_Number__c,cdm_Store_Branch_Number__c //ERPSiteNumber__c, Zuora__Status__c,cdm_Store_Branch_Number__c  //sitenumber
                                   FROM Account where ParentId =: acc.Id and Recordtype.Name='Site' order by 
                                   Name limit 500]){    // Account                  
                                       BillingSitesWrapper wrapObj = new BillingSitesWrapper(obj, false);
                                       wrapsiteWrapList.add(wrapObj);                                                                                                                                                                                                                                                                                               }
                return wrapsiteWrapList;
            }
            //system.debug('Master Customer Number is Null For Account');
        }
        return null;
    }
    
    @AuraEnabled
    public static Task  AssignTasktoQueue(String OpportunityId){
        //system.debug('Opportunity Id for Task >> '+OpportunityId);
        if(String.isNotBlank(OpportunityId)){
            
            Opportunity opp = [Select Id, Name, Opportunity_Number__c, Pricing_Review_Request_Status__c FROM Opportunity Where Id =: OpportunityId];
            opp.Pricing_Review_Request_Status__c = 'Pending';
            opp.Initial_Pricing_Review_Submission_Date__c=System.now();
            update opp;
            
            Request_Payments_Review_Queue__mdt Queue = new Request_Payments_Review_Queue__mdt();
            Queue =[select id,QueueId__c  from Request_Payments_Review_Queue__mdt limit 1];
            if((String.isNotBlank(Queue.QueueId__c)) && (isCreateable('Task')==true)){
                Task t = new Task(); 
                t.OwnerId = Queue.QueueId__c;
                t.Subject = 'New Pricing Review Request for: '+opp.Opportunity_Number__c +' Raised By '+' '+UserInfo.getFirstName()+' '+ UserInfo.getLastName();
                t.Status = 'Open';  
                t.Priority = 'Normal';   
                t.WhatId = OpportunityId;
                t.IsReminderSet=true;
                Database.DMLOptions notifyOption = new Database.DMLOptions();
                notifyOption.EmailHeader.triggerUserEmail = true;
                notifyOption.optAllOrNone=true;
                // we need to use the Database.insert() with the DMLOptions to insert the task instead of using the standard insert DML command
                Database.insert(t, notifyOption);
                //insert t;
                return t;  
            }
            
        }
        return null;
    }
    
    @AuraEnabled
    public static Task  requestRateReviewUpdate(String OpportunityId){
        if(String.isNotBlank(OpportunityId)){
            
            Opportunity opp = [Select Id, Name, Opportunity_Number__c, Pricing_Review_Request_Status__c FROM Opportunity Where Id =: OpportunityId];
            opp.Pricing_Review_Request_Status__c = 'Rate Review Request';
            update opp;
            
            Request_Payments_Review_Queue__mdt Queue = new Request_Payments_Review_Queue__mdt();
            Queue =[select id,QueueId__c  from Request_Payments_Review_Queue__mdt limit 1];
            if((String.isNotBlank(Queue.QueueId__c)) && (isCreateable('Task')==true)){
                Task t = new Task(); 
                t.OwnerId = Queue.QueueId__c;
                t.Subject = 'Pricing Review Request for Rate Review: '+opp.Opportunity_Number__c +' Raised By '+' '+UserInfo.getFirstName()+' '+ UserInfo.getLastName();
                t.Status = 'Open';  
                t.Priority = 'Normal';   
                t.WhatId = OpportunityId;
                t.IsReminderSet=true;
                Database.DMLOptions notifyOption = new Database.DMLOptions();
                notifyOption.EmailHeader.triggerUserEmail = true;
                notifyOption.optAllOrNone=true;
                // we need to use the Database.insert() with the DMLOptions to insert the task instead of using the standard insert DML command
                Database.insert(t, notifyOption);
                //insert t;
                return t;  
            }
            
        }
        return null;
    }
    public static Boolean isCreateable(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isCreateable();
    }
    
    @AuraEnabled
    public static ApprovePricingResponse updatePricingApprove(String oppId){
        ApprovePricingResponse resp=new ApprovePricingResponse();
        if(oppId != null){
            try{
                Opportunity opp = [Select Id, Pricing_Review_Request_Status__c, Pricing_Type__c, Payment_Sales_Offer__c, Pricing_Approver_Name__c FROM Opportunity Where Id =: oppId];
                resp.opp=opp;
                //validate Pricing Type
                if(opp.Pricing_Type__c==null || opp.Payment_Sales_Offer__c == null){
                    resp.errorMsg='Please select pricing type and payment sales offer in the NCR Payments Fee Details section.';
                    return resp;
                }
                List<Task> taskListToUpdate = new List<Task>();
                for(Task obj : [Select Id, WhatId  FROM Task Where WhatId =: oppId AND Status != 'Closed/Complete' AND Subject Like '%Pricing Review Request%']){
                    obj.status = 'Closed/Complete';
                    taskListToUpdate.add(obj);
                }
                opp.Pricing_Review_Request_Status__c = 'Approve';
                opp.Pricing_Approver_Name__c = 'Approved By:'+[Select Id, Name FROM User Where Id =: UserInfo.getUserId()].Name+' On '+System.now();
                update opp;
                if(!taskListToUpdate.isEmpty()){
                    update taskListToUpdate;
                }   
                return resp;
            }catch (exception e){
                resp.errorMsg='Exception Occured:'+e;
                return resp; 
            }           
            
        }
        return null;
    }
    @AuraEnabled
    public static ApprovePricingResponse updatePricingReject(String oppId){
        ApprovePricingResponse resp=new ApprovePricingResponse();
        if(oppId != null){
            try{
                Opportunity opp = [Select Id, Pricing_Review_Request_Status__c, Pricing_Type__c, Pricing_Approver_Name__c FROM Opportunity Where Id =: oppId];
                resp.opp=opp;            
                List<Task> taskListToUpdate = new List<Task>();
                for(Task obj : [Select Id, WhatId  FROM Task Where WhatId =: oppId AND Status != 'Closed/Complete' AND Subject Like '%Pricing Review Request%']){
                    obj.status = 'Closed/Complete';
                    taskListToUpdate.add(obj);
                }
                opp.Pricing_Review_Request_Status__c = 'Reject';
                opp.Pricing_Approver_Name__c = 'Rejected By:'+[Select Id, Name FROM User Where Id =: UserInfo.getUserId()].Name+' On '+System.now();
                update opp;
                if(!taskListToUpdate.isEmpty()){
                    update taskListToUpdate;
                }   
                return resp;
            }catch (exception e){
                resp.errorMsg='Exception Occured:'+e;
                return resp; 
            }           
            
        }
        return null;
    }
    
    @AuraEnabled
    public static ApprovePricingResponse updateMoreInfoProvided(String oppId){
        ApprovePricingResponse resp=new ApprovePricingResponse();
        if(oppId != null){
            try{
                Opportunity opp = [Select Id, Pricing_Review_Request_Status__c, Pricing_Type__c, Pricing_Approver_Name__c FROM Opportunity Where Id =: oppId];
                resp.opp=opp;            
                List<Task> taskListToUpdate = new List<Task>();
                for(Task obj : [Select Id, WhatId  FROM Task Where WhatId =: oppId AND Status != 'Closed/Complete' AND Subject Like '%Pricing Review Request: More Information%']){
                    obj.status = 'Closed/Complete';
                    taskListToUpdate.add(obj);
                }
                opp.Pricing_Review_Request_Status__c = 'More Information Provided';
                update opp;
                if(!taskListToUpdate.isEmpty()){
                    update taskListToUpdate;
                }   
                return resp;
            }catch (exception e){
                resp.errorMsg='Exception Occured:'+e;
                return resp; 
            }           
            
        }
        return null;
    }
    @AuraEnabled
    public static ApprovePricingResponse updatePricingWithdraw(String oppId){
        ApprovePricingResponse resp=new ApprovePricingResponse();
        if(oppId != null){
            try{
                Opportunity opp = [Select Id, Pricing_Review_Request_Status__c, Pricing_Type__c, Pricing_Approver_Name__c FROM Opportunity Where Id =: oppId];
                resp.opp=opp;            
                List<Task> taskListToUpdate = new List<Task>();
                for(Task obj : [Select Id, WhatId  FROM Task Where WhatId =: oppId AND Status != 'Closed/Complete' AND Subject Like '%Pricing Review Request%']){
                    obj.status = 'Closed/Complete';
                    taskListToUpdate.add(obj);
                }
                opp.Pricing_Review_Request_Status__c = 'Withdrawn';
                update opp;
                if(!taskListToUpdate.isEmpty()){
                    update taskListToUpdate;
                } 
                return resp;
            }catch (exception e){
                resp.errorMsg='Exception Occured:'+e;
                return resp; 
            }           
            
        }
        return null;
    }
    
    @AuraEnabled
    public static  Task  updateMoreInfo(String OpportunityId){
        if(String.isNotBlank(OpportunityId)){
            
            Opportunity opp = [Select Id,OwnerId, Name, Opportunity_Number__c, Pricing_Review_Request_Status__c, Pricing_More_Info_Reason__c FROM Opportunity Where Id =: OpportunityId];
            opp.Pricing_Review_Request_Status__c = 'More Information Requested';
            update opp;            
            if((isCreateable('Task')==true)){
                Task t = new Task(); 
                t.OwnerId = opp.OwnerId;
                t.Subject = 'Pricing Review Request: More Information for '+opp.Opportunity_Number__c +' To Provide '+' '+opp.Pricing_More_Info_Reason__c;
                t.Status = 'Open';  
                t.Priority = 'Normal';   
                t.WhatId = OpportunityId;
                t.IsReminderSet=true;
                Database.DMLOptions notifyOption = new Database.DMLOptions();
                notifyOption.EmailHeader.triggerUserEmail = true;
                notifyOption.optAllOrNone=true;
                // we need to use the Database.insert() with the DMLOptions to insert the task instead of using the standard insert DML command
                Database.insert(t, notifyOption);
                //insert t;
                return t;  
            }
            
        }
        return null;
    }
    @AuraEnabled
    public static Opportunity getOppRecord(String oppId){
        Opportunity opp = [Select Id,  Pricing_Review_Request_Status__c FROM Opportunity Where Id =: oppId];
        opp.Pricing_Review_Request_Status__c = 'Pending';
        //  opp.NCR_Payment_Pricing_Approve__c = false;
        update opp;
        return opp;
    }
    
    @AuraEnabled
    public static List<Task> getRelatedTask(String oppId){
        List<Task> taskList = new List<Task>();
        taskList = [Select Id, WhatId  FROM Task Where WhatId =: oppId AND Status != 'Closed/Complete' AND Subject Like '%Pricing Review Request%'];
        return taskList;
    }
    @AuraEnabled
    public static QteWrapper valQteInfo(Id QteId){
        SBQQ__Quote__c Qte;
        List<NCR_Payments_Site__c> MultiQuotePaymentSites;
        List<String> errStr=new List<string>();
        
        if(!String.isBlank(QteId)){
            Qte = [Select id,SBQQ__Account__c,SBQQ__Account__r.Parent.Customer_Number__c, Name, POS__c,SBQQ__Opportunity2__r.Channel_Office__c,SBQQ__Opportunity2__r.Channel_Office__r.Payments_Agent_ID__c,SBQQ__Opportunity2__r.Channel_Office__r.Name,Deliver_To_Site__c,Deliver_To_Site__r.Name,Deliver_To_Site__r.Site_Number__c, Deliver_To_Site__r.cdm_Store_Branch_Number__c,SBQQ__PrimaryContact__c,SBQQ__PrimaryContact__r.Name, SBQQ__PrimaryContact__r.Phone,SBQQ__PrimaryContact__r.Email,
            Existing_Payments_Customer__c, (Select id, SBQQ__ListPrice__c, SBQQ__ProductCode__c, qtc_Pricing_Type__c,qtc_Basis_Points__c, qtc_Annual_Volume__c, qtc_Average_Check__c from SBQQ__LineItems__r where Service_Offer_Category__c='Payments Processing') from SBQQ__Quote__c   where id=:QteId];
        }

        if (Qte.Existing_Payments_Customer__c == 'Yes') {
            throw new AuraHandledException('Cannot Generate Payment Application for Existing Payments Customer quotes');
        }

        SBQQ__Quote__c quoteRec = CPQ_InfiniCeptCallouts.getQuoteDetail(QteId);
        MultiQuotePaymentSites = CPQ_InfiniCeptCalloutHelper.getPaymentSites(QteId);
        boolean dupSites=CPQ_InfiniCeptCalloutHelper.checkDuplicateSites(MultiQuotePaymentSites);
        if (quoteRec.qtc_Multi_Site__c) {
            if(quoteRec.qtc_Number_of_Sites_with_Payments__c!=quoteRec.NCR_Payments_Sites__r.size()){
                errStr.add('Number of Sites does not match NCR Payment Site record count.'); 
            }
            if(dupSites){
                errStr.add('Duplicate NCR Payments Site detected. Please remove the duplicate before continuing.'); 
            }
            
        } else {
            List<NCR_Payments_Site__c> nps=[Select id, Name, Quote__c, Account_Sites__r.Name, Account_Sites__r.Site_Number__c, MID__c, TID__c, NCR_Payments_Application_Status__c from NCR_Payments_Site__c where Quote__c =:QteId AND NCR_Payments_Application_Status__c != 'Withdrawn'];
            if(nps.size()>0){
                return new QteWrapper(nps[0]);    
            }
        }
        
        
        
        if(Qte.SBQQ__Account__r.Parent!=null && !String.isEmpty(Qte.SBQQ__Account__r.Parent.Customer_Number__c) && (Qte.SBQQ__Account__r.Parent.Customer_Number__c.equals('41181899'))){
            errStr.add('Unable to send payments application on account that has not been properly defined. Please update customer record in CDM or work with sales operations.');  
        }
        
        if(!(Qte.SBQQ__LineItems__r.size()>0)){
            errStr.add('This Quote doesnt contains NCR Payments, Application cannot be generated for this quote.');  
        }
        if(String.isEmpty(Qte.POS__c)){
            errStr.add('POS/Product Descriptor is missing on Quote.');
        }
        //Channel Office
        if(String.isEmpty(Qte.SBQQ__Opportunity2__r.Channel_Office__c)){
            errStr.add('Channel Office is missing on Opportunity.');
        }
        else if(String.isEmpty(Qte.SBQQ__Opportunity2__r.Channel_Office__r.Payments_Agent_ID__c)){
            errStr.add('Payments Agent Id is not assigned to Channel Office, Contact Salesforce Admin.');
        }
         
        //Deliver_To_Site__c,Deliver_To_Site__r.Name,Deliver_To_Site__r.Site_Number__c
        if(String.isEmpty(Qte.Deliver_To_Site__c)){
            errStr.add('Deliver To Site is not specified on Quote.');
        }else if(String.isEmpty(Qte.Deliver_To_Site__r.Site_Number__c)){
            errStr.add('Site Number is missing on Deliver to site selected on Quote.');
        }            
        
        return new QteWrapper(Qte,errStr,MultiQuotePaymentSites);
    }
    @AuraEnabled
    public static String sndApplFmQte(String QteId){
        String response='';
        if(!String.isBlank(QteId)){
            SBQQ__Quote__c quoteRec = CPQ_InfiniCeptCallouts.getQuoteDetail(QteId); response = CPQ_InfiniCeptCallouts.submitAppRequest(QteId);
        }
        return response;
    }
    @AuraEnabled
    public static ApplicationResponseWrapper sendApplication(String oppId, String billingAccs){
        if(!String.isBlank(oppId)){
            Opportunity opp = [Select Id, Pricing_Review_Request_Status__c, Pricing_Approver_Name__c FROM Opportunity Where Id =: oppId];    
            String response=JP_OutBoundOnBoardingService.initiateMerchantOnboarding(oppId,billingAccs);
            ApplicationResponseWrapper resposeWrap = new ApplicationResponseWrapper(opp,response);
            return resposeWrap;
        }
        return null;
    }
    //Method created for eba-sf-2024
    @AuraEnabled
     public static RejResponseWrapper withdrawnApplication(String oppId,  String msg){
          if(!String.isBlank(oppId)){
              system.debug('oppIdoppIdoppIdoppId');
            Set<Id> pymSiteIds = new Set<Id>();
            Opportunity opp = [Select Id, Pricing_Review_Request_Status__c, Pricing_Approver_Name__c FROM Opportunity Where Id =: oppId]; 
            for(NCR_Payments_Site__c ns :[Select id from NCR_Payments_Site__c where Opportunity__c =:oppId and  NCR_Payments_Application_Status__c !='Approved' and NCR_Payments_Application_Status__c !='ApprovedAndBoarded' and NCR_Payments_Application_Status__c !='Declined'  and NCR_Payments_Application_Status__c !='AcquirerReview' and NCR_Payments_Application_Status__c !='Withdrawn']){
                pymSiteIds.add(ns.id);
            }                   
            String response=JP_OutBoundOnBoardingService.initiateAppWithdrawn(oppId,pymSiteIds, msg);
            RejResponseWrapper resposeWrap = new RejResponseWrapper(opp,response);
            return resposeWrap;
        }
         return null;
    }
    
    //Edit by Yogesh 
    @AuraEnabled
    public static List<Task> getRelatedTaskStatus(String oppId){
        List<Task> taskList = new List<Task>();
        List<Task> updatedTaskList = new List<Task>();
        Map<Id,Opportunity> oppMap = new Map<Id, Opportunity>();
        for(Opportunity oppObj : [Select id , Pricing_Review_Request_Status__c from Opportunity where id =:oppId]){
            oppMap.put(oppObj.id, oppObj);
        }
        taskList = [Select Id, WhatId FROM Task Where WhatId  =: oppId AND Subject Like '%Pricing Review Request%' ];
        for(Task taskObj : taskList){
            if(oppMap.get(taskObj.WhatId).Pricing_Review_Request_Status__c =='Approve'){
                updatedTaskList.add(new Task(id=taskObj.id, Status='Closed/Complete'));
            }
        }
        update updatedTaskList;
        return updatedTaskList;
    }
    
    //Changes done for eba-sf-2024
    @AuraEnabled(cacheable=false)
    public static EnableButtonWrapper executeButtonsStatusCalculation(String oppId){
        Boolean enableGenerateButton=false;
        Boolean enableWithdrawnButton=false;
        //Integer chkst;
        Boolean ch=false;
        String enableWithdrawnButtonReason='';
        Boolean enableReqPricingButton = false;
        Boolean showAppoveButton=false;
        String GenerateButtonDisableReason='';
        String ReviewButtonDisableReason='';
        String approverMessage='';
        Integer totalSites=0;
        Set<String> userSet=new Set<String>();
        Opportunity opp= new Opportunity();
        //identifying pricing Approvers
        Request_Payments_Review_Queue__mdt Queue = new Request_Payments_Review_Queue__mdt();
        Queue =[select id,QueueId__c  from Request_Payments_Review_Queue__mdt limit 1];
        List<GroupMember> userList=  [Select UserOrGroupId From GroupMember where GroupId=:Queue.QueueId__c];
        for(GroupMember user:userList){
            userSet.add(user.UserOrGroupId);
        }
        String currentUser= UserInfo.getUserId(); 
        //if Current user approver showAppoveButton=true   
        if(!userSet.isEmpty() && userSet.contains(currentUser)){           
            showAppoveButton=true;           
        }
        
        // Get Opportunity Details and Sites
        if(!String.isBlank(oppId)){
            opp = [Select Id,Pricing_Type__c, Payment_Sales_Offer__c, AccountId,Account.Name,Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.Master_Customer_Number__c, Account.BillingCountry, POS__c,Contacts__c,Contacts__r.Email,Contacts__r.Phone,Channel_Office__c, Channel_Office__r.Payments_Agent_ID__c,Pricing_Review_Request_Status__c,Pricing_Approver_Name__c, Total_Annual_Transactions__c, Total_Annual_Volume__c, Pricing_More_Info_Reason__c, Pricing_Team_Comments__c, Pricing_Reject_Reason_Comments__c, Pricing_Rate_Review_Comments__c, Initial_Pricing_Review_Submission_Date__c, Pricing_Analyst__c FROM Opportunity Where Id =: oppId];
            totalSites= [select count() from NCR_Payments_Site__c where Opportunity__c=:oppId AND NCR_Payments_Application_Status__c != 'Withdrawn'];
            //To validate if any site has status other thn  Approved, ApprovedandBoarded, or Declined than ch=true(Withdraw Payments Application button activated)
            for(NCR_Payments_Site__c sites : [select NCR_Payments_Application_Status__c from NCR_Payments_Site__c where Opportunity__c=:oppId]){
                if((sites.NCR_Payments_Application_Status__c  !='Approved' && sites.NCR_Payments_Application_Status__c  !='ApprovedAndBoarded') && sites.NCR_Payments_Application_Status__c  !='Declined' && sites.NCR_Payments_Application_Status__c  !='AcquirerReview' && sites.NCR_Payments_Application_Status__c  !='Withdrawn' ){
                    ch = true;
                    break;
                }
            }
        }
        //validate Pricing Type
        if(opp.Pricing_Type__c==null || opp.Payment_Sales_Offer__c == Null){
            approverMessage='Note: Before approving, please make sure to select pricing type and payments sales offers in the NCR Payments Fee Details section.';
        }else{
            approverMessage=''; 
        }
        
        //identified Sites to set Generate and Review buttons
        if(totalSites==0){
            
            if(opp.Pricing_Review_Request_Status__c==null || opp.Pricing_Review_Request_Status__c=='Reject' || opp.Pricing_Review_Request_Status__c=='Withdrawn'){
                enableReqPricingButton=true;  
            }
            //Find Request Pricing Disable reason  
            
            if(enableReqPricingButton) {
                if(opp.Total_Annual_Volume__c==null || opp.Total_Annual_Transactions__c==null||opp.POS__c==null){
                    enableReqPricingButton=false;
                    String fields='';
                    if(opp.Total_Annual_Volume__c==null){
                        if(!String.isEmpty(fields)){
                            fields=fields+', '+'Total Annual Volume ($)';
                        }else{
                            fields='Total Annual Volume ($)';
                        }
                    }
                    if(opp.Total_Annual_Transactions__c==null){
                        if(!String.isEmpty(fields)){
                            fields=fields+', '+'Total Annual Transactions (#)';
                        }else{
                            fields='Total Annual Transactions (#)';
                        }
                    }
                    if(opp.POS__c==null){
                        if(!String.isEmpty(fields)){
                            fields=fields+', '+'POS';
                        }else{
                            fields='POS';
                        }
                    }
                    ReviewButtonDisableReason='Please complete NCR Payments Detail section fields:'+fields;
                }else{
                    enableReqPricingButton=true;
                }
            }else{
                enableReqPricingButton=false;
            }
            
        }
        else{
            enableGenerateButton=false;
            enableReqPricingButton=false;
        }
        if(opp!=null && showAppoveButton==false){
            if(opp.Pricing_Review_Request_Status__c=='Approve' ){
                enableGenerateButton=true; 
            }else{
                enableGenerateButton=false;
                if(opp.Pricing_Review_Request_Status__c==null || opp.Pricing_Review_Request_Status__c==''){
                    GenerateButtonDisableReason=' Pricing Review Required to proceed.';  
                } else if(opp.Pricing_Review_Request_Status__c=='Pending' || opp.Pricing_Review_Request_Status__c=='More Info Provided'){
                    GenerateButtonDisableReason=' Awaiting Pricing Review Approval.';   
                }
                else if(opp.Pricing_Review_Request_Status__c=='More Information Requested'){
                    GenerateButtonDisableReason=' Pricing Team is waiting for more Info.';   
                }
                else if(opp.Pricing_Review_Request_Status__c=='More Information Provided'){
                    GenerateButtonDisableReason=' Requested Information was provided, Waiting on Pricing Team Review and Approval.';   
                }
                else if(opp.Pricing_Review_Request_Status__c=='Reject'){
                    GenerateButtonDisableReason=' Pricing Team Rejected the Pricing.';   
                }
                else if(opp.Pricing_Review_Request_Status__c=='Withdrawn'){
                    GenerateButtonDisableReason=' Pricing Review Request was withdrawn.';   
                }else if(opp.Pricing_Review_Request_Status__c=='Rate Review Request'){
                    GenerateButtonDisableReason=' Rate Review was requested on Approved pricing, Awaiting Rate Review Approval by Pricing Team.';   
                }else{
                    GenerateButtonDisableReason=' Awaiting Pricing Review Approval.';
                }
                
                
                
            } 
            //validate disable reason if Generate button true
            if(enableGenerateButton==true){
                if(totalSites>0){
                    GenerateButtonDisableReason='Payments Application already sent for '+totalSites+' Site(s)'; 
                }
                else if(opp.Account.BillingStreet==null || opp.Account.BillingCity==null || opp.Account.BillingState==null || opp.Account.BillingPostalCode==null){
                    GenerateButtonDisableReason='Corporate Address for Account:'+opp.Account.Name+' is incomplete, Please complete Corporate Address.';
                }else if(opp.POS__c==null){
                    GenerateButtonDisableReason='To Submit the Request please fill POS value First.';
                    
                }
                /*else if(opp.Contacts__c==null && opp.Channel_Office__c==null){
GenerateButtonDisableReason='Primary Contact  and Channel Office need to be selected in Opportunity.';

}else if(opp.Contacts__c==null){
GenerateButtonDisableReason='Primary Contact need to be selected in Opportunity.';

}else if(opp.Contacts__c!=null && opp.Contacts__r.Phone==null){
GenerateButtonDisableReason='Please populate the Phone number on the primary contact record to proceed.';

} else if(opp.Contacts__c!=null && opp.Contacts__r.Email==null){
GenerateButtonDisableReason='Primary Contact Email is blank, Please populate Email.';

} */else if(opp.Channel_Office__c==null){
    GenerateButtonDisableReason='Please select the Channel Office under the Details section to proceed.';
    
}else if(opp.Channel_Office__c!=null && opp.Channel_Office__r.Payments_Agent_ID__c==null){
    GenerateButtonDisableReason='The Channel Office selected does not have an assigned Agent ID, please contact Salesforce Admin.';
    
}else if(getBillingSites(opp.AccountId)==null || getBillingSites(opp.AccountId).size()==0){
    GenerateButtonDisableReason='There are currently no billing sites associated with this account.';
    
}else{
    GenerateButtonDisableReason='You are good to proceed with initiating Payments Application.';
}
                // Message says !Good then disable
                if(!GenerateButtonDisableReason.containsIgnoreCase('Good')){
                    enableGenerateButton=false;
                }
                if(GenerateButtonDisableReason.containsIgnoreCase('Already') && ch ==true){
                    enableGenerateButton= false;
                    enableWithdrawnButton = true;
                }
                if(GenerateButtonDisableReason.containsIgnoreCase('Already') && ch ==false){
                    enableGenerateButton=false;
                    enableWithdrawnButton = false;
                }
            }
            
        }
        
        //populate response
        EnableButtonWrapper btnWrapper =new EnableButtonWrapper(enableGenerateButton,enableWithdrawnButton,opp,showAppoveButton,enableReqPricingButton, GenerateButtonDisableReason, ReviewButtonDisableReason, approverMessage);
        return btnWrapper;
    }
    //End By Yogesh Changes
    public class BillingSitesWrapper {
        @AuraEnabled public Account billingSite{get;set;}
        @AuraEnabled public Boolean isAdded{get;set;}
        
        public BillingSitesWrapper(Account billingSite, Boolean isAdded) {
            this.billingSite = billingSite;
            this.isAdded = isAdded;
        }
    }
    public class ApprovePricingResponse {
        @AuraEnabled public Opportunity opp{get;set;}
        @AuraEnabled public String errorMsg{get;set;}
        public ApprovePricingResponse() {
            
        }
        
        public ApprovePricingResponse(Opportunity opp, String errorMsg) {
            this.opp = opp;
            this.errorMsg = errorMsg;
        }
    }
    public class QteWrapper {
        @AuraEnabled public SBQQ__Quote__c Qte{get;set;}
        @AuraEnabled public List<String> res{get;set;}
        @AuraEnabled public List<NCR_Payments_Site__c> MultiQtePaymentSites{get;set;}
        @AuraEnabled public NCR_Payments_Site__c nps{get;set;}
        public QteWrapper(SBQQ__Quote__c Qte, List<String> res, List<NCR_Payments_Site__c> MultiQtePaySites) {
            this.Qte = Qte;
            this.res = res;
            this.MultiQtePaymentSites = MultiQtePaySites;
        }
        public QteWrapper(NCR_Payments_Site__c nps) {
            this.nps = nps;
        }
    }
    public class ApplicationResponseWrapper {
        @AuraEnabled public Opportunity opp{get;set;}
        @AuraEnabled public String res{get;set;}
        
        public ApplicationResponseWrapper(Opportunity opp, String res) {
            this.opp = opp;
            this.res = res;
        }
    }
     public class RejResponseWrapper {
        @AuraEnabled public Opportunity opp{get;set;}
        @AuraEnabled public String res{get;set;}
        
        public RejResponseWrapper(Opportunity opp, String res) {
            this.opp = opp;
            this.res = res;
        }
    }
    public class EnableButtonWrapper {
        @AuraEnabled public Boolean enableGenerateButton{get;set;}
        
        @AuraEnabled public Boolean enableWithdrawnButton{get;set;}
        @AuraEnabled public Opportunity opp{get;set;}
        @AuraEnabled public Boolean enableAppoveButton{get;set;}
        @AuraEnabled public Boolean enableReqPricingButton{get;set;}
        @AuraEnabled public String DissableReason{get;set;}
        @AuraEnabled public String DissableReviewReason{get;set;}
        @AuraEnabled public String approverMessage{get;set;}
        
        
        public EnableButtonWrapper(Boolean enableGenerateButton, Boolean enableWithdrawnButton,Opportunity opp,Boolean enableAppoveButton,Boolean enableReqPricingButton,String DissableReason, String DissableReviewReason, String approverMessage) {
            this.enableGenerateButton = enableGenerateButton;
            this.enableWithdrawnButton = enableWithdrawnButton;
            this.opp = opp;
            this.enableAppoveButton=enableAppoveButton;
            this.enableReqPricingButton=enableReqPricingButton;
            this.DissableReason=DissableReason;
            this.DissableReviewReason=DissableReviewReason;
            this.approverMessage=approverMessage;
        }
    }
    
    @auraEnabled
    Public Static List<ContactWrap> GetAllACHContacts(String AccId){
        Set<String> conIdSet= new Set<String>();
        List<ContactWrap> conWrapLst= new List<ContactWrap>();
        
        if(String.isNotBlank(AccId)){
            for(Contact con : [Select id,Name from Contact Where AccountId = :AccId AND Active_Contact__c = TRUE]){
                
                if(!conIdSet.contains(con.Id)){
                    conIdSet.add(con.Id);
                    ContactWrap conObj = new ContactWrap();
                    conObj.ConName=con.Name;
                    conObj.ConId=con.Id;
                    conWrapLst.add(conObj);
                }
                
                
            }
            
            for(AccountContactRelation acr : [Select Contact.id,Contact.Name from AccountContactRelation Where AccountId = :AccId AND Contact.Active_Contact__c = TRUE]){
                if(!conIdSet.contains(acr.Contact.Id)){
                    conIdSet.add(acr.Contact.Id);
                    ContactWrap conObj = new ContactWrap();
                    conObj.ConName=acr.Contact.Name;
                    conObj.ConId=acr.Contact.Id;
                    conWrapLst.add(conObj);
                }
                
            }  
            
        }
        
        
        //system.debug('conWrapLst'+conWrapLst);
        return conWrapLst;
    }
    
    @auraEnabled
    Public Static Contact SavePaymtAsigneOnQte(String ConId,String qid){
        contact conObj = new contact();
        if(String.isNotBlank(ConId)){
            try{
                SBQQ__Quote__c QuoteObj = new SBQQ__Quote__c();
                QuoteObj.id=qid;
                QuoteObj.Payments_Application_Signee__c=ConId;
                Update QuoteObj;
                conObj =[Select id,Name,Email,Phone from contact where id=:QuoteObj.Payments_Application_Signee__c];
            }
            catch(Exception e){
                
            }
            
        }
        return conObj;
    }
    
    public class ContactWrap{
        @auraEnabled
        Public  String ConName;
        @auraEnabled
        Public  String ConId ;
    }
    
    @auraEnabled
    Public Static Contact SavePaymtAsigneOnOpp(String ConId,String OppId){
        contact conObj = new contact();
        if(String.isNotBlank(ConId)){
            try{
                Opportunity oppObj= new Opportunity();
                oppObj.id=OppId;
                oppObj.Payments_Application_Signee__c = ConId;
                Update oppObj;
                conObj =[Select id,Name,Email,Phone from contact where id=:oppObj.Payments_Application_Signee__c];
            }
            catch(Exception e){
                
            }
            
        }
        return conObj;
    }
}