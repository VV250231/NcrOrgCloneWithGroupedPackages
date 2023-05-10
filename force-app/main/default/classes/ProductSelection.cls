/****************************************************************************************************************
*   ClassName :   ProductScheduleController
*   Description :   
*   Author      :   
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description
CSI-365           5th Jul 2022    Puneet Bhatia			 Added changes for CATM Products One Time Revenue
EBA_SF-2491       19-12-2022      Monika               JDK Locale impact - Upgrade API Part 5  
****************************************************************************************************************/
public class ProductSelection{

    @AuraEnabled 
    public static List<WrapperProductSelctionController> getProductList(String recordId)
    {
        string Message;
        Map<Id, OpportunityLineitem> mapIdtoOLIObj = new Map<Id,OpportunityLineitem >() ;
        List<OpportunityLineitem> OliPackageProduct = new List<OpportunityLineitem>();
        list<WrapperProductSelctionController> ProductList = new List<WrapperProductSelctionController>(); 
        try{
            for(OpportunityLineItem ProductObj : [ select id,name,source__c,Product2.Name,Opportunity.CloseDate,Opportunity.IsClosed,Opportunity.Name,Opportunity.CurrencyIsoCode, Opportunity.Expected_Delivery_Date__c, OpportunityId, Product2.Service_Offer_Category__c, (Select id,OpportunityLineItemId,Quantity,ScheduleDate,Type from OpportunityLineItemSchedules where Quantity > 0 and ScheduleDate < :GlobalVariable.unhandledQtyDate Order by ScheduleDate),Product_Category__c,UnitPrice,Quantity,TotalPrice,Unscheduled_Quantity__c, HasQuantitySchedule, Is_Subscriptioned__c,One_Time_Fee__c,Number_of_Terms__c,Total_Cost_Value__c,Actual_Contract_Value__c,Monthly_Fee__c, Qty_Type__c,product2.OriginalCorporation__c from OpportunityLineItem where OpportunityId =:recordId and ((Opportunity.CATM_Record__c = TRUE and product2.OriginalCorporation__c='Cardtronics') OR (Opportunity.CATM_Record__c = FALSE and product2.OriginalCorporation__c!='Cardtronics'))]  ){
                // [Select id,Monthly_Fee__c,Number_of_Terms__c,One_Time_Fee__c,Total_Cost_Value__c,Actual_Contract_Value__c,Product2.Service_Offer_Category__c,Name,Quantity,Unscheduled_Quantity__c,Is_Subscriptioned__c,TotalPrice,UnitPrice,Product2Id,Product2.Name,Product2.Available_for_Subscription__c,Product2.Product_Category__c, HasQuantitySchedule,Number_of_Licenses__c, ListPrice, Discount, Package_ID__c,Package_Name__c,Sub_Package_ID__c, Sub_Package_Name__c, Master_Line_id__c,Sites__c,Source__c, OpportunityId from OpportunityLineItem where OpportunityId = :recordId Order By Package_ID__c Desc]){
               // if(String.isEmpty(ProductObj.source__c)){
                    ProductList.add(new WrapperProductSelctionController(ProductObj));
              //  } 
            
              //else {
                //    OliPackageProduct.add(ProductObj);  
                //}
                mapIdtoOLIObj.put(ProductObj.Id, ProductObj);
            }
           /* if(!OliPackageProduct.isEmpty() ) {
                handlePackageSorting(OliPackageProduct, ProductList , null , mapIdtoOLIObj) ;
            } */
            
            } 
            catch (ListException e) {
               Message= e.getMessage();  
            } 
            catch (Exception e) {
                 Message= e.getMessage();
            } 
        /*if(String.isNotBlank(Message)) {
           // System.assert(false, '>>>>>ERR >>' + Message) ;
        } commented empty block */
            system.debug('ProductList------------------------------------------'+ProductList);
        return ProductList;
    }
    
    
   
