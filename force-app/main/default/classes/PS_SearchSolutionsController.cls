/*
##################################################################################################
# Project Name && Request Num..........: NSC Sales Central
# File............................: PS_SearchSolutionsController.cls                                                       
# Created by................: Nagendra Singh                                                                  
# Created Date...........:  12/15/2017                                                                               
# Last Modified by......:  Nagendra
# Description...............: This is the class for SearchSolutionComponent as part of the MDM project requirement.
#  Revision History
 Version     Modified By          Story No.
################################################################################################
*/
public class PS_SearchSolutionsController {

    
    @AuraEnabled
    public static List<WrapperFavorite> getProducts(String SolutionId,String recordId){   
        List<WrapperFavorite> prodList2 =new List<WrapperFavorite>();
        List<Product_Solution_Mapping__c>  ProductSolutionMapping = [select id,Product__c, Product__r.Name from Product_Solution_Mapping__c where  Product_Solution__c =:SolutionId /*Id IN:pbeList*/ order by Product__r.Name ASC];
        set<Id> ProductId = new set<Id>();
        for(Product_Solution_Mapping__c PSM: ProductSolutionMapping){
            ProductId.add(PSM.Product__c);
        }
        List<Product2>  lstObj = [select id, name from product2 where isActive=true AND Id In :ProductId /*Id IN:pbeList*/ order by Name ASC];           
        List<OpportunityLineItem> mpOppLineItems = [select id,Product2Id from OpportunityLineItem where OpportunityId =:recordId];
        List<User_Favorite_Products__c> usfavlist= [select id, name,user__c,Products__c  from User_Favorite_Products__c 
                                                    where User__c=:UserInfo.getUserId()];
        //System.debug('lstObj'+lstObj);
        set<Id> prdid=new set<Id>() ;  
        set<Id> multipleLine =new set<Id>();
        set<Id> opplineprodid1=new set<Id>();
        
        for(User_Favorite_Products__c fav: usfavlist){ 
            prdid.add(fav.Products__c);   
        }
        for(OpportunityLineItem oppln: mpOppLineItems ){  
            if(opplineprodid1.contains((oppln.Product2Id))){
                multipleLine.add(oppln.Product2Id);
            }
            opplineprodid1.add(oppln.Product2Id);            
        } 
        for(Product2 pd: lstObj) {
            WrapperFavorite wp= new WrapperFavorite();
            wp.prd = pd;
            wp.isselected = false;
            if(prdid.contains(pd.id) && (opplineprodid1.contains(pd.id))){
                wp.favselected=True; 
                wp.HasSchedule=True;
                wp.ProductName=pd.Name;
                wp.SetsortColor=True;
                if(multipleLine.contains(pd.id)){
                    wp.Hasmultiple=true;
                }else{
                    wp.Hasmultiple=false;
                }
                prodList2.add(wp); 
            }   
        }
        
        for(Product2 pd: lstObj) {
            WrapperFavorite wp= new WrapperFavorite();
            wp.prd = pd;
            wp.isselected = false;
            wp.ProductName=pd.Name;
           // wp.SetsortColor=True;
            if(prdid.contains(pd.id) && (!opplineprodid1.contains(pd.id))){
                wp.favselected=True; 
                wp.HasSchedule=false;
                
                if(multipleLine.contains(pd.id)){
                    wp.Hasmultiple=false;
                }else{
                    wp.Hasmultiple=true;
                }
                prodList2.add(wp); 
            }   
            
        }
        for(Product2 pd: lstObj) {
            WrapperFavorite wp= new WrapperFavorite();
            wp.prd = pd;
            wp.isselected = false;
            wp.ProductName=pd.Name;
            wp.SetsortColor=True;
            if(!prdid.contains(pd.Id) && (opplineprodid1.contains(pd.id))){
                wp.favselected=false; 
                wp.HasSchedule=true;
                if(multipleLine.contains(pd.id)){
                    wp.Hasmultiple=True;
                }else{
                    wp.Hasmultiple=false;
                }
                prodList2.add(wp);
            }
        }
        
        for(Product2 pd: lstObj) {
            WrapperFavorite wp= new WrapperFavorite();
            wp.prd = pd;
            wp.isselected = false;
            wp.ProductName =pd.Name;
            if(!prdid.contains(pd.id) && (!opplineprodid1.contains(pd.id))){
                wp.favselected=false; 
                wp.HasSchedule=false;
                if(multipleLine.contains(pd.id)){
                    wp.Hasmultiple=false;
                }else{
                    wp.Hasmultiple=true;
                    
                }
                prodList2.add(wp); 
            }   
        }
        return prodList2;
    }
    @AuraEnabled
    public static void removeFavourite(String ProductId) { 
       PS_SearchBarComponentController.removeFavourite(ProductId);
    }
    @AuraEnabled
    public static String addFavourite(String ProductId){
      return PS_SearchBarComponentController.addFavourite(ProductId);
        
    }
     
}