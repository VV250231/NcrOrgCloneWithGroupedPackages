/*
Created By : Pankaj Kashyap(PK185150)
Created Date :   
Version : V1.9
Functionality : 
1-Sent Email Notification to SalesPerson or Account Manager or Customer Success Manager.
2-Share Deming Record To EditShareWithUser/ReadShareWithUser fields.
3-Populate Related Order from EDBI Order
*/

public class CADD_ManagementHandler {
    
    //DemingPrePopulatedData  Trigger Logic starts
        /*
    Created By : Pankaj Kashyap(PK185150)
    Created Date :   
    Version : V1.9
    Functionality : 
    1-Sent Email Notification to SalesPerson or Account Manager or Customer Success Manager.
    2-Share Deming Record To EditShareWithUser/ReadShareWithUser fields.
    3-Populate Related Order from EDBI Order
    */ 
    public static void isBeforeInsert (List<Deming__c> demingTriggerNew, List<Deming__c> demingTriggerOld) {  
        Map<String,String> SalesGlobalId_And_CustomerNoMap = new Map<String,String>();
        Set<String> SalesPersonGlobalId = new Set<String>(); 
        Set<String> MasterCustomerNoSet= new Set<String>();
        Map<String,NCR_Employee_Detail__c> MapOfNCREmp = new Map<String,NCR_Employee_Detail__c>();
        Map<String,Account> MapForAccountManger = new Map<String,Account>();
        Map<String,AccountTeamMember> AccountTeamMap = new Map<String,AccountTeamMember>();
        Map<String,AccountTeamMember> AccountTeamMapForIm = new Map<String,AccountTeamMember>(); //Implementation Cordinator Map
        Set<String> SetForAccountTeamMember = new Set<String>();
        Set<String> SalesOrgCodeSet =  new Set<String>();
        Map<String,Sales_Org_Temp__c > DemingSalesOrgCodeMap = new Map<String,Sales_Org_Temp__c >();
        Map<String,User> QuickLookAndUserMap = new Map<String,User>();
        Set<String> QuickLookSet = new Set<String>();
        Map<String,String> DemingAccountNameMap = new Map<String,String>();
        //Map<String,Decimal> OrderNumberWithAmountMap= new Map<String,Decimal>();
        Set<String> OrderCountryCodeSet = new Set<String>();
        Map<String,String> OrderNumberWithCountryCodeMap= new Map<String,String>();
        Map<String,id> OrderNumberWithOpportunityMap= new Map<String,id>();
        Map<String,String> OrderNumberWithFuaSiteNameMap= new Map<String,String>();
        Map<String,String> OrderNumberWithFuaSiteNbrMap= new Map<String,String>();
        Map<String,String> OrderNumberWithshipToSiteNameMap= new Map<String,String>();
        Map<String,String> OrderNumberWithShipToSiteNbrMap= new Map<String,String>();
        //Map<String,String> OrderNumberWithQuote = new Map<String,String>();
        Map<String,String> quoteNumberWithOpportunityMap= new Map<String,String>();
        Set<String> quoteNumberSet= new Set<String>();
        Set<String> prepondArrivalDateOrder = new Set<String>();
        
        
        for(Deming__c DemObj : demingTriggerNew){
            
            if(String.IsNotBlank(DemObj.SalesPerson_Global_Id__c)){
                
                String[] arrOrdCode = DemObj.SalesPerson_Global_Id__c.split('\\-'); 
                SalesPersonGlobalId.add(arrOrdCode[0]);
                
                if(String.isNotBlank(DemObj.Customer_No__c)){
                    
                    MasterCustomerNoSet.add(DemObj.Customer_No__c);
                }   
                
            }
            
            else if(String.IsEmpty(DemObj.SalesPerson_Global_Id__c) && String.IsNotBlank(DemObj.Customer_No__c)){
                
                MasterCustomerNoSet.add(DemObj.Customer_No__c);
            }
            
            
            
            if(String.IsNotBlank(DemObj.Order_number__c)){
                
                String Temp='';
                
                if(String.isNotBlank(DemObj.Customer_Country_code__c)){
                    
                    Temp=DemObj.Order_number__c+DemObj.Customer_Country_code__c;
                    OrderCountryCodeSet.add(Temp);
                }  
                else{
                    OrderCountryCodeSet.add(DemObj.Order_number__c);
                }
                
            }
            if(String.isNotBlank(DemObj.Quote_Number__c)){
                quoteNumberSet.add(DemObj.Quote_Number__c);  
            }
            
            
            if(String.IsNotBlank(DemObj.SalesOrdCode__c)){
                
                SalesOrgCodeSet.add(DemObj.SalesOrdCode__c); 
                
            }
            if(DemObj.Max_Promise_Date__c<DemObj.RDD__c){
                prepondArrivalDateOrder.add(DemObj.Order_Id__c);  
            }
        }
        
        
        
        if(SalesPersonGlobalId.Size()>0){
            for(NCR_Employee_Detail__c EmpObj : [Select id,Global_ID__c,Quicklook_ID__c,InActive__c from NCR_Employee_Detail__c where Global_ID__c IN : SalesPersonGlobalId and InActive__c=false Limit 50000]){
                
                if(!MapOfNCREmp.containsKey(EmpObj.Global_ID__c)){
                    MapOfNCREmp.put(EmpObj.Global_ID__c,EmpObj); 
                }  
                
                if(String.isNotBlank(EmpObj.Quicklook_ID__c)){
                    QuickLookSet.add(EmpObj.Quicklook_ID__c.toupperCase());
                    
                }
            }
        }
        
        
        if(MasterCustomerNoSet.Size() >0 ){
            for(Account AccObj : [Select id,Name,Master_Customer_Number__c,Owner.Email,Owner.Quicklook_ID__c,Owner.Global_ID__c from Account where Master_Customer_Number__c IN :MasterCustomerNoSet Limit 50000 ]){
                
                
                if(!MapForAccountManger.ContainsKey(AccObj.Master_Customer_Number__c)){ 
                    
                    MapForAccountManger.put(AccObj.Master_Customer_Number__c,AccObj);   
                }
                SetForAccountTeamMember.add(AccObj.Id);
                
                if(String.isNotBlank(AccObj.Owner.Quicklook_ID__c)){
                    QuickLookSet.add(AccObj.Owner.Quicklook_ID__c.toupperCase());
                    
                }  
            }
        }
        
        
        
        if(SetForAccountTeamMember.Size()>0){
            for(AccountTeamMember MemObj : [Select AccountId,Account.Name,TeamMemberRole,Account.Master_Customer_Number__c,UserId,User.Email,User.IsActive,User.Quicklook_ID__c from AccountTeamMember where AccountId IN:SetForAccountTeamMember and ((TeamMemberRole='Customer Success Manager') OR (TeamMemberRole='Implementation Coordinator'))]){
                
                if((!AccountTeamMap.ContainsKey(MemObj.Account.Master_Customer_Number__c)) && (MemObj.TeamMemberRole == 'Customer Success Manager')){
                    AccountTeamMap.put(MemObj.Account.Master_Customer_Number__c,MemObj);
                    QuickLookSet.add(MemObj.User.Quicklook_ID__c.toupperCase());
                }
                
                
                if((!AccountTeamMapForIm.ContainsKey(MemObj.Account.Master_Customer_Number__c)) && (MemObj.TeamMemberRole == 'Implementation Coordinator')){
                    AccountTeamMapForIm.put(MemObj.Account.Master_Customer_Number__c,MemObj);
                    QuickLookSet.add(MemObj.User.Quicklook_ID__c.toupperCase());
                }
                
            }
        }
        
        if(SalesOrgCodeSet.Size() > 0 ){
            
            for(Sales_Org_Temp__c OrdCodeObj : [Select id,Sales_Org_Code__c,Hierarchy_2__c from Sales_Org_Temp__c where Sales_Org_Code__c  IN : SalesOrgCodeSet]){
                
                if(!DemingSalesOrgCodeMap.ContainsKey(OrdCodeObj.Sales_Org_Code__c)){
                    DemingSalesOrgCodeMap.Put(OrdCodeObj.Sales_Org_Code__c,OrdCodeObj);   
                }
            }
        }
        if(quoteNumberSet.size()>0){
            //System.debug('#######quoteNumberSet'+quoteNumberSet);
            for(QuBy_Detail__c quoteOppo:[select Opportunity__c,Quote_Number__c from QuBy_Detail__c where Quote_Number__c in :quoteNumberSet ] ){
                quoteNumberWithOpportunityMap.put(quoteOppo.Quote_Number__c,quoteOppo.Opportunity__c);
                
            }
            //System.debug('#######QuoteNumberMapp'+quoteNumberWithOpportunityMap);
        }
        if(QuickLookSet.size()>0){
            for(User UserObj: [Select id,name,email,Quicklook_ID__c from User where Quicklook_ID__c IN : QuickLookSet and isActive=true]){
                
                if(!QuickLookAndUserMap.ContainsKey(UserObj.Quicklook_ID__c.toupperCase())){
                    
                    QuickLookAndUserMap.put(UserObj.Quicklook_ID__c.toupperCase(),UserObj); 
                    
                }
            }
        }
        if(OrderCountryCodeSet.Size() >0){
            for(EDBI_Order__c EDBIObj : [Select id,fua_site_name__c,fua_site_nbr__c,ship_to_site_name__c,ship_to_site_nbr__c,Opportunity__c,Order_Value_in_Thousand__c,Quote_Number__c,Order_Number_with_Country_Code__c from EDBI_Order__c where Order_Number_with_Country_Code__c IN: OrderCountryCodeSet]){
                
                
                if(String.IsNotBlank(EDBIObj.Order_Number_with_Country_Code__c)  &&  !OrderNumberWithCountryCodeMap.ContainsKey(EDBIObj.Order_Number_with_Country_Code__c) ){
                    OrderNumberWithCountryCodeMap.put(EDBIObj.Order_Number_with_Country_Code__c,EDBIObj.Id);
                }
                if(String.IsNotBlank(EDBIObj.Order_Number_with_Country_Code__c)  &&  !OrderNumberWithFuaSiteNameMap.ContainsKey(EDBIObj.Order_Number_with_Country_Code__c) ){
                    OrderNumberWithFuaSiteNameMap.put(EDBIObj.Order_Number_with_Country_Code__c,EDBIObj.fua_site_name__c);
                }
                if(String.IsNotBlank(EDBIObj.Order_Number_with_Country_Code__c)  &&  !OrderNumberWithFuaSiteNbrMap.ContainsKey(EDBIObj.Order_Number_with_Country_Code__c) ){
                    OrderNumberWithFuaSiteNbrMap.put(EDBIObj.Order_Number_with_Country_Code__c,EDBIObj.fua_site_nbr__c);
                }
                if(String.IsNotBlank(EDBIObj.Order_Number_with_Country_Code__c)  &&  !OrderNumberWithshipToSiteNameMap.ContainsKey(EDBIObj.Order_Number_with_Country_Code__c) ){
                    OrderNumberWithshipToSiteNameMap.put(EDBIObj.Order_Number_with_Country_Code__c,EDBIObj.ship_to_site_name__c);
                }
                if(String.IsNotBlank(EDBIObj.Order_Number_with_Country_Code__c)  &&  !OrderNumberWithShipToSiteNbrMap.ContainsKey(EDBIObj.Order_Number_with_Country_Code__c) ){
                    OrderNumberWithShipToSiteNbrMap.put(EDBIObj.Order_Number_with_Country_Code__c,EDBIObj.ship_to_site_nbr__c);
                }
                
                
                
                
            }
        }
        //System.debug('quoteNoSet1111'+quoteNoSet); 
        
        
        
        for(Deming__c DemingObj : demingTriggerNew){
            String Tmp='';
            
            if(String.IsNotBlank(DemingObj.Order_number__c)){
                if(String.IsNotBlank(DemingObj.Customer_Country_code__c)){
                    Tmp=DemingObj.Order_number__c+DemingObj.Customer_Country_code__c;
                }
                else{
                    Tmp=DemingObj.Order_number__c;
                }
                
            }
            List<String> arrOrdCode=new List<String>();
            if(String.isNotBlank(DemingObj.SalesPerson_Global_Id__c)){
                String[] Temp = DemingObj.SalesPerson_Global_Id__c.split('\\-'); 
                arrOrdCode.add(Temp[0]); 
            }
            if(String.IsNotBlank(Tmp) && String.IsNotBlank(OrderNumberWithCountryCodeMap.get(Tmp))  && OrderNumberWithCountryCodeMap.ContainsKey(Tmp)){
                DemingObj.Related_Order__c=OrderNumberWithCountryCodeMap.get(Tmp);
            } 
            if(String.IsBlank(DemingObj.Cadd_Status__c))  {
                DemingObj.Cadd_Status__c='Open';
            } 
            
            if(String.IsNotBlank(Tmp) && null!=OrderNumberWithFuaSiteNameMap.get(Tmp)  && OrderNumberWithFuaSiteNameMap.ContainsKey(Tmp)){
                DemingObj.fua_site_name__c=OrderNumberWithFuaSiteNameMap.get(Tmp);
            }
            if(String.IsNotBlank(Tmp) && null!=OrderNumberWithFuaSiteNbrMap.get(Tmp)  && OrderNumberWithFuaSiteNbrMap.ContainsKey(Tmp)){
                DemingObj.fua_site_nbr__c=OrderNumberWithFuaSiteNbrMap.get(Tmp);
            }
            if(String.IsNotBlank(Tmp) && null!=OrderNumberWithshipToSiteNameMap.get(Tmp)  && OrderNumberWithshipToSiteNameMap.ContainsKey(Tmp)){
                DemingObj.ship_to_site_name__c=OrderNumberWithshipToSiteNameMap.get(Tmp);
            }
            if(String.IsNotBlank(Tmp) && null!=OrderNumberWithShipToSiteNbrMap.get(Tmp)  && OrderNumberWithShipToSiteNbrMap.ContainsKey(Tmp)){
                DemingObj.ship_to_site_nbr__c=OrderNumberWithShipToSiteNbrMap.get(Tmp);
            }
            if(prepondArrivalDateOrder.size()>0){
                if(prepondArrivalDateOrder.contains(DemingObj.Order_Id__C)){
                    DemingObj.isPDPreponded__c =true;
                }
            }
            //System.debug('#########'+quoteNumberWithOpportunityMap);
            if(String.isBlank(DemingObj.Opportunity__C) && quoteNumberWithOpportunityMap.containsKey(DemingObj.Quote_Number__c)){
                
                DemingObj.Opportunity__C=quoteNumberWithOpportunityMap.get(DemingObj.Quote_Number__c);
                //System.debug('@@@@@'+quoteNumberWithOpportunityMap.get(DemingObj.Quote_Number__c));
                
            }   
            if(String.isNotBlank(DemingObj.Customer_No__c) && MapForAccountManger.containsKey(DemingObj.Customer_No__c)){
                
                DemingObj.Account_Name__c=MapForAccountManger.get(DemingObj.Customer_No__c).Name;
                DemingObj.RelatedAccount__c  =MapForAccountManger.get(DemingObj.Customer_No__c).Id;
                //DemingObj.Region__c=MapForAccountManger.get(DemingObj.Customer_No__c).Account_Region__c;
            }
            
            if(MapOfNCREmp.KeySet().size()>0 && MapOfNCREmp.ContainsKey(arrOrdCode[0])){
                
                DemingObj.CADD_Owner__c= MapOfNCREmp.get(arrOrdCode[0]).Quicklook_ID__c+'@ncr.com';
                DemingObj.IsSalespersonFound__c=true; 
                
                if(String.isNotBlank(DemingObj.Customer_No__c) && MapForAccountManger.containskey(DemingObj.Customer_No__c) && String.isNotBlank(MapForAccountManger.get(DemingObj.Customer_No__c).Owner.Global_ID__c)){
                    DemingObj.Customer_Delivery_Partner_Email__c=MapForAccountManger.get(DemingObj.Customer_No__c).Owner.Email;
                    if(MapForAccountManger.get(DemingObj.Customer_No__c).Owner != Null && QuickLookAndUserMap.ContainsKey(MapForAccountManger.get(DemingObj.Customer_No__c).Owner.Quicklook_ID__c.toupperCase())){
                        DemingObj.EditShareWithUserSpFound__c=String.valueOf(QuickLookAndUserMap.get(MapForAccountManger.get(DemingObj.Customer_No__c).Owner.Quicklook_ID__c.toupperCase()).Id).substring(0, 15);
                    }
                    
                }
                
                if(QuickLookAndUserMap.containsKey(MapOfNCREmp.get(arrOrdCode[0]).Quicklook_ID__c.toupperCase())){
                    
                    DemingObj.EditShareWithUser__c=String.valueOf(QuickLookAndUserMap.get(MapOfNCREmp.get(arrOrdCode[0]).Quicklook_ID__c.toupperCase()).Id).substring(0, 15);
                }
                
                
                if(String.isNotBlank(DemingObj.Customer_No__c) && AccountTeamMap.ContainsKey(DemingObj.Customer_No__c)){
                    
                    if(AccountTeamMap.get(DemingObj.Customer_No__c).TeamMemberRole == 'Customer Success Manager'){
                        DemingObj.AccountManagerEmail__c=AccountTeamMap.get(DemingObj.Customer_No__c).User.Email;
                        if(QuickLookAndUserMap.containsKey(AccountTeamMap.get(DemingObj.Customer_No__c).User.Quicklook_ID__c.toupperCase())){
                            DemingObj.ReadShareWithUser__c=String.valueOf(QuickLookAndUserMap.get(AccountTeamMap.get(DemingObj.Customer_No__c).User.Quicklook_ID__c.toupperCase()).Id).substring(0, 15);
                        }
                    } 
                }
            } 
            
            else if(String.isNotBlank(DemingObj.Customer_No__c) && MapForAccountManger.containsKey(DemingObj.Customer_No__c)){
                
                if(String.isNotBlank(MapForAccountManger.get(DemingObj.Customer_No__c).Owner.Global_ID__c)){
                    DemingObj.CADD_Owner__c=MapForAccountManger.get(DemingObj.Customer_No__c).Owner.Quicklook_ID__c+'@ncr.com';
                    DemingObj.Is_Account_Manager__c=true;
                    
                    if(QuickLookAndUserMap.KeySet() != null && MapForAccountManger.get(DemingObj.Customer_No__c) !=null && QuickLookAndUserMap.containsKey(MapForAccountManger.get(DemingObj.Customer_No__c).Owner.Quicklook_ID__c.toupperCase())){
                        DemingObj.EditShareWithUser__c=String.valueOf(QuickLookAndUserMap.get(MapForAccountManger.get(DemingObj.Customer_No__c).Owner.Quicklook_ID__c.toupperCase()).Id).substring(0, 15);
                    } 
                }
                
                
            }
            
            //System.debug('!!!!!CustomerNo'+AccountTeamMap+'!!!!'+DemingObj.Customer_No__c); 
            if(AccountTeamMap.ContainsKey(DemingObj.Customer_No__c)){
                DemingObj.AccountManagerEmail__c=AccountTeamMap.get(DemingObj.Customer_No__c).User.Email;
                
                if(QuickLookAndUserMap.containsKey(AccountTeamMap.get(DemingObj.Customer_No__c).User.Quicklook_ID__c.toupperCase())){
                    DemingObj.ReadShareWithUser__c=String.valueOf(QuickLookAndUserMap.get(AccountTeamMap.get(DemingObj.Customer_No__c).User.Quicklook_ID__c.toupperCase()).Id).substring(0, 15);
                }
            }           
            
            // }
            
            else{
                DemingObj.Neither_SP_nor_AM_found__c =true;
                if( String.IsNotBlank(DemingObj.Customer_No__c) && AccountTeamMap.ContainsKey(DemingObj.Customer_No__c)){
                    DemingObj.CADD_Owner__c=AccountTeamMap.get(DemingObj.Customer_No__c).User.Email;
                    
                    if(QuickLookAndUserMap.containsKey(AccountTeamMap.get(DemingObj.Customer_No__c).User.Quicklook_ID__c.toupperCase())){
                        DemingObj.EditShareWithUser__c=String.valueOf(QuickLookAndUserMap.get(AccountTeamMap.get(DemingObj.Customer_No__c).User.Quicklook_ID__c.toupperCase()).Id).substring(0, 15);
                    }
                }   
            } 
            
            if((String.isNotBlank(DemingObj.Customer_No__c)) && (AccountTeamMapForIm.get(DemingObj.Customer_No__c) != null) && (String.isNotBlank(AccountTeamMapForIm.get(DemingObj.Customer_No__c).TeamMemberRole)) && (AccountTeamMapForIm.get(DemingObj.Customer_No__c).TeamMemberRole == 'Implementation Coordinator')){
                DemingObj.AccountCordinatorEmail__c=AccountTeamMapForIm.get(DemingObj.Customer_No__c).User.Email;
                if(QuickLookAndUserMap.containsKey(AccountTeamMapForIm.get(DemingObj.Customer_No__c).User.Quicklook_ID__c.toupperCase())){
                    DemingObj.AccountCoordinatorUserId__c=String.valueOf(QuickLookAndUserMap.get(AccountTeamMapForIm.get(DemingObj.Customer_No__c).User.Quicklook_ID__c.toupperCase()).Id).substring(0, 15);
                }		
            } 
        }
        //Code to Populate SP/AM/CRM 
        
    }
    