   /* public static List<WrapperProductSelctionController> handlePackageSorting(List<OpportunityLineitem> PackageLine, List<WrapperProductSelctionController> returnList, set<Id> SetOfAdmin , Map<Id, OpportunityLineItem> mapIdtoOLIObj){
        // List<PS_Schedule_NewClass.dataWrapper> returnListFromPS = new List<PS_Schedule_NewClass.dataWrapper>(); 
        // convertDataWrapperToProductSelectionWrapper() ;
        List<PS_Schedule_NewClass.dataWrapper> passListToPS = new List<PS_Schedule_NewClass.dataWrapper>(); 
        PS_Schedule_NewClass.getPackageProducts( PackageLine , passListToPS , null) ;
        convertDataWrapperToProductSelectionWrapper(passListToPS, returnList , mapIdtoOLIObj ) ;
        return returnList ;
    } */
    
    /*public static List<WrapperProductSelctionController> convertDataWrapperToProductSelectionWrapper(List<PS_Schedule_NewClass.dataWrapper> passListToPS , List<WrapperProductSelctionController> returnList, Map<Id, OpportunityLineItem> mapIdtoOLIObj ) {
       OpportunityLineItem ProductValue ;
        for(PS_Schedule_NewClass.dataWrapper sourceRecd :  passListToPS ) {
            WrapperProductSelctionController destinationObj = new WrapperProductSelctionController() ;
            destinationObj.value=false;
            destinationObj.Eroorvalue=false;
            ProductValue =  mapIdtoOLIObj.get(sourceRecd.PW.productID) ;
            destinationObj.productObj=  ProductValue;
            destinationObj.ProductName=ProductValue.Product2.Name;
            destinationObj.quantity=ProductValue.Quantity;
            destinationObj.unitPrice=ProductValue.UnitPrice; 
            destinationObj.totalValue=ProductValue.TotalPrice;
            destinationObj.OneTimeFee=ProductValue.One_Time_Fee__c;
            destinationObj.NoOfTerms=ProductValue.Number_of_Terms__c;
            destinationObj.MonthlyFee=ProductValue.Monthly_Fee__c;
            destinationObj.NoOfLicenses=ProductValue.Number_of_Licenses__c;
            destinationObj.ProductId=ProductValue.Product2Id;
            destinationObj.scheduledvalue=ProductValue.Unscheduled_Quantity__c;
            destinationObj.HasQuantitySchedule =ProductValue.HasQuantitySchedule;
            destinationObj.AvailableforSubscription=ProductValue.Is_Subscriptioned__c;
            destinationObj.ProductCatogery=ProductValue.Product2.Service_Offer_Category__c; 
            destinationObj.OliId=ProductValue.Id;
            //PAckage level fields
            /*destinationObj.source=ProductValue.source__c;
            destinationObj.ListPrice=ProductValue.ListPrice; 
            destinationObj.Discount=ProductValue.Discount;
            destinationObj.PackageID=ProductValue.Package_ID__c;
            destinationObj.PackageName=ProductValue.Package_Name__c;
            destinationObj.SubPackageID=ProductValue.Sub_Package_ID__c;
            destinationObj.SubPackageName=ProductValue.Sub_Package_Name__c; 
            destinationObj.MasterLineId=ProductValue.Master_Line_id__c; 
            destinationObj.Sites=ProductValue.Sites__c;
            destinationObj.isPackage= sourceRecd.PW.isPackage;
            destinationObj.isCompanion= sourceRecd.PW.isCompanion; 
           returnList.add(destinationObj) ;
        }
        return returnList ;
    } */
    
    
    @AuraEnabled
    public static String SelectforFavroute1(String[] SelectedProductid){
        string Message;
         try{
             Set<Id> SetProductId = new Set<Id>();
             for(String pid : SelectedProductid){
                 SetProductId.add(pid);
             }
            List<User_Favorite_Products__c> listofFab=new List<User_Favorite_Products__c>();
            //system.debug('>>>'+SelectedProductid.size());
            Map<Id,String> UFP_ToProductId =  new Map<Id,String>();
             List<User_Favorite_Products__c> AlreadyFavProducts =  [select id, name,user__c,Frequency_of_Use__c,Products__r.Name,Products__c  from User_Favorite_Products__c 
                                                              where User__c=:UserInfo.getUserId() and Products__c  !=null ];
             for(User_Favorite_Products__c UFP : AlreadyFavProducts){
                 if(!UFP_ToProductId.containskey(UFP.Products__c)){
                     UFP_ToProductId.put(UFP.Products__c,UFP.Products__r.Name);
                 }
             }
             
            for(Id selectedidobj : SetProductId){
                if(!UFP_ToProductId.containsKey(selectedidobj)){
                    //system.debug('>>>>>>'+selectedidobj);
                User_Favorite_Products__c obj = new User_Favorite_Products__c();
                obj.user__c = UserInfo.getUserId();
                obj.Products__c = selectedidobj;
                listofFab.add(obj);
                }
                
                 
            }
             if(listofFab.size()>0){
                 insert listofFab;
             }
             
            
         }
       
          catch(DmlException e) { 
            Message= e.getMessage();
          }
        return Message;
    }
    
