/*
##################################################################################################
# Project Name && Request Num..........: Deal Desk
# File............................: FileUploadController.cls                                                        
# Created by................: Mohammad Ahad                                                                   
# Created Date...........: 03/10/2017                                                                              
# Last Modified by......:  Mohammad Ahad
# Last Modified Date..: 05/23/2017
# Description...............: This class is used in File Upload Component for DealDesk Project.
################################################################################################
*/


public class FileUploadController {
    
    @AuraEnabled
    public  static string  saveTheFileSolBL(String recordId, String jsonCSVWrapperList, Boolean versionUpgrade) {
        List <Pricing_Bid_Log_Detail__c> pdList=new List<Pricing_Bid_Log_Detail__c>();
        List <CSVWrapper> CSVWrapperList=new List<CSVWrapper>();
        String msg='';
        Integer i=0;
        try{
            CSVWrapperList = (List <CSVWrapper>) JSON.deserialize(jsonCSVWrapperList, List<CSVWrapper>.class);
            if(CSVWrapperList!=null && recordId!=null){
                if(versionUpgrade){
                    Pricing_Bid_Log__c pbl=new Pricing_Bid_Log__c(id=recordId, create_Version__c=true);
                    update pbl;
                }
                Pricing_Bid_Log__c pblName = [select name from Pricing_Bid_Log__c where id =: recordId].get(0);
                for(CSVWrapper csvw:CSVWrapperList){
                    Pricing_Bid_Log_Detail__c pd=new Pricing_Bid_Log_Detail__c(Name=pblName.name +' no.'+i, pid__c=csvw.PID, WOT__c=csvw.WOT, Description__c=csvw.Description, Product_Category__c=csvw.Product_Category, Local_Currency__c=csvw.Local_Currency, Exchange_Rate__c=csvw.Exchange_Rate, Extended_List_Price_Per_Unit__c=csvw.Extended_List_Price, Extended_MRP_Per_Unit__c=csvw.Extended_MRP, 
                                                                               MRP_Discount__c=csvw.MRP_Discount,  Net_Price__c=csvw.Net_Price, Quantity__c=csvw.Qty, Product_Revenue__c=csvw.Product_Revenue, Controllable_GM__c=csvw.Controllable_GM, Standard_GM__c=csvw.Standard_GM, pricing_bid_log__c=recordId);
                    pdList.add(pd);
                    i++;
                }
                list <Pricing_Bid_log_detail__c> PBLDid = [select id, name, Pricing_Bid_log__c from Pricing_Bid_log_detail__c where Pricing_Bid_log__c=:recordId];
                try{
                    insert pdList;
                    msg='Successfully loaded the Solution Bid Log file:';   
                }
                catch (Exception e){
                    msg='Error: '+e.getMessage()+e.getLineNumber()+e.getStackTraceString()+e.getCause();
                } 
                if(msg == 'Successfully loaded the Solution Bid Log file:'){
                    delete PBLDid;
                }
            }else{
                msg='The File is corrupted or some Technical error occured, Please report to IDC, NSC <NI230033@ncr.com>';
                
            }
        }catch (Exception e){
            msg='Error: '+e.getMessage()+e.getLineNumber()+e.getStackTraceString()+e.getCause();
        } 
        return msg;
    }
    