    public static void isAfterInsert (List<Deming__c> demingTriggerNew, List<Deming__c> demingTriggerOld) {  
        list<id>dmgId=new list<id>();
        Set<String> OrderIdSet = new Set<String>();
        for(Deming__c Dmg : demingTriggerNew){
            
            if(String.IsNotBlank(Dmg.Order_ID__c)){
                OrderIdSet.add(Dmg.Order_ID__c);
                
            }
            if(String.IsNotBlank(string.valueof(dmg.Order_Id__c))&& String.IsNotBlank(string.valueof(dmg.Order_number__c))){
                
                if(dmg.Cadd_Status__c=='Open' && dmg.Cadd_Status__c!=null ) {
                    
                    dmgId.add(dmg.id);  
                }
            }
        }  
    }
    
    
   // NSC_SOUP_ERP Trigger Logic starts
    public static void isBeforeUpdate (List<Deming__c > demingTriggerNew,List<Deming__c > demingTriggerOld) {  
        Set<String> prepondArrivalDateOrder = new Set<String>();
            Set<String> postpondArrivalDateOrder = new Set<String>();
            Set<String> quoteNumberSet= new Set<String>();
            Map<String,String> quoteNumberWithOpportunityMap= new Map<String,String>();
            
            for(Deming__c dmg:demingTriggerNew) {
                /*if(dmg.Cadd_Status__c == 'Rejected'){
                    
                    if(String.isBlank(dmg.Reason_Of_Rejection__c)){
                        //dmg.addError('Error added to account on trigger');
                       
                        dmg.Reason_Of_Rejection__c.addError('Please select reason of rejection',false);  
                       
                    } 
                    
                }*/
                
                if(String.IsNotBlank(dmg.Cadd_Status__c)){
                    if(dmg.Cadd_Status__c=='Approved') {
                        dmg.Customer_Acceptance_Date__c=dmg.Max_Promise_Date__c;
                        
                    }
                    else if(dmg.Cadd_Status__c=='Rejected'){
                        dmg.Customer_Acceptance_Date__c=null;
                        
                    } 
                }   
                else   {
                    dmg.Customer_Acceptance_Date__c=null;
                }  
                if(dmg.Max_Promise_Date__c<dmg.RDD__c){
                    
                    prepondArrivalDateOrder.add(dmg.Order_Id__c);  
                }
                else{
                    
                   postpondArrivalDateOrder.add(dmg.Order_Id__c);  
                }
                

                
                if(String.isNotBlank(dmg.Quote_Number__c)){
                quoteNumberSet.add(dmg.Quote_Number__c);  
            }
                
                
            } 
            if(quoteNumberSet.size()>0){
            
            for(QuBy_Detail__c quoteOppo:[select Opportunity__c,Quote_Number__c from QuBy_Detail__c where Quote_Number__c in :quoteNumberSet ] ){
                quoteNumberWithOpportunityMap.put(quoteOppo.Quote_Number__c,quoteOppo.Opportunity__c);
                
            }
            
        }

            for(Deming__c DemingObj : demingTriggerNew){
                if(prepondArrivalDateOrder.size()>0){
                    if(prepondArrivalDateOrder.contains(DemingObj.Order_Id__C)){
                    DemingObj.isPDPreponded__c =true;
                    }
                }
                if(postpondArrivalDateOrder.size()>0){
                    if(postpondArrivalDateOrder.contains(DemingObj.Order_Id__C)){
                    DemingObj.isPDPreponded__c =false;
                    }
                }
                //System.debug('#########'+quoteNumberWithOpportunityMap);
        if(quoteNumberWithOpportunityMap.containsKey(DemingObj.Quote_Number__c)&&((String.isBlank(DemingObj.Opportunity__C)|| DemingObj.Opportunity__C!=quoteNumberWithOpportunityMap.get(DemingObj.Quote_Number__c)))){
          
                DemingObj.Opportunity__C=quoteNumberWithOpportunityMap.get(DemingObj.Quote_Number__c);
                  //System.debug('@@@@@'+quoteNumberWithOpportunityMap.get(DemingObj.Quote_Number__c));
                }  
            }
    }
    