    @AuraEnabled
    public static String SelectforDel(String[] SelectedProductid){
        string Message;
         try{
             
            List<OpportunityLineItem> listofFab=new List<OpportunityLineItem>();
            //system.debug('>>>'+SelectedProductid.size());
            
            for(String selectedidobj : SelectedProductid){
                OpportunityLineItem oli =new OpportunityLineItem();
                oli.id=selectedidobj ;
                listofFab.add(oli);
                
            }
             
            delete listofFab; 
            
         }
       
          catch(DmlException e)  {  Message= e.getMessage();}
        return Message;
    }

     @AuraEnabled
   public static String removeSchedule(String[] SelectedProductid, String recordId) { 
       String msg;
       try{
       List<OpportunityLineItem> opplist= [select id,Product2Id,Name  from OpportunityLineItem where OpportunityId =:recordId AND Product2Id IN:SelectedProductid ];
       //Set<id> setDup=new Set<id>();
        
       Delete opplist;
          
       } 
       catch(DmlException e) { msg= e.getMessage(); }
       return msg;
         
}
       
    
       
       
   
          
   @AuraEnabled
   public Static String InsertOpportunityLineItem(String[] Product_Selected_From_Favorite_Section, String Oppid , Boolean[] subsciptionValArray, String[] ServLineItemTypeArray, String[] HWMMntcTypeArray, String[] qtyTypeArray){
        SYstem.debug(ServLineItemTypeArray);
        //system.debug('>>>>Pankaj Kashyap'+Product_Selected_From_Favorite_Section);
        String spricebookId = GlobalVariable.pricebookId , Msg; 
        //String Msg;  
        Opportunity o = [Select o.Id, 
                                o.Pricebook2Id,
                                o.CurrencyIsoCode,                                
					o.CATM_Record__c, 
                                o.Contract_Term_Mths__c
                           from Opportunity o  
                         where o.Id = :Oppid]; 
                         
       ID pricebookId = o.Pricebook2Id;
       if(Test.isRunningTest()) pricebookId = null;
        if(pricebookId == null) { 
            pricebookId = spricebookId;
            List<Pricebook2> pb2 = [Select p.Description, p.Id, p.Name from Pricebook2 p where p.Id = :pricebookId];
            //save the pricebook into opportunity
            if(!pb2.isEmpty())o.Pricebook2Id = pb2.get(0).Id;
            try{ update o; }
            catch(Exception e){ Msg = e.getMessage();
                return Msg;                
            }
        }    
        
        
        if(pricebookId != null) {
            try{
            List<ID> productIdList = new List<ID>();
            for(String cp2 : Product_Selected_From_Favorite_Section) {
                productIdList.add(cp2);
            }
            List<PricebookEntry> pbeList = [Select p.CurrencyIsoCode, 
                                                   p.Id, 
                                                   p.Name, 
                                                   p.Pricebook2Id, 
                                                   p.Product2Id, 
                                                   p.ProductCode, 
                                                   p.UseStandardPrice,
                                                   p.IsActive                                                  
                                              From PricebookEntry p  
                                             Where p.Pricebook2Id = :pricebookId
                                               and p.CurrencyIsoCode = :o.CurrencyIsoCode                                              
                                               and p.Product2Id in :productIdList
                                            ];
            List<OpportunityLineItem> addOLIlist = new List<OpportunityLineItem>();
            List<CurrencyType> clist = [Select c.ConversionRate from CurrencyType c where c.IsoCode = :o.CurrencyIsoCode];
            Double conversionRate = clist[0].ConversionRate;
            Integer indexI = 0 ;
            for(String cp2 : Product_Selected_From_Favorite_Section) {
                OpportunityLineItem aoli = new OpportunityLineItem();
                aoli.OpportunityId = o.id;
                aoli.ServiceDate = System.today();  
                
                Double totalPriceInUSD = 0.00;

                aoli.Quantity = 1; 
                aoli.UnitPrice = 0.00;
                aoli.Is_Subscriptioned__c = subsciptionValArray[indexI];
                
                if(ServLineItemTypeArray != NULL && ServLineItemTypeArray.size() > 0) {
                	String servType =  ServLineItemTypeArray[indexI];
                    
                    if(String.isNotBlank(servType)) {
                        aoli.Opportunity_Line_Item_Type__c = servType;
                    }
                }
                
                if(HWMMntcTypeArray != NULL && HWMMntcTypeArray.size() > 0 && String.isNotBlank(HWMMntcTypeArray[indexI])) {
              		aoli.Maintenance_Type__c = HWMMntcTypeArray[indexI];
                }
                if(qtyTypeArray != NULL && qtyTypeArray.size() > 0 && String.isNotBlank(qtyTypeArray[indexI])) {
              		aoli.Qty_Type__c = qtyTypeArray[indexI];
                }
                
if(o != null && o.CATM_Record__c) {
               		aoli.Number_of_Terms__c = o.Contract_Term_Mths__c; 	   
                }
                //aoli.HasRevenueSchedule=false;
                
               
                //aoli.PSM__c = cp2.oppProduct.PSM__c; // retalix to ncr migration
                
                for(Integer i = 0; i < pbeList.size(); i++) {
                    PricebookEntry pbe = (PricebookEntry) pbeList[i];
                    if(pbe.Product2Id == cp2) {
                        aoli.PricebookEntryId = pbe.Id;                     
                        break;
                    }
                }
                addOLIList.add(aoli);
                indexI++ ;
            }
            if(addOLIlist.size() > 0) {                             
                insert addOLIlist;
            }
         }  
            catch(DmlException e) { Msg = e.getDmlMessage(0);
                return Msg;     
            }
            catch(Exception e){ Msg = e.getMessage();
                return Msg;
            } 
       }
         return Msg;                
       }  
       