    @AuraEnabled
    public  static string  saveTheFileSerBL(String recordId, String jsonCSVWrapList, Boolean versionUpgrade) {
        List <Pricing_Bid_Log_Detail__c> pdListSerBL=new List<Pricing_Bid_Log_Detail__c>();
        List <CSVWrapperServiceBL> CSVWrapList=new List<CSVWrapperServiceBL>();
        CSVWrapList = (List <CSVWrapperServiceBL>) JSON.deserialize( jsonCSVWrapList, List<CSVWrapperServiceBL>.class  );
        
        String msg='Error';
        Integer i=0;
        if(versionUpgrade){
            Pricing_Bid_Log__c pbl=new Pricing_Bid_Log__c(id=recordId, create_Version__c=true);
            try{
                update pbl;
            }
            catch (Exception e){
                msg=e.getMessage()+e.getLineNumber()+e.getStackTraceString()+e.getCause();
            }
            
            
        }
        Id RecordTypeIdSerPBLD = Schema.SObjectType.Pricing_Bid_Log_Detail__c.getRecordTypeInfosByName().get('Services Bid Log').getRecordTypeId();
        if(CSVWrapList!=null && recordId!=null){
            Pricing_Bid_Log__c pblName = [select name from Pricing_Bid_Log__c where id =: recordId].get(0);
            for(CSVWrapperServiceBL csvser:CSVWrapList){
                Pricing_Bid_Log_Detail__c pd=new Pricing_Bid_Log_Detail__c(Name=pblName.name+' no.'+i, BU_Warranty__c=csvser.BU_Warranty, BU_Warranty_SLA__c=csvser.BU_Warranty_SLA, 
                                                                           BU_Warranty_Term__c=csvser.BU_Warranty_Term, CAF_List_Price_Per_Unit__c=csvser.CAF_List_Price, Controllable_OI__c=csvser.Controllable_OI,
                                                                           Country__c=csvser.Country, Customer__c=csvser.Customer, Date__c=csvser.Date_dt,Deal_Desk_Analyst__c=csvser.Deal_Desk_Analyst, Division__c=csvser.Division, 
                                                                           Duration_of_Contract_Years__c=csvser.Duration_of_Contract, Erosion_Driver_Competitive_Innovation__c=csvser.Competitive_Innovation, Erosion_Driver_Cost_Pressure__c=csvser.Cost_Pressure,
                                                                           Erosion_Driver_NCR_Performance__c=csvser.NCR_Performance, Erosion_Driver_Unhappy_with_Incumbent__c=csvser.Unhappy_with_Incumbent, Erosion_Driver_Unhappy_with_NCR_service__c=csvser.Unhappy_with_NCR_service,  
                                                                           Exchange_Rate__c=csvser.Exchange_Rate, Extended_List_Price_Per_Unit__c=csvser.Extended_List_Price, Extended_MRP_Per_Unit__c=csvser.Extended_MRP, FLMY_Rate__c=csvser.FLMY_Rate, 
                                                                           GM_Only__c=csvser.GM, GM__c=csvser.GM_dollar, Installation_Total_Qty__c=csvser.Installation_Total_Qty, Installation_Unit_Cost__c=csvser.Installation_Unit_Cost, 
                                                                           Managed_Services__c=csvser.Managed_Services, MRP_Discount__c=csvser.MRP_Discount, Net_Price__c=csvser.Net_Price, Opportunity_Number__c=csvser.Opportunity_Number, 
                                                                           Price_Erosion_GM_Change__c=csvser.Price_Erosion_GM_Change, Product_Description__c=csvser.Product_Description, PID__c=csvser.PID, Price_Erosion_Price_Change__c=csvser.Price_Erosion_Price_Change, Product_Category__c=csvser.Product_Category, 
                                                                           Product_Revenue__c=csvser.Product_Revenue, Quantity__c=csvser.Quantity, RecordTypeId=RecordTypeIdSerPBLD, Region__c=csvser.Region, Regular_Charge_Unit_Discount__c=csvser.Regular_Charge_Unit_Discount, 
                                                                           Regular_Charge_Unit_Extended_Net__c=csvser.Regular_Charge_Unit_Extended_Net, Regular_Charge_Unit_Total_Discount__c=csvser.Regular_Charge_Unit_Total_Discount, 
                                                                           SAMY_rate__c=csvser.SAMY_rate, SAMY_Type__c=csvser.SAMY_Type, Scope_Erosion_GM_Change_USD__c=csvser.Scope_Erosion_USD, Scope_Erosion_GM_Change__c=csvser.Scope_Erosion_GM_Change, 
                                                                           Select_Erosion_Type__c=csvser.Select_Erosion_Type, ServiceNow_Opportunity_Number__c=csvser.ServiceNow_Opportunity_Number, SGM_Only__c=csvser.SGM, SGM__c=csvser.SGM_dollar, 
                                                                           SID__c=csvser.SID, SLA__c=csvser.SLA, SLA_Description__c=csvser.SLA_Description, Solution_Architect__c=csvser.Solution_Architect, SSC_Salesperson__c=csvser.SSC_Salesperson, 
                                                                           Standard_GM__c=csvser.Standard_GM, Total_Net_Revenue__c=csvser.Total_Net_Revenue, Total_Quantity_Labor_Hours__c=csvser.Total_Quantity_Labor_Hours, 
                                                                           Upgrade_Unit_Discount__c=csvser.Upgrade_Unit_Discount, Upgrade_Unit_Extended_Net__c=csvser.Upgrade_Unit_Extended_Net, Upgrade_Unit_Total_Discount__c=csvser.Upgrade_Unit_Total_Discount, pricing_bid_log__c=recordId);
                pdListSerBL.add(pd);
                i++;
            }
            list <Pricing_Bid_log_detail__c> PBLDidSer = [select id, name, Pricing_Bid_log__c from Pricing_Bid_log_detail__c where Pricing_Bid_log__c=:recordId];
            try{
                insert pdListSerBL;
                msg='Succesfully loaded the Services Bid Log file:';   
            }
            catch (Exception e){
                msg='Error: '+e.getMessage()+e.getLineNumber()+e.getStackTraceString()+e.getCause();
            } 
            
            if(msg == 'Succesfully loaded the Services Bid Log file:'){
                try{
                    delete PBLDidSer;
                }catch (Exception e){
                    msg='Error: '+e.getMessage()+e.getLineNumber()+e.getStackTraceString()+e.getCause();
                }
            }
        }else{
            msg='The File is corrupted or some Technical error occured, Please report to IDC, NSC <NI230033@ncr.com>';
        }
        return msg;
    }
    @AuraEnabled
    public static String getRecordTypeName(Id recordId)  
    {
        String RecordtypeName =[SELECT Id,recordtype.name FROM Pricing_Bid_Log__c  WHERE Id =: recordId][0].recordtype.name;
        //system.debug('&&&'+recordtype.name);
        if(RecordtypeName.contains('Solution'))
        {
            return 'SolutionBidLog';  
        } 
        
        else if(RecordtypeName.contains('Services')){
            return 'ServicesBidLog';  
        }
        else{
            return 'NoRecordTypeName';
        }
        
    } 
}