    public static void isAfterUpdate (List<Deming__c > demingTriggerNew, List<Deming__c > demingTriggerOld, Map<id, Deming__c> oldDemingMap) { 
          
        list<id>dmgId=new list<id>();
        //Set<Deming__Share> DemingShareRecordShare= new Set<Deming__Share>();
        //Map<String,List<String>> DemingAcountShareMap = new Map<String,List<String>>();
        //Map<String,List<String>> ListDemingShare= new Map<String,List<String>>();
        //List<Deming__Share> ShareObjToUpsert = new List<Deming__Share>();
    
        if(Trigger.IsUpdate) {

                    /*for(Deming__Share shareObj : [select id,ParentId,UserOrGroupId,AccessLevel,RowCause from Deming__Share where ParentId IN : Trigger.NewMap.KeySet() and AccessLevel = 'Read']){
                              
                                if(!ListDemingShare.ContainsKey(shareObj.ParentId)){
                                    ListDemingShare.put(shareObj.ParentId,new List<String>());
                                }
                                ListDemingShare.get(shareObj.ParentId).add(shareObj.UserOrGroupId);
                                shareObj.AccessLevel='Edit';
                                ShareObjToUpsert.add(shareObj);
                     }*/
            
            
                    for(deming__c dmg:demingTriggerNew){

                        if(String.IsNotBlank(string.valueof(dmg.Order_Id__c))&& String.IsNotBlank(string.valueof(dmg.Order_number__c))){
                            
                            if(dmg.Cadd_Status__c!=oldDemingMap.get(dmg.id).Cadd_Status__c && dmg.Cadd_Status__c!=null ) {
                                
                                dmgId.add(dmg.id);  
                            }
                            else if((String.IsnotBlank(dmg.Reason_Of_Rejection__c)) && (oldDemingMap.get(dmg.id).Reason_Of_Rejection__c  != dmg.Reason_Of_Rejection__c)){
                                dmgId.add(dmg.id);
                            }
                        }
                            
                        /*if((DemingValidateExecution.ValidateNotificationSwitch()) && (String.isNotBlank(dmg.RelatedAccount__c)) && (UserInfo.getUserId().SubString(0,15) == CADDDoNotReply__c.getValues('Do Not Reply User For CADD').UserID__c) && (dmg.Include_In_Process__c == true) && (dmg.Include_In_Process__c != trigger.oldMap.get(dmg.id).Include_In_Process__c)){ 
                             
                                if(String.isNotBlank(dmg.RelatedAccount__c) && (!DemingAcountShareMap.containsKey(dmg.RelatedAccount__c))){
                                    DemingAcountShareMap.put(dmg.RelatedAccount__c, new List<String>());
                                }
                            
                                 DemingAcountShareMap.get(dmg.RelatedAccount__c).add(dmg.id);
                        }*/
                        
                    } 
               
                    if(dmgId.size()>0){
                        if(System.isFuture() || System.isBatch()){               
                            Nsc_Soup_Integration.synchLOS_OM(dmgId);
                        }else{                
                            Nsc_Soup_Integration.synchLOS_OM_With_Future(dmgId);
                        }   
                    }  
                 
                   /* if(DemingAcountShareMap.Size() != null && DemingAcountShareMap.size()>0){
                    
                        for(AccountTeamMember AccTeamObj : [SELECT Id,TeamMemberRole,UserId,AccountId  FROM AccountTeamMember  WHERE AccountId IN:DemingAcountShareMap.KeySet()]){
                            
                            if((String.isNotBlank(AccTeamObj.AccountId)) && (DemingAcountShareMap.get(AccTeamObj.AccountId) != null) && (DemingAcountShareMap.ContainsKey(AccTeamObj.AccountId)) && (DemingAcountShareMap.get(AccTeamObj.AccountId).Size()>0)){
                                System.debug('>>>>>>>>4'+AccTeamObj);
                                for(String DemObjId : DemingAcountShareMap.get(AccTeamObj.AccountId)){         
                                    if((ListDemingShare.containsKey(DemObjId) != null) && (ListDemingShare.get(DemObjId) != null) && (!ListDemingShare.get(DemObjId).contains(AccTeamObj.UserId))){
                                        DemingShareRecordShare.add(DemingEmailServiceClass.CreateShareRecord(AccTeamObj.UserId, 'Edit', DemObjId));
                                    }  
                                    
                                    else {
                                        DemingShareRecordShare.add(DemingEmailServiceClass.CreateShareRecord(AccTeamObj.UserId, 'Edit', DemObjId));
                                    }
                                    
                                }
                             
                            }
    
                        }  
                    } */
               
                    /*if(DemingShareRecordShare.size()>0){
                               try{
                                   List<Deming__Share> TempList = new List<Deming__Share>();
                                   TempList.addAll(DemingShareRecordShare);
                                   insert TempList;  
                               }
                               catch(Exception e){
                                   System.debug('Error While share Record of deming from Trigger NSC_SOUP_ERP'+e);
                        
                               }       
                    }
        
                    if(ShareObjToUpsert.size()>0){
                            update ShareObjToUpsert;
                    } */
        
            }  
    }

