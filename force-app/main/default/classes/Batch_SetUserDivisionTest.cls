@isTest
public class Batch_SetUserDivisionTest {
   
static testMethod void getPrdrecordstest() {
List<String> filterlist=new List<String>();
WrapperFavorite wp= new WrapperFavorite();
List<Product2> insertprodlist=new List<product2>();
//Creating products 
  Product2 pd=TestRecordsFactory.createProduct();
  pd.IsActive=True;
  List<Product2> prdlist1=new List<product2>();
        Product2 p01 = new Product2();
        p01.Name= '2181-Full-Size Cash Drawer';
        p01.CurrencyIsoCode = 'USD';
        p01.Family = 'Solution';
        p01.Name = '1902-ECPIX LSI';
        p01.Product_Category__c = 'PRODUCTCATEGORY: ';
        //p01.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p01.Solution_Portfolio__c = 'Payment Solutions';
        //p01.Division__c='Financial';
        p01.isActive=true;
        p01.Industry__c='Retail';
        prdlist1.add(P01);
        insertprodlist.add(P01);

 List<Product2> prdlist2=new List<product2>();
        Product2 p02 = new Product2();
        p02.name= 'IPS';
        p02.CurrencyIsoCode = 'USD';
        p02.Family = 'Solution';
        p02.Name = '1902-ECPIX LSI';
        p02.Product_Category__c = 'PRODUCTCATEGORY:SW ';
        //p02.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p02.Solution_Portfolio__c = 'Payment Solutions';
        //p02.Division__c='Retail';
        p02.isActive=true;
        prdlist2.add(P02);
        insertprodlist.add(P02);
        
 List<Product2> prdlist3=new List<product2>();
        Product2 p03 = new Product2();
        p03.Name= '2186';
        p03.CurrencyIsoCode = 'USD';
        p03.Family = 'Solution';
        p03.Name = '1902-ECPIX LSI';
        p03.Product_Category__c = 'HW';
        //p03.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p03.Solution_Portfolio__c = 'Payment Solutions';
        //p02.Division__c='Retail';
        p03.isActive=true;
        prdlist3.add(P03);
        insertprodlist.add(P03);
         
         
        List<Product2> prdlist4=new List<product2>();
        Product2 p04 = new Product2();
        p04.Name= 'Cloud';
        p04.CurrencyIsoCode = 'USD';
        p04.Family = 'Solution';
        p04.Name = '1902-ECPIX LSI';
        p04.Product_Category__c = 'PRODUCTCATEGORY:SW';
        //p04.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p04.Solution_Portfolio__c = 'Payment Solutions'; 
        p04.isActive=true;
        prdlist4.add(P04);
        

        insertprodlist.add(P04);
    

   insert insertprodlist;   
  //end products creation     
   
   //Creating Opportunity Line Items  
    EBDEDDSetting__c ebdedd = new EBDEDDSetting__c();
    ebdedd.Name = 'EDSD_Calc';
    ebdedd.isActive__c = true;
    insert ebdedd;    
    system.assert(ebdedd.id!=null);
    system.assertEquals(ebdedd.isActive__c , true);
    Opportunity opp= TestRecordsFactory.createSimpleOpportunity();
    List<PricebookEntry> pbe=TestRecordsFactory.createPriceBookEntry(insertprodlist);
    List <OpportunityLineItem> oliL=TestRecordsFactory.createOpportunityLineItem(opp,pbe);
    OpportunityLineItem oli=TestRecordsFactory.createOpportunityLineItem(opp,pbe[0]);
      Test.starttest(); 
        Batch_SetUserDivision obj = new Batch_SetUserDivision();
        database.executeBatch(obj);
      Test.stoptest();
       
        }
    static testmethod void Schedule_SetUserDivisoinTest(){
        
        Test.startTest();
       String sch = '0 0 23 * * ?';
        String jobId1=system.schedule('Test check', sch, new Schedule_SetUserDivisoin()); 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId1];  
        System.assertEquals(sch, ct.CronExpression); 
        Test.stopTest();
    }
}