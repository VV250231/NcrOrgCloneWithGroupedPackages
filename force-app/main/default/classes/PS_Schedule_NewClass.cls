/****************************************************************************************************************
*   ClassName :   PS_Schedule_NewClass
*   Description :   
*   Author      :   
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName            Description
EBA_SF-2497       22nd Dec 2022   Puneet Bhatia	     Added changes in getOpportunity method for Product Scheduler Format Changes (non-CATM)
****************************************************************************************************************/ 
public class PS_Schedule_NewClass {
    
    @AuraEnabled
    public static boolean isCommunity(){
        Id siteId = Site.getSiteId();
        if (siteId != null) {
            return true;
        }
        return false;
    }
    
    @AuraEnabled 
    public static Profile getUserInfo(){
        Profile profile = [SELECT Id FROM Profile WHERE Id =:userInfo.getProfileId()];
        return profile; 
    }
    
    /*@AuraEnabled
public static List<AAS_Functionality_Assignment__c> aasFunctionalityAccess(){
User userDetails =[SELECT Id,Profile.Name,UserRole.Name FROM User where Id=:userinfo.getUserId() ];   
List<AAS_Functionality_Assignment__c> assUsers= [select Profile_Name__c,Role_Name__c,UserId__c from AAS_Functionality_Assignment__c where (Role_Name__c=: userDetails.UserRole.Name and Role_Name__c !=null) or Profile_Name__c=:userDetails.Profile.Name or UserId__c=:userDetails.Id ];
//List<AAS_Functionality_Assignment__c> assUsers= [select Profile_Name__c,Role_Name__c,UserId__c from AAS_Functionality_Assignment__c where Role_Name__c like :('%'+userDetails.UserRole.Name+'%') or Profile_Name__c like :('%'+userDetails.Profile.Name+'%') or UserId__c like :('%'+userDetails.Id+'%') ];
return assUsers;
} */
    