	public static void manageDemingTeamSharing (List<Deming__c > demingTriggerNew,List<Deming__c > demingTriggerOld) {  
        Map<Id,Set<String>> CaadIdUserMap= new Map<Id,Set<String>>();
          Map<Id,List<String>> CaddIdAccountIdMap = new Map<Id,List<String>>();
          
          Map<Id,List<String>> AccountTeamMemberShareMap = new Map<Id,List<String>>();
          Set<Deming__Share> DemingShareRecordCadd= new Set<Deming__Share>();
          Set<Deming__Share> DemingShareRecordAccountTeam= new Set<Deming__Share>();
          
          
          for(Deming__c DeminObj : demingTriggerNew){
              
              
              if((String.isNotBlank(DeminObj.EditShareWithUser__c)) &&  (!CaadIdUserMap.containsKey(DeminObj.EditShareWithUser__c))){
                  CaadIdUserMap.put(DeminObj.EditShareWithUser__c,new Set<String>());
              }
              
              if(String.isNotBlank(DeminObj.EditShareWithUser__c))
              CaadIdUserMap.get(DeminObj.EditShareWithUser__c).add(DeminObj.id);
              
              
              if((String.isNotBlank(DeminObj.ReadShareWithUser__c)) &&  (!CaadIdUserMap.containsKey(DeminObj.ReadShareWithUser__c))){
                  CaadIdUserMap.put(DeminObj.ReadShareWithUser__c,new Set<String>());
              }
              
              
              if(String.isNotBlank(DeminObj.ReadShareWithUser__c))
              CaadIdUserMap.get(DeminObj.ReadShareWithUser__c).add(DeminObj.id);
              
              
              
              if((String.isNotBlank(DeminObj.EditShareWithUserSpFound__c)) &&  (!CaadIdUserMap.containsKey(DeminObj.EditShareWithUserSpFound__c))){
                  CaadIdUserMap.put(DeminObj.EditShareWithUserSpFound__c,new Set<String>());
              }
              
              if(String.isNotBlank(DeminObj.EditShareWithUserSpFound__c))
              CaadIdUserMap.get(DeminObj.EditShareWithUserSpFound__c).add(DeminObj.id);
                
              
              
              if(!CaddIdAccountIdMap.Containskey(DeminObj.RelatedAccount__c)){
                  CaddIdAccountIdMap.put(DeminObj.RelatedAccount__c, new List<String>());
              }  
             
              CaddIdAccountIdMap.get(DeminObj.RelatedAccount__c).add(DeminObj.Id);
          }
          
          if(CaddIdAccountIdMap != null && CaddIdAccountIdMap.KeySet().size()>0){
              
              for(AccountTeamMember AccTeamObj : [SELECT Id,TeamMemberRole,UserId,AccountId,User.Name,User.isActive,user.profile.name  FROM AccountTeamMember  WHERE AccountId IN:CaddIdAccountIdMap.KeySet() and User.IsActive= true and  user.profile.name !='90 Chatter Free']){
                
                  if(!AccountTeamMemberShareMap.containsKey(AccTeamObj.AccountId)){
                      AccountTeamMemberShareMap.put(AccTeamObj.AccountId,new List<String>());
                  }     
                  AccountTeamMemberShareMap.get(AccTeamObj.AccountId).add(AccTeamObj.UserId);
                  //system.debug('<><><>'+AccountTeamMemberShareMap);
              }
          }
          
          
          if(CaadIdUserMap != null && CaadIdUserMap.keySet().Size()>0){
               
              for(User UserObj : [Select id,isActive,user.profile.name from User where Id IN: CaadIdUserMap.KeySet() and isActive = true and user.profile.name !='90 Chatter Free']){
                   
                  if((CaadIdUserMap.containsKey(UserObj.id)) && (CaadIdUserMap.get(UserObj.id) != null)){
                      
                      for(String CaddRecordId : CaadIdUserMap.get(UserObj.id)){
                          DemingShareRecordCadd.add(DemingEmailServiceClass.CreateShareRecord(UserObj.Id, 'Edit', CaddRecordId));
                      }
                       
                  }
                   
              }
          } 
          
          
          
          if(AccountTeamMemberShareMap != null){
              
               for(Deming__c DemingObj : demingTriggerNew){
                   
                   if(String.isNotBlank(DemingObj.RelatedAccount__c)){
                       
                     if((AccountTeamMemberShareMap.containsKey(DemingObj.RelatedAccount__c))  && (AccountTeamMemberShareMap.get(DemingObj.RelatedAccount__c).size()>0)){
                        
                        for(String Userid : AccountTeamMemberShareMap.get(DemingObj.RelatedAccount__c)){
                            system.debug('Userid'+Userid);
                             DemingShareRecordAccountTeam.add(DemingEmailServiceClass.CreateShareRecord(Userid, 'Edit', DemingObj.id));
                         }
                    }
                   }
   
               }
          }
          
          if(DemingShareRecordCadd.size()>0){
              List<Deming__Share> TempDemingShare = new List<Deming__Share>();
              TempDemingShare.addAll(DemingShareRecordCadd);
              insert TempDemingShare;
          }
          
          
          if(DemingShareRecordAccountTeam.size()>0){
              List<Deming__Share> TempDemingShare = new List<Deming__Share>();
              TempDemingShare.addAll(DemingShareRecordAccountTeam);
              insert TempDemingShare;
          }
       } 
}