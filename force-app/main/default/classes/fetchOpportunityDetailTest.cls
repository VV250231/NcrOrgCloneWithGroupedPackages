/*
##################################################################################################
# Project Name && Request Num..........: NSC Sales Central&& Product Scheduler For Lightining
# File............................: fetchOpportunityDetailTest.Test class                                                        
# Created by................: Saritha karutrui                                                                   
# Created Date...........: 12-29-2016                                                                              
# Last Modified by......:  Saritha karutrui 
# Last Modified Date..: 12-29-2016
# Description...............: This test class is the written with respect to Apex class:fetchOpportunityDetail
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
BA_SF-2491 JDK Locale impact - Upgrade API Part 5 
################################################################################################
*/
@IsTest
Public class  fetchOpportunityDetailTest{
    
    static testMethod void EddandEbdSetMethod() {
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
        fetchOpportunityDetail.getOpportunity(opp.id);
        fetchOpportunityDetail.isCommunity();
        fetchOpportunityDetail.getOppDetails(opp.id);
        //fetchOpportunityDetail.aasFunctionalityAccess();
        System.assertEquals(false, fetchOpportunityDetail.isCommunity());
		System.assertEquals(false, fetchOpportunityDetail.getOppDetails(opp.id)[0].CPQ__c);
    }
    static testMethod void EddandEbdSetMethod1() {
        Profile p = [SELECT Id FROM Profile WHERE Id='00e700000013gPe'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles',Quicklook_ID__c='BHG123', UserName='standarsgdfhdg@testorg.com');
        System.runAs(u) {
            Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
            fetchOpportunityDetail.getOpportunity(opp.id);
            System.assertEquals(new Set<String>{'Other Admin'}, fetchOpportunityDetail.getOpportunity(opp.id).keyset());
        }
    }
    static testMethod void testDeleteProductFromBundle(){
        pricebook2 pricebook = TestRecordsFactory.createPriceBook();
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
        opp.Pricebook2Id = pricebook.Id;
        update opp;
        Product2 prod = TestRecordsFactory.createProduct();
        Favorite_Bundle__c bundle = new Favorite_Bundle__c(); 
        bundle.Name = 'Test bundle';
        bundle.ownerid = UserInfo.getUserId();
        insert bundle;
        User_Favorite_Products__c favProduct = new User_Favorite_Products__c();
        favProduct.Favorite_Bundle__c = bundle.Id;
        favProduct.Products__c = prod.Id;
        favProduct.UnitPrice__c = 100;
        favProduct.Quantity__c = 10;
        insert favProduct;
        fetchOpportunityDetail.DeleteProductWrapper dWrapper = new fetchOpportunityDetail.DeleteProductWrapper();
        dWrapper.Id = favProduct.Id;
        dWrapper.Status = true; 
        fetchOpportunityDetail.DeleteProductWrapper MapOfBundleProductForDelete = new fetchOpportunityDetail.DeleteProductWrapper();
        MapOfBundleProductForDelete.Id = bundle.Id;
        MapOfBundleProductForDelete.Status = true;
        fetchOpportunityDetail.InsertSchedueWrapper MapForInsert = new fetchOpportunityDetail.InsertSchedueWrapper();
        MapForInsert.Id = bundle.Id;
         system.assertEquals(MapForInsert.Id , bundle.Id);
        MapForInsert.Status = true;
        List<fetchOpportunityDetail.DeleteProductWrapper> dProdWrapList = new List<fetchOpportunityDetail.DeleteProductWrapper>();
        dProdWrapList.Add(dWrapper);
        List<fetchOpportunityDetail.DeleteProductWrapper> pdBundleWrapList = new List<fetchOpportunityDetail.DeleteProductWrapper>();
        pdBundleWrapList.Add(MapOfBundleProductForDelete);
        List<fetchOpportunityDetail.InsertSchedueWrapper> MapForInsertList = new List<fetchOpportunityDetail.InsertSchedueWrapper>();
        MapForInsertList.Add(MapForInsert);
        Test.startTest();
        try{
            fetchOpportunityDetail.InsertBundle('Test Bundle');
            fetchOpportunityDetail.AddBundleProductToItemToSchedule(JSON.serialize(MapForInsertList),opp.Id);
            fetchOpportunityDetail.getProductBundle();
            TableRowController.UpdateBundleProduct(favProduct.id,20,20);
            fetchOpportunityDetail.DeleteProductFromBundle( JSON.serialize(dProdWrapList),JSON.serialize(pdBundleWrapList));
            opp.Pricebook2Id = null;
            update opp;
            fetchOpportunityDetail.AddBundleProductToItemToSchedule(JSON.serialize(MapForInsertList),opp.Id);
            
        }catch(Exception ex){
            System.debug('exception>>>>>' + ex.getMessage());
        }
        Test.stopTest();
    }   
    
}