    @AuraEnabled
    public static List<dataWrapper> getData(Id OppId) {
        //  set<Id> SetOfAdmin = new Set<id>{'00e70000000x3egAAA'};
        //Changes done by Yogesh - related to Story EBA_SF-1918
        set<Id> SetOfAdmin= NSCCommonInfoUtil.getIdSetOf('PS_SCH_AdmnPrfId');
        String Catm180DaysRestriction = System.Label.CATM_Cant_Update_Closed_Opportunities_180days;
        //End by Yogesh
        List<OpportunityLineitem> OliHWProduct = new List<OpportunityLineitem>();
        List<OpportunityLineitem> OliSWProduct = new List<OpportunityLineitem>();
        List<OpportunityLineitem> OliServiceProduct = new List<OpportunityLineitem>();
        List<OpportunityLineitem> OliPackageProduct = new List<OpportunityLineitem>();
        List<dataWrapper> returnList = new List<dataWrapper>();  
        //done by sushant
        for( OpportunityLineitem oli : [ select id,name, source__c,Product2.Name,Opportunity.CloseDate,Opportunity.IsClosed,Opportunity.Name,
                                        Opportunity.CurrencyIsoCode, Opportunity.Expected_Delivery_Date__c, OpportunityId, Product2.Service_Offer_Category__c,
                                        (Select id,OpportunityLineItemId,Quantity,ScheduleDate,Type  from OpportunityLineItemSchedules where Quantity > 0 and
                                         ScheduleDate < :GlobalVariable.unhandledQtyDate Order by ScheduleDate),Product_Category__c,UnitPrice,Quantity,
                                        TotalPrice,Unscheduled_Quantity__c, HasQuantitySchedule, Is_Subscriptioned__c,One_Time_Fee__c,Number_of_Terms__c,
                                        Total_Cost_Value__c,Actual_Contract_Value__c,Monthly_Fee__c, ListPrice, Discount,Qty_Type__c, Product2.OriginalCorporation__c from OpportunityLineItem where OpportunityId =:OppId Order By Master_Line_id__c Desc, CreatedDate Asc]  ){
                                            //Qty_Type__c added by stuti
                                            //done by sushant ends 
                                            //system.debug('oli-----'+oli);
                                            //###Added For Package @Ajay, Puneet, Sushant ###
                                            if(!String.isEmpty(oli.source__c)){               
                                                OliPackageProduct.add(oli);   
                                            }
                                            else if(oli.Product_Category__c == 'SW' ){
                                                //System.debug('in SW 1111');
                                                OliSWProduct.add(oli);
                                            }
                                            else if(oli.Product_Category__c == 'HW'){
                                                OliHWProduct.add(oli);
                                            }
                                            else{
                                                OliServiceProduct.add(oli);
                                            }
                                        }
        /* if(OliPackageProduct.size()>0){
getPackageProducts(OliPackageProduct, returnList, SetOfAdmin) ; 
} */
        for(OpportunityLineitem oli: OliSWProduct ){
            dataWrapper DW = new dataWrapper();
            productWrapper PRW = new productWrapper();
            
            PRW.productID = oli.id;            
            PRW.Name = oli.Product2.Name;
            PRW.UnitPrice = oli.UnitPrice;
            PRW.Quantity = oli.Quantity;
            PRW.TotalPrice = oli.TotalPrice;
            //added by Sushant
            PRW.TotalACVPrice=oli.Actual_Contract_Value__c;
            PRW.TotalTCVPrice=oli.Total_Cost_Value__c;
            PRW.NumberOfTerms=oli.Number_of_Terms__c;
            PRW.OneTimeFee=oli.One_Time_Fee__c;
            PRW.MonthlyFee=oli.Monthly_Fee__c;
            //system.debug('##'+PRW.MonthlyFee);  
            //added by Sushant ends
            PRW.Unscheduled_Quantity = oli.Unscheduled_Quantity__c;
            PRW.RevenueType = oli.Product2.Service_Offer_Category__c ;
            PRW.isSubscriptioned = oli.Is_Subscriptioned__c ;
            //PRW.isPackage=false;
            PRW.Source=oli.Source__c;
            PRW.qtyTyp=oli.Qty_Type__c; //added by Stuti
            PRW.isCATMProduct = (String.isNotBlank(oli.Product2.OriginalCorporation__c) && oli.Product2.OriginalCorporation__c.equalsIgnoreCase(System.Label.CATM_ORGCORP)) ? true : false;
                
            /*if(oli.Is_Subscriptioned__c == true || oli.Product2.Service_Offer_Category__c == 'Cloud') {
//PRW.UnitPrice = oli.UnitPrice/12 ;
if(oli.TotalPrice!=null && oli.TotalPrice  > 0) 
PRW.UnitPrice = (oli.TotalPrice - (oli.One_Time_Fee__c * oli.Quantity)) /(oli.Quantity * oli.Number_of_Terms__c);
else 
PRW.UnitPrice = 0;   
}*/
            
            if(oli.Unscheduled_Quantity__c>0){
                PRW.UnchStyleClass = 'unchYellow';
            }
            else if(oli.Unscheduled_Quantity__c==0){
                PRW.UnchStyleClass = 'unchGreen';
            }
            else{
                PRW.UnchStyleClass = 'unchRed';
            }
            
            List<PermissionSetAssignment> userhasPS=[SELECT Id,Assignee.Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, 
                                           PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment 
                                           WHERE Assignee.id =:UserInfo.getUserId() and PermissionSet.Name=:Catm180DaysRestriction];
            system.debug('userhasPS-----'+userhasPS.size());
            if(SetOfAdmin.contains(UserInfo.getProfileId()) || userhasPS.size() >0){
                DW.IsClosed = false;
            } else if(!SetOfAdmin.contains(UserInfo.getProfileId()) && oli.Opportunity.IsClosed){
                DW.IsClosed = true;
            }
            DW.EDD = oli.Opportunity.Expected_Delivery_Date__c;
            DW.EBD = oli.Opportunity.CloseDate;
            DW.Name = oli.Opportunity.Name;
            DW.Currenci = oli.Opportunity.CurrencyIsoCode;
            DW.PW = PRW;
            
            DW.ISWList = new List<itemScheduleWrapper>();
            for( OpportunityLineItemSchedule OLIS : oli.OpportunityLineItemSchedules ){
                itemScheduleWrapper ISWR = new itemScheduleWrapper(); 
                ISWR.ScheduleID = OLIS.id;
                ISWR.productID = oli.id;            
                ISWR.Quantity = OLIS.Quantity;
                ISWR.schMonth = OLIS.ScheduleDate.month();
                ISWR.schYear = OLIS.ScheduleDate.year();
                DW.ISWList.add( ISWR );
            }
            returnList.add( DW );
            
        }
        for(OpportunityLineitem oli: OliServiceProduct ){
            dataWrapper DW = new dataWrapper();
            productWrapper PRW = new productWrapper();
            PRW.productID = oli.id;            
            PRW.Name = oli.Product2.Name;
            PRW.UnitPrice = oli.UnitPrice;
            PRW.Quantity = oli.Quantity;
            PRW.TotalPrice = oli.TotalPrice;
            
            //added by Sushant
            PRW.TotalACVPrice=oli.Actual_Contract_Value__c;
            PRW.TotalTCVPrice=oli.Total_Cost_Value__c;
            PRW.NumberOfTerms=oli.Number_of_Terms__c;
            PRW.OneTimeFee=oli.One_Time_Fee__c;
            PRW.MonthlyFee=oli.Monthly_Fee__c;
            //system.debug('##'+PRW.MonthlyFee);   
            //added by Sushant ends
            PRW.Unscheduled_Quantity = oli.Unscheduled_Quantity__c;
            PRW.RevenueType = oli.Product2.Service_Offer_Category__c ;
            PRW.isSubscriptioned = oli.Is_Subscriptioned__c ;
            //PRW.isPackage=false;
            PRW.Source=oli.Source__c;
            PRW.qtyTyp=oli.Qty_Type__c; //by Stuti
            PRW.isCATMProduct = (String.isNotBlank(oli.Product2.OriginalCorporation__c) && oli.Product2.OriginalCorporation__c.equalsIgnoreCase(System.Label.CATM_ORGCORP)) ? true : false;
            /*
if(oli.Is_Subscriptioned__c == true || oli.Product2.Service_Offer_Category__c == 'Cloud') {
//PRW.UnitPrice = oli.UnitPrice/12 ;
if(oli.TotalPrice!=null && oli.TotalPrice  > 0) 
PRW.UnitPrice = (oli.TotalPrice - (oli.One_Time_Fee__c * oli.Quantity)) /(oli.Quantity * oli.Number_of_Terms__c);
else 
PRW.UnitPrice = 0;   
}*/
            if(oli.Unscheduled_Quantity__c>0){
                PRW.UnchStyleClass = 'unchYellow';
            }
            else if(oli.Unscheduled_Quantity__c==0){
                PRW.UnchStyleClass = 'unchGreen';
            }
            else{
                PRW.UnchStyleClass = 'unchRed';
            }
            
            List<PermissionSetAssignment> userhasPS=[SELECT Id,Assignee.Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, 
                                           PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment 
                                           WHERE Assignee.id =:UserInfo.getUserId() and PermissionSet.Name=:Catm180DaysRestriction];
            system.debug('userhasPS-----'+userhasPS.size());
            if(SetOfAdmin.contains(UserInfo.getProfileId()) || userhasPS.size() > 0){
                DW.IsClosed = false;
            } else if(!SetOfAdmin.contains(UserInfo.getProfileId()) && oli.Opportunity.IsClosed){
                DW.IsClosed = true;
            }
            DW.PW = PRW;
            DW.EDD = oli.Opportunity.Expected_Delivery_Date__c;
            DW.EBD = oli.Opportunity.CloseDate;
            DW.Name = oli.Opportunity.Name;
            DW.Currenci = oli.Opportunity.CurrencyIsoCode;
            DW.ISWList = new List<itemScheduleWrapper>();
            for( OpportunityLineItemSchedule OLIS : oli.OpportunityLineItemSchedules ){
                itemScheduleWrapper ISWR = new itemScheduleWrapper();
                ISWR.ScheduleID = OLIS.id;
                ISWR.productID = oli.id;            
                ISWR.Quantity = OLIS.Quantity;
                ISWR.schMonth = OLIS.ScheduleDate.month();
                ISWR.schYear = OLIS.ScheduleDate.year();
                DW.ISWList.add( ISWR );
            }
            returnList.add( DW ); 
        }
        for(OpportunityLineitem oli: OliHWProduct ){
            dataWrapper DW = new dataWrapper();
            productWrapper PRW = new productWrapper();
            PRW.productID = oli.id;            
            PRW.Name = oli.Product2.Name;
            PRW.UnitPrice = oli.UnitPrice;
            PRW.Quantity = oli.Quantity;
            PRW.TotalPrice = oli.TotalPrice;
            
            //added by Sushant
            PRW.TotalACVPrice=oli.Actual_Contract_Value__c;
            PRW.TotalTCVPrice=oli.Total_Cost_Value__c;
            PRW.NumberOfTerms=oli.Number_of_Terms__c;
            PRW.OneTimeFee=oli.One_Time_Fee__c;
            PRW.Source=oli.Source__c;
            PRW.MonthlyFee=oli.Monthly_Fee__c;    
            //system.debug('##'+PRW.MonthlyFee); 
            //added by Sushant ends
            PRW.Unscheduled_Quantity = oli.Unscheduled_Quantity__c;
            PRW.RevenueType = oli.Product2.Service_Offer_Category__c ;
            PRW.isSubscriptioned = oli.Is_Subscriptioned__c ;
            PRW.qtyTyp=oli.Qty_Type__c; //by Stuti
            PRW.isCATMProduct = (String.isNotBlank(oli.Product2.OriginalCorporation__c) && oli.Product2.OriginalCorporation__c.equalsIgnoreCase(System.Label.CATM_ORGCORP)) ? true : false;
            // PRW.isPackage=false;
            /*
if(oli.Is_Subscriptioned__c == true || oli.Product2.Service_Offer_Category__c == 'Cloud') {
//PRW.UnitPrice = oli.UnitPrice/12 ;
if(oli.TotalPrice!=null && oli.TotalPrice  > 0) 
PRW.UnitPrice = (oli.TotalPrice - (oli.One_Time_Fee__c * oli.Quantity)) /(oli.Quantity * oli.Number_of_Terms__c);
else 
PRW.UnitPrice = 0;   
}*/
            if(oli.Unscheduled_Quantity__c>0){
                PRW.UnchStyleClass = 'unchYellow';
            }
            else if(oli.Unscheduled_Quantity__c==0){
                PRW.UnchStyleClass = 'unchGreen';
            }
            else{
                PRW.UnchStyleClass = 'unchRed';
            }
            
            List<PermissionSetAssignment> userhasPS=[SELECT Id,Assignee.Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, 
                                           PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment 
                                           WHERE Assignee.id =:UserInfo.getUserId() and PermissionSet.Name=:Catm180DaysRestriction];
            system.debug('userhasPS-----'+userhasPS.size());
            
            if(SetOfAdmin.contains(UserInfo.getProfileId()) || userhasPS.size() >0){
                DW.IsClosed = false;
            } else if(!SetOfAdmin.contains(UserInfo.getProfileId()) && oli.Opportunity.IsClosed){
                DW.IsClosed = true;
            }
            DW.PW = PRW;
            DW.EDD = oli.Opportunity.Expected_Delivery_Date__c;
            DW.EBD = oli.Opportunity.CloseDate;
            DW.Name = oli.Opportunity.Name;
            DW.Currenci = oli.Opportunity.CurrencyIsoCode;
            DW.ISWList = new List<itemScheduleWrapper>();
            for( OpportunityLineItemSchedule OLIS : oli.OpportunityLineItemSchedules ){
                itemScheduleWrapper ISWR = new itemScheduleWrapper();
                ISWR.ScheduleID = OLIS.id;
                ISWR.productID = oli.id;            
                ISWR.Quantity = OLIS.Quantity;
                ISWR.schMonth = OLIS.ScheduleDate.month();
                ISWR.schYear = OLIS.ScheduleDate.year();
                DW.ISWList.add( ISWR );
            }
            returnList.add( DW ); 
        }    
        return  returnList; 
    }        
    // method created for Package handling    
    /*public static List<dataWrapper> getPackageProducts(List<OpportunityLineitem> PackageLine, List<dataWrapper> returnList, set<Id> SetOfAdmin){
List<OpportunityLineitem> packageLineSorted=new List<OpportunityLineitem>();
Set<id> packageSubPackageIdSet=new Set<id>();
//Sorting the list package ans subpackages together
for(OpportunityLineitem oli: PackageLine ){
if(oli.Source__c.toUpperCase()=='PACKAGE' && String.isEmpty(oli.Master_Line_Id__c)){
//add packages  
packageLineSorted.add(oli);
packageSubPackageIdSet.add(oli.id);
//add Sub Packages
for(OpportunityLineitem oliSub: PackageLine ){
if(oliSub.Master_Line_Id__c==oli.id){
packageLineSorted.add(oliSub);  
packageSubPackageIdSet.add(oliSub.id);
}
}
}
}
//rest add PRoducts of PAckage and Sub Package
for(OpportunityLineitem oli: PackageLine ){
if(!packageSubPackageIdSet.contains(oli.id)){
packageLineSorted.add(oli);                    
}
}

for(OpportunityLineitem oli: packageLineSorted ){
dataWrapper DW = new dataWrapper();
productWrapper PRW = new productWrapper();
PRW.productID = oli.id;            
PRW.Name = oli.Product2.Name;
PRW.UnitPrice = oli.UnitPrice;
// masking Quantity with Sites in Packages
PRW.Quantity = oli.Quantity;
PRW.TotalPrice = oli.TotalPrice;
PRW.TotalACVPrice=oli.Actual_Contract_Value__c;
PRW.TotalTCVPrice=oli.Total_Cost_Value__c;
PRW.NumberOfTerms=oli.Number_of_Terms__c;
PRW.OneTimeFee=oli.One_Time_Fee__c;
PRW.MonthlyFee=oli.Monthly_Fee__c;    
PRW.Unscheduled_Quantity = oli.Unscheduled_Quantity__c;
PRW.RevenueType = oli.Product2.Service_Offer_Category__c ;
PRW.isSubscriptioned = oli.Is_Subscriptioned__c ;
PRW.isPackage=false;
PRW.Source=oli.Source__c;
if(oli.Source__c.equalsIgnoreCase('Package')){
PRW.isPackage=true;   
}
if(oli.Source__c.equalsIgnoreCase('Package-Inclusive')){
PRW.isCompanion=true;  
}
// ###Added For Package @Ajay, Puneet, Sushant ###
PRW.NumberOfLicense=oli.Number_of_Licenses__c;
PRW.NumberOfSites=oli.Sites__c;
PRW.MasterLineId=oli.Master_Line_Id__c;
if(oli.Unscheduled_Quantity__c>0){
PRW.UnchStyleClass = 'unchYellow';
}
else if(oli.Unscheduled_Quantity__c==0){
PRW.UnchStyleClass = 'unchGreen';
}
else{
PRW.UnchStyleClass = 'unchRed';
}

if(SetOfAdmin != null && SetOfAdmin.contains(UserInfo.getProfileId())){
DW.IsClosed = false;
} else if( SetOfAdmin!=null && !SetOfAdmin.contains(UserInfo.getProfileId()) && oli.Opportunity.IsClosed){
DW.IsClosed = true;
} else if(SetOfAdmin == null ) {
DW.IsClosed = null ;
}
DW.PW = PRW;
DW.EDD = oli.Opportunity.Expected_Delivery_Date__c;
DW.EBD = oli.Opportunity.CloseDate;
DW.Name = oli.Opportunity.Name;
DW.Currenci = oli.Opportunity.CurrencyIsoCode;
DW.ISWList = new List<itemScheduleWrapper>();
system.debug(oli+'**'+oli.OpportunityLineItemSchedules);
for( OpportunityLineItemSchedule OLIS : oli.OpportunityLineItemSchedules ){
itemScheduleWrapper ISWR = new itemScheduleWrapper();
ISWR.ScheduleID = OLIS.id;
ISWR.productID = oli.id;            
ISWR.Quantity = oli.Source__c.toUpperCase()=='PACKAGE'?OLIS.Quantity/oli.Number_of_Licenses__c:OLIS.Quantity;
ISWR.schMonth = OLIS.ScheduleDate.month();
ISWR.schYear = OLIS.ScheduleDate.year();
DW.ISWList.add( ISWR );
}
returnList.add( DW ); 
}   
system.debug('**11'+returnList);
return returnList;
} */
    
