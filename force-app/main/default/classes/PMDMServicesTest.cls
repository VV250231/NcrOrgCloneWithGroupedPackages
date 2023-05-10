/*
#####################################################################################################################
# Project Name..........: NSC PMDM                                                                         #
# File..................: TestProductRequest.cls                                                             #
# Version...............: 1                                                                                         #
# Created by............: Ravikant Maurya                                                                                #
# Created Date..........: 01-04-2018                                                                               #
# Last Modified by......: Ravikant Maurya                                                                               #
# Last Modified Date....: 01-04-2018                                                                                #
# Description...........: This  functionality is targeted to test Web Service Class PMDMServices.                                                                    #
#####################################################################################################################
*/
@isTest (seeAllData=true)
public class PMDMServicesTest {
    public static testMethod void runUnitTest() {
        
        ProductRequest prequest = new ProductRequest();
        prequest.ID = '12345';    
        prequest.Product_Name = 'Test Product';
        prequest.Product_Type = 'Hardware';
        prequest.Product_Description = 'Test Hardware product';
        prequest.Product_Status = 'ORDERABLE';
        prequest.Product_Manager = 'Ravikant Maurya';
        prequest.Revenue_Type = 'HW';
        //prequest.End_of_Sales_Date = System.now() + 10;
        prequest.ROR_Created_Date = System.now();
        prequest.ROR_Modified_Date = System.now() + 5;
        prequest.ROR_Created_By = 'Ravikant Maurya';
        prequest.ROR_Modified_By = 'Ravikant Maurya';
        
        ProductRequest.valueSetParentType vspt = new ProductRequest.valueSetParentType();
        vspt.name = 'testData';
        List<ProductRequest.valueSetParentType> vsptList = new  List<ProductRequest.valueSetParentType>();
        vsptList.add(vspt);
        
        ProductRequest.ProductHierarchyListSet phls = new ProductRequest.ProductHierarchyListSet();
        phls.ProductHierarchy = vsptList;
        prequest.ProductHierarchySet = phls;
        
        
        prequest.getStringVsp(vsptList);
        
        ProductRequest.IndustryListSet ils = new ProductRequest.IndustryListSet();
        ils.Division = vsptList;
        prequest.DivisionSet =  ils;
        
        ProductRequest.valueSetType vst = new ProductRequest.valueSetType();
        vst.name = 'Testing value set';
        vst.SGID =  '12345';
        List<ProductRequest.valueSetType> vstList = new  List<ProductRequest.valueSetType>();
        vstList.add(vst);
        ProductRequest.Assigned_Industry_GroupListSet aig = new ProductRequest.Assigned_Industry_GroupListSet();
        aig.offer_Portfolio = vstList;
        
        prequest.OfferPortfolioSet = aig;
        
        ProductRequest.SolutionListSet sls = new ProductRequest.SolutionListSet();
        sls.Solution = vstList;
        prequest.SolutionSet = sls;
        
        
        PMDMServices.ProductSyncRequest(prequest);
        ResponseOfRequest re = PMDMServices.ProductSyncRequest(prequest);
        prequest.Product_Name = '';
        PMDMServices.ProductSyncRequest(prequest);
        prequest.Product_Name = 'Test Product';
        prequest.ID = '';
        PMDMServices.ProductSyncRequest(prequest);
        prequest.ID = '12345';
        prequest.Product_Status = '';
        PMDMServices.ProductSyncRequest(prequest);
        prequest.Product_Status = 'ORDERABLE';
        prequest.Product_Type = '';
        PMDMServices.ProductSyncRequest(prequest);
        prequest.Product_Type = 'Hardware';
        prequest.Revenue_Type = '';
        PMDMServices.ProductSyncRequest(prequest);
        prequest.Revenue_Type = 'HW';
        prequest.ROR_Modified_By = '';
        PMDMServices.ProductSyncRequest(prequest);
        prequest.ROR_Modified_By = 'Ravikant Maurya';
        prequest.Ror_Created_By = '';
        PMDMServices.ProductSyncRequest(prequest);
        prequest.Ror_Created_By = 'Ravikant Maurya';
        prequest.ROR_Created_Date = null;
        PMDMServices.ProductSyncRequest(prequest);
        prequest.ROR_Created_Date = System.now(); 
        //prequest.ROR_Modified_Date = null;
        
        Product2 prod = new Product2();
        prod.Name = 'Test product';
        prod.End_Date__c = System.now();
        prod.PMDM_Unique_Key__c = prequest.ID;
        insert prod;
        
        PMDMServices.ProductSyncRequest(prequest);
        PMDMServices.ProductSyncRequest(null); 
        
        ResponseOfRequest res = new ResponseOfRequest();
        PMDMProcessing pd = new PMDMProcessing();
        res = pd.activatePriceBookEntry(prod);
        PMDMProcessing.testHack_1();
        ProductRequest.testHack_1();
        
    }
    public static testMethod void runUnitTest1() {
        
        SolutionRequest srequest = new SolutionRequest();
        srequest.Offer_Status = 'Orderable';    
        srequest.Offer_Type = 'Offer';
        ResponseOfRequest re = new ResponseOfRequest();
        
        List<SolutionRequest.valueSetParentType> vsptList = new  List<SolutionRequest.valueSetParentType>();
        SolutionRequest.valueSetParentType vspt = new SolutionRequest.valueSetParentType();
        SolutionRequest.valueSetParentType vspt1 = new SolutionRequest.valueSetParentType();
        SolutionRequest.valueSetParentType vspt2 = new SolutionRequest.valueSetParentType();
        
        vspt.name = 'test1';
        vspt.SGID='test1';
        vspt.Parent_SGID='test2';
            vspt1.name = 'test2';
        vspt1.SGID='test2';
        vspt1.Parent_SGID='test3';
            vspt2.name = 'test3';
        vspt2.SGID='test3';
        vspt2.Parent_SGID=null;
            vsptList.add(vspt);
        vsptList.add(vspt1);
        vsptList.add(vspt2);
        SolutionRequest.SolutionListSet sl=new SolutionRequest.SolutionListSet() ;
        sl.Solution=vsptList;       
        re = PMDMServices.SolutionSyncRequest(srequest);
        srequest.getSolMap(vsptList);
        system.assert(re !=null,'No response is return.');
        
        
    }
    
    
    
}