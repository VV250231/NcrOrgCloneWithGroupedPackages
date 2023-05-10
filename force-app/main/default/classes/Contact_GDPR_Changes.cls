public with sharing class Contact_GDPR_Changes{
    
    public void checkifsuspendprocessing(List<Contact> clist){
        system.debug('################ Suspend processing Started ####################');
        List<Contact> processcontactlist = new List<Contact>();
        for(Contact c : clist){
            if(c.SuspendProcessing_Contact__c == true){
                processcontactlist.add(c);  
            }
        }
         if(processcontactlist.size() > 0){
            checkifindividualexist(processcontactlist); 
        }
        system.debug('################ Suspend Processing Logic Completed ####################');
    }
    public void checkifindividualexist(List<Contact> clist){
        system.debug('########### checkifindividualexist #############  ');
        List<Contact> createlist = new List<Contact>();
        List<Contact> updatelist = new List<Contact>();
        Set<id> indids = new Set<id>();
        
        for(Contact c : clist){
            if(c.IndividualId == null){
                createlist.add(c); 
            } 
            if(c.IndividualId != null && c.SuspendProcessing_Contact__c == true){
                updatelist.add(c); 
                indids.add(c.IndividualId);
            } 
        }
        
        if(createlist.size() > 0){
            checkifindividualrecordinsystem(createlist); 
        }
        if(updatelist.size() > 0){
            updateindividualrecord(indids) ;
        }
        
    }
    public void checkifindividualrecordinsystem(List<Contact> clist){
        system.debug(' ############ checkifindividualrecord ############# ');
        List<Contact> cexistc = New List<Contact>();List<Contact> dexistc = New List<Contact>();
        Set<id> dexist = New Set<id>();
        Set<String> emailid = New Set<String>();
        Map<id,id> idic = new Map<id,id>();
        for(Contact c : clist){
            dexist.add(c.id);
            emailid.add(c.Email);
        }
        List<Individual> ilist =new  List<Individual>(); ilist = [Select id,LastName,FirstName,iemail__c,HasOptedOutProcessing from Individual where iemail__c IN: emailid ];
        
        system.debug(' ############ checkifindividualrecord ############# ');
        for (Integer i = 0 ; i <= (clist.size()-1) ;i++){
            for(Individual ii : ilist){
                if(ii.iemail__c == clist[i].email){
                    cexistc.add(clist[i]); 
                    idic.put(clist[i].id,ii.id);
                    dexist.remove(clist[i].id);
                   // clist.remove(i);
                }
            }
            if(dexist.contains(clist[i].id)){dexistc.add(clist[i]);  }
        }
        
        if(cexistc.size() > 0){
            assignindividualrecord(idic,cexistc) ;
        }
        if(dexist.size() > 0){
            createindividualrecord(clist) ;
        }
    }
    
    public void assignindividualrecord(Map<id,id> idic,List<Contact> cexistc){
        system.debug(' ############ assignindividualrecord ############# ');
        Set<id> indids = new Set<id>();
        for(Contact c : cexistc){
            try
            {  
                id d = idic.get(c.id);
                c.IndividualId = d ;
            }
            catch(Exception e)
            {
                System.debug('Exception @ Query:  ' + e.getMessage());
            }
            if(c.SuspendProcessing_Contact__c == true){
                indids.add(idic.get(c.id));
            }
            
        }
        if(indids.size() >0){
            updateindividualrecord(indids);
        }
    }
    
    public void createindividualrecord(List<Contact> clist){
         
        system.debug('############ createindividualrecord #############  ');
        List<Individual> icreate = new List<Individual>();
        
        for(Contact c : clist){
            Individual i =new Individual();
            i.FirstName = c.FirstName;
            i.LastName = c.LastName;
            i.HasOptedOutProcessing = true ;
            i.iemail__c = c.email;
            i.company__c = c.Account.Name;
            icreate.add(i);
        }
        insert icreate ;
        checkifindividualrecordinsystem(clist);
    }
    
    public void updateindividualrecord(Set<ID> indids){
        system.debug('############ updateindividualrecord #############  ');
        List<Individual> iupdate = new List<Individual>();
        for(Individual i  : [Select id,HasOptedOutProcessing from Individual where id IN: indids]){
            i.HasOptedOutProcessing = true ;
            iupdate.add(i);
        }
        update iupdate;
    }
    
}