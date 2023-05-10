/*
##################################################################################################
# Class Name............................:WrapperFavorite.cls                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
BA_SF-2491 JDK Locale impact - Upgrade API Part 5 
                               
################################################################################################
*/
public class WrapperFavorite {
    @AuraEnabled
    public User_Favorite_Products__c Prod {get;set;} 
    @AuraEnabled
    public Boolean selected {get;set;} 
    
    @AuraEnabled
    public Product2 prd {get;set;} 
    @AuraEnabled
    public Boolean isselected {get;set;} 
    @AuraEnabled
    public Boolean favselected{get;set;} 
    @AuraEnabled
    Public   String FilterName{get;set;}
    @AuraEnabled
    Public  Boolean HasSchedule{get;set;}
    @AuraEnabled
    Public Boolean HasMultiple{get;set;}
    @AuraEnabled
    Public   Id ProductId{get;set;}
    @AuraEnabled
    Public  String ProductName{get;set;}
    @AuraEnabled
    public Boolean SetsortColor {get;set;} 
    
}