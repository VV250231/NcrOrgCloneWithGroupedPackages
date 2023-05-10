public class ScrollComponentConreoller {

    @AuraEnabled
    public static String addFavourite(String ProductId){
        string Message; 
        try{
            User_Favorite_Products__c FavObj = new User_Favorite_Products__c();
            FavObj.Products__c=ProductId;
            FavObj.User__c=UserInfo.getUserId(); 
            insert FavObj; 
        }
        catch(DmlException e) 
        { 
            Message= e.getMessage();
        }
        return Message;
    }
    
     @AuraEnabled
     Public static String RemoveFavourite(String ProductId){
       system.debug('>>>>'+ProductId);  
        string Message; 
        try{
            if(String.isNotBlank(ProductId)){
                 User_Favorite_Products__c FavObj =[Select Id,Name from User_Favorite_Products__c where Products__c = : ProductId AND User__c=:UserInfo.getUserId()];
                 Delete FavObj;
            }
           
        }
        catch(DmlException e) 
        { 
            Message= e.getMessage();
        }
        return Message;   
     }  
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
}