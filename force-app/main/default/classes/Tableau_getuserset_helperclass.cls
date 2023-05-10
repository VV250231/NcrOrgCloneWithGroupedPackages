/*
* Created By : Saagar Kinja
* BA         : Haley Logan / Jenni Cosler
* This trigger helper class updates the User Sets depending on Role level Hiererchy in Salesforce.
*/

public class Tableau_getuserset_helperclass {
    
    /* ########################################################################################################## */ 
    
    public static void updatefields(List<Tableau__c> triggernew){
        SET<ID> RoleIDs = new SET<ID>();
        For(Tableau__c Tobject:triggernew){ 
            RoleIDs.add(Tobject.RoleID__c);
        } 
        
        Map<ID, UserRole> UserRoleobjectMAP =new Map<Id,UserRole>([select Id,DeveloperName,Name from UserRole where id IN :roleIds]);
        
        For(Tableau__c Tobject:triggernew){ 
            if(!UserRoleobjectMAP.isEmpty() && !String.isBlank(Tobject.RoleID__c) && UserRoleobjectMAP.containsKey(Tobject.RoleID__c)){
            Tobject.RoleName__c = UserRoleobjectMAP.get(Tobject.RoleID__c).Name ;
            Tobject.RoleDeveloperName__c = UserRoleobjectMAP.get(Tobject.RoleID__c).DeveloperName ;
            }
        }                 
    }
    
    /* ########################################################################################################## */ 
    
    public static void updatescript(List<Tableau__c> triggernew){
        LIST<Tableau__c> TABLEAUOBJECTOUPDATE = new LIST<Tableau__c>();
        SET<ID> RoleIDs = new SET<ID>();
        SET<STRING> tableauserqlookid = new SET<STRING>();
        MAP<ID,SET<ID>> ROLEMAP = new MAP<ID,SET<ID>>();
        SET<ID> subrole = new SET<ID>();
        MAP<ID,SET<ID>> getAllSubRoleIds = new MAP<ID,SET<ID>>();
        MAP<ID,SET<STRING>> getallusers = new MAP<ID,SET<STRING>>();
        String USERSETT1 = 'sk250817', USERSETT2 = 'sk250817' ;
        MAP<ID,SET<STRING>> USERSET1 = new  MAP<ID,SET<STRING>>(); 
        MAP<ID,SET<STRING>> USERSET2 = new  MAP<ID,SET<STRING>>();
        SET<ID> ALLROLEIDS = new SET<ID>();
        /* ########################################################################################################## */ 
        
        system.debug('##########START############START############START###########START##################################### ');
        
        
        For(Tableau__c pse:triggernew){ 
            RoleIDs.add(pse.RoleID__c);
        } 
        
        for(TableauUser__c r : [Select id, UserQlookID__c  from TableauUser__c] ){
            tableauserqlookid.add(r.UserQlookID__c);
        }
        
      //  system.debug(' ### We have the list of Role IDs, triggering transaction :: '+ RoleIDs);   
        
        
        for(TableauSubRoleIDs__c r : [Select id, SubRoleID__c,RoleID__c  from TableauSubRoleIDs__c WHERE RoleID__c IN : RoleIDs] ){
            SET<ID> m = new SET<ID>();
            LIST<ID> t = new LIST<ID>();
            t = r.SubRoleID__c.split(',');
            //SET<ID> m = new SET<ID>();
            for(ID d : t){
                m.add(d);
                ALLROLEIDS.add(d);
            }
            ROLEMAP.put(r.RoleID__c,m);
            
        }
        
      //  system.debug(' ### ALLROLEIDS of ROLE IDs :: '+ ALLROLEIDS);   
      //  system.debug(' ### Here is the MAP of the ROLE ID(Transactional) and the MAP of ROLE IDs :: '+ ROLEMAP);    
        
        USERSET1 = getalluserset1(RoleIDs, ROLEMAP, tableauserqlookid,ALLROLEIDS);  
        
      //  system.debug(' ### Here is the USERSET1 of the ROLE ID(Transactional) and the MAP of ROLE IDs :: '+ USERSET1);  
        
        for(Tableau__c Tobject:triggernew){
            if(!USERSET1.isEmpty() && !String.isBlank(tobject.RoleID__c) && USERSET1.containskey(tobject.RoleID__c) ){  
                Tobject.TestTotalUsers__c= USERSET1.get(tobject.RoleID__c).size();
                STRING value1 = 'sk250817'; STRING value2 = 'sk250817';
                Integer fullsize = USERSET1.get(tobject.RoleID__c).size();
                integer i = 0;  
                for(STRING s : USERSET1.get(tobject.RoleID__c)) {
                    i=i+1;
                    if(i <= fullsize/2){
                        value1 = value1 + ','+s;
                    }
                    if(i > fullsize/2){
                        value2 = value2 + ','+s; 
                    }
                    
                }
                
                //  Tobject.TestUserSet__c  = value1;
                Tobject.UserSet1__c= value1;
                Tobject.UserSet2__c= value2;
                
                //system.debug(' ### Inserting logs , ID is:: '+  Tobject.ID +' ## and Qlooks are :: '+ Tobject.TestUserSet__c);
            }
        }
        
        system.debug('#########END###############END##############END##########END#########END###################### ');
        
        /* ########################################################################################################## */
        
    }
    /* ############################################################################### */ 
    
    private static  MAP<ID,SET<STRING>>  getalluserset1(SET<ID> ROLEIDS, MAP<ID,SET<ID>> ROLEMAP, SET<STRING> tableauserqlookid,SET<ID> ALLROLEIDS){
        
        MAP<ID,SET<STRING>> USERSET1 = new MAP<ID,SET<STRING>>();
        
        for(Id id:ROLEIDS){
            USERSET1.put(id,new SET<STRING>{'sk250817'}); 
        }
        
        
        List<TableauSubUser__c> uss = new List<TableauSubUser__c>([Select Id, qlook__c ,UserRoleId__c From TableauSubUser__c]);
      //  system.debug('uss +'+uss);
        
        for(ID idt : ROLEIDS){
            for(TableauSubUser__c u : uss){ 
               // system.debug('### ### ### here we have the rolemap of this specific idd :: '+idt+' ### and rolemap set :: ' + ROLEMAP.get(idt));
                if(USERSET1.keyset().contains(idt) && ROLEMAP.get(idt).contains(u.UserRoleId__c)){
                    SET<STRING> t = new SET<STRING>();
                    t.addall(USERSET1.get(idt));
                    t.add(u.qlook__c);
                    USERSET1.put(idt,t);
                }
            }
        }
       // system.debug('here is the total size of roles we have'+USERSET1);
        return USERSET1;
        
    }
    
    
}