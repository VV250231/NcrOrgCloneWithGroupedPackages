public class LeadandContactDetailCtrl {
    public String inputUserIds{get;set;}
    
    
    public String getLeadandConDetail(){
        String body= '';
        if(String.isNotBlank(inputUserIds)) {
            List<String> userIdSets = inputUserIds.split(',');
            List<Contact> conList = new List<Contact>();
            List<Lead> leadList = new List<Lead>();
            List<String> userIdLst = new List<String>(userIdSets);
            
            
            Map<String,List<Contact>> conMap = new Map<String, List<Contact>>();
            Map<String,List<Lead>> leadMap = new Map<String, List<Lead>>();
            //System.debug('@@@'+[SELECT id,Name,OwnerId,Owner.Name From Lead Where OwnerId IN:userIdSets]);
            for(Lead leadObj : [SELECT id,Name,OwnerId,Owner.Name From Lead Where IsConverted=False AND OwnerId IN:userIdSets]){
                if(leadMap.containsKey(leadObj.OwnerId +'-'+leadObj.Owner.Name)){
                    leadMap.get(leadObj.OwnerId +'-'+leadObj.Owner.Name).add(leadObj);
                }else{
                    leadMap.put(leadObj.OwnerId +'-'+leadObj.Owner.Name,new List<Lead>{leadObj});
                }  
            }
            
            for(Contact conObj : [SELECT id,Name,OwnerId,Owner.Name From Contact Where OwnerId IN:userIdSets]){                      
                if(conMap.containsKey(conObj.OwnerId +'-'+conObj.Owner.Name)){
                    conMap.get(conObj.OwnerId +'-'+conObj.Owner.Name).add(conObj);
                }else{
                    conMap.put(conObj.OwnerId +'-'+conObj.Owner.Name,new List<Contact>{conObj});
                }          
            }
            system.debug('@@@@'+conMap.size());
            if(conMap.size()>0 || leadMap.size()>0){
                List<User__c> customSettingList = new List<User__c>();
                List<User__c> mcs = User__c.getall().values();
                
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                String[] sendingTo = new String[]{mcs[0].Email_Address__c};
                    message.setToAddresses(sendingTo);          
                //  message.setInReplyTo('NI230017@ncr.com');
                message.setSenderDisplayName('NSC Admin');
                message.optOutPolicy = 'FILTER';
                message.subject = 'Inactive Users Leads And Contacts';            
               
                //body = str1;
                //body += str2;            
                
                if(conMap.size()>0){
                    //     body += 'Below the list Of contact of all deactivated users names and its contacts list<br/>';                
                    for(String mapId : conMap.keySet()){
                        body += '<b>Salesforce User Name :</b>&nbsp'+ mapId.split('-')[1]+'<br/><br/>';            
                        body += '<b>List Of Contact </b><br/>';
                        for(Contact con : conMap.get(mapId))
                        {
                            System.debug('@@@@'+con);          
                            body += '<a href="'+Label.inactiveLeadAndContactLabel+'lightning/r/Contact/'+con.id+'/view">' +con.Name+'</a><br/>';               
                        }
                        body+='<br/>';
                    }
                }
                body +=' <br/><br/>';
                if(leadMap.size()>0){
                    //        body += 'Below the list Of Lead of all deactivated users name and its lead list-<br/>'; 
                    for(String mapLeadId : leadMap.keySet()){
                        body += '<b>Salesforce User Name : </b>&nbsp'+ mapLeadId.split('-')[1]+'<br/><br/>';            
                        body += '<b>List Of Lead </b><br/>';
                        
                        for(Lead leadObj : leadMap.get(mapLeadId))
                        {
                            System.debug('@@@@'+leadObj);          
                            body += '<a href="'+Label.inactiveLeadAndContactLabel+'lightning/r/Lead/'+leadObj.id+'/view">' +leadObj.Name+'</a><br/>';               
                        }
                        body+='<br/>';
                    }
                }
            }
        }
        return body;
    }
}