       @AuraEnabled
       public Static String ClientToServerProductSynk(String ProductFinalArray){
       //system.debug('>>>>>>'+ProductFinalArray);
       string Message;
       Map<String,cls_data> Product2ListSynkMap = new Map<String,cls_data>();
       List<OpportunityLineItem> OppLineItemListSynk=new List<OpportunityLineItem>();    

        
               
                try{
                jsonWrapper CD = (jsonWrapper)System.JSON.deserialize(ProductFinalArray, ProductSelection.jsonWrapper.class);
                for(cls_data C : CD.data ){

                   OpportunityLineItem oliobj=new OpportunityLineItem();
                   oliobj.id=C.OliId;
                   oliobj.UnitPrice=C.unitPrice;
                   oliobj.Quantity=c.quantity;
                   oliobj.TotalPrice=c.totalValue;
                   OppLineItemListSynk.add(oliobj);   
                } 
                
                if(OppLineItemListSynk.Size()>0){
                    update OppLineItemListSynk;
                   
                }
        }
         
          
         catch (ListException e) {
               Message= e.getMessage();  
            } 
            
         catch(DmlException e) 
          { 
            Message= e.getMessage();
          }
        return 'Exception...';
 
   }  
   
   
   
   public class jsonWrapper{
       public cls_data[] data;
   }
   
