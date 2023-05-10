public class TableRowController {
	@AuraEnabled
    public static void UpdateBundleProduct(String ProductId, Double UnitPrice , Integer Quantity) { // Changed Unit Price from Integer to Decimal - EBA_SF-2209
        
         
         try {
               User_Favorite_Products__c UserFavObj= new User_Favorite_Products__c();
               UserFavObj.Id=ProductId;
        	   if(UnitPrice != null){ 
                 //UserFavObj.UnitPrice__c=integer.valueof(UnitPrice); //EBA_SF-2209
                 UserFavObj.UnitPrice__c=UnitPrice;
                   
                }
                if(Quantity != null){
                 UserFavObj.Quantity__c=integer.valueof(Quantity);
               }
             
             update UserFavObj;
         }
        catch (Exception e) {
        
            throw new AuraHandledException('Darn it! Something went wrong: '
                + e.getMessage());    
        }
   

        
    }
}