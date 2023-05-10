/*
* Created By : Saagar Kinja
* BA         : Haley Logan / Jenni Cosler
* This trigger helper class manages the Tableau users
*/
public class Tableau_Sub_User_Create_Helper{
/* ########################################################################################################## */ 
    public static void create_sub_users(List<TableauUser__c> triggernew){
     List<TableauSubUser__c> tsuser = new List<TableauSubUser__c>();
     
        For(TableauUser__c t : triggernew){
             
             if(t.TRole1__c != null){
             TableauSubUser__c ts = new TableauSubUser__c();
             ts.qlook__c = t.UserQlookID__c.toLowerCase() ;
             ts.RoleIds__c = t.TRole1__c ;
             ts.TableauUser__c = t.id;
             tsuser.add(ts);
             } 
             
             if(t.TRole2__c != null){
             TableauSubUser__c ts = new TableauSubUser__c();
             ts.qlook__c = t.UserQlookID__c.toLowerCase() ;
             ts.RoleIds__c = t.TRole2__c ;
             ts.TableauUser__c = t.id;
             tsuser.add(ts);
             }
             
             if(t.TRole3__c != null){
             TableauSubUser__c ts = new TableauSubUser__c();
             ts.qlook__c = t.UserQlookID__c.toLowerCase() ;
             ts.RoleIds__c = t.TRole3__c ;
             ts.TableauUser__c = t.id;
             tsuser.add(ts);
             }
          }
      insert tsuser;
    }
    
    
     /* ########################################################################################################## */ 
    
    public static void deleteallexisting(List<TableauUser__c> triggernew){
    
    Set<id> settodel = new Set<id>();
    for(TableauUser__c t : triggernew){
      settodel.add(t.id);
    }
    List<TableauSubUser__c> ttodel = new List<TableauSubUser__c>([Select id from TableauSubUser__c where TableauUser__c  IN: settodel]);
    
    if(ttodel.size() >0){
    delete ttodel;
    }
    
    }
    /* ########################################################################################################## */ 
       
    
}