    public class cls_data {
        public boolean value;
        public Decimal quantity,unitPrice,OneTimeFee,NoOfTerms,MonthlyFee,totalValue;    //0
        //public Decimal unitPrice;   //0
        //public Decimal OneTimeFee,NoOfTerms,MonthlyFee,totalValue;   //0
        //public Decimal NoOfTerms;   //0
        //public Decimal MonthlyFee;   //0
        //public Decimal totalValue;  //0
        public String ProductName , ProductId , OliId;  //2330-Wireless Networking Prods
        //public String ProductId;    //01t70000001CIpYAAW
        //public String OliId;
        
    }
    
    /*@AuraEnabled
    public static String deletePackage(String packageOliId, String recordId) { 
        return PS_Schedule_NewClass.deletePackage(packageOliId, recordId ) ;
        
    } */
    
     @AuraEnabled
    public static SubsProductWrapper getSubsOnlyProd(){
           
        Set<String> SubsProdSet= new Set<String>(); 
        Set<String> SubsRevenueSet= new Set<String>(); 
        
        SubsProductWrapper subsProdWrapObj= new SubsProductWrapper();
        List<Subscription_only_products__c> subsProdList=  Subscription_only_products__c.getall().values();
        
        if(subsProdList.size()>0){
            if(String.isNotBlank(subsProdList[0].Product_Name__c)){
                 List<String> subProdLst = subsProdList[0].Product_Name__c.split(',');
                 for(String prodName : subProdLst){
                     SubsProdSet.add(prodname);            
                 }
            if(String.isNotBlank(subsProdList[0].Product_Revenue_Type__c)){
                 List<String> subRevtypeLst = subsProdList[0].Product_Revenue_Type__c.split(',');
                 for(String revenueType : subRevtypeLst){
                    SubsRevenueSet.add(revenueType);               
                 }
                }
            }
            
            subsProdWrapObj.ProductNames = SubsProdSet;
            subsProdWrapObj.RevenueTypes = SubsRevenueSet;
                                    
        }
        return subsProdWrapObj;
    }
    @AuraEnabled
    public static Opportunity getOpportunity(String recordId){
         Opportunity opp=[Select id, Catm_Record__c,Contract_Term_Mths__c from Opportunity where id=:recordId];
         return opp;
    }
    
