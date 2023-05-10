/****************************************************************************************************************
*   ClassName :   ProductSelectChildController
*   Description :   
*   Author      :   
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description
CSI-365           5th Jul 2022    Puneet Bhatia			 Added changes for CATM Products One Time Revenue
EBA_SF-2050       08/07/2022      Kapil Bhati            Added changes in the total cost and one time fee
****************************************************************************************************************/
public class ProductSelectChildController {
    @AuraEnabled 
    public static void UpdateProductvalue(Double UnitPrice,Double TotalValue,Double Quantity,Double OneTimeFee,Double NoOfTerms,String OliId,Boolean isAvialableForSubscription,String ProductCatogery,String qtyTyp, Boolean isCATMProduct, Boolean isCATMOpp){
        //system.debug('isAvialableForSubscription'+isAvialableForSubscription);
        //Opportunity o=[Select id, name,CATM_Record__c from Opportunity where id =: mainOppId];
        Set<String> qtyTypeVal = new Set<String>(); 
        OpportunityLineItem oli_Obj= new OpportunityLineItem();
        List<OpportunityLineItem> oppPkgLines=new List<OpportunityLineItem>();
        
        NoOfTerms = (NoOfTerms != null ? NoOfTerms : 0);
        OneTimeFee = (OneTimeFee != null ? OneTimeFee : 0);
        //if(!isPackage){
            oli_Obj.Id=OliId;
            oli_Obj.Quantity=Double.valueOf(Quantity);
            oli_Obj.Number_of_Terms__c=Double.valueOf(NoOfTerms);
            if(isAvialableForSubscription || ProductCatogery=='Cloud' || isCATMProduct){
                //oli_Obj.UnitPrice= oli_Obj.UnitPrice*12;
                //oli_Obj.UnitPrice=                
                oli_Obj.One_Time_Fee__c=Double.valueOf(OneTimeFee);
                oli_Obj.Number_of_Terms__c=Double.valueOf(NoOfTerms);
                
                
                //oli_obj.Total_Cost_Value__c=Double.valueOf(OneTimeFee)*Double.valueOf(Quantity)+Double.valueOf(Quantity)*Double.valueOf(NoOfTerms)*Double.valueOf(UnitPrice);
                 // EBA_SF-2050 change done by Kapil Bhati 
                if(isCATMOpp) {
                	oli_obj.Total_Cost_Value__c=Double.valueOf(OneTimeFee)*Double.valueOf(Quantity)+Double.valueOf(Quantity)*Double.valueOf(NoOfTerms)*Double.valueOf(UnitPrice);    
                } else {
                    oli_obj.Total_Cost_Value__c=Double.valueOf(OneTimeFee)+Double.valueOf(Quantity)*Double.valueOf(NoOfTerms)*Double.valueOf(UnitPrice);
                }
                if(Double.valueOf(NoOfTerms)>12){
                    oli_obj.Actual_Contract_Value__c=Double.valueOf(Quantity)*12*Double.valueOf(UnitPrice);
                }else{
                    oli_obj.Actual_Contract_Value__c=Double.valueOf(Quantity)*Double.valueOf(NoOfTerms)*Double.valueOf(UnitPrice);
                }
                if(oli_obj.Total_Cost_Value__c!=null && oli_obj.Total_Cost_Value__c>0){
                    oli_Obj.UnitPrice=oli_obj.Total_Cost_Value__c/Double.valueOf(Quantity);  
                }          
                oli_Obj.Monthly_Fee__c=Double.valueOf(UnitPrice);
            }else{
                oli_Obj.UnitPrice=Double.valueOf(UnitPrice);
                oli_Obj.Actual_Contract_Value__c = Double.valueOf(Quantity) * Double.valueOf(UnitPrice);
                oli_Obj.Total_Cost_Value__c = Double.valueOf(Quantity) * Double.valueOf(UnitPrice);
            }
            oli_Obj.Qty_Type__c=qtyTyp;

        /*****************************Package Logic*********************************/
        /*else{ 
            oli_Obj.Id=OliId;
            oli_Obj.One_Time_Fee__c=Double.valueOf(OneTimeFee); //oneTimeFee
            oli_Obj.Monthly_Fee__c=Double.valueOf(UnitPrice); //Monthly Fee
            //oli_Obj.Monthly_Fee__c=;
           // oli_Obj.Number_of_Licenses__c=Double.valueOf(NoOfLicenses); //NoOfLicenses
            oli_Obj.Number_of_Terms__c=Double.valueOf(NoOfTerms); //# of Months
            oli_Obj.Sites__c=  Double.valueOf(Sites); //# ofSites
            Sites= Double.valueOf(Sites); //quantity    
            
            oli_obj.Total_Cost_Value__c=Double.valueOf(OneTimeFee)*Sites+Sites*Double.valueOf(NoOfTerms)*Double.valueOf(UnitPrice);
            if(Double.valueOf(NoOfTerms)>12){
                oli_obj.Actual_Contract_Value__c=Sites*12*Double.valueOf(UnitPrice);
            }else{
                oli_obj.Actual_Contract_Value__c=Sites*Double.valueOf(NoOfTerms)*Double.valueOf(UnitPrice);
            }
           // oli_Obj.Quantity= Double.valueOf(Sites)*Double.valueOf(NoOfLicenses); 
            if(oli_obj.Total_Cost_Value__c!=null && oli_obj.Total_Cost_Value__c>0){
                oli_Obj.UnitPrice=oli_obj.Total_Cost_Value__c/oli_Obj.Quantity;  
            }
            //Fetch all OLI related to package and set Number Of Terms, ACV, TCV accoedingly
           // oppPkgLines=getAllPackageProducts(OliId, oppid);
            
       // } */
        
        /*****************************************************************************/
        
        //system.debug('oli_Obj----------------------------------------------------------'+oli_Obj);
        
        try{
            Update oli_Obj;
            /*if(isPackage && oppPkgLines.size()>0){
                for(OpportunityLineItem oli:oppPkgLines){
                    oli.Number_of_Terms__c=oli_Obj.Number_of_Terms__c;
                    if(Double.valueOf(NoOfTerms)>12){
                        oli_obj.Actual_Contract_Value__c=oli.Sites__c*12*oli.Monthly_Fee__c;
                    }else{
                        oli.Actual_Contract_Value__c=oli.Sites__c*oli_Obj.Number_of_Terms__c*oli.Monthly_Fee__c;
                    }
                    oli.Total_Cost_Value__c=Double.valueOf(oli.One_Time_Fee__c)*oli.Sites__c+oli.Sites__c*oli_Obj.Number_of_Terms__c*oli.Monthly_Fee__c;
                    oli.TotalPrice= oli.Total_Cost_Value__c;
                    
                }
                oppPkgLines.add(oli_Obj);
                update oppPkgLines; 
            } */
             //else{
               // update oli_Obj;
            //}
        }
        
        catch(Exception e){
            System.debug('Exception Occur ::::::: '+e);
            throw new AuraHandledException('Something went wrong: '
                                           + e.getMessage());
        }
        
    } 
    
