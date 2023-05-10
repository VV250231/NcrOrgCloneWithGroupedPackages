public with sharing class  Zuora_SetMarketProductController{

Public id zquoteRecId;

String commaSeperatedSelectedMP = null ;

Public Boolean isEditButtonDisabled{get;set;}
Public Boolean isSaveButtonDisabled{get;set;}

Public String s ='Default';
     
Public Map<String,List<SelectOption>>  mapProductNameandMPOptions{get;set;}

Public List<zqu__QuoteRatePlan__c> lstQRP = new List<zqu__QuoteRatePlan__c>();
Public Set<String> setAllMarketProductIds = new Set<String>();
Public Map<String,List<String>> mapProductIdandMPIds = new Map<String,List<String>>();
Public Map<String,string> mapProductIdandProductName = new Map<String,string>();
Public Map<String,List<zqu__QuoteRatePlan__c >> mapProductIdandQRP = new Map<String,List<zqu__QuoteRatePlan__c >>();



Public Map<String,List<Product2>> mapZP1andMPObj = new Map<String,List<Product2>>();
Public Map<String,Product2> mapMPIdandObject = new Map<String,Product2>();

Public List<String> lstSelectedMarketProductIds = new List<String>();
Public Map<String,String> mapToDisplaySelectedMarketProductName{get;set;}

//Public Map<String,string> mapZuoraProductidandDefaultMarketProductid = new Map<String,string>();

//mapToDisplaySelectedMarketProductName = new Map<String,String>(); // map ();

    public Zuora_SetMarketProductController(ApexPages.StandardController controller) 
    { 
     mapToDisplaySelectedMarketProductName = new Map<String,String>();
     isEditButtonDisabled = false;
     isSaveButtonDisabled = true;
     zquoteRecId= ApexPages.currentPage().getParameters().get('id');
     system.debug('****id from page***'+zquoteRecId);
      if(zquoteRecId != null)
      {
        
         lstQRP =[select id,zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__r.Name,zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__r.Id,ListMarketProductIdsfromProduct__c,MarketProductId__c,zqu__QuoteProductName__c from zqu__QuoteRatePlan__c where zqu__Quote__c =: zquoteRecId and zqu__AmendmentType__c NOT IN ('RemoveProduct','Oiginal','')  ];
         if(lstQRP!= null && lstQRP.size()>0 ){
         system.debug('****getProductandMarketProductIds(lstQRP )***'+lstQRP);
         getProductandMarketProductIds(lstQRP );}
      }
    }
    
    
    public void getProductandMarketProductIds(List<zqu__QuoteRatePlan__c> lstQuoteRatePlan)
    {
      for(zqu__QuoteRatePlan__c objQRP :lstQuoteRatePlan)
      {
      
       if(String.isNotBlank(objQRP.ListMarketProductIdsfromProduct__c) && objQRP.ListMarketProductIdsfromProduct__c != null)
          {
           if(!mapProductIdandQRP.containsKey(objQRP.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__r.Id))
           {
                  mapProductIdandQRP.put(objQRP.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__r.Id,new List<zqu__QuoteRatePlan__c >());
           }
           mapProductIdandQRP.get(objQRP.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__r.Id).add(objQRP ) ;
                   
           List<String> lstSplitMarketProductIds = new List<String>();
          // split and get the MP ids into a set 
           lstSplitMarketProductIds = objQRP.ListMarketProductIdsfromProduct__c.split(';');
           mapProductIdandMPIds.put(objQRP.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__r.Id,lstSplitMarketProductIds );
           setAllMarketProductIds.addAll(lstSplitMarketProductIds );
          
           mapProductIdandProductName.put(objQRP.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__r.Id,objQRP.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__r.Name);
          
          }
          system.debug('****setAllMarketProductIds***'+setAllMarketProductIds);
           
      }
       system.debug('******mapProductIdandProductName++'+mapProductIdandProductName);
       
       system.debug('******map of quote product and qrp list++'+mapProductIdandQRP);
       
      //query all the market products
      if(setAllMarketProductIds != null && setAllMarketProductIds.size() > 0)
      {
          for(Product2 objProd:[select id,PMDM_Unique_Key__c,name from Product2 where PMDM_Unique_Key__c in :setAllMarketProductIds])
          {
              mapMPIdandObject.put(objProd.PMDM_Unique_Key__c ,objProd);
          }   
      
       system.debug('++++++++++map of market product id and obejct+++mapMPIdandObject++'+mapMPIdandObject);
       system.debug('+++++++++++map of zp and market product ids mapProductIdandMPIds****'+mapProductIdandMPIds);
      //create the map of Zuora Product and Market Product object i.e mapZP1andMPObj
      for(String zpId: mapProductIdandMPIds.keyset())
      {
          mapZP1andMPObj.put(zpId,new list<Product2>());
          for(String mpIds: mapProductIdandMPIds.get(zpId))
          {
              if(mapMPIdandObject!= null && mapMPIdandObject.containskey(mpIds))
              {
                 mapZP1andMPObj.get(zpId).add(mapMPIdandObject.get(mpIds)); 
              }
          } 
       }
       
     system.debug('******inside setAllMarketProductIds& value of mapZP1andMPObj********' +mapZP1andMPObj);
     system.debug('******mapToDisplaySelectedMarketProductName********' +mapToDisplaySelectedMarketProductName);
       
       for(zqu__QuoteRatePlan__c objQRP :lstQuoteRatePlan)
       {
           system.debug('++++++++++objQRP.ListMarketProductIdsfromProduct__c++++++'+objQRP.ListMarketProductIdsfromProduct__c);
            // we need to display only those products whose market product exist
            if(String.isNotBlank(objQRP.ListMarketProductIdsfromProduct__c) && objQRP.ListMarketProductIdsfromProduct__c != null)
            {
             if(String.isNotBlank(objQRP.MarketProductId__c) && (!mapMPIdandObject.isEmpty() || mapMPIdandObject != null) && mapMPIdandObject.containsKey(objQRP.MarketProductId__c))
             { 
             mapToDisplaySelectedMarketProductName.put(mapProductIdandProductName.get(objQRP.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__r.Id),mapMPIdandObject.get(objQRP.MarketProductId__c).name);
             }
             else
             {mapToDisplaySelectedMarketProductName.put(mapProductIdandProductName.get(objQRP.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__r.Id),'Not Selected');}
        
            }  
       }
        
        
       }
          mapProductNameandMPOptions = createPicklist();
        
       
       
       system.debug('++++++++++map of zuora product and market product obejct+++mapZP1andMPObj'+mapZP1andMPObj);
    }
    
    Public Map<String,List<SelectOption>> createPicklist()
    {
     Map<String,List<SelectOption>> mapProandOptions = new Map<String,List<SelectOption>>();
       system.debug('++++++++++inside create picklist obejct+++mapZP1andMPObj'+mapZP1andMPObj);
       if(mapZP1andMPObj != null && !mapZP1andMPObj.isEmpty())
       {
         for(String proId:mapZP1andMPObj.keyset())
         {
             List<SelectOption> lstOptions = new List<SelectOption>();
             for(Product2 marketProObj:mapZP1andMPObj.get(proId) )
             {  
                 lstOptions.add(new SelectOption(marketProObj.PMDM_Unique_Key__c ,marketProObj.name));
             }
             mapProandOptions.put(mapProductIdandProductName.get(proId),lstOptions);
         } 
       }
       
      system.debug('***inside create picklist*******'+mapProandOptions);
     return mapProandOptions;
      
     
     }
        
    public void Contorlsave() {
    
     isEditButtonDisabled = false;
     isSaveButtonDisabled = true;
     Map<String,String> mapQuoteProductandSelectedMarketProduct = new Map<String,String>();
     Set<string> setSelectedMarketProductIds = new Set<String>();
    
     commaSeperatedSelectedMP = apexpages.currentPage().getParameters().get('inpval'); 
     if( commaSeperatedSelectedMP != null)
     {
         system.debug('+++++++++++selected value from page mapSelectedMarketProductIds '+apexpages.currentPage().getParameters().get('inpval'));
         lstSelectedMarketProductIds = commaSeperatedSelectedMP.split(',');
         setSelectedMarketProductIds.addAll(lstSelectedMarketProductIds);
     
     
     
     // create map of selected market product and zuora product
     for(String zpId: mapProductIdandMPIds.keyset())
     {
          
          for(String mpIds: mapProductIdandMPIds.get(zpId))
          {
              if(setSelectedMarketProductIds != null && setSelectedMarketProductIds.contains(mpIds))
              {
                 //mapZP1andMPObj.get(zpId).add(mapMPIdandObject.get(mpIds)); 
                 mapQuoteProductandSelectedMarketProduct.put(zpId,mpIds);
                 mapToDisplaySelectedMarketProductName.put(mapProductIdandProductName.get(zpId),mapMPIdandObject.get(mpIds).name);
              }
            
          } 
          
     }
       
       // update all the rate plans mapProductIdandQRP
       
       if(!mapQuoteProductandSelectedMarketProduct.isEmpty())
       {
           List<zqu__QuoteRatePlan__c> lstQRPToUpdate = new List<zqu__QuoteRatePlan__c>();
           for(String idQuoteProduct: mapQuoteProductandSelectedMarketProduct.keyset())
           {
               for(zqu__QuoteRatePlan__c objQRP:mapProductIdandQRP.get(idQuoteProduct))
               {
                   zqu__QuoteRatePlan__c tempObj = new zqu__QuoteRatePlan__c();
                   tempObj.id = objQRP.id;
                   tempObj.MarketProductId__c = mapQuoteProductandSelectedMarketProduct.get(idQuoteProduct);
                   lstQRPToUpdate.add(tempObj);
               } 
           }
           if(lstQRPToUpdate != null && lstQRPToUpdate.size() > 0)
           {
           
           update lstQRPToUpdate;
            }     
        }
 
    
    }
    }
 
   public void edit() {
    isEditButtonDisabled = true;
    isSaveButtonDisabled = false;// isSaveButtonDisabled = false; 
    }
    
    public String getcollectPicklistValue() {
        return s;
    }
                        
    public void setcollectPicklistValue(String s) {
        this.s = s;
    }
    
    
}