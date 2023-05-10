public class LinkCaseWithNPSSurveyResultHandler {
    
    //public static boolean isFirst = true;
    // Assigning Case Owner to contact owner if case-->Account.LOB id 'T&T' otherwise account owner
    public static void updateCaseOwner(List<Case> caseL){
        Set<Id> conIdS = new Set<Id>();
        Map<Id, String> conIdtoAccLOBMap = new Map<Id, String>();
        Map<Id, Contact> conIdtoConMap = new Map<Id, Contact>();
        //Set<Id> caseRecordTypeIdSet = new Set<Id>();
        //Set<String> CaseIdSet = new Set<String>();
        //List<Case> CaseListToUpdateCaseOwner = new List<Case>();
        
        //for(RecordType recType : [Select Id, Name FROM RecordType Where Name ='Close The Loop' OR Name = 'Follow-up']){
        /*for(RecordType recType : [Select Id, Name FROM RecordType Where Name ='Close The Loop']){
            caseRecordTypeIdSet.add(recType.Id);
        }*/
        Id clsLupRecId = [Select Id, Name FROM RecordType Where Name ='Close The Loop'].Id;
        for(Case c : caseL){
            if(c.ContactId != null && c.recordTypeId == clsLupRecId){
            	conIdS.add(c.ContactId);
               /* if(String.isNotBlank(obj.Id)){
                    CaseIdSet.add(obj.Id);
                } */
            }
        }
        
        if(!conIdS.isEmpty()){
            for(Contact c : [Select ownerId, Account.LOB__c, Account.ownerId  FROM Contact Where Id IN : conIdS]){
                conIdtoConMap.put(c.Id, c);
                conIdtoAccLOBMap.put(c.Id, c.Account.LOB__c);
            }
        }
        
        if(conIdtoAccLOBMap.size() > 0 && conIdtoConMap.size() > 0){
            for(Case c : caseL){
                //Case CaseObjToUpdate = new Case();
               // caseObj.Id =caseObj.Id;
                if(c.contactId != null && conIdtoAccLOBMap.get(c.contactId) == 'T&T'){
                    if(conIdtoConMap.containsKey(c.contactId) && String.isNotBlank(conIdtoConMap.get(c.contactId).ownerId)){
                         c.ownerId = conIdtoConMap.get(c.contactId).ownerId;
                    }
                   
                }else{
                    if(conIdtoConMap != null && conIdtoConMap.containsKey(c.contactId) && conIdtoConMap.get(c.contactId).Account != null){
                        c.ownerId = conIdtoConMap.get(c.contactId).Account?.ownerId;
                    }
                }
                
              // CaseListToUpdateCaseOwner.add(CaseObjToUpdate);
               
            }
        }
        
       /* if(CaseListToUpdateCaseOwner != null && CaseListToUpdateCaseOwner.size()>0){
                update CaseListToUpdateCaseOwner; 
            }*/
    }
        
    public static Map<String,Map<String,VocLineOfBusiness__mdt>> GetMapOfFunctionalAreaAndLob(){
        List<VocLineOfBusiness__mdt> metaList =  new List<VocLineOfBusiness__mdt>();
        Map<String,Map<String,VocLineOfBusiness__mdt>> fctnAreaNdLobM = new Map<String,Map<String,VocLineOfBusiness__mdt>>();
        metaList= [Select id,Label,RelatedQueue__c,FunctionalAreaOwner__c,VocFunctionaArea__r.Label,VocFunctionaArea__c,VocFunctionaArea__r.FunctionalAreaOwner__c from VocLineOfBusiness__mdt where Label <> 'Sales'];
        if((metaList != null) && (metaList.size()>0)){
            for(VocLineOfBusiness__mdt m : metaList){
                String mlab = m.label.touppercase();
                if(!fctnAreaNdLobM.containsKey(mlab)){
                    fctnAreaNdLobM.put(mlab, new Map<String,VocLineOfBusiness__mdt>());
                }
                if(!fctnAreaNdLobM.get(mlab).containsKey(m.VocFunctionaArea__r.Label.touppercase())){
                    fctnAreaNdLobM.get(mlab).put(m.VocFunctionaArea__r.Label.touppercase(),m);
                }
            }
        }
        return fctnAreaNdLobM;
    }
    public static void updateContactOwnerEmail(List<Case> caseL){ 
        Set<Id> conIdS = new Set<Id>();
        Map<Id, String> conIdToConOwnMailM = new Map<Id, String>();
        List<VocRecordTypeChild__mdt> VOCRecTypM = new List<VocRecordTypeChild__mdt>();
        VOCRecTypM =[Select id,PickListValue__c,RecordTypeId__c,Status__c from VocRecordTypeChild__mdt]; 
        Set<String> VocRecTyp = new Set<String>();
        for(VocRecordTypeChild__mdt m : VOCRecTypM){
            if(!VocRecTyp.contains(m.RecordTypeId__c)){
                VocRecTyp.add(m.RecordTypeId__c);
            } 
        }
        for(Case c : caseL){
            if(c.ContactId != null && VocRecTyp.contains(c.recordTypeId)){
                conIdS.add(c.ContactId);
            }
        }
        if(conIdS != null && conIdS.size() > 0 ){
             for(Contact c : [Select Id, Owner.Email FROM Contact Where Id IN : conIdS]){
                if(c.owner != null && c.OwnerId != null &&  String.isNotBlank(c.owner.Email)){
                    conIdToConOwnMailM.put(c.Id, c.owner.Email); 
                } 
            }
        }
        
        if(conIdToConOwnMailM !=  null && conIdToConOwnMailM.keySet().size()>0){
             for(Case c : caseL){         
                if(conIdToConOwnMailM.containsKey(c.ContactId)){
                    c.Contact_Owner_Email__c = conIdToConOwnMailM.get(c.ContactId);
                }
            }
        }
        
    }
}