    public class dataWrapper{
        @AuraEnabled
        public boolean IsClosed{get;set;}
        @AuraEnabled
        public date EDD{get;set;}
        @AuraEnabled
        public date EBD{get;set;}
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public String Currenci{get;set;}
        @AuraEnabled
        public productWrapper PW{get;set;}
        @AuraEnabled
        public List<itemScheduleWrapper> ISWList{get;set;}
        
        
    }
    
    public class productWrapper{
        @AuraEnabled
        public string productID{get;set;}
        @AuraEnabled
        public string Name{get;set;}
        @AuraEnabled
        public decimal UnitPrice{get;set;}
        @AuraEnabled
        public decimal Quantity{get;set;}
        @AuraEnabled
        public decimal TotalPrice{get;set;}
        //added by Sushant
        @AuraEnabled
        public decimal MonthlyFee{get;set;}
        @AuraEnabled
        public decimal TotalTCVPrice{get;set;}
        @AuraEnabled
        public decimal TotalACVPrice{get;set;}
        @AuraEnabled
        public decimal NumberOfTerms{get;set;}
        @AuraEnabled
        public decimal OneTimeFee{get;set;}
        //added by Sushant ends
        @AuraEnabled
        public decimal Unscheduled_Quantity{get;set;}
        @AuraEnabled
        public String UnchStyleClass{get;set;}
        @AuraEnabled
        public String RevenueType{get;set;}
        //CodeAdded By PK185150
        @AuraEnabled
        public String ReasonCode{get;
                                 set; 
                                }
        //CodeAdded By PK185150
        @AuraEnabled
        public String qtyTyp{get;set;} //by Stuti EBA-2072
        @AuraEnabled
        public Boolean isSubscriptioned ;
        @AuraEnabled
        public Boolean isCATMProduct;
        // ###Added For Package @Ajay, Puneet, Sushant ###        
        /* @AuraEnabled
public Boolean isPackage ;
@AuraEnabled
public Boolean isCompanion ;
@AuraEnabled
public decimal NumberOfLicense{get;set;}
@AuraEnabled
public decimal NumberOfSites{get;set;}
@AuraEnabled
public String MasterLineId{get;set;} */
        @AuraEnabled
        public String Source{get;set;}
        
    }
    
