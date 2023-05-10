/*
##################################################################################################
# Project Name..........: Bundling In PS                                                                    
# File..................: AccordianHeaderControllerTest.cls                                                        
# Version...............: 43.0 
# Created by............: Ravikant Maurya                                                                   
# Created Date..........: 23-02-2015                                                                               
# Last Modified by......: Puneet Bhatia
# Last Modified Date....: 18-07-2018 
# Description...........: The test class is written to test the Bundeling Functionality developed By Pankaj Kashyap.
################################################################################################
*/
@isTest
public class AccordianHeaderControllerTest {
    static testMethod void testAccordianHeaderController(){
        Favorite_Bundle__c bundle = new Favorite_Bundle__c(); 
        bundle.Name = 'Test bundle';
        insert bundle;
        
        Renewable_Products__c rp = new Renewable_Products__c();
        rp.Name = 'Record1';
        rp.Product_Revenue_Types__c = 'HWM,SWM,Managed Service';
        insert rp;
        
        AccordianHeaderController.UpdateBundleName(bundle.Id, 'Test Bundle Updated');
        Favorite_Bundle__c bundleObj = [select name from Favorite_Bundle__c bundle where id=:bundle.Id];
        System.assert(bundleObj.Name=='Test Bundle Updated');
        AccordianHeaderController.addFavouriteBundle(bundle.Id);
        User_Favorite_Products__c favObj = [select id from User_Favorite_Products__c where Bundle__c=:bundle.Id ];
        System.assert(favObj.Id!=null);
        string mssg = AccordianHeaderController.RemoveFavouriteBundle(bundle.Id);
        System.assert(mssg==null);
        AddProductToBundleController.getRnwableProds(); 
        try{
            AccordianHeaderController.UpdateBundleName('12345', 'Test Bundle Updated');
            
        }catch(Exception ex){
            System.debug('Error: '+ex.getMessage());
        }
        
    }
    
    static testMethod void testAddProductToBundleMethod(){
        Product2 prod = TestRecordsFactory.createProduct();
        
        Favorite_Bundle__c bundle = new Favorite_Bundle__c(); 
        bundle.Name = 'Test bundle';
        insert bundle;
        
        List<AddProductToBundleController.BundleWrapper> bundleWrapList = new List<AddProductToBundleController.BundleWrapper>();
        AddProductToBundleController.BundleWrapper bundleWrap = new AddProductToBundleController.BundleWrapper();
        bundleWrap.Id = bundle.Id;
        bundleWrap.Status = true;
        bundleWrapList.add(bundleWrap);
        
        List<AddProductToBundleController.ProductWrapper> productWrapList = new List<AddProductToBundleController.ProductWrapper>();
        AddProductToBundleController.ProductWrapper productWrap = new AddProductToBundleController.ProductWrapper();
        productWrap.Id = prod.Id;
        productWrap.Status = true;
        productWrap.isSubricption = true;
        productWrap.LineItemType = 'New';
        productWrap.HWMMntcType = 'Connected HWM';
        productWrapList.add(productWrap);
        
        AddProductToBundleController.AddProductToBundleMethod(JSON.serialize(bundleWrapList),JSON.serialize(productWrapList));
        string updateMssg = AddProductToBundleController.UpdateBundleName(bundle.Id, bundle.Name);
        System.assert(updateMssg=='SuccessTest bundle');
        try{
            AddProductToBundleController.UpdateBundleName('12345', bundle.Name); 
        }catch(Exception ex){
            System.debug('Error: '+ex.getMessage());
        }
    }
    
