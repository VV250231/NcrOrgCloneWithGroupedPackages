public with sharing class Lead_GDPR_Changes {
    
    public void checkifsuspendprocessing(List<Lead> clist){
        system.debug('################ Suspend processing Started ####################');
        List<Lead> processcontactlist = new List<Lead>();
        for(Lead c : clist){
            if(c.SuspendProcessing_Lead__c == true){
                processcontactlist.add(c);  
            }
        }
        if(processcontactlist.size() > 0){
            checkifindividualexist(processcontactlist); 
        }
        system.debug('################ Suspend Processing Logic Completed ####################');
    }
    public void checkifindividualexist(List<Lead> clist){
        system.debug('########### checkifindividualexist #############  ');
        List<Lead> createlist = new List<Lead>();
        List<Lead> updatelist = new List<Lead>();
        Set<id> indids = new Set<id>();
        
        for(Lead c : clist){
            if(c.IndividualId == null){
                createlist.add(c); 
            } 
            if(c.IndividualId != null && c.SuspendProcessing_Lead__c == true){
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
    public void checkifindividualrecordinsystem(List<Lead> clist){
        system.debug(' ############ checkifindividualrecord ############# ');
        List<Lead> cexistc = New List<Lead>(); List<Lead> dexistc = New List<Lead>();
        Set<id> dexist = New Set<id>();
        Map<id,id> idic = new Map<id,id>();
        Set<String> emailid = New Set<String>();
        for(Lead c : clist){
            dexist.add(c.id);
            emailid.add(c.email);
        }
        List<Individual> ilist =new  List<Individual>(); ilist = [Select id,LastName,iemail__c,FirstName,Company__c,HasOptedOutProcessing from Individual where iemail__c IN: emailid ];
        
         for (Integer i = 0 ; i <= (clist.size()-1) ;i++){
            for(Individual ii : ilist){
                if(String.isNotBlank(ii.iemail__c) && String.isNotBlank(clist[i].email)){
                    if((ii.iemail__c == clist[i].email)){
                        cexistc.add(clist[i]); 
                        idic.put(clist[i].id,ii.id);
                        dexist.remove(clist[i].id);
                    }
                }
                if(String.isNotBlank(ii.FirstName) && String.isNotBlank(clist[i].FirstName) && String.isNotBlank(ii.LastName) && String.isNotBlank(clist[i].LastName) && String.isNotBlank(ii.company__c) && String.isNotBlank(clist[i].Company)){
                    if(ii.FirstName == clist[i].FirstName && ii.LastName == clist[i].LastName && ii.company__c == clist[i].Company){
                        cexistc.add(clist[i]); 
                        idic.put(clist[i].id,ii.id);
                        dexist.remove(clist[i].id);
                    }
                }
               
            }
            if(dexist.contains(clist[i].id)){dexistc.add(clist[i]);  }
        }
        
        if(cexistc.size() > 0){
            assignindividualrecord(idic,cexistc) ;
        }
        if(dexist.size() > 0){
            createindividualrecord(dexistc) ;
        }
    }
    public void assignindividualrecord(Map<id,id> idic,List<Lead> cexistc){
        system.debug(' ############ assignindividualrecord ############# ');
        Set<id> indids = new Set<id>();
        for(Lead c : cexistc){
            try{  
                id d = idic.get(c.id);
                c.IndividualId = d ;
            }
            catch(Exception e){
                System.debug('Exception @ Query:  ' + e.getMessage());
            }
            if(c.SuspendProcessing_Lead__c == true){
                indids.add(idic.get(c.id));
            }
            
        }
        if(indids.size() >0){
            updateindividualrecord(indids);
        }
    }
    public void createindividualrecord(List<Lead> clist){
        system.debug('############ createindividualrecord #############  ');
        List<Individual> icreate = new List<Individual>();
        
        for(Lead c : clist){
            Individual i =new Individual();
            i.FirstName = c.FirstName;
            i.LastName = c.LastName;
            i.HasOptedOutProcessing = true ;
            if(String.isNotBlank(c.email)){ i.iemail__c = c.email ;}
            else if(String.isBlank(c.email)){
                String t = c.id +'@'+c.id+'.com';
                i.iemail__c =t ;
                c.email = t ;
            }
            i.company__c = c.company;
            icreate.add(i);
        }
        insert icreate ;
        checkifindividualrecordinsystem(clist);
    }
    public void updateindividualrecord(Set<ID> indids){
        system.debug('############ updateindividualrecord #############  ');
        List<Individual> iupdate = new List<Individual>();
        for(Individual i  : [Select id,HasOptedOutProcessing,FirstName from Individual where id IN: indids]){
            i.HasOptedOutProcessing = true ;
            iupdate.add(i);
        }
        update iupdate;
    }
}