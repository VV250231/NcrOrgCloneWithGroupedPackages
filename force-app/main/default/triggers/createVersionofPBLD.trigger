/*
##################################################################################################
# Project Name && Request Num..........: Deal Desk
# File............................:  createVersionofPBLD Trigger                                                      
# Created by................: Mohammad Ahad                                                                   
# Created Date...........: 17/10/2017                                                                              
# Last Modified by......:  Mohammad Ahad
# Last Modified Date..: 05/15/2017
# Description...............: This trigger we are using for creating the version of Pricing Bid log details. This trigger fires, when a 
							version of Pricing bId log is created and a record is inserted in Pricing Bid Log version History.
################################################################################################
*/
trigger createVersionofPBLD on Pricing_Bid_Log_Version_History__c (After insert) {
    
    Id RecordTypeIdSolPBLD = Schema.SObjectType.Pricing_Bid_Log_Detail__c.getRecordTypeInfosByName().get('Solution Bid Log').getRecordTypeId();
    Id RecordTypeIdSerPBLD = Schema.SObjectType.Pricing_Bid_Log_Detail__c.getRecordTypeInfosByName().get('Services Bid Log').getRecordTypeId();	
    Id RecordTypeIdSolPBLDVH = Schema.SObjectType.Pricing_Bid_Log_Detail_Version_History__c.getRecordTypeInfosByName().get('Solution Bid Log').getRecordTypeId();
    Id RecordTypeIdSerPBLDVH = Schema.SObjectType.Pricing_Bid_Log_Detail_Version_History__c.getRecordTypeInfosByName().get('Services Bid Log').getRecordTypeId();
   
                Set<Id> pblID = new Set<Id>();
                Set<Id> pblvhID = new Set<Id>(); 
                for(Pricing_Bid_Log_Version_History__c pblvh : trigger.new){
                    pblID.add(pblvh.Pricing_Bid_Log__c);
                    pblvhID.add(pblvh.id);
                }
               
    List<Pricing_Bid_Log_Detail__c> PBLDList = new List<Pricing_Bid_Log_Detail__c>();
    PBLDList = [select id, pricing_bid_log__c, pid__c, WOT__c, Description__c, Product_Category__c, Local_Currency__c,Exchange_Rate__c, Extended_List_Price_Per_Unit__c, Extended_MRP_Per_Unit__c, Net_Price__c, Quantity__c, Product_Revenue__c, Controllable_GM__c, Standard_GM__c, 
                BU_Warranty__c, BU_Warranty_SLA__c, BU_Warranty_Term__c, CAF_List_Price_Per_Unit__c, Controllable_OI__c,Country__c, Customer__c, Date__c, 
                Deal_Desk_Analyst__c, Division__c, Duration_of_Contract_Years__c, Erosion_Driver_Competitive_Innovation__c, 
                Erosion_Driver_Cost_Pressure__c, Erosion_Driver_NCR_Performance__c, Erosion_Driver_Unhappy_with_Incumbent__c,  Erosion_Driver_Unhappy_with_NCR_service__c,  
                FLMY_Rate__c, GM_Only__c, GM__c, Installation_Total_Qty__c, Installation_Unit_Cost__c, 
                Managed_Services__c, MRP_Discount__c, Opportunity_Number__c, Price_Erosion_GM_Change__c, Price_Erosion_Price_Change__c, Product_Description__c, 
                RecordTypeId, Region__c, Regular_Charge_Unit_Discount__c, Regular_Charge_Unit_Extended_Net__c, Regular_Charge_Unit_Total_Discount__c, SAMY_rate__c, SAMY_Type__c, 
                Scope_Erosion_GM_Change_USD__c, Scope_Erosion_GM_Change__c, Select_Erosion_Type__c, ServiceNow_Opportunity_Number__c, SGM_Only__c, SGM__c, SID__c, SLA__c, SLA_Description__c, 
                Solution_Architect__c, SSC_Salesperson__c, Total_Net_Revenue__c, Total_Quantity_Labor_Hours__c, Upgrade_Unit_Discount__c, Upgrade_Unit_Extended_Net__c, 
                Upgrade_Unit_Total_Discount__c from Pricing_Bid_Log_Detail__c  where pricing_bid_log__c =: pblID];
    		system.debug('^^^'+PBLDList);
            List<Pricing_Bid_Log_Detail_Version_History__c> insertListofPBLDVH = new List<Pricing_Bid_Log_Detail_Version_History__c>();
            for(Pricing_Bid_Log_Version_History__c pricingBidVersion : trigger.new){
                for(Pricing_Bid_Log_Detail__c pbld : PBLDList){
            
            Pricing_Bid_Log_Detail_Version_History__c pbldvh = new Pricing_Bid_Log_Detail_Version_History__c();
            pbldvh.Pricing_Bid_Log_Version_History__c = pricingBidVersion.id;
           if(pbld.RecordTypeId == RecordTypeIdSolPBLD){
                pbldvh.RecordTypeId = RecordTypeIdSolPBLDVH;
            }
            else if(pbld.RecordTypeId == RecordTypeIdSerPBLD){
                pbldvh.RecordTypeId = RecordTypeIdSerPBLDVH;
            }
            pbldvh.PID__c=pbld.PID__c;
            pbldvh.wot__c=pbld.wot__c;
            pbldvh.Description__c=pbld.Description__c;
            pbldvh.Product_Category__c=pbld.Product_Category__c; 
            pbldvh.Local_Currency__c=pbld.Local_Currency__c;
            pbldvh.Exchange_Rate__c=pbld.Exchange_Rate__c;
            pbldvh.Extended_List_Price_Per_Unit__c=pbld.Extended_List_Price_Per_Unit__c; 
            pbldvh.Extended_MRP_Per_Unit__c=pbld.Extended_MRP_Per_Unit__c; 
            pbldvh.Net_Price__c=pbld.Net_Price__c; 
            pbldvh.Quantity__c=pbld.Quantity__c; 
            pbldvh.Product_Revenue__c=pbld.Product_Revenue__c; 
            pbldvh.Controllable_GM__c=pbld.Controllable_GM__c; 
            pbldvh.Standard_GM__c=pbld.Standard_GM__c;
            
            pbldvh.BU_Warranty__c = pbld.BU_Warranty__c; 
            pbldvh.BU_Warranty_SLA__c = pbld.BU_Warranty_SLA__c; 
            pbldvh.BU_Warranty_Term__c = pbld.BU_Warranty_Term__c; 
            pbldvh.CAF_List_Price_Per_Unit__c = pbld.CAF_List_Price_Per_Unit__c; 
            pbldvh.Controllable_OI__c = pbld.Controllable_OI__c;
            pbldvh.Country__c=pbld.Country__c; 
            pbldvh.Customer__c=pbld.Customer__c; 
            pbldvh.Date__c=pbld.Date__c;
            pbldvh.Deal_Desk_Analyst__c = pbld.Deal_Desk_Analyst__c; 
            pbldvh.Division__c=pbld.Division__c; 
            pbldvh.Duration_of_Contract_Years__c=pbld.Duration_of_Contract_Years__c; 
            pbldvh.Erosion_Driver_Competitive_Innovation__c=pbld.Erosion_Driver_Competitive_Innovation__c; 
            pbldvh.Erosion_Driver_Cost_Pressure__c=pbld.Erosion_Driver_Cost_Pressure__c;
            pbldvh.Erosion_Driver_NCR_Performance__c=pbld.Erosion_Driver_NCR_Performance__c; 
            pbldvh.Erosion_Driver_Unhappy_with_Incumbent__c=pbld.Erosion_Driver_Unhappy_with_Incumbent__c; 
            pbldvh.Erosion_Driver_Unhappy_with_NCR_service__c=pbld.Erosion_Driver_Unhappy_with_NCR_service__c;  
            pbldvh.Exchange_Rate__c=pbld.Exchange_Rate__c; 
            pbldvh.Extended_List_Price_Per_Unit__c=pbld.Extended_List_Price_Per_Unit__c; 
            pbldvh.Extended_MRP_Per_Unit__c=pbld.Extended_MRP_Per_Unit__c; 
            pbldvh.FLMY_Rate__c=pbld.FLMY_Rate__c; 
            pbldvh.GM_Only__c=pbld.GM_Only__c; 
            pbldvh.GM__c=pbld.GM__c; 
            pbldvh.Installation_Total_Qty__c=pbld.Installation_Total_Qty__c; 
            pbldvh.Installation_Unit_Cost__c=pbld.Installation_Unit_Cost__c; 
            pbldvh.Managed_Services__c=pbld.Managed_Services__c; 
            pbldvh.MRP_Discount__c=pbld.MRP_Discount__c; 
            pbldvh.Net_Price__c=pbld.Net_Price__c; 
            pbldvh.Opportunity_Number__c=pbld.Opportunity_Number__c; 
            pbldvh.Price_Erosion_GM_Change__c=pbld.Price_Erosion_GM_Change__c; 
            pbldvh.Price_Erosion_Price_Change__c=pbld.Price_Erosion_Price_Change__c; 
            pbldvh.Product_Category__c=pbld.Product_Category__c; 
            pbldvh.Product_Description__c=pbld.Product_Description__c; 
            pbldvh.Quantity__c=pbld.Quantity__c; 
            //pbldvh.RecordTypeId='0124B0000004X1D'; 
            pbldvh.Region__c=pbld.Region__c; 
            pbldvh.Regular_Charge_Unit_Discount__c=pbld.Regular_Charge_Unit_Discount__c; 
            pbldvh.Regular_Charge_Unit_Extended_Net__c=pbld.Regular_Charge_Unit_Extended_Net__c; 
            pbldvh.Regular_Charge_Unit_Total_Discount__c=pbld.Regular_Charge_Unit_Total_Discount__c; 
            pbldvh.SAMY_rate__c=pbld.SAMY_rate__c; 
            pbldvh.SAMY_Type__c=pbld.SAMY_Type__c; 
            pbldvh.Scope_Erosion_GM_Change_USD__c=pbld.Scope_Erosion_GM_Change_USD__c; 
            pbldvh.Scope_Erosion_GM_Change__c=pbld.Scope_Erosion_GM_Change__c; 
            pbldvh.Select_Erosion_Type__c=pbld.Select_Erosion_Type__c; 
            pbldvh.ServiceNow_Opportunity_Number__c=pbld.ServiceNow_Opportunity_Number__c; 
            pbldvh.SGM_Only__c=pbld.SGM_Only__c; 
            pbldvh.SGM__c=pbld.SGM__c; 
            pbldvh.SID__c=pbld.SID__c; 
            pbldvh.SLA__c=pbld.SLA__c; 
            pbldvh.SLA_Description__c=pbld.SLA_Description__c; 
            pbldvh.Solution_Architect__c=pbld.Solution_Architect__c; 
            pbldvh.SSC_Salesperson__c=pbld.SSC_Salesperson__c; 
            pbldvh.Standard_GM__c=pbld.Standard_GM__c; 
            pbldvh.Total_Net_Revenue__c=pbld.Total_Net_Revenue__c; 
            pbldvh.Total_Quantity_Labor_Hours__c=pbld.Total_Quantity_Labor_Hours__c; 
            pbldvh.Upgrade_Unit_Discount__c=pbld.Upgrade_Unit_Discount__c; 
            pbldvh.Upgrade_Unit_Extended_Net__c=pbld.Upgrade_Unit_Extended_Net__c; 
            pbldvh.Upgrade_Unit_Total_Discount__c=pbld.Upgrade_Unit_Total_Discount__c;
            insertListofPBLDVH.add( pbldvh );
        }
    }
    
    if( insertListofPBLDVH != null && insertListofPBLDVH.size() > 0 )
        insert insertListofPBLDVH;
}