    public class SubsProductWrapper{
        @AuraEnabled public Set<String> ProductNames{get;set;}
        @AuraEnabled public Set<String> RevenueTypes{get;set;}
           }
    
  
    @AuraEnabled 
    public static void updateLineItemTerm(String OliId, Double NoOfTerms){
        OpportunityLineItem oli= new OpportunityLineItem();
        oli.Id=OliId;
        oli.Number_of_Terms__c=Double.valueOf(NoOfTerms);  
    try{
        Update oli;
    }
    catch(Exception e){
            System.debug('Exception Occur ::::::: '+e);
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());
        }
    }
    
    @AuraEnabled 
    public static void saveBulkProduct(String oppId, Boolean isCATMOpp, String ctrMonths, String JsonString) {
    	//ProductScheduleController.SaveManegeSchedule(JsonString);
    	
        //if(String.isBlank(JsonString)) {
        
        //stuti 2426
       		Opportunity opp =[Select id, Contract_Term_Mths__c from Opportunity where id =: oppId];
        
        Integer psContMnths = (ctrMonths == null || String.isBlank(ctrMonths) || !ctrMonths.isNumeric())?0:integer.valueof(ctrMonths); 
        
        Integer oppContMonths = opp.Contract_Term_Mths__c==null?0:integer.valueof(opp.Contract_Term_Mths__c);
        
        if(psContMnths!=oppContMonths){
            opp.Contract_Term_Mths__c = psContMnths; 
            try {
           		update opp;
            }  
            catch(Exception e){
                System.debug('Exception Occur ::::::: '+e);
                throw new AuraHandledException('Something went wrong: '
                                               + e.getMessage());
            }
        }
        //}
        
        
    	List<WrapperProductSelctionController> wpscList=new List<WrapperProductSelctionController>();
        
        //2226 by Stuti
        
        try{
        if(String.isNotBlank(JsonString)){
        wpscList=(List<WrapperProductSelctionController>)JSON.deserialize(JSONString, List<WrapperProductSelctionController>.class);
        System.debug('print wrapper-->'+wpscList);  
        }
        }
        catch(Exception e){
            System.debug('Exception Occur ::::::: '+e);
            throw new AuraHandledException('Something went wrong: '
                                           + e.getMessage());
        }
        List<OpportunityLineItem> OLIList=new List<OpportunityLineItem>();
        Set<String> qtyTypeVal = new Set<String>(); 
        
        
        
        
        for(WrapperProductSelctionController  wrpCtrl : wpscList) {
        	OpportunityLineItem oli = new OpportunityLineItem();    
            
            oli.Id=wrpCtrl.OliId;
            oli.Quantity= wrpCtrl.quantity != null ? Double.valueOf(wrpCtrl.quantity) : 0;
            oli.Number_of_Terms__c=Double.valueOf(wrpCtrl.NoOfTerms);
            
            if(wrpCtrl.AvailableforSubscription || wrpCtrl.ProductCatogery=='Cloud' || wrpCtrl.isCATMProduct){
                
                Double onetimefee = wrpCtrl.OneTimeFee != null ? Double.valueOf(wrpCtrl.OneTimeFee) : 0;                 
                oli.One_Time_Fee__c=   onetimefee;        
                 
                if(isCATMOpp) {
                	oli.Total_Cost_Value__c = (onetimefee * oli.Quantity) + oli.Quantity * oli.Number_of_Terms__c * Double.valueOf(wrpCtrl.unitPrice);    
                } else {
                	oli.Total_Cost_Value__c = onetimefee + oli.Quantity * oli.Number_of_Terms__c * Double.valueOf(wrpCtrl.unitPrice);
                }
                
                if(Double.valueOf(wrpCtrl.NoOfTerms)>12){
                    oli.Actual_Contract_Value__c=Double.valueOf(wrpCtrl.quantity)*12*Double.valueOf(wrpCtrl.unitPrice);
                }else{
                    oli.Actual_Contract_Value__c=Double.valueOf(wrpCtrl.quantity)*Double.valueOf(wrpCtrl.NoOfTerms)*Double.valueOf(wrpCtrl.unitPrice);
                }
                if(oli.Total_Cost_Value__c!=null && oli.Total_Cost_Value__c>0){
                    oli.UnitPrice=oli.Total_Cost_Value__c/Double.valueOf(wrpCtrl.quantity);  
                }          
                oli.Monthly_Fee__c=Double.valueOf(wrpCtrl.unitPrice);
            }else{
                oli.UnitPrice=Double.valueOf(wrpCtrl.unitPrice);
            }
            oli.Qty_Type__c=wrpCtrl.qtyTyp;
            OLIList.add(oli);
        }
        
        try{
            if(!OLIList.isEmpty()) Update OLIList;
           
        }
        
        catch(Exception e){
            System.debug('Exception Occur ::::::: '+e);
            throw new AuraHandledException('Something went wrong: '
                                           + e.getMessage());
        }
            
	}
    
}