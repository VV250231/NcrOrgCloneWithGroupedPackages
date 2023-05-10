trigger SynkCSM_To_CADD on AccountTeamMember (After insert,Before Delete) {
        
         if(Trigger.IsAfter){
         
            if(Trigger.isInsert){
                    Set<String> IdSetOfAccount= new Set<String>();
                    Set<Deming__c> UpdateDeminRecord = new Set<Deming__c>();
                    Set<Deming__Share> DemingShareRecordShare = new Set<Deming__Share>();
                    Map<String,List<AccountTeamMember>> AccountAndUserIdMap= new Map<String,List<AccountTeamMember>>();
                    Map<String,AccountTeamMember> AccountAndUserIdMapCSM= new Map<String,AccountTeamMember>();
                    Map<String,AccountTeamMember> AccountAndUserIdMapIMC= new Map<String,AccountTeamMember>();
                    for(AccountTeamMember AccTeamObj : [SELECT Id,TeamMemberRole,UserId,User.Quicklook_ID__c,User.Email,AccountId FROM AccountTeamMember  WHERE Id IN : Trigger.newMap.KeySet()]){
                        
                        
                        if(AccTeamObj.TeamMemberRole=='Customer Success Manager'){
                            IdSetOfAccount.add(AccTeamObj.AccountId);
                            if(!AccountAndUserIdMapCSM.ContainsKey(AccTeamObj.AccountId)){
                                  AccountAndUserIdMapCSM.put(AccTeamObj.AccountId,AccTeamObj);    
                                 
                            } 
                        }
                        
                        if(AccTeamObj.TeamMemberRole=='Implementation Coordinator'){
                            IdSetOfAccount.add(AccTeamObj.AccountId);
                            if(!AccountAndUserIdMapIMC.containsKey(AccTeamObj.AccountId)){
                                AccountAndUserIdMapIMC.put(AccTeamObj.AccountId,AccTeamObj);
                                //ssystem.debug('>>>>>'+AccountAndUserIdMapIMC); 
                            }
                        }
                        
                        
                        
                        if(!AccountAndUserIdMap.ContainsKey(AccTeamObj.AccountId)){
                            AccountAndUserIdMap.put(AccTeamObj.AccountId, new List<AccountTeamMember>());
                        }
                        AccountAndUserIdMap.get(AccTeamObj.AccountId).add(AccTeamObj);
                    }
                    
                    for(Deming__c DemRecord : [Select id,RelatedAccount__c,AccountManagerEmail__c,AccountCordinatorEmail__c,AccountCoordinatorUserId__c from Deming__c where RelatedAccount__c IN:AccountAndUserIdMap.keySet() AND Cadd_Status__c = 'Open']){
                        Deming__c DemObj = new Deming__c();
                        DemObj.Id=DemRecord.id;
                           
                           if((AccountAndUserIdMap != null) && (AccountAndUserIdMap.containsKey(DemRecord.RelatedAccount__c) != null)  && (AccountAndUserIdMap.containsKey(DemRecord.RelatedAccount__c))){
                                
                                for(AccountTeamMember teamObj : AccountAndUserIdMap.get(DemRecord.RelatedAccount__c)){
                                       DemingShareRecordShare.add(DemingEmailServiceClass.CreateShareRecord(teamObj.UserId, 'Edit', DemObj.id));                  
                                       
                                       if((AccountAndUserIdMapCSM.containsKey(DemRecord.RelatedAccount__c)) && (AccountAndUserIdMapCSM.get(DemRecord.RelatedAccount__c).TeamMemberRole=='Customer Success Manager')){
                                            DemObj.AccountManagerEmail__c=AccountAndUserIdMapCSM.get(DemRecord.RelatedAccount__c).User.Email;
                                            DemObj.ReadShareWithUser__c=String.valueOf(AccountAndUserIdMapCSM.get(DemRecord.RelatedAccount__c).UserId).substring(0, 15);
                                       }
                                       if((AccountAndUserIdMapIMC.containsKey(DemRecord.RelatedAccount__c)) && (AccountAndUserIdMapIMC.get(DemRecord.RelatedAccount__c).TeamMemberRole=='Implementation Coordinator')){
                                           
                                           DemObj.AccountCordinatorEmail__c=AccountAndUserIdMapIMC.get(DemRecord.RelatedAccount__c).User.Email;
                                           DemObj.AccountCoordinatorUserId__c=String.valueOf(AccountAndUserIdMapIMC.get(DemRecord.RelatedAccount__c).UserId).substring(0, 15);
                                       }
                                       UpdateDeminRecord.add(DemObj); 
                                }
                               
                          
                            }
                  }
                    
                    if(DemingShareRecordShare.Size() > 0 ){
                         List<Deming__Share> ListtoInsertShareObj = new List<Deming__Share>();
                         ListtoInsertShareObj.addAll(DemingShareRecordShare);
                         insert ListtoInsertShareObj; 
                    }   
                        
                    if(UpdateDeminRecord.size()>0){
                         List<Deming__c> DemingUpdateList= new List<Deming__c>();
                         DemingUpdateList.addAll(UpdateDeminRecord);
                         update DemingUpdateList;
                    }
                }
            }

            if(Trigger.isBefore  && Trigger.isDelete){
                Set<String> UserIdSet = new Set<String>();
                List<Deming__Share> ShareObjToDelete = new List<Deming__Share>();
                for(AccountTeamMember AccTeamObj : [SELECT Id,TeamMemberRole,UserId,User.Quicklook_ID__c,User.Email,AccountId FROM AccountTeamMember  WHERE Id IN : Trigger.OldMap.keySet()]){
                    if(!UserIdSet.contains(AccTeamObj.UserId)){
                        UserIdSet.add(AccTeamObj.UserId); 
                    }
                    
                }
                if(UserIdSet.size()>0){
                 
                    for(Deming__Share ShareObj : [Select id,ParentId,UserOrGroupId,AccessLevel,RowCause from Deming__Share WHERE  UserOrGroupId IN : UserIdSet]){
                        Deming__Share ObjShare = new Deming__Share();
                        ObjShare.id=ShareObj.id;
                        ShareObjToDelete.add(ObjShare); 
                    }
                }
                if(ShareObjToDelete.size()>0){
                    Delete ShareObjToDelete;
                }
            }
            
            
}