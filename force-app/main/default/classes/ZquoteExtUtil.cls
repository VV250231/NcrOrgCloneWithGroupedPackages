public with sharing class ZquoteExtUtil {
    final static String ONE_TIME_CHARGE = 'One-Time';
    final static String RECURRING_CHARGE = 'Recurring';
    final static String MONTHLY_BILLING = 'Month';
    final static String REMOVE_PRODUCT_AMENDMENT_TYPE = 'RemoveProduct';
    final static String NEW_PRODUCT_AMENDMENT_TYPE = 'NewProduct';
    final static String UPDATE_PRODUCT_AMENDMENT_TYPE = 'UpdateProduct';

    public static Map<ID, Map<String, Decimal>> calcQuoteOneTimeandMonthlyaFee(Map<ID, String> quoteIdSubIdMap) {
        Map<ID, Map<String, Decimal>> quoteOneTimeandMonthlyMap =  new Map<ID, Map<String, Decimal>>();
        
        if(quoteIdSubIdMap != NULL && quoteIdSubIdMap.size() > 0) {
            Map<ID, Decimal> quoteOneTimeMap = new Map<ID, Decimal>();
            Map<ID, Decimal> quoteMonthlyMap = new Map<ID, Decimal>();
            Map<String, Map<String, List<Zuora__SubscriptionProductCharge__c>>> zuoraIdSubscriptionMap = new Map<String, Map<String, List<Zuora__SubscriptionProductCharge__c>>>(); 
            Map<Id, Map<String, Set<String>>> quoteIdChargeMap = new Map<Id, Map<String, Set<String>>>(); 
            Map<String, List<Zuora__SubscriptionProductCharge__c>> ratePlanIDSubChargeMap;
            
            for(ID quoteId : quoteIdSubIdMap.keySet()){
                quoteOneTimeMap.put(quoteId, 0);
                quoteMonthlyMap.put(quoteId, 0);
            }
            
            // find existing subscription charges for quote 
            for(Zuora__Subscription__c zsub : [SELECT Zuora__External_Id__c, 
                                                (SELECT Zuora__External_Id__c, Zuora__RatePlanId__c, Zuora__Price__c,
                                                 Zuora__ExtendedAmount__c, Zuora__Type__c, Zuora__BillingPeriod__c
                                                 FROM Zuora__Subscription_Product_Charges__r)
                                                 FROM Zuora__Subscription__c 
                                                 WHERE Zuora__External_Id__c IN :quoteIdSubIdMap.values()]) 
            {
             
               if(!zuoraIdSubscriptionMap.containsKey(zsub.Zuora__External_Id__c)) {
                   ratePlanIDSubChargeMap = new Map<String, List<Zuora__SubscriptionProductCharge__c>>();
                   
                   for(Zuora__SubscriptionProductCharge__c zcharge : zsub.Zuora__Subscription_Product_Charges__r) {
                      System.debug('+++ existing product and charges' + zcharge.Zuora__Price__c +'rate paln id'+zcharge.Zuora__RatePlanId__c);                                                       
                       List<Zuora__SubscriptionProductCharge__c> subChargeList = ratePlanIDSubChargeMap.get(zcharge.Zuora__RatePlanId__c);
                       if(subChargeList == NULL) {
                           subChargeList = new List<Zuora__SubscriptionProductCharge__c>();
                       }
                       subChargeList.add(zcharge);
                       ratePlanIDSubChargeMap.put(zcharge.Zuora__RatePlanId__c, subChargeList); 
                   } 
                   zuoraIdSubscriptionMap.put(zsub.Zuora__External_Id__c, ratePlanIDSubChargeMap ); 
               }
            }
         
     
                                                                                                                                                    
             // find added/updated/removed charges for amendment quote
             // in case of update and remove quote , we also need to craete map of quote id and zuora rate plan ids and charges ids
             for(zqu__QuoteRatePlan__c zquQuoteRatePlan :[Select Id, zqu__Quote__c, zqu__AmendmentType__c, zqu__SubscriptionRatePlanZuoraId__c, 
                                                            (Select zqu__Total__c, zqu__SubscriptionRatePlanChargeZuoraId__c,zqu__Period__c,
                                                             zqu__ChargeType__c from zqu__Quote_Rate_Plan_Charges__r) 
                                                          from zqu__QuoteRatePlan__c where zqu__Quote__c IN :quoteIdSubIdMap.keySet()]) 
                                                          
                                                             
            {
               
                if(zquQuoteRatePlan.zqu__AmendmentType__c == NEW_PRODUCT_AMENDMENT_TYPE) {
                     for(zqu__QuoteRatePlanCharge__c zqc : zquQuoteRatePlan.zqu__Quote_Rate_Plan_Charges__r) {
                        if(zqc.zqu__ChargeType__c  == ONE_TIME_CHARGE) {
                            quoteOneTimeMap.put(zquQuoteRatePlan.zqu__Quote__c, quoteOneTimeMap.get(zquQuoteRatePlan.zqu__Quote__c) + zqc.zqu__Total__c);
                        } else if(zqc.zqu__ChargeType__c == RECURRING_CHARGE && zqc.zqu__Period__c == MONTHLY_BILLING) {
                            quoteMonthlyMap.put(zquQuoteRatePlan.zqu__Quote__c, quoteMonthlyMap.get(zquQuoteRatePlan.zqu__Quote__c) + zqc.zqu__Total__c);
                        }   
                     }
                }
                
                if(zquQuoteRatePlan.zqu__AmendmentType__c == UPDATE_PRODUCT_AMENDMENT_TYPE) {
                     Set<String> subRatePlanChargeZuoraIds = new Set<String>();
                     
                     for(zqu__QuoteRatePlanCharge__c zqc : zquQuoteRatePlan.zqu__Quote_Rate_Plan_Charges__r) {
                        if(zqc.zqu__ChargeType__c  == ONE_TIME_CHARGE) {
                            quoteOneTimeMap.put(zquQuoteRatePlan.zqu__Quote__c, quoteOneTimeMap.get(zquQuoteRatePlan.zqu__Quote__c) + zqc.zqu__Total__c);
                            subRatePlanChargeZuoraIds.add(zqc.zqu__SubscriptionRatePlanChargeZuoraId__c);
                        } else if(zqc.zqu__ChargeType__c == RECURRING_CHARGE && zqc.zqu__Period__c == MONTHLY_BILLING) {
                            // map of zuora rate plan id and its chagres ids...
                            quoteMonthlyMap.put(zquQuoteRatePlan.zqu__Quote__c, quoteMonthlyMap.get(zquQuoteRatePlan.zqu__Quote__c) + zqc.zqu__Total__c);
                            subRatePlanChargeZuoraIds.add(zqc.zqu__SubscriptionRatePlanChargeZuoraId__c);
                            // map of quote id and ids of zuora rate plan and its charges ids of Zuora
                        }   
                     }
                     
                     if(subRatePlanChargeZuoraIds.size() > 0) {
                         Map<String, Set<String>> qrpSubIdQRPCSubId = quoteIdChargeMap.get(zquQuoteRatePlan.zqu__Quote__c);
                         if(qrpSubIdQRPCSubId == NULL) {
                             qrpSubIdQRPCSubId = new Map<String, Set<String>>();
                         } 
                         qrpSubIdQRPCSubId.put(zquQuoteRatePlan.zqu__SubscriptionRatePlanZuoraId__c, subRatePlanChargeZuoraIds);
                         quoteIdChargeMap.put(zquQuoteRatePlan.zqu__Quote__c, qrpSubIdQRPCSubId);
                     }
                     
                }
                 
                 
                if(zquQuoteRatePlan.zqu__AmendmentType__c == 'RemoveProduct') {
                
                    Map<String, Set<String>> qrpSubIdQRPCSubId = quoteIdChargeMap.get(zquQuoteRatePlan.zqu__Quote__c);
                         if(qrpSubIdQRPCSubId == NULL) {
                             qrpSubIdQRPCSubId = new Map<String, Set<String>>();
                         } 
                         qrpSubIdQRPCSubId.put(zquQuoteRatePlan.zqu__SubscriptionRatePlanZuoraId__c, NULL); // removed product's zuora rate paln and its charges ids
                         quoteIdChargeMap.put(zquQuoteRatePlan.zqu__Quote__c, qrpSubIdQRPCSubId);  // quote id and its above map 
                 }
             }
            
             // find original charges linked with quote i.e present in product and charges under subscription in salesforce
             Map<String, Decimal> tempChargeTotalMap;
             for(ID quoteId : quoteIdSubIdMap.keySet()) {
                String subZuoraId = quoteIdSubIdMap.get(quoteId); // get zuora subscription id (amend subscription id present in quote)
                ratePlanIDSubChargeMap = zuoraIdSubscriptionMap.get(subZuoraId); // all the charges , in the form of rate plan id and product and charges
                
                if(ratePlanIDSubChargeMap != NULL && ratePlanIDSubChargeMap.size() > 0) {
                    Map<String, Set<String>> qrpSubIdQRPCSubId = quoteIdChargeMap.get(quoteId); // get the id of rate plan whcih are added or remove in the current amendment
                    
                    for(String ratePlanId : ratePlanIDSubChargeMap.keySet()) 
                    {
                        if(qrpSubIdQRPCSubId == null || (qrpSubIdQRPCSubId != NULL && !qrpSubIdQRPCSubId.containsKey(ratePlanId)))
                        {
                             List<Zuora__SubscriptionProductCharge__c> subChargeList = ratePlanIDSubChargeMap.get(ratePlanId);
                             
                              for(Zuora__SubscriptionProductCharge__c zSubCharge: subChargeList) {
                                 if(zSubCharge.Zuora__Type__c == ONE_TIME_CHARGE && zSubCharge.Zuora__Price__c != NULL) {
                                     quoteOneTimeMap.put(quoteId , quoteOneTimeMap.get(quoteId) + zSubCharge.Zuora__Price__c);
                                 } else if(zSubCharge.Zuora__Type__c == RECURRING_CHARGE && zSubCharge.Zuora__BillingPeriod__c == MONTHLY_BILLING
                                    && zSubCharge.Zuora__Price__c != NULL) {
                                     quoteMonthlyMap.put(quoteId , quoteMonthlyMap.get(quoteId) + zSubCharge.Zuora__Price__c);   
                                 }
                             }
                         }
                    }  
                }
              
                tempChargeTotalMap = new Map <String, Decimal>{'totalOneTimeFee' => quoteOneTimeMap.get(quoteId ), 'totalMonthlyFee' => quoteMonthlyMap.get(quoteId )};
                quoteOneTimeandMonthlyMap.put(quoteId, tempChargeTotalMap);
             }
         }
         return quoteOneTimeandMonthlyMap;
    }
    

    @future
    public static void futureShareQuoteWithAccandAccTeam(Map<Id, Id> quoteAccountIdMap) {
        shareQuoteWithAccandAccTeam(quoteAccountIdMap);
    }
    
  
    public static void shareQuoteWithAccandAccTeam(Map<Id, Id> quoteAccountIdMap) {
        if(quoteAccountIdMap != NULL) { 
            List<zqu__Quote__Share> quoteShareList = new List<zqu__Quote__Share>();
            Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, OwnerId, (SELECT Id, UserId FROM AccountTeamMembers) 
                                                                FROM Account WHERE Id IN :quoteAccountIdMap.values()]);
            
            /*List<User> cancelQuoteApprovers = [SELECT Id FROM User WHERE Quicklook_ID__c = 'cn250024' LIMIT 1];*/
            
            List<Group> sendToZbillingGroup = [SELECT id,name, type FROM Group WHERE DeveloperName= 'Send_to_Z_billing_group' and Type='Regular'];
            System.debug('sendToZbillingGroup>>' + sendToZbillingGroup);
            
            for(Id quoteId :quoteAccountIdMap.keySet()) {
                Id parentAccid = quoteAccountIdMap.get(quoteId);
                Account parentAcc = accMap.get(parentAccid);
                
                if(!sendToZbillingGroup.isEmpty()) {
                    zqu__Quote__Share approverShr =  new zqu__Quote__Share();
                    approverShr.parentId = quoteId;
                    approverShr.UserOrGroupId = sendToZbillingGroup.get(0).Id;
                    approverShr.AccessLevel = 'edit';
                    approverShr.RowCause = Schema.zqu__Quote__Share.RowCause.DI_SendToZbillingGroup__c;
                    quoteShareList.add(approverShr);
                }
                
                zqu__Quote__Share quoteShr =  new zqu__Quote__Share();
                quoteShr.parentId = quoteId;
                quoteShr.UserOrGroupId = parentAcc.OwnerId;
                quoteShr.AccessLevel = 'edit';
                quoteShr.RowCause = Schema.zqu__Quote__Share.RowCause.AccountOwner__c;
                quoteShareList.add(quoteShr);
                
                for(AccountTeamMember atm :parentAcc.AccountTeamMembers) {
                    zqu__Quote__Share accTeamShr =  new zqu__Quote__Share();
                    accTeamShr .parentId = quoteId;
                    accTeamShr .UserOrGroupId = atm.UserId;
                    accTeamShr .AccessLevel = 'edit';
                    accTeamShr .RowCause = Schema.zqu__Quote__Share.RowCause.AccountTeamMember__c;
                    quoteShareList.add(accTeamShr );  
                }
            }
            
            Database.SaveResult[] lsr = Database.insert(quoteShareList,false);
        }
    }

    //called on quote approval status changing
    public void onApprovalStatusChange(zqu__Quote__c qt) {
        if(qt.zqu__Opportunity__c != null) {
            Integer countApproved = [select count() from zqu__Quote__c where zqu__Opportunity__c = :qt.zqu__Opportunity__c and DI_Approval_Status__c = 'Approved'];
            Opportunity oppUpdate = new Opportunity(Id = qt.zqu__Opportunity__c, Has_Approved_Quote__c = (countApproved > 0));
            update oppUpdate;            
        }
    }

}