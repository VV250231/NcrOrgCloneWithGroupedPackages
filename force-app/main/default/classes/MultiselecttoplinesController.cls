/**
##################################################################################################
# Project Name and Request Num..........: NSC Sales Central
# File............................: MuliselectcomponentToplines.Component AND MultiselectcomponentToplinesNotSold.Component 
# Created by................: Saritha karutrui                                                                   
# Created Date...........: 10-08-2016                                                                              
# Last Modified by......:  Saritha Karuturi 
# Last Modified Date..:    10-08-2016
# Description...............: This class will be used as server side controller for above mentioned two components.It is basically send the toplines and competitotrs infromation to components.
These componenets data will be displayed.

                              NSCI_AGILE-2048: Phase 2 Show list of toplines in the funnel
                              NSCI_AGILE-2047: Phase 1 Show list of competitors and purchased toplines
                              NSCI_AGILE-2049: Phase 3 Show list of toplines we have not sold
                              EBA_SF-2491 JDK Locale impact - Upgrade API Part 5 

################################################################################################
*/



public class MultiselecttoplinesController {
    @AuraEnabled 
    public static String getpickval_CompetitorValues(){
        return [Select Competetors__c From ToplineCompetetors__c].Competetors__c; 
    }
     
    @AuraEnabled  
    public static List<WrapperMultipleSelectToplineNotSold> NewGetPicklistNotSoldValue(String accId){
    String accname=[Select Master_Customer_Number__c from Account where Id =:accId].Master_Customer_Number__c ; 
    List<WrapperMultipleSelectToplineNotSold>  WrpLst=new List<WrapperMultipleSelectToplineNotSold>();    
      Map<String,Boolean> KeyOppMap=new Map<String,Boolean>(); 
        Map<String,Boolean> OpptyMapFinal=new Map<StrinG,Boolean>();
        Majors_Product_Matrix__c MjrPrdMtrxRcrd=[select id,New_Competetors__c,Purchased_List__c,Producttoplines__c from Majors_Product_Matrix__c where MCN__c =:accname limit 1];
        
        if(String.isNotBlank(MjrPrdMtrxRcrd.id))
        {
            for(String pl : MjrPrdMtrxRcrd.Purchased_List__c.split(';')){
                
                if(!KeyOppMap.containsKey(pl)){
                    KeyOppMap.put(pl, True);
                }    
                
            }
            
            for(String pt: MjrPrdMtrxRcrd.Producttoplines__c.split(';'))
            {
                if(KeyOppMap.containsKey(pt))
                {
                    OpptyMapFinal.put(pt,True);
                }   
                
                else{
                    OpptyMapFinal.put(pt,False);
                }
            }
        }

		if(OpptyMapFinal.size()!=null) {
            for(String strval: OpptyMapFinal.KeySet())
            {
                //if(OpptyMapFinal.containsKey(Mapstrvalue))
                //{
                    WrpLst.add(new WrapperMultipleSelectToplineNotSold(strval,OpptyMapFinal.get(strval)));
                //}
            }
       } 
       return WrpLst;   
    }
        
   @AuraEnabled
   public static String addCompetetors(String testvalue)
    {
      ToplineCompetetors__c mpm =[Select Id, Competetors__c From ToplineCompetetors__c limit 1];
                   if(testvalue!=null){
                   mpm.Competetors__c = mpm.Competetors__c+';'+testvalue;
                   }
              upsert mpm;
         
        return mpm.Competetors__c;
              
    }
    
    
   @AuraEnabled
   public static void saveCompetetors(String rightvalues,String accId)
    {
      String accname=[Select Master_Customer_Number__c from Account where Id =:accId].Master_Customer_Number__c;     
      //Majors_Product_Matrix__c str1=[select id,name,Account_Name__c,MCN__c,New_Competetors__c ,ATM_Client_SW__c,iServices__c,Channel_Management__c,ATM_SS_Fraud_SW__c,Check_Processing__c,Cx_Marketing__c,Remote_Distributed_Capture__c from Majors_Product_Matrix__c where MCN__c =:accname];
      Majors_Product_Matrix__c str1=[select id,New_Competetors__c from Majors_Product_Matrix__c where MCN__c =:accname] ;
     if(rightvalues!=null){
      str1.New_Competetors__c=rightvalues;
      upsert str1;  
      }      
    }
    
  @AuraEnabled  
  public static void SaveNotSoldvalues(String notsoldvalue1, String accId) 
    {
   
         String accname=[Select Master_Customer_Number__c from Account where Id =:accId].Master_Customer_Number__c;     
         Majors_Product_Matrix__c mpm1=[select id,Producttoplines__c from Majors_Product_Matrix__c where MCN__c =:accname];

        if(String.isNotBlank(notsoldvalue1))
        {
             mpm1.Producttoplines__c = mpm1.Producttoplines__c+';'+notsoldvalue1;                        
        }
                  
                   
       update mpm1;
    }
     
    @AuraEnabled  
    public static List<WrapperMultipleSelectTopline> NewGetPicklistCompetetorsValue(String accId){
    //Account accname=[select id,name,Master_Customer_Number__c,(select id,MCN__C FROM Master_Customer_Number__r) from Account where Id=:accId];
    String accname=[Select Master_Customer_Number__c from Account where Id =:accId].Master_Customer_Number__c;    
    //select id,name,Account_Name__c,MCN__c,ATM_Client_SW__c,HW_Owned_By_Customer__c,iServices__c,Channel_Management__c,ATM_SS_Fraud_SW__c,Check_Processing__c,Cx_Marketing__c,Remote_Distributed_Capture__c from Majors_Product_Matrix__c where MCN__c =:acc.Master_Customer_Number__c];    
        Map<String,Boolean> KeyOppMap=new Map<String,Boolean>();
        String str1=[select id, New_Competetors__c from Majors_Product_Matrix__c where MCN__c =:accname].New_Competetors__c ;
        String str2=[Select Id, Competetors__c From ToplineCompetetors__c limit 1].Competetors__c;  
        if(String.isNotBlank(str1) && str1.length()>1){  
                for(String str : str1.split(';')){
                  KeyOppMap.put(str, true); 
                } 
        }
        if(String.isNotBlank(str2) && str2.length()>1){
            for(String str : str2.split(';')){
                        if(!KeyOppMap.containsKey(str))
                        KeyOppMap.put(str, false); 
                } 
        }
         
        List<WrapperMultipleSelectTopline>  WrpLst=new List<WrapperMultipleSelectTopline>();
        if(KeyOppMap.size()!=null){
            for(String Mapstrval: KeyOppMap.KeySet())
            {
                //if(KeyOppMap.containsKey(Mapstrvalue))
                //{
                    WrpLst.add(new WrapperMultipleSelectTopline(Mapstrval,KeyOppMap.get(Mapstrval)));
                //}
            }  
        }         
        return WrpLst; 
    }
    
    @AuraEnabled
    public static void saveSelectedSoldItems(String rightvalues,String leftvalues,String accId)
    {
      String accMCN=[Select Master_Customer_Number__c from Account where Id =:accId].Master_Customer_Number__c;     
      Majors_Product_Matrix__c str1=[select id,Purchased_List__c,Not_Sold_List__c from Majors_Product_Matrix__c where MCN__c =:accMCN];    
      if(rightvalues!=null && leftvalues != null){
       str1.Purchased_List__c=rightvalues;
       str1.Not_Sold_List__c=leftvalues;    
       upsert str1;   
      }      
    }
}