    /*@AuraEnabled 
    public static List<OpportunityLineItem> packageHierarchyDetails(String masterLineId,String oppid){
        //List<OpportunityLineItem> prddata=[SELECT id,name,Product_Category__c,Quantity from OpportunityLineItem where Master_Line_id__c = :masterLineId and Source__c='Package'];  
        List<OpportunityLineItem> prddata=[ select id,name,source__c,Product2.Name,Product2.Service_Offer_Category__c,Product_Category__c,Quantity,Package_ID__c,Package_Name__c,Sub_Package_ID__c,
                                           Sub_Package_Name__c,Master_Line_id__c from OpportunityLineItem
                                           where OpportunityId =: oppid and Product2.Service_Offer_Category__c<>null and Master_Line_id__c=: masterLineId  
                                           Order By  Master_Line_id__c Desc];
        return prddata;
    } */
   /* @AuraEnabled 
    public static List<OpportunityLineItem> getAllPackageProducts(String masterLineId,String oppid){
        //List<OpportunityLineItem> prddata=[SELECT id,name,Product_Category__c,Quantity from OpportunityLineItem where Master_Line_id__c = :masterLineId and Source__c='Package'];  
        List<OpportunityLineItem> pkgDirect=[ select id,Product2.Name,UnitPrice, Quantity, TotalPrice, Total_Cost_Value__c,source__c,Actual_Contract_Value__c,Number_of_Licenses__c,One_Time_Fee__c,Sites__c,Monthly_Fee__c,Number_of_Terms__c,Revenue_Type__c,Is_Subscriptioned__c,   Master_Line_id__c from OpportunityLineItem
                                             where OpportunityId =: oppid  and Master_Line_id__c=: masterLineId  
                                            ];
        List<Id> subPackages=new List<Id>();
        for(OpportunityLineItem oli:pkgDirect){
            if(oli.source__c.toUpperCase()=='PACKAGE'){
                subPackages.add(oli.id);
            }
        }
        List<OpportunityLineItem> subpkgDirect=[ select id,Product2.Name,UnitPrice, Quantity, TotalPrice, Total_Cost_Value__c,source__c,Actual_Contract_Value__c,Number_of_Licenses__c,One_Time_Fee__c,Sites__c,Monthly_Fee__c,Number_of_Terms__c,Revenue_Type__c,Is_Subscriptioned__c,   Master_Line_id__c from OpportunityLineItem
                                                where OpportunityId =: oppid  and Master_Line_id__c IN: subPackages  
                                               ];
        pkgDirect.addAll(subpkgDirect);
        return pkgDirect;
    } */
    
    
   /* @AuraEnabled
    public static String deletePackage(String packageOliId, String recordId) { 
        return PS_Schedule_NewClass.deletePackage(packageOliId, recordId ) ;
        
    } */
    @AuraEnabled 
    public static Map<String, String> getQtyTypes(){
        Map<String, String> options = new Map<String, String>();
        
        for (Schema.PicklistEntry p: OpportunityLineItem.Qty_Type__c.getDescribe().getPicklistValues()) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
       
   
}