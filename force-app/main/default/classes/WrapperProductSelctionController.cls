/*
##################################################################################################
# Class Name............................:WrapperProductSelctionController.cls                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
public Class WrapperProductSelctionController{
    
    @AuraEnabled 
    public Boolean value{get;set;}
    
    @AuraEnabled 
    public Boolean HasQuantitySchedule {get;set;}
    
    @AuraEnabled
    public Decimal quantity{get;set;} 
        
    @AuraEnabled 
    public Decimal unitPrice{get;set;}
    
    @AuraEnabled 
    public Decimal totalValue{get;set;}
    
    @AuraEnabled 
    public Decimal totalACVValue{get;set;}
    
    @AuraEnabled 
    public Decimal OneTimeFee{get;set;}
    
    @AuraEnabled 
    public Decimal NoOfTerms{get;set;}
    
    //As a Service Pahse-2
    @AuraEnabled 
    public Decimal NoOfLicenses{get;set;}
    
   /* @AuraEnabled 
    public String source{get;set;}
    
    @AuraEnabled 
    public Decimal ListPrice{get;set;}
    
    @AuraEnabled 
    public Decimal Discount{get;set;}
    
    @AuraEnabled 
    public String PackageID{get;set;}
    
    @AuraEnabled 
    public String PackageName{get;set;}
    
    @AuraEnabled 
    public String SubPackageID{get;set;}
    
    @AuraEnabled 
    public String SubPackageName{get;set;}
    
    @AuraEnabled 
    public String MasterLineId{get;set;}
    
    @AuraEnabled 
    public Decimal Sites{get;set;}
    
    @AuraEnabled
    public Boolean isPackage {get;set;}
    
    @AuraEnabled
    public Boolean isCompanion {get;set;} */
    
    
    //As as service pahse 2 ends
    @AuraEnabled 
    public Decimal MonthlyFee{get;set;}
    
    @AuraEnabled 
    public Decimal scheduledvalue{get;set;}
    
    @AuraEnabled   
    public OpportunityLineItem productObj{get;set;}
    
    @AuraEnabled 
    public String ProductName{get;set;}
    
    @AuraEnabled  
    public String ProductId{get;set;}
    
    @AuraEnabled 
    public String OliId{get;set;}
    
    @AuraEnabled 
    public Boolean Eroorvalue{get;set;}
 
    @AuraEnabled 
    Public Boolean AvailableforSubscription{get;set;}
    
    @AuraEnabled 
    Public String qtyTyp{get;set;}
    
    @AuraEnabled 
    Public Boolean isCATMProduct{get;set;}
    
    @AuraEnabled Public String ProductCatogery{get;set;}
    
    /* commented to avoid empty blocks 
    public WrapperProductSelctionController() {
        
    } */
    
    public WrapperProductSelctionController(OpportunityLineItem ProductValue){
        value=false;
        Eroorvalue=false;
        productObj=ProductValue;
        ProductName=ProductValue.Product2.Name;
        quantity=ProductValue.Quantity;
        unitPrice=ProductValue.UnitPrice;
        totalValue=ProductValue.TotalPrice; 
        totalACVValue=ProductValue.Actual_Contract_Value__c;
        OneTimeFee=ProductValue.One_Time_Fee__c;
        NoOfTerms=ProductValue.Number_of_Terms__c;
        MonthlyFee=ProductValue.Monthly_Fee__c;
        //NoOfLicenses=ProductValue.Number_of_Licenses__c;
        ProductId=ProductValue.Product2Id;
        scheduledvalue=ProductValue.Unscheduled_Quantity__c;
        HasQuantitySchedule =ProductValue.HasQuantitySchedule;
        AvailableforSubscription=ProductValue.Is_Subscriptioned__c;
        ProductCatogery=ProductValue.Product2.Service_Offer_Category__c; 
        OliId=ProductValue.Id;
        qtyTyp=ProductValue.Qty_Type__c;
        isCATMProduct = (String.isNotBlank(ProductValue.Product2.OriginalCorporation__c) && ProductValue.Product2.OriginalCorporation__c.equalsIgnoreCase(System.Label.CATM_ORGCORP)) ? true : false;
        //isCatm=ProductValue.Opportunity.CATM_Record__c;
        //PAckage level fields
       /* source=ProductValue.source__c;
        ListPrice=ProductValue.ListPrice; 
        Discount=ProductValue.Discount;
        PackageID=ProductValue.Package_ID__c;
        PackageName=ProductValue.Package_Name__c;
        SubPackageID=ProductValue.Sub_Package_ID__c;
        SubPackageName=ProductValue.Sub_Package_Name__c; 
        MasterLineId=ProductValue.Master_Line_id__c; 
        Sites=ProductValue.Sites__c;
    isPackage=false;        
        if(ProductValue.Source__c=='Package'){
            isPackage=true;
            isCompanion=false;
        }
        if(ProductValue.Source__c=='Package-Inclusive'){
            isPackage=false;
            isCompanion=true;  
        } */
    }
    
}