    static testMethod void testTableContainerClass(){
        Product2 prod = TestRecordsFactory.createProduct();
        prod.isActive=true;
        prod.OriginalCorporation__c = 'Cardtronics';
        update prod;
        Opportunity opp= TestRecordsFactory.createSimpleOpportunity();
        opp.CATM_Record__c = True;
        Update opp;
        
        Favorite_Bundle__c bundle = new Favorite_Bundle__c(); 
        bundle.Name = 'Test bundle';
        bundle.ownerid = UserInfo.getUserId();
        insert bundle;
        
        User_Favorite_Products__c favProduct = new User_Favorite_Products__c();
        favProduct.Favorite_Bundle__c = bundle.Id;
        favProduct.Bundle__c = bundle.Id;
        favProduct.Products__c = prod.Id;
        favProduct.UnitPrice__c = 100;
        favProduct.Quantity__c = 10;
        favProduct.User__c = UserInfo.getUserId();
        insert favProduct;
        
        User_Favorite_Products__c favProduct1 = new User_Favorite_Products__c();
        favProduct1.Favorite_Bundle__c = bundle.Id;
        favProduct.Bundle__c = bundle.Id;
        favProduct1.Products__c = prod.Id;
        favProduct1.UnitPrice__c = 100;
        favProduct1.Quantity__c = 10;
        favProduct1.User__c = UserInfo.getUserId();
        insert favProduct1;
        
        List<TableContainerClass.Bundle_Delete_Wrapper> dBundleWrapList = new List<TableContainerClass.Bundle_Delete_Wrapper>();
        TableContainerClass.Bundle_Delete_Wrapper dWrap = new TableContainerClass.Bundle_Delete_Wrapper();
        dWrap.Id = bundle.Id;
        dBundleWrapList.Add(dWrap);
        List<TableContainerClass.BundleProduct_Delete_Wrapper> pdBundleWrapList = new List<TableContainerClass.BundleProduct_Delete_Wrapper>();
        TableContainerClass.BundleProduct_Delete_Wrapper pdWrap = new TableContainerClass.BundleProduct_Delete_Wrapper();
        pdWrap.Id = favProduct1.Id;
        pdBundleWrapList.Add(pdWrap);
        
        Test.startTest();
        List<Object> prdctList = TableContainerClass.GetUserFavBundle_Product(opp.id);
        System.assert(prdctList.size()>0);
        TableContainerClass.InsertBundle('Test Insert Bundle');
        try{
            TableContainerClass.delbundle(JSON.serialize(dBundleWrapList),JSON.serialize(pdBundleWrapList));
            PS_SearchBarComponentController.getUserFavoriteBundle();
            
        }catch(Exception ex){
            System.debug('exception>>>>>' + ex.getMessage());
        }
        
        
        Test.stopTest();
        
        
        
        
        
    }
    
    static testMethod void testAddBundle_Product_To_ItemToSchedule(){
        
        pricebook2 pricebook = TestRecordsFactory.createPriceBook();
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
        opp.Pricebook2Id = pricebook.Id;
        update opp;
        Product2 prod = TestRecordsFactory.createProduct();
        prod.isActive = true ;
        update  prod;
        
        Favorite_Bundle__c bundle = new Favorite_Bundle__c(); 
        bundle.Name = 'Test bundle';
        bundle.ownerid = UserInfo.getUserId();
        insert bundle;
        
        User_Favorite_Products__c favProduct = new User_Favorite_Products__c();
        favProduct.Favorite_Bundle__c = bundle.Id;
        favProduct.Products__c = prod.Id;
        favProduct.UnitPrice__c = 100;
        favProduct.Quantity__c = 10;
        favProduct.LineItemType__c = 'New'; 
        favProduct.Maintenance_Type__c = 'Connected HWM';
        insert favProduct;
        
        
        List<TableContainerClass.Bundle_Delete_Wrapper> dBundleWrapList = new List<TableContainerClass.Bundle_Delete_Wrapper>();
        TableContainerClass.Bundle_Delete_Wrapper dWrap = new TableContainerClass.Bundle_Delete_Wrapper();
        dWrap.Id = bundle.Id;
        dBundleWrapList.Add(dWrap);
        List<TableContainerClass.BundleProduct_Delete_Wrapper> pdBundleWrapList = new List<TableContainerClass.BundleProduct_Delete_Wrapper>();
        TableContainerClass.BundleProduct_Delete_Wrapper pdWrap = new TableContainerClass.BundleProduct_Delete_Wrapper();
        pdWrap.Id = favProduct.Id;
        pdBundleWrapList.Add(pdWrap);
        
        List<TableContainerClass.BundleSpecificProduct> pdBundleWrapList1 = new List<TableContainerClass.BundleSpecificProduct>();
        TableContainerClass.BundleSpecificProduct pdWrap11 = new TableContainerClass.BundleSpecificProduct();
        pdWrap11.Id = favProduct.Id;
        pdBundleWrapList1.Add(pdWrap11);
        
        Test.startTest();
        
        try{
            string mssg = TableContainerClass.AddBundle_Product_To_ItemToSchedule(JSON.serialize(dBundleWrapList),opp.Id, JSON.serialize(pdBundleWrapList));
            System.assert(mssg==null);           
            
        }catch(Exception ex){
            System.debug('exception>>>>>' + ex.getMessage());
        }
        
        Test.stopTest();
        opp.Pricebook2Id =  null ;
        update opp ;
        TableContainerClass.AddBundle_Product_To_ItemToSchedule(JSON.serialize(dBundleWrapList),opp.Id, JSON.serialize(pdBundleWrapList1));
    }
    
    static testMethod void testException(){
        contact con = new contact(Lastname='test23201');
        insert con;
       string mssg = AccordianHeaderController.addFavouriteBundle(con.id);
        System.assert(mssg!=null);
    }
        
}