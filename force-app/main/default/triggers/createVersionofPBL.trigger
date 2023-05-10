trigger createVersionofPBL on Pricing_Bid_Log__c (after update) {
 	
	Id RecordTypeIdSolPBL = Schema.SObjectType.Pricing_Bid_Log__c.getRecordTypeInfosByName().get('Solution Bid Log').getRecordTypeId();
    Id RecordTypeIdSerPBL = Schema.SObjectType.Pricing_Bid_Log__c.getRecordTypeInfosByName().get('Services Bid Log').getRecordTypeId();	
    Id RecordTypeIdSolPBLVH = Schema.SObjectType.Pricing_bid_log_version_history__c.getRecordTypeInfosByName().get('Solution Bid Log').getRecordTypeId();
    Id RecordTypeIdSerPBLVH = Schema.SObjectType.Pricing_bid_log_version_history__c.getRecordTypeInfosByName().get('Services Bid Log').getRecordTypeId();
    
    
    
    list<Pricing_bid_log_version_history__c> createListPBLVH = new list<Pricing_bid_log_version_history__c>();
    
    
    for(Pricing_bid_log__c pbl:trigger.new){
        if((Trigger.oldMap.get(pbl.Id).lastmodifieddate != Trigger.newMap.get(pbl.Id).lastmodifieddate) && pbl.create_version__c == True){
            Pricing_bid_log_version_history__c pblvh = new Pricing_bid_log_version_history__c();
           if(trigger.oldmap.get(pbl.id).recordtypeid == RecordTypeIdSolPBL ){
                pblvh.recordTypeId = RecordTypeIdSolPBLVH;                
                }
            else if(trigger.oldmap.get(pbl.id).recordtypeid == RecordTypeIdSerPBL ){
                pblvh.recordTypeId = RecordTypeIdSerPBLVH;
            }
            pblvh.More_Detailed_Description__c = Trigger.oldMap.get(pbl.Id).More_Detailed_Description__c;
            pblvh.Bid_Status__c = Trigger.oldMap.get(pbl.Id).Bid_Status__c;
            pblvh.Discontinued_Reason__c= Trigger.oldMap.get(pbl.id).Discontinued_Reason__c;
            pblvh.Primary_Competitor__c = Trigger.oldMap.get(pbl.id).Primary_Competitor__c;
            pblvh.Key_Criteria__c = Trigger.oldMap.get(pbl.id).Key_Criteria__c;
            pblvh.Competitor_Offering__c = Trigger.oldMap.get(pbl.id).Competitor_Offering__c;
            pblvh.Price_Variance__c =  Trigger.oldMap.get(pbl.id).Price_Variance__c;
            pblvh.Analyst__c = Trigger.oldMap.get(pbl.Id).Analyst__c;
            pblvh.Analyst_Request_Date__c = Trigger.oldMap.get(pbl.Id).Analysis_Request_Date__c;
            pblvh.Approval_Level__c = Trigger.oldMap.get(pbl.Id).Approval_Level__c;
            pblvh.Customer__c = Trigger.oldMap.get(pbl.id).Customer__c;
            //pblvh.Bid_Number__c = pbl.Name;
            pblvh.Pricing_Bid_Log__c = pbl.id;
            pblvh.name=pbl.Bid_Number__c+ '_' +Trigger.oldMap.get(pbl.Id).Bid_Version__c;
            pblvh.Bid_Review_Date__c = Trigger.oldMap.get(pbl.Id).Bid_Review_Date__c;
            pblvh.Bid_Version__c = Trigger.oldMap.get(pbl.Id).Bid_Version__c;
            pblvh.Comments__c = Trigger.oldMap.get(pbl.Id).Comments__c;
            //pblvh.Country__c= Trigger.oldMap.get(pbl.Id).Country__c;
            pblvh.Customer__c= Trigger.oldMap.get(pbl.Id).Customer__c;
            pblvh.Current_Status__c= Trigger.oldMap.get(pbl.Id).Current_Status__c;
            pblvh.Direct__c= Trigger.oldMap.get(pbl.Id).Direct__c;
            pblvh.End_Customer__c= Trigger.oldMap.get(pbl.Id).End_Customer__c;
            pblvh.Industry__c= Trigger.oldMap.get(pbl.Id).Industry__c;
            pblvh.Materials_Receipt_Date__c= Trigger.oldMap.get(pbl.Id).Materials_Receipt_Date__c;
            pblvh.Negotiation_Price_Strategy__c= Trigger.oldMap.get(pbl.Id).Negotiation_Price_Strategy__c;
            pblvh.Opportunity_Number__c= Trigger.oldMap.get(pbl.Id).Opportunity_Number__c;
            system.debug('^^^'+Trigger.oldMap.get(pbl.Id).Opportunity_Number__c);
            pblvh.Quote_Number__c= Trigger.oldMap.get(pbl.Id).Quote_Number__c;
            pblvh.Rebid__c= Trigger.oldMap.get(pbl.Id).Rebid__c;
            pblvh.Total_Controllable_GM__c= Trigger.oldMap.get(pbl.Id).Total_Controllable_GM__c;
            pblvh.Total_Deal_Revenue__c= Trigger.oldMap.get(pbl.Id).Total_Deal_Revenue__c;
            pblvh.Quote_Type__c= Trigger.oldMap.get(pbl.Id).Quote_Type__c;
            pblvh.Second_Analyst__c = Trigger.oldMap.get(pbl.Id).Second_Analyst__c;
            pblvh.Deal_Type__c = Trigger.oldMap.get(pbl.Id).Deal_Type__c;
            pblvh.Is_there_any_Erosion__c = Trigger.oldMap.get(pbl.Id).Is_there_any_Erosion__c;
            pblvh.Erosion_Driver__c = Trigger.OldMap.get(pbl.id).Erosion_Driver__c;
            pblvh.GM_Change_in__c = Trigger.OldMap.get(pbl.id).GM_Change_in__c;
            pblvh.GM_Change_in_USd__c = Trigger.OldMap.get(pbl.id).GM_Change_in_USd__c;
            pblvh.Opportunity_Number_of_Opportunity__c = Trigger.OldMap.get(pbl.id).Opportunity_Number_of_Opportunity__c;
            pblvh.Opportunity_2__c = Trigger.OldMap.get(pbl.id).Opportunity_2__c;
            pblvh.Opportunity_Number_2__c = Trigger.OldMap.get(pbl.id).Opportunity_Number_2__c;
            pblvh.Opportunity_3__c = Trigger.OldMap.get(pbl.id).Opportunity_3__c;
            pblvh.Opportunity_4__c = Trigger.OldMap.get(pbl.id).Opportunity_4__c;
            pblvh.Opportunity_5__c = Trigger.OldMap.get(pbl.id).Opportunity_5__c;
            pblvh.Opportunity_6__c = Trigger.OldMap.get(pbl.id).Opportunity_6__c;
            
            createListPBLVH.add(pblvh);
        }
        //pbl.create_version__c = false;
    }
    if(createListPBLVH != null && createListPBLVH.size()>0 ){
        insert createListPBLVH;
    }
    
}