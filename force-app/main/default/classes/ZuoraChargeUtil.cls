public with sharing class ZuoraChargeUtil {
    final String ONE_TIME_CHARGE = 'One-Time'; 
    final String RECURRING_CHARGE = 'Recurring';
    final String  USAGE_CHARGE = 'Usage';
    final String MONHTLY_PERIOD = 'Month';
    final String ANNUAL_PERIOD = 'Annual';
    final String NEW_SUBSCRIPTION = 'New Subscription';
    final String AMEND_SUBSCRIPTION =  'Amend Subscription';
    
    public static boolean runACVCalc = true;
    
    public Map<Id, Id> getOppDetailfromQuote(Set<ID> zQuoteIds) {
        Map<Id, Id> quoteOppMap = new Map<Id, Id>();
        for (zqu__Quote__c quote : [SELECT Id, zqu__Primary__c, zqu__Opportunity__c FROM zqu__Quote__c WHERE Id IN :zQuoteIds AND Is_NCR_Quote__c = false AND zqu__Opportunity__r.StageName NOT IN ('Closed/Booked','Closed/Lost','Closed/Discontinued') And zqu__Status__c != 'Sent to Z-Billing' ]) {
            if (quote.zqu__Primary__c && quote.zqu__Opportunity__c != null) {
                quoteOppMap.put(quote.Id, quote.zqu__Opportunity__c);
            }
        }
        return quoteOppMap;
    }
    
    public Map<Id, Id> getOppDetailfromQuoteRatePlan(Set<ID> zRatePlanIds) {
        Map<Id, Id> quoteOppMap = new Map<Id, Id>();
        for(zqu__QuoteRatePlan__c qrp :[SELECT Id, zqu__Quote__c, zqu__Quote__r.zqu__Primary__c, 
                                        zqu__Quote__r.zqu__Opportunity__c,
                                        zqu__Quote__r.Is_NCR_Quote__c,
                                        zqu__Quote__r.zqu__SubscriptionType__c, 
                                        zqu__Quote__r.zqu__InitialTerm__c,                                                                 
                                        zqu__Quote__r.zqu__StartDate__c, 
                                        zqu__Quote__r.zqu__SubscriptionTermStartDate__c,
                                        zqu__Quote__r.zqu__SubscriptionTermEndDate__c  
                                        FROM zqu__QuoteRatePlan__c 
                                        WHERE Id IN :zRatePlanIds 
                                        AND zqu__Quote__r.Is_NCR_Quote__c = false AND zqu__Quote__r.zqu__Status__c != 'Sent to Z-Billing' AND zqu__Quote__r.zqu__Opportunity__r.StageName NOT IN ('Closed/Booked','Closed/Lost','Closed/Discontinued') AND zqu__AmendmentType__c NOT IN ('','Original')]) {
            
            if (qrp.zqu__Quote__c != null && qrp.zqu__Quote__r.zqu__Primary__c && qrp.zqu__Quote__r.zqu__Opportunity__c != null) {
                quoteOppMap.put(qrp.zqu__Quote__c, qrp.zqu__Quote__r.zqu__Opportunity__c);    
            }
        }
        return quoteOppMap;
    }
    
    
    private List<zqu__QuoteRatePlanCharge__c> getChargeListWithZQuoteOppDetail(Set<ID> zChargeIds) {
        return [SELECT Id, zqu__ChargeType__c, zqu__Period__c,
            zqu__EffectivePrice__c, ChargeACV__c, 
            MinimumChargeCode__c, zqu__QuoteRatePlan__r.zqu__Quote__c,
            zqu__QuoteRatePlan__r.zqu__Quote__r.Is_NCR_Quote__c,
            zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Primary__c,  
            zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Opportunity__c, 
            zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__SubscriptionType__c, 
            zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__InitialTerm__c,                                                                 
            zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__StartDate__c, 
            zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__SubscriptionTermStartDate__c,
            zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__SubscriptionTermEndDate__c                                                                
            FROM zqu__QuoteRatePlanCharge__c
            WHERE zqu__QuoteRatePlan__c != null AND
            zqu__QuoteRatePlan__r.zqu__AmendmentType__c NOT IN ('Original','') AND
            zqu__QuoteRatePlan__r.zqu__Quote__c != null AND
            zqu__QuoteRatePlan__r.zqu__Quote__r.Is_NCR_Quote__c = false AND zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Status__c != 'Sent to Z-Billing' AND
            zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Opportunity__r.StageName NOT IN ('Closed/Booked','Closed/Lost','Closed/Discontinued') AND
            Id IN :zChargeIds];  
    }
    
    public void calcACVFromRatePlan(Set<ID> zRatePlanIds) {
        if (zRatePlanIds != null && zRatePlanIds.size() > 0) {
            Map<Id, Id> quoteOppMap = getOppDetailfromQuoteRatePlan(zRatePlanIds);
            
            if (!quoteOppMap.isEmpty()) {
                updateOppLineItems(quoteOppMap, true);
            }
        }
    }
    
    public void calcACVFromQuote(Set<ID> zQuoteIds) {
        if (zQuoteIds != null && zQuoteIds.size() > 0) {
            Map<Id, Id> quoteOppMap = getOppDetailfromQuote(zQuoteIds); 
            
            if (!quoteOppMap.isEmpty()) {
                updateOppLineItems(quoteOppMap, true);
            }   
        }
    }
    
    public void updateOppLineItems(Map<Id, Id> quoteOppMap, Boolean isDeleteOLI) {
        CheckRecursive.OpportunityTriggerbypass = false;
        
        if (quoteOppMap != null && quoteOppMap.size() > 0) {
            //Map<Id, Id> quoteOppMap = new Map<Id, Id>();
            Map<Id, Map<Id, Decimal>> quoteToplineMap = new  Map<Id, Map<Id, Decimal>>();
            
            // CHANGE PRODUCT LOOKUP IN BELOW QUERY // add field market product of qrp
            List<zqu__QuoteRatePlanCharge__c> zChargeList = [SELECT Id, zqu__QuoteRatePlan__r.MarketProductId__c,ChargeACV__c, zqu__QuoteRatePlan__r.zqu__Quote__c, 
                                                                zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Topline_Product_Lkp__c
                                                                FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__c != null AND
                                                                zqu__QuoteRatePlan__r.zqu__AmendmentType__c NOT IN ('Original','') AND
                                                                zqu__QuoteRatePlan__r.zqu__Quote__c != null AND zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Status__c != 'Sent to Z-Billing' AND
                                                                zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Opportunity__r.StageName NOT IN ('Closed/Booked','Closed/Lost','Closed/Discontinued') AND
                                                                zqu__QuoteRatePlan__r.zqu__Quote__c IN :quoteOppMap.keySet()];
                                                                
            // get the market product id values from the PMDM_Unique_Key__c
            Set<String> mpIds = new Set<String>();
            for(zqu__QuoteRatePlanCharge__c zCharge : zChargeList)
            {
                if(String.isNotBlank(zCharge.zqu__QuoteRatePlan__r.MarketProductId__c))
                   mpIds.add(zCharge.zqu__QuoteRatePlan__r.MarketProductId__c);
            }
            // get product 2 id from                
            Map<String,Product2> mapPMDMIDandProduct2Id = new Map<String,Product2>();   
            if(mpIds != null && mpIds.size() > 0)
            { 
               for(Product2 objProduct2 :[Select id, PMDM_Unique_Key__c  from Product2 where PMDM_Unique_Key__c IN :mpIds and Product_Type__c != 'Zuora Product'])
               {
                   mapPMDMIDandProduct2Id.put(objProduct2.PMDM_Unique_Key__c,objProduct2);
               }
            }               
           
           Set<Id> toplineIds = new Set<Id>();                                                     
           Map<Id, Decimal> toplineMap;                                                     
           for (zqu__QuoteRatePlanCharge__c zCharge : zChargeList) {
               Id toplineId = mapPMDMIDandProduct2Id != null && mapPMDMIDandProduct2Id.containsKey(zCharge.zqu__QuoteRatePlan__r.MarketProductId__c)?mapPMDMIDandProduct2Id.get(zCharge.zqu__QuoteRatePlan__r.MarketProductId__c).Id:null;
               
               if(toplineId  != null && String.IsNotBlank(toplineId)) {
                   toplineIds.add(toplineId); 
                   toplineMap = quoteToplineMap.get(zCharge.zqu__QuoteRatePlan__r.zqu__Quote__c);
                   Decimal chargeACV = (zCharge.ChargeACV__c != null) ? zCharge.ChargeACV__c : 0;
                   
                   if (toplineMap == null) {
                       toplineMap = new Map<Id, Decimal>(); 
                       quoteToplineMap.put(zCharge.zqu__QuoteRatePlan__r.zqu__Quote__c, toplineMap);            
                   } 
                   Decimal totalACV = (toplineMap.get(toplineId) != null) ? toplineMap.get(toplineId) + chargeACV : chargeACV;
                   toplineMap.put(toplineId, totalACV);  
               }
           }
           system.debug('++++++++++++boolen isDeleteOLI++'+isDeleteOLI);
           if(isDeleteOLI)  {
               if (!quoteOppMap.isEmpty()) { 
                   deleteOLIsFromOpp(quoteOppMap.values());
               }
                       
               if ((!quoteToplineMap.isEmpty()) && (!toplineIds.isEmpty())) {
                   Map<Id, Id> PrdPBEMap = getToplinePriceBookEntries(toplineIds);
                   List<OpportunityLineItem> newOLIs = new List<OpportunityLineItem>();
                      
                   for (Id quoteId :quoteToplineMap.keySet()) {
                       String OppId = quoteOppMap.get(quoteId);
                       Map<Id, Decimal> productMap = quoteToplineMap.get(quoteId);
                       
                       for(Id prdId : productMap.keySet()) {
                           OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = OppId, Quantity = 1);
                           oli.PricebookEntryId = PrdPBEMap.get(prdId);
                           oli.UnitPrice = productMap.get(prdId);       
                           newOLIs.add(oli);
                       }
                   }  
                   if (!newOLIs.isEmpty()) {
                       CheckRecursive.addValOppTriggerRun();
                       insert newOLIs;
                       CheckRecursive.resetOppAmountValidation(); 
                   } 
               }
               
           } else { // isDeleteOLI false
               if (!quoteToplineMap.isEmpty()) {
                   updateExistingOLIofOpp(quoteToplineMap, quoteOppMap);
               }
           }
        }
    }
    
    
     public void populateChargeACV(Set<ID> zChargeIds) {
        if (zChargeIds != null && zChargeIds.size() > 0) {
            Map<Id, Id> quoteOppMap = new Map<Id, Id>();
            List<zqu__QuoteRatePlanCharge__c> zChargeList = getChargeListWithZQuoteOppDetail(zChargeIds);
       
            for (zqu__QuoteRatePlanCharge__c zCharge : zChargeList) {
                zCharge.ChargeACV__c = getChargeACV(zCharge);
            }
            if (!zChargeList.isEmpty()) update zChargeList; 
        }
    }
    
    public void populateChargeACVBefore(List<zqu__QuoteRatePlanCharge__c> QRPClist) {
        Set<Id> QRPIds = new Set<Id>();
        
        for (zqu__QuoteRatePlanCharge__c zCharge : QRPClist) { 
            if(zCharge.zqu__QuoteRatePlan__c != null) {
                QRPIds.add(zCharge.zqu__QuoteRatePlan__c);
            }
        }
        
        if(QRPIds != null && QRPIds.size() > 0) {
            Map<Id, zqu__QuoteRatePlan__c> ratePlanQuoteMap = getQuoteDetailfromQuoteRatePlan(QRPIds);
        
            
            for (zqu__QuoteRatePlanCharge__c zCharge : QRPClist) {
                Decimal ChargeACV = 0;
                
                if (zCharge.zqu__QuoteRatePlan__c != null) {
                    zCharge.ChargeACV__c = 0;
                    zqu__QuoteRatePlan__c ratePlan =  ratePlanQuoteMap.get(zCharge.zqu__QuoteRatePlan__c);  
                    
                    if(ratePlan != null) {
                        if ((zCharge.zqu__ChargeType__c == USAGE_CHARGE) || String.isNotEmpty(zCharge.MinimumChargeCode__c)
                                    || (zCharge.zqu__EffectivePrice__c == null) || (zCharge.zqu__EffectivePrice__c == 0)
                                    || (zCharge.zqu__EffectivePrice__c == 999999)) {
                            zCharge.ChargeACV__c = 0;
                            
                        } else if (zCharge.zqu__ChargeType__c == RECURRING_CHARGE) {
                            if (zCharge.zqu__Period__c == MONHTLY_PERIOD) {  
                                zCharge.ChargeACV__c = zCharge.zqu__EffectivePrice__c * 12;  
                            } else if (zCharge.zqu__Period__c == ANNUAL_PERIOD) {
                                zCharge.ChargeACV__c = zCharge.zqu__EffectivePrice__c; 
                            } 
                            
                        } else if (zCharge.zqu__ChargeType__c == ONE_TIME_CHARGE) {
                            if (ratePlan.zqu__Quote__r.zqu__SubscriptionType__c == NEW_SUBSCRIPTION) {
                                if (ratePlan.zqu__Quote__r.zqu__InitialTerm__c != null && 
                                        ratePlan.zqu__Quote__r.zqu__InitialTerm__c > 0) {
                                    zCharge.ChargeACV__c = (zCharge.zqu__EffectivePrice__c/ ratePlan.zqu__Quote__r.zqu__InitialTerm__c) *12;
                                } 
                                
                            } else if (ratePlan.zqu__Quote__r.zqu__SubscriptionType__c == AMEND_SUBSCRIPTION) {
                                if (ratePlan.zqu__Quote__r.zqu__SubscriptionTermEndDate__c != null && 
                                        ratePlan.zqu__Quote__r.zqu__StartDate__c != null) {
                                    Date amendEffectDate = ratePlan.zqu__Quote__r.zqu__StartDate__c;
                                    Date subscriptionEnddate = ratePlan.zqu__Quote__r.zqu__SubscriptionTermEndDate__c;
                                    integer monthDiff = getMonthDiff(amendEffectDate, subscriptionEnddate);
                                    zCharge.ChargeACV__c = (monthDiff > 0) ? (zCharge.zqu__EffectivePrice__c/ monthDiff )*12 : 0;
                                }
                            }
                        }  
                    }    
                } 
            }
        }
    }
    
    
    
    public Map<Id, zqu__QuoteRatePlan__c> getQuoteDetailfromQuoteRatePlan(Set<ID> zRatePlanIds) {
        Map<Id, zqu__QuoteRatePlan__c> quoteOppMap = new Map<Id, zqu__QuoteRatePlan__c>();
        for(zqu__QuoteRatePlan__c qrp :[SELECT Id, zqu__Quote__c, zqu__Quote__r.zqu__Primary__c, 
                                        zqu__Quote__r.zqu__Opportunity__c,
                                        zqu__Quote__r.Is_NCR_Quote__c,
                                        zqu__Quote__r.zqu__SubscriptionType__c, 
                                        zqu__Quote__r.zqu__InitialTerm__c,                                                                 
                                        zqu__Quote__r.zqu__StartDate__c, 
                                        zqu__Quote__r.zqu__SubscriptionTermStartDate__c,
                                        zqu__Quote__r.zqu__SubscriptionTermEndDate__c  
                                        FROM zqu__QuoteRatePlan__c 
                                        WHERE Id IN :zRatePlanIds AND
                                        zqu__AmendmentType__c NOT IN ('Original','') AND
                                        zqu__Quote__r.zqu__Opportunity__r.StageName NOT IN ('Closed/Booked','Closed/Lost','Closed/Discontinued') AND
                                        zqu__Quote__r.Is_NCR_Quote__c = false AND zqu__Quote__r.zqu__Status__c != 'Sent to Z-Billing' ]) {
            
            if (qrp.zqu__Quote__c != null && qrp.zqu__Quote__r.zqu__Primary__c && qrp.zqu__Quote__r.zqu__Opportunity__c != null) {
                quoteOppMap.put(qrp.Id, qrp );    
            }
        }
        return quoteOppMap;
    }
    
    
    public void calcChargeACV(Set<ID> zChargeIds, Boolean isDeleteOLI) {
        if (zChargeIds != null && zChargeIds.size() > 0) {
            Map<Id, Id> quoteOppMap = new Map<Id, Id>();
            List<zqu__QuoteRatePlanCharge__c> zChargeList = getChargeListWithZQuoteOppDetail(zChargeIds);
       
            for (zqu__QuoteRatePlanCharge__c zCharge : zChargeList) {
                
                if (zCharge.zqu__QuoteRatePlan__r.zqu__Quote__c != null && zCharge.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Primary__c 
                        && zCharge.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Opportunity__c != null) {
                    quoteOppMap.put(zCharge.zqu__QuoteRatePlan__r.zqu__Quote__c, zCharge.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Opportunity__c);
                }
            }
            if (!quoteOppMap.isEmpty()) {updateOppLineItems(quoteOppMap, isDeleteOLI);}
       }
    }
    
    
    
    
    /*public void calcACVByTopline(Set<ID> zQuoteIds) {
        if (zQuoteIds != null && zQuoteIds.size() > 0) {
            Map<Id, Id> quoteOppMap = new Map<Id, Id>();
            Map<Id, Map<Id, Decimal>> quoteToplineMap = new  Map<Id, Map<Id, Decimal>>();
            
            List<zqu__QuoteRatePlanCharge__c> zChargeList = [SELECT Id, ChargeACV__c,  
                                                                zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.Topline_Product__c,
                                                                zqu__QuoteRatePlan__r.zqu__Quote__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Opportunity__c
                                                                FROM zqu__QuoteRatePlanCharge__c
                                                                WHERE zqu__QuoteRatePlan__c != null AND
                                                                zqu__QuoteRatePlan__r.zqu__Quote__c != null AND 
                                                                zqu__QuoteRatePlan__r.zqu__Quote__c IN :zQuoteIds];
           
           Set<Id> toplineIds = new Set<Id>();                                                     
           Map<Id, Decimal> toplineMap;                                                     
           for (zqu__QuoteRatePlanCharge__c zCharge : zChargeList) {
               Id toplineId = zCharge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.Topline_Product__c;
               
               if(toplineId  != null) {
                   toplineIds.add(toplineId); 
                   toplineMap = quoteToplineMap.get(zCharge.zqu__QuoteRatePlan__r.zqu__Quote__c);
                   Decimal chargeACV = (zCharge.ChargeACV__c != null) ? zCharge.ChargeACV__c : 0;
                   
                   if (toplineMap == null) {
                       toplineMap = new Map<Id, Decimal>(); 
                       quoteToplineMap.put(zCharge.zqu__QuoteRatePlan__r.zqu__Quote__c, toplineMap);            
                   } 
                   Decimal totalACV = (toplineMap.get(toplineId) != null) ? toplineMap.get(toplineId) + chargeACV : chargeACV;
                   toplineMap.put(toplineId, totalACV);  
               }
               
               if (zCharge.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Opportunity__c != null) {
                   quoteOppMap.put(zCharge.zqu__QuoteRatePlan__r.zqu__Quote__c, zCharge.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Opportunity__c);            
               }
           }
           
           if (!quoteOppMap.isEmpty()) deleteOLIsFromOpp(quoteOppMap.values());
                   
           if ((!quoteToplineMap.isEmpty()) && (!toplineIds.isEmpty())) {
               Map<Id, Id> PrdPBEMap = getToplinePriceBookEntries(toplineIds);
               List<OpportunityLineItem> newOLIs = new List<OpportunityLineItem>();
                  
               for (Id quoteId :quoteToplineMap.keySet()) {
                   String OppId = quoteOppMap.get(quoteId);
                   Map<Id, Decimal> productMap = quoteToplineMap.get(quoteId);
                   
                   for(Id prdId : productMap.keySet()) {
                      OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = OppId, Quantity = 1);
                       oli.PricebookEntryId = PrdPBEMap.get(prdId);
                       oli.UnitPrice = productMap.get(prdId);       
                       newOLIs.add(oli);
                   }
               }  
               if (!newOLIs.isEmpty()) insert newOLIs; 
           }
        }
    } */
      
    private Decimal getChargeACV(zqu__QuoteRatePlanCharge__c zCharge) {
        Decimal ChargeACV = 0;
        
        if (zCharge != null) {
            if ((zCharge.zqu__ChargeType__c == USAGE_CHARGE) || String.isNotEmpty(zCharge.MinimumChargeCode__c)
                        || (zCharge.zqu__EffectivePrice__c == null) || (zCharge.zqu__EffectivePrice__c == 0)) {
                ChargeACV = 0;
                
            } else if (zCharge.zqu__ChargeType__c == RECURRING_CHARGE) {
                if (zCharge.zqu__Period__c == MONHTLY_PERIOD) {  
                    ChargeACV = zCharge.zqu__EffectivePrice__c * 12;  
                } else if (zCharge.zqu__Period__c == ANNUAL_PERIOD) {
                    ChargeACV = zCharge.zqu__EffectivePrice__c; 
                } 
                
            } else if (zCharge.zqu__ChargeType__c == ONE_TIME_CHARGE) {
                if (zCharge.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__SubscriptionType__c == NEW_SUBSCRIPTION) {
                    if (zCharge.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__InitialTerm__c != null && 
                            zCharge.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__InitialTerm__c > 0) {
                        ChargeACV = (zCharge.zqu__EffectivePrice__c/ zCharge.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__InitialTerm__c) *12;
                    } 
                    
                } else if (zCharge.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__SubscriptionType__c == AMEND_SUBSCRIPTION) {
                    if (zCharge.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__SubscriptionTermEndDate__c != null && 
                            zCharge.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__StartDate__c != null) {
                        Date amendEffectDate = zCharge.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__StartDate__c;
                        Date subscriptionEnddate = zCharge.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__SubscriptionTermEndDate__c;
                        integer monthDiff = getMonthDiff(amendEffectDate, subscriptionEnddate);
                        ChargeACV = (monthDiff > 0) ? (zCharge.zqu__EffectivePrice__c/ monthDiff )*12 : 0;
                    }
                }
            }    
        } 
        return ChargeACV;   
    }
    
    
    
    
    
    
    private integer getMonthDiff(Date startDate, Date endDate) {
        integer monthDiff = startDate.monthsBetween(endDate);  
        if (endDate.day() > startDate.day()) monthDiff++;
        return monthDiff;
    }
    
    public void deleteOLIsFromOpp(List<Id> oppIds) {
        if (oppIds != null && oppIds.size() > 0) {
            List<OpportunityLineItem> oliList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId IN :oppIds];
            if (!oliList.isEmpty()) {
                CheckRecursive.addValOppTriggerRun();
                delete oliList;
                CheckRecursive.resetOppAmountValidation();
            }
        }    
    }
    
    public void updateExistingOLIofOpp(Map<Id, Map<Id, Decimal>> quoteToplineMap, Map<Id, Id> quoteOppMap) {
        if (quoteOppMap != null && quoteOppMap.size() > 0 && quoteToplineMap != null && quoteToplineMap.size() > 0) {
            List<OpportunityLineItem> upsertOLIList = new List<OpportunityLineItem>();
            
            Map<Id, List<OpportunityLineItem>> oppOLIMap = new Map<Id, List<OpportunityLineItem>>();
            List<OpportunityLineItem> tempOLIList;
            for(OpportunityLineItem oli : [SELECT Id, OpportunityId, UnitPrice, Quantity, PricebookEntry.Product2Id FROM OpportunityLineItem WHERE OpportunityId IN :quoteOppMap.values()]) {
                tempOLIList = oppOLIMap.get(oli.OpportunityId);
                
                if(tempOLIList == null) {
                    tempOLIList = new List<OpportunityLineItem>();
                    oppOLIMap.put(oli.OpportunityId, tempOLIList);
                }
                tempOLIList.add(oli);
            }
            
            // IF NO TOPLINES EXIST ON OPPORUNITY, THEN NO TOPLINE UPDATE
            if(oppOLIMap != null && oppOLIMap.size() >  0) {
            
                for(Id quoteId : quoteToplineMap.keySet()) {
                    Map<Id, Decimal> toplineMap = quoteToplineMap.get(quoteId);  
                    Id OpportunityId = quoteOppMap.get(quoteId);
                    List<OpportunityLineItem> oliList = oppOLIMap.get(OpportunityId); 
                    
                    if((toplineMap != null) && (toplineMap.size() > 0) && (OpportunityId != null) && (oliList != null) && (oliList.size() > 0)) {
                        
                        for(Id tolplineId : toplineMap.keySet()) {
                            
                            for(OpportunityLineItem oli : oliList) {
                                if(tolplineId == oli.PricebookEntry.Product2Id) {
                                    oli.UnitPrice = toplineMap.get(tolplineId);
                                    upsertOLIList.add(oli);
                                }
                            }
                        }
                    }
                }
            
            }
            
            if(upsertOLIList!= null && upsertOLIList.size() > 0) {
                CheckRecursive.addValOppTriggerRun();
                upsert upsertOLIList;
                CheckRecursive.resetOppAmountValidation();
            }
        }    
        
    }
    
    private Map<Id, Id> getToplinePriceBookEntries(Set<Id> toplineIds) {
        Map<Id, Id> PrdPBEMap = new Map<Id, Id>();
        if (toplineIds != null && toplineIds.size() > 0) {
            String pbID = GlobalVariable.pricebookId;
            for (PricebookEntry pbe : [SELECT Id, Product2Id FROM PricebookEntry WHERE  Pricebook2Id =: pbID  and Product2Id IN :toplineIds and CurrencyIsoCode = 'USD' and IsActive = true]) {
                PrdPBEMap.put(pbe.Product2Id, pbe.Id);    
            
         }
       }  
        return PrdPBEMap;
    }
    
    public static boolean runACVCalcOnce() {
        if(runACVCalc){
            runACVCalc = false;
            return true;
        }else {
            return runACVCalc;
        }
   }

}