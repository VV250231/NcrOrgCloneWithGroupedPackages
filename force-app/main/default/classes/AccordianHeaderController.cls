public class AccordianHeaderController {
@AuraEnabled
    public static void UpdateBundleName(String BundleId,String BundleName) {
        
         
         try {
             Favorite_Bundle__c FavBundleObj = new Favorite_Bundle__c();
               //system.debug('>>>'+BundleId);
               if(BundleName != null){
                 FavBundleObj.Name=BundleName;
                 FavBundleObj.Id= BundleId;
                 Update   FavBundleObj;
                   
             }
         }
        catch (Exception e) {
        
            throw new AuraHandledException('Darn it! Something went wrong: '
                + e.getMessage());    
        }
   

        
    } 
    
    @AuraEnabled
    public static String addFavouriteBundle(String bundleId){
        string Message; 
        try{
            User_Favorite_Products__c FavObj = new User_Favorite_Products__c();
            FavObj.Bundle__c = bundleId;
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
     Public static String RemoveFavouriteBundle(String bundleId){
       //system.debug('>>>>'+bundleId);  
        string Message; 
        try{
            if(String.isNotBlank(bundleId)){
                 User_Favorite_Products__c FavObj =[Select Id,Name from User_Favorite_Products__c where Bundle__c = : bundleId AND User__c=:UserInfo.getUserId()];
                 Delete FavObj;
            }
           
        }
        catch(DmlException e) 
        { 
            Message= e.getMessage();
        }
        return Message;   
     } 
}