    public class itemScheduleWrapper{   
        @AuraEnabled
        public string productID{get;set;}
        @AuraEnabled
        public string ScheduleID{get;set;}
        @AuraEnabled
        public decimal Quantity{get;set;}
        @AuraEnabled
        public integer schMonth{get;set;}
        @AuraEnabled
        public integer schYear{get;set;}
    }
    @AuraEnabled
    Public static Opportunity getOpportunityById(Id OppId){
        //set<Id> SetOfAdmin = new Set<id>{'00e70000000x3egAAA'};
        set<Id> SetOfAdmin= NSCCommonInfoUtil.getIdSetOf('PS_SCH_AdmnPrfId');
        Opportunity opp = [Select id,name,Expected_Delivery_Date__c,CloseDate,isClosed,StageName from Opportunity where id=: OppId];
        if(SetOfAdmin.contains(UserInfo.getProfileId()))
            opp.StageName = 'Open';
        else if(!SetOfAdmin.contains(UserInfo.getProfileId()) &&
                (opp.StageName =='Closed/Booked'|| opp.StageName =='Closed/Booked - NonFunnel'|| 
                 opp.StageName =='Closed/Lost'|| opp.StageName =='Closed/Discontinued'))
            opp.StageName = 'Close';
        return opp;
    }
    
    @AuraEnabled
    public static String removeSchedule(String[] SelectedProductid, String recordId) { 
        //system.debug('SelectedProductid'+SelectedProductid);
        //system.debug('recordId'+recordId);
        String msg;
        try{
            List<OpportunityLineItem> opplist= [select id,Product2Id,Name  from OpportunityLineItem where OpportunityId =:recordId AND Product2Id IN:SelectedProductid ];
            Delete opplist;       
        } 
        catch(Exception e) {  msg= e.getMessage();}
        //system.debug('msg'+msg);
        return msg;  
    }
    @AuraEnabled
    public static String removeOLI(String[] SelectedProductid, String recordId) { 
        //system.debug('SelectedProductid'+SelectedProductid);
        //system.debug('recordId'+recordId);
        String msg;
        try{
            List<OpportunityLineItem> opplist= [select id,Product2Id,Name  from OpportunityLineItem where OpportunityId =:recordId AND Id IN:SelectedProductid ];
            Delete opplist;       
        } 
        catch(Exception e) { msg= e.getMessage();}
        //system.debug('msg'+msg);
        return msg;  
    }
    
    /*@future
public static void deletePackageinFuture(String packageOliId, String recordId) {
deletePackage(packageOliId, recordId);     
}

@AuraEnabled
public static String deletePackage(String packageOliId, String recordId) {

String msg='Package successfully removed from Opportunity';
List<OpportunityLineItem> delPkgLine=new List<OpportunityLineItem> ();
Set<String> subpkgID=new Set<String>();
try{
// fetching all lines to avoid SOQL
List<OpportunityLineItem> opplist= [select id,Product2Id,Name, Master_Line_Id__c, Source__c  from OpportunityLineItem where OpportunityId =:recordId];
//iterate to find package, product and subpackages
for(OpportunityLineItem oli:opplist)   {
if(oli.id==packageOliId){
delPkgLine.add(oli);  
}
if(oli.Master_Line_Id__c==packageOliId){
if(oli.Source__c.toUpperCase()=='PACKAGE'){
delPkgLine.add(oli); 
subpkgID.add(oli.id);  
}else{
delPkgLine.add(oli);   
}
}
} 
//iterate again to find sub pkg product
for(OpportunityLineItem oli:opplist)   {
if(subpkgID.contains(oli.Master_Line_Id__c)){
delPkgLine.add(oli);   
}

} 
Delete delPkgLine;
} 
catch(Exception e) 
{ 
msg= 'ERROR: '+e.getMessage();
}
system.debug('msg'+msg);
return msg;  
} */
    
    @AuraEnabled
    public static list<productWrapper> InsertOpportunityLineItemPS(String[] Product_Selected_From_Favorite_Section, String Oppid, Boolean[] isSubscriptioned, String[] servLineItemTypes, String[] HWMMntcTypes, String[] qtyTypes) {  
        //ProductSelection.InsertOpportunityLineItem(Product_Selected_From_Favorite_Section, Oppid);
        list<productWrapper> NewOlis = new list<productWrapper>();
        list<String> ProductName= new list<String>();
        list<Boolean> CATMProducts = new list<Boolean>();
        String spricebookId = GlobalVariable.pricebookId;
        String Msg;  
        Opportunity o = [Select o.Id, 
                         o.Pricebook2Id,
                         o.CurrencyIsoCode,
                         o.CATM_Record__c, 
                         o.Contract_Term_Mths__c
                         from Opportunity o  
                         where o.Id = :Oppid];
        
        ID pricebookId = o.Pricebook2Id;
        if(pricebookId == null) {
            pricebookId = spricebookId;
            //Pricebook2 pb2 = [Select p.Description, p.Id, p.Name from Pricebook2 p where p.Id = :pricebookId];
            //save the pricebook into opportunity
            o.Pricebook2Id = [Select p.Description, p.Id, p.Name from Pricebook2 p where p.Id = :pricebookId].get(0).Id;
            
            try { update o; 
            } catch(Exception e){                
                System.debug('Exception Caught'+e.getMessage());
                throw new AuraHandledException(e.getMessage()); 
            }
            
        }    
        
        try {
            if(pricebookId != null) {
                // try{
                List<ID> productIdList = new List<ID>();
                for(String cp2 : Product_Selected_From_Favorite_Section) {
                    productIdList.add(cp2);
                }
                List<PricebookEntry> pbeList = [Select p.CurrencyIsoCode, 
                                                p.Id, 
                                                p.Name, 
                                                p.Pricebook2Id, 
                                                p.Product2Id,
                                                p.Product2.Name,
                                                p.Product2.Service_Offer_Category__c ,
                                                p.ProductCode, 
                                                p.UseStandardPrice,
                                                p.IsActive,
                                                p.Product2.OriginalCorporation__c 
                                                From PricebookEntry p  
                                                Where p.Pricebook2Id = :pricebookId
                                                and p.CurrencyIsoCode = :o.CurrencyIsoCode                                              
                                                and p.Product2Id in :productIdList
                                               ];
                List<OpportunityLineItem> addOLIlist = new List<OpportunityLineItem>();
                List<CurrencyType> clist = [Select c.ConversionRate from CurrencyType c where c.IsoCode = :o.CurrencyIsoCode];
                Double conversionRate = clist[0].ConversionRate;
                Integer ik =0;
                Boolean isCATMPrd = false;
                for(String cp2 : Product_Selected_From_Favorite_Section) {
                    OpportunityLineItem aoli = new OpportunityLineItem();
                    aoli.OpportunityId = o.id;
                    aoli.ServiceDate = System.today();  
                    
                    Double totalPriceInUSD = 0.00;
                    
                    aoli.Quantity = 1; 
                    aoli.UnitPrice = 0.00;
                    aoli.Is_Subscriptioned__c = isSubscriptioned[ik] ;
                    //aoli.HasRevenueSchedule=false;
                    
                    if(servLineItemTypes != NULL && servLineItemTypes.size() > 0) {
                        String servType =  servLineItemTypes[ik];
                        
                        if(String.isNotBlank(servType)) {
                            aoli.Opportunity_Line_Item_Type__c = servType;
                        }
                    }
                    
                    if(HWMMntcTypes != NULL && HWMMntcTypes.size() > 0 && String.isNotBlank(HWMMntcTypes[ik])) {                                              
                    	aoli.Maintenance_Type__c = HWMMntcTypes[ik];                    
                    }
                    
                    if(qtyTypes != NULL && qtyTypes.size() > 0 && String.isNotBlank(qtyTypes[ik])) {                                              
                    	aoli.Qty_Type__c = qtyTypes[ik];                    
                    }
                    
                    if(o != null && o.CATM_Record__c) {
               			aoli.Number_of_Terms__c = o.Contract_Term_Mths__c; 	   
                	}
                    //aoli.PSM__c = cp2.oppProduct.PSM__c; // retalix to ncr migration
                    
                    for(Integer i = 0; i < pbeList.size(); i++) {
                        PricebookEntry pbe = (PricebookEntry) pbeList[i];
                        if(pbe.Product2Id == cp2) {
                            aoli.PricebookEntryId = pbe.Id;
                            aoli.Revenue_Type__c = pbe.Product2.Service_Offer_Category__c ;
                            ProductName.add(pbe.Product2.Name);
                            isCATMPrd = (String.isNotBlank(pbe.Product2.OriginalCorporation__c) && pbe.Product2.OriginalCorporation__c.equalsIgnoreCase(System.Label.CATM_ORGCORP)) ? true : false;
                            CATMProducts.add(isCATMPrd);
                            break;
                        }
                    }
                    addOLIList.add(aoli);
                    ik++ ;
                    // producnameList
                }
                if(addOLIlist.size() > 0) {                             
                    insert addOLIlist;
                    Integer index=0;
                    for(OpportunityLineItem obj:addOLIlist){
                        productWrapper pW = new productWrapper();
                        pW.productID = obj.id;
                        pW.Name = ProductName[index];
                        pW.UnitPrice = 0;
                        pW.Quantity = obj.Quantity;
                        pW.TotalPrice = 0;
                        //done by sushant
                        pw.TotalTCVPrice = 0;
                        pw.TotalACVPrice = 0;
                        pw.NumberOfTerms = obj.Number_of_Terms__c;
                        pw.OneTimeFee = 0;
                        pw.MonthlyFee =0;
                        //done by sushant ends
                        pW.Unscheduled_Quantity = 1;
                        pW.UnchStyleClass = 'unchYellow';
                        pW.RevenueType = obj.Revenue_Type__c ;
                        pW.isSubscriptioned = obj.Is_Subscriptioned__c ; 
                        pW.qtyTyp=obj.Qty_Type__c;
                        pW.isCATMProduct = CATMProducts[index];
                        // pW.isPackage=false;
                        //pW.isCompanion=false;
                        // ###Added For Package @Ajay, Puneet, Sushant ###
                        //pW.NumberOfLicense=0;
                        //pW.NumberOfSites=0;
                        //pW.MasterLineId='';
                        NewOlis.add(pW);
                        index++;
                    }
                }
                /* }
catch(Exception e){
system.debug(e.getMessage());
//Msg = e.getMessage();
//return Msg;
}*/
            }
        }  catch(DmlException e) {            
            throw new AuraHandledException(e.getDmlMessage(0));           		     
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());  
        } 
        return NewOlis;   
        
    }
    @AuraEnabled    
    public Static String SubmitManegeSchedule(String JsonStringSubmit){
        //system.debug('@@@@@'+JsonStringSubmit);
        return ProductScheduleController.SubmitManegeSchedule(JsonStringSubmit); 
    }
    
    
    @AuraEnabled
    public static Date getCurrentDate(){
        return System.today() ;
    }
    
    /*@AuraEnabled
public static list<productWrapper> fetchAddedPackageDetails( String Oppid, String masterOLI) { 
list<productWrapper> NewOlis = new list<productWrapper>();
List<OpportunityLineItem> oliList= getAllPackageProducts(masterOLI, Oppid);
for(OpportunityLineItem obj:oliList){
productWrapper pW = new productWrapper();
pW.productID = obj.id;
pW.Name = obj.product2.Name;
pW.UnitPrice = obj.UnitPrice;
pW.Quantity = obj.Quantity;
pW.TotalPrice = obj.TotalPrice;
//done by sushant
pw.TotalTCVPrice = obj.Total_Cost_Value__c;
pw.TotalACVPrice = obj.Actual_Contract_Value__c;
pw.NumberOfTerms = obj.Number_of_Terms__c;
pw.OneTimeFee = obj.One_Time_Fee__c;
pw.MonthlyFee =obj.Monthly_Fee__c;
//done by sushant ends
pW.Unscheduled_Quantity = obj.Sites__c;
pW.UnchStyleClass = 'unchYellow';
pW.RevenueType = obj.Revenue_Type__c ;
pW.isSubscriptioned = obj.Is_Subscriptioned__c ;
/*if(obj.Source__c.equalsIgnoreCase('Package')){
pW.isPackage=true;   
}
//if(obj.Source__c.equalsIgnoreCase('Package-Inclusive')){
//   pW.isCompanion=true;  
//}
//pW.NumberOfLicense=obj.Number_of_Licenses__c;
//pW.NumberOfSites=obj.Sites__c;
//pW.MasterLineId=obj.Master_Line_Id__c;
NewOlis.add(pW);
}
return NewOlis;
} */
    
    /* @AuraEnabled 
public static List<OpportunityLineItem> getAllPackageProducts(String masterLineId,String oppid){
List<OpportunityLineItem> pkgDirect=[ select id,Product2.Name,UnitPrice, Quantity, TotalPrice, Total_Cost_Value__c,source__c,Actual_Contract_Value__c,Number_of_Licenses__c,One_Time_Fee__c,Sites__c,Monthly_Fee__c,Number_of_Terms__c,Revenue_Type__c,Is_Subscriptioned__c,   Master_Line_id__c from OpportunityLineItem
where OpportunityId =: oppid  and (Master_Line_id__c=: masterLineId  OR id=:masterLineId) order by Master_Line_id__c asc
];
List<Id> subPackages=new List<Id>();
for(OpportunityLineItem oli:pkgDirect){
if(oli.source__c.toUpperCase()=='PACKAGE' && oli.Master_Line_id__c!=null){
subPackages.add(oli.id);
}
}
List<OpportunityLineItem> subpkgDirect=[ select id,Product2.Name,UnitPrice, Quantity, TotalPrice, Total_Cost_Value__c,source__c,Actual_Contract_Value__c,One_Time_Fee__c,Monthly_Fee__c,Number_of_Terms__c,Revenue_Type__c,Is_Subscriptioned__c from OpportunityLineItem
where OpportunityId =: oppid  and Master_Line_id__c IN: subPackages 
];
pkgDirect.addAll(subpkgDirect);
return pkgDirect;
} */
    @AuraEnabled
    public static SubsProductWrapper getSubsOnlyProd(){     
        Set<String> SubsProdSet= new Set<String>(); 
        Set<String> SubsRevenueSet= new Set<String>();
        
        SubsProductWrapper subsProdWrapObj= new subsProductWrapper();
        List<Subscription_only_products__c> subsProdList=  Subscription_only_products__c.getall().values();
        
        if(subsProdList.size()>0){            
            if(String.isNotBlank(subsProdList[0].Product_Name__c)){
                for(String prodName : subsProdList[0].Product_Name__c.split(',')){
                    SubsProdSet.add(prodname);            
                }
                if(String.isNotBlank(subsProdList[0].Product_Revenue_Type__c)){
                    for(String revenueType : subsProdList[0].Product_Revenue_Type__c.split(',')){
                        SubsRevenueSet.add(revenueType);               
                    }
                }
            }
            
            subsProdWrapObj.ProductNames = SubsProdSet;
            subsProdWrapObj.RevenueTypes = SubsRevenueSet;
            
            
        }
        return subsProdWrapObj;
    } 
    
    public class SubsProductWrapper{
        @AuraEnabled public Set<String> ProductNames{get;set;}
        @AuraEnabled public Set<String> RevenueTypes{get;set;}
    }
    
    @AuraEnabled 
    public static Map<String, String> getQtyTypes(){
        Map<String, String> options = new Map<String, String>();
        
        for (Schema.PicklistEntry p: OpportunityLineItem.Qty_Type__c.getDescribe().getPicklistValues()) {
            
            options.put(p.getLabel(), p.getValue());
        }
        return options;
    }
   @AuraEnabled
    public static Opportunity getOpportunity(String OppId){
         Opportunity opp=[Select id, Catm_Record__c,Contract_Term_Mths__c,CurrencyIsoCode from Opportunity where id=:OppId];
        system.debug('opp check'+opp);
         return opp;
        
    } 
}