/*
* Test Class Name : Controller_indvidualobject_listview_Test
*/
public class GDPR_Updates_helperclass {

    public static void generate_autonumber_insert(List<Individual> triggernew){
    
       List<Individual> individuallist = new List<Individual>([Select id,Auto_Number__c from Individual]);
       
       Integer countofindividualrecords = individuallist.size();
       
       for(Individual i : triggernew){
       
        i.Auto_Number__c ='GDPR(I)-' + countofindividualrecords ;
        countofindividualrecords =  countofindividualrecords + 1;
       
       }
    
    }
    
    public static void generate_autonumber_update(List<Individual> triggernew,Map<id, Individual> TriggeroldMap){
    
      for(Individual i : triggernew){
       
        i.Auto_Number__c = TriggeroldMap.get(i.id).Auto_Number__c ;
        
     }   
    
    }
 
}