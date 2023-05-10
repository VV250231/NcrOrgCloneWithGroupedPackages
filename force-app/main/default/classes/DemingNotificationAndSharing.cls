global class DemingNotificationAndSharing implements Database.Batchable<sObject>, Database.Stateful {
   
    global Set<String> MCNSet = new Set<String>();
    global Set<String> IndustrySet  = new Set<String>();
    global Set<String> IdSetOfUser = new Set<String>();
    global Set<String> ReasonCodeSet  = new Set<String>(); 
    global Set<String> CustomerRequestSet= new Set<String>();
    global Set<String> NonCustomerRequestSet= new Set<String>();
    global Boolean ValidateMCN; 
    global Boolean ValidateIndustry; 
    global Boolean ValidateReasonCode;
    global  String UserId;
    
    global Set<String> toAddressCustomerRequested= new Set<String>();
    global Set<String> ccAddressCustomerRequested = new Set<String>();
    global Set<String> customerNameCustomerRequested= new Set<String>();
	
    global Set<String> toAddressNonCustomerRequested= new Set<String>();
    global Set<String> ccAddressNonCustomerRequested= new Set<String>();
    global Set<String> customerNameNonCustomerRequested= new Set<String>();
	
    global Set<String> toAddressPdLessRdd= new Set<String>();
    global Set<String> ccAddressPdLessRdd= new Set<String>();
    global Set<String> customerNamePdLessRdd= new Set<String>();
    
    
    global DemingNotificationAndSharing(Set<String >IdSetOfUser,Boolean ValidateMCN,Boolean ValidateIndustry,Boolean ValidateReasonCode,Set<String> MCNSet,Set<String> IndustrySet,Set<String> ReasonCodeSet,Set<String> CustomerRequestSet,Set<String> NonCustomerRequestSet){
        this.ValidateMCN=ValidateMCN;
        this.ValidateIndustry=ValidateIndustry;
        this.ValidateReasonCode=ValidateReasonCode;
        this.MCNSet=MCNSet;
		this.IndustrySet=IndustrySet;
		this.ReasonCodeSet=ReasonCodeSet;
        this.IdSetOfUser=IdSetOfUser; 
        this.CustomerRequestSet=CustomerRequestSet;
        this.NonCustomerRequestSet=NonCustomerRequestSet;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
           
             String query='';
             if(IdSetOfUser.size()>0){ 
                  UserId = new List<String> (IdSetOfUser).get(0); 
                  IdSetOfUser.remove(UserId);
                 
             }   
                   if(ValidateMCN && ValidateIndustry && ValidateReasonCode){ 
                        return Database.getQueryLocator('Select Id,AccountCoordinatorUserId__c,AccountCordinatorEmail__c,CreatedById,ReadShareWithUser__c,Region__c,Customer_Name__c,Customer_No__c,Customer_Industry__c,EditShareWithUserSpFound__c,Include_In_Process__c,AccountManagerEmail__c,EditShareWithUser__c,Customer_Delivery_Partner_Email__c,Neither_SP_nor_AM_found__c,IsSalespersonFound__c,Is_Account_Manager__c,Max_Promise_Date__c,Rdd__c, Reason_Code__c, CADD_Owner__c FROM Deming__c WHERE EditShareWithUser__c =:UserId  and Include_In_Process__c =false and  (Customer_No__c  IN:MCNSet OR Region__c IN:ReasonCodeSet OR Customer_Industry__c IN:IndustrySet) AND  (Reason_Code__c =null OR Reason_Code__c IN:CustomerRequestSet OR Reason_Code__c IN:NonCustomerRequestSet)');  
                   }
                    
                    else if(ValidateMCN  && ValidateIndustry){
                        return Database.getQueryLocator('Select Id,AccountCoordinatorUserId__c,AccountCordinatorEmail__c,CreatedById,ReadShareWithUser__c,Region__c,Customer_Name__c,Customer_No__c,Customer_Industry__c,EditShareWithUserSpFound__c,Include_In_Process__c,AccountManagerEmail__c,EditShareWithUser__c,Customer_Delivery_Partner_Email__c,Neither_SP_nor_AM_found__c,IsSalespersonFound__c,Is_Account_Manager__c,Max_Promise_Date__c,Rdd__c, Reason_Code__c, CADD_Owner__c FROM Deming__c WHERE EditShareWithUser__c =:UserId and Include_In_Process__c =false and  (Customer_No__c  IN:MCNSet OR Customer_Industry__c IN:IndustrySet AND (Reason_Code__c IN:CustomerRequestSet OR Reason_Code__c IN:NonCustomerRequestSet OR Reason_Code__c = null)');  
                    }
                    
                    else if(ValidateMCN && ValidateReasonCode){
                        return Database.getQueryLocator('Select Id,AccountCoordinatorUserId__c,AccountCordinatorEmail__c,CreatedById,ReadShareWithUser__c,Region__c,Customer_Name__c,Customer_No__c,Customer_Industry__c,EditShareWithUserSpFound__c,Include_In_Process__c,AccountManagerEmail__c,EditShareWithUser__c,Customer_Delivery_Partner_Email__c,Neither_SP_nor_AM_found__c,IsSalespersonFound__c,Is_Account_Manager__c, Max_Promise_Date__c, Rdd__c, Reason_Code__c, CADD_Owner__c FROM Deming__c WHERE EditShareWithUser__c =:UserId  and Include_In_Process__c =false and  (Customer_No__c  IN:MCNSet  OR Region__c IN:ReasonCodeSet AND (Reason_Code__c IN:CustomerRequestSet OR Reason_Code__c IN:NonCustomerRequestSet OR Reason_Code__c=null)');  
                    }
                    
                    else if(ValidateIndustry && ValidateReasonCode){
                        return Database.getQueryLocator('Select Id,AccountCoordinatorUserId__c,AccountCordinatorEmail__c,CreatedById,ReadShareWithUser__c,Region__c,Customer_Name__c,Customer_No__c,Customer_Industry__c,EditShareWithUserSpFound__c,Include_In_Process__c,AccountManagerEmail__c,EditShareWithUser__c,Customer_Delivery_Partner_Email__c,Neither_SP_nor_AM_found__c,IsSalespersonFound__c,Is_Account_Manager__c, Max_Promise_Date__c, Rdd__c, Reason_Code__c, CADD_Owner__c FROM Deming__c WHERE EditShareWithUser__c =:UserId and Include_In_Process__c =false and  (Region__c IN:ReasonCodeSet OR Customer_Industry__c IN:IndustrySet) AND (Reason_Code__c IN:CustomerRequestSet OR Reason_Code__c IN:NonCustomerRequestSet OR Reason_Code__c=null)');  
                    }
        
                    else if(ValidateMCN){
                        return Database.getQueryLocator('Select Id,AccountCoordinatorUserId__c,AccountCordinatorEmail__c,CreatedById,ReadShareWithUser__c,Region__c,Customer_Name__c,Customer_No__c,Customer_Industry__c,EditShareWithUserSpFound__c,Include_In_Process__c,AccountManagerEmail__c,EditShareWithUser__c,Customer_Delivery_Partner_Email__c,Neither_SP_nor_AM_found__c,IsSalespersonFound__c,Is_Account_Manager__c, Max_Promise_Date__c, Rdd__c, Reason_Code__c, CADD_Owner__c FROM Deming__c WHERE EditShareWithUser__c =:UserId  and Include_In_Process__c =false and  Customer_No__c  IN:MCNSet AND (Reason_Code__c IN:CustomerRequestSet OR Reason_Code__c IN:NonCustomerRequestSet OR Reason_Code__c=null)');  
                    }
                    
                    else if(ValidateIndustry){
                        return Database.getQueryLocator('Select Id,AccountCoordinatorUserId__c,AccountCordinatorEmail__c,CreatedById,ReadShareWithUser__c,Region__c,Customer_Name__c,Customer_No__c,Customer_Industry__c,EditShareWithUserSpFound__c,Include_In_Process__c,AccountManagerEmail__c,EditShareWithUser__c,Customer_Delivery_Partner_Email__c,Neither_SP_nor_AM_found__c,IsSalespersonFound__c,Is_Account_Manager__c, Max_Promise_Date__c, Rdd__c, Reason_Code__c, CADD_Owner__c FROM Deming__c WHERE EditShareWithUser__c =:UserId and Include_In_Process__c =false and  Customer_Industry__c IN:IndustrySet AND (Reason_Code__c IN:CustomerRequestSet OR Reason_Code__c IN:NonCustomerRequestSet OR Reason_Code__c=null)');  
                    }
                    
                    else if(ValidateReasonCode){
                        return Database.getQueryLocator('Select Id,AccountCoordinatorUserId__c,AccountCordinatorEmail__c,CreatedById,ReadShareWithUser__c,Region__c,Customer_Name__c,Customer_No__c,Customer_Industry__c,EditShareWithUserSpFound__c,Include_In_Process__c,AccountManagerEmail__c,EditShareWithUser__c,Customer_Delivery_Partner_Email__c,Neither_SP_nor_AM_found__c,IsSalespersonFound__c,Is_Account_Manager__c, Max_Scheduled_Arrival_Date__c,Max_Promise_Date__c, Rdd__c, Reason_Code__c, CADD_Owner__c FROM Deming__c WHERE EditShareWithUser__c =:UserId and Include_In_Process__c =false and Region__c IN:ReasonCodeSet AND (Reason_Code__c IN:CustomerRequestSet OR Reason_Code__c IN:NonCustomerRequestSet OR Reason_Code__c=null)');  
                    }
                    
                    else{
                        return Database.getQueryLocator('Select Id,AccountCoordinatorUserId__c,AccountCordinatorEmail__c,CreatedById,ReadShareWithUser__c,Region__c,Customer_Name__c,Customer_No__c,Customer_Industry__c,EditShareWithUserSpFound__c,Include_In_Process__c,AccountManagerEmail__c,EditShareWithUser__c,Customer_Delivery_Partner_Email__c,Neither_SP_nor_AM_found__c,IsSalespersonFound__c,Is_Account_Manager__c, Max_Scheduled_Arrival_Date__c,Max_Promise_Date__c, Rdd__c, Reason_Code__c, CADD_Owner__c FROM Deming__c WHERE EditShareWithUser__c =:UserId and  Include_In_Process__c =false AND (Reason_Code__c IN:CustomerRequestSet OR Reason_Code__c IN:NonCustomerRequestSet OR Reason_Code__c=null)');  
                    }    
    }

    global void execute(Database.BatchableContext BC, List<Deming__c> scope){
                
                list<Deming__c> DemingListToUpdate= new List<Deming__c>();
                //Set<Deming__Share> DemingShareRecordShare= new Set<Deming__Share>(); 
                for(Deming__c  DemObj : scope){
					//Max_Promise_Date__c
					//RDD__c
			    Deming__c ObjectDeming= new Deming__c();
                ObjectDeming.id=DemObj.id;
                ObjectDeming.Include_In_Process__c=true; 
                DemingListToUpdate.add(ObjectDeming); 
					
				    if(DemObj.Max_Promise_Date__c < DemObj.RDD__c){
                     //if(DemObj.Reason_Code__c == 'Customer Request' || DemObj.Reason_Code__c == null || DemObj.Reason_Code__c == 'Credit Holds' ||  DemObj.Reason_Code__c =='Initial Date'  ||  DemObj.Reason_Code__c =='Operational Holds' ||  DemObj.Reason_Code__c =='Plant Capacity' || DemObj.Reason_Code__c =='Supply'){
					   if(CustomerRequestSet.contains(DemObj.Reason_Code__c) || NonCustomerRequestSet.contains(DemObj.Reason_Code__c) || DemObj.Reason_Code__c == null){
					   if(DemObj.IsSalespersonFound__c){
								if((String.isNotBlank(DemObj.CADD_Owner__c)) && (!toAddressPdLessRdd.contains(DemObj.CADD_Owner__c.toLowerCase()))){
									toAddressPdLessRdd.add(DemObj.CADD_Owner__c.toLowerCase());
									
								} 
								
								if((String.isNotBlank(DemObj.EditShareWithUserSpFound__c)) && (DemObj.EditShareWithUser__c != DemObj.EditShareWithUserSpFound__c) && (!ccAddressPdLessRdd.contains(DemObj.Customer_Delivery_Partner_Email__c.toLowerCase()))){
									ccAddressPdLessRdd.add(DemObj.Customer_Delivery_Partner_Email__c.toLowerCase());
								}
								
								if((String.isNotBlank(DemObj.ReadShareWithUser__c)) && (DemObj.EditShareWithUser__c != DemObj.ReadShareWithUser__c) && (!ccAddressPdLessRdd.contains(DemObj.AccountManagerEmail__c.toLowerCase()))){
									ccAddressPdLessRdd.add(DemObj.AccountManagerEmail__c.toLowerCase());
								}

								if((String.isNotBlank(DemObj.AccountCoordinatorUserId__c)) && (DemObj.EditShareWithUser__c != DemObj.AccountCoordinatorUserId__c) && (!ccAddressPdLessRdd.contains(DemObj.AccountCordinatorEmail__c.toLowerCase()))){
									ccAddressPdLessRdd.add(DemObj.AccountCordinatorEmail__c.toLowerCase());
								}
								
								if(String.isNotBlank(DemObj.Customer_Name__c) &&  (!customerNamePdLessRdd.contains(DemObj.Customer_Name__c)) && (customerNamePdLessRdd.size()<=500)){
									customerNamePdLessRdd.add(DemObj.Customer_Name__c);
								}
								
							}
                        
							else{
								
								if((String.isNotBlank(DemObj.CADD_Owner__c)) && (!toAddressPdLessRdd.contains(DemObj.CADD_Owner__c.toLowerCase()))){
									toAddressPdLessRdd.add(DemObj.CADD_Owner__c.toLowerCase());
									
								} 
								 
								if((String.IsNotBlank(DemObj.EditShareWithUserSpFound__c)) && (DemObj.EditShareWithUserSpFound__c != DemObj.EditShareWithUser__c) && (!ccAddressPdLessRdd.contains(DemObj.Customer_Delivery_Partner_Email__c.toLowerCase()))){
									ccAddressPdLessRdd.add(DemObj.Customer_Delivery_Partner_Email__c.toLowerCase());
								}
								
								if((String.IsNotBlank(DemObj.AccountCoordinatorUserId__c)) && (DemObj.AccountCoordinatorUserId__c != DemObj.EditShareWithUser__c) && (!ccAddressPdLessRdd.contains(DemObj.AccountCordinatorEmail__c.toLowerCase()))){
									ccAddressPdLessRdd.add(DemObj.AccountCordinatorEmail__c.toLowerCase());
								}
								
								if(String.isNotBlank(DemObj.Customer_Name__c) &&  (!customerNamePdLessRdd.contains(DemObj.Customer_Name__c)) && (customerNamePdLessRdd.size()<= 500)){
									customerNamePdLessRdd.add(DemObj.Customer_Name__c);  
								}
								
						   }
                    	}
			        }   
				    else if(DemObj.Max_Promise_Date__c >= DemObj.RDD__c){
						
						//if(DemObj.Reason_Code__c=='Customer Request'){
                        if(CustomerRequestSet.contains(DemObj.Reason_Code__c)){ 
							if(DemObj.IsSalespersonFound__c){
								if((String.isNotBlank(DemObj.CADD_Owner__c)) && (!toAddressCustomerRequested.contains(DemObj.CADD_Owner__c.toLowerCase()))){
									toAddressCustomerRequested.add(DemObj.CADD_Owner__c.toLowerCase());
									
								} 
								
								if((String.isNotBlank(DemObj.EditShareWithUserSpFound__c)) && (DemObj.EditShareWithUser__c != DemObj.EditShareWithUserSpFound__c) && (!ccAddressCustomerRequested.contains(DemObj.Customer_Delivery_Partner_Email__c.toLowerCase()))){
									ccAddressCustomerRequested.add(DemObj.Customer_Delivery_Partner_Email__c.toLowerCase());
								}
								
								if((String.isNotBlank(DemObj.ReadShareWithUser__c)) && (DemObj.EditShareWithUser__c != DemObj.ReadShareWithUser__c) && (!ccAddressCustomerRequested.contains(DemObj.AccountManagerEmail__c.toLowerCase()))){
									ccAddressCustomerRequested.add(DemObj.AccountManagerEmail__c.toLowerCase());
								}
								
								if((String.isNotBlank(DemObj.AccountCoordinatorUserId__c)) && (DemObj.EditShareWithUser__c != DemObj.AccountCoordinatorUserId__c) && (!ccAddressCustomerRequested.contains(DemObj.AccountCordinatorEmail__c.toLowerCase()))){
									ccAddressCustomerRequested.add(DemObj.AccountCordinatorEmail__c.toLowerCase());
								}
								
								if(String.isNotBlank(DemObj.Customer_Name__c) &&  (!customerNameCustomerRequested.contains(DemObj.Customer_Name__c))  && (customerNameCustomerRequested.size() <= 500)){
									customerNameCustomerRequested.add(DemObj.Customer_Name__c);
								}
								
							}
                        
							else{
								
								if((String.isNotBlank(DemObj.CADD_Owner__c)) && (!toAddressCustomerRequested.contains(DemObj.CADD_Owner__c.toLowerCase()))){
									toAddressCustomerRequested.add(DemObj.CADD_Owner__c.toLowerCase());
									
								} 
								 
								if((String.IsNotBlank(DemObj.EditShareWithUserSpFound__c)) && (DemObj.EditShareWithUserSpFound__c != DemObj.EditShareWithUser__c) && (!ccAddressCustomerRequested.contains(DemObj.Customer_Delivery_Partner_Email__c.toLowerCase()))){
									ccAddressCustomerRequested.add(DemObj.Customer_Delivery_Partner_Email__c.toLowerCase());
								}
								
								if((String.IsNotBlank(DemObj.AccountCoordinatorUserId__c)) && (DemObj.AccountCoordinatorUserId__c != DemObj.EditShareWithUser__c) && (!ccAddressCustomerRequested.contains(DemObj.AccountCordinatorEmail__c.toLowerCase()))){
									ccAddressCustomerRequested.add(DemObj.AccountCordinatorEmail__c.toLowerCase());
								}
								
								if(String.isNotBlank(DemObj.Customer_Name__c) &&  (!customerNameCustomerRequested.contains(DemObj.Customer_Name__c)) && (customerNameCustomerRequested.size() <= 500)){
									customerNameCustomerRequested.add(DemObj.Customer_Name__c);
								}
								
						   }   
                        
                         
                    }
                    
                    //else if(DemObj.Reason_Code__c == null || DemObj.Reason_Code__c == 'Credit Holds' ||  DemObj.Reason_Code__c =='Initial Date'  ||  DemObj.Reason_Code__c =='Operational Holds' ||  DemObj.Reason_Code__c =='Plant Capacity' || DemObj.Reason_Code__c =='Supply'){
                    else if(DemObj.Reason_Code__c == null || NonCustomerRequestSet.contains(DemObj.Reason_Code__c)){    
                           if(DemObj.IsSalespersonFound__c){
                            
								if((String.isNotBlank(DemObj.CADD_Owner__c)) && (!toAddressNonCustomerRequested.contains(DemObj.CADD_Owner__c.toLowerCase()))){
									toAddressNonCustomerRequested.add(DemObj.CADD_Owner__c.toLowerCase());
									
								} 
								
								if(String.isNotBlank(DemObj.EditShareWithUserSpFound__c) &&  ( DemObj.EditShareWithUser__c != DemObj.EditShareWithUserSpFound__c && !ccAddressNonCustomerRequested.contains(DemObj.Customer_Delivery_Partner_Email__c.toLowerCase()))){
									ccAddressNonCustomerRequested.add(DemObj.Customer_Delivery_Partner_Email__c.toLowerCase());
								}
								
								if((String.isNotBlank(DemObj.ReadShareWithUser__c)) && (DemObj.EditShareWithUser__c != DemObj.ReadShareWithUser__c) && (!ccAddressNonCustomerRequested.contains(DemObj.AccountManagerEmail__c.toLowerCase()))){
									ccAddressNonCustomerRequested.add(DemObj.AccountManagerEmail__c.toLowerCase()); 
								}
								
								
								if((String.isNotBlank(DemObj.AccountCoordinatorUserId__c)) && (DemObj.EditShareWithUser__c != DemObj.AccountCoordinatorUserId__c) && (!ccAddressNonCustomerRequested.contains(DemObj.AccountCordinatorEmail__c.toLowerCase()))){
									ccAddressNonCustomerRequested.add(DemObj.AccountCordinatorEmail__c.toLowerCase()); 
								}
								
								if(String.isNotBlank(DemObj.Customer_Name__c) &&  (!customerNameNonCustomerRequested.contains(DemObj.Customer_Name__c)) && (customerNameNonCustomerRequested.size()<=500)){
									customerNameNonCustomerRequested.add(DemObj.Customer_Name__c);
								}
                            
                            }
                        
                        else{
                             
								if(String.isNotBlank(DemObj.CADD_Owner__c) && (!toAddressNonCustomerRequested.contains(DemObj.CADD_Owner__c.toLowerCase()))){
									toAddressNonCustomerRequested.add(DemObj.CADD_Owner__c.toLowerCase());  
								}  
								 
								if((String.isNotBlank(DemObj.EditShareWithUserSpFound__c)) && (DemObj.EditShareWithUserSpFound__c != DemObj.EditShareWithUser__c) && (!ccAddressNonCustomerRequested.contains(DemObj.Customer_Delivery_Partner_Email__c.toLowerCase()))){
									ccAddressNonCustomerRequested.add(DemObj.Customer_Delivery_Partner_Email__c.toLowerCase());
								}
								
								if((String.isNotBlank(DemObj.AccountCoordinatorUserId__c)) && (DemObj.AccountCoordinatorUserId__c != DemObj.EditShareWithUser__c) && (!ccAddressNonCustomerRequested.contains(DemObj.AccountCordinatorEmail__c.toLowerCase()))){
									ccAddressNonCustomerRequested.add(DemObj.AccountCordinatorEmail__c.toLowerCase());
								}
								
								if((String.isNotBlank(DemObj.Customer_Name__c)) &&  (!customerNameNonCustomerRequested.contains(DemObj.Customer_Name__c)) && (customerNameNonCustomerRequested.size() <= 500)){
									customerNameNonCustomerRequested.add(DemObj.Customer_Name__c);
								}
                            
                        }
                        
                    }
			    } 
                    
                /*if( String.isNotBlank(DemObj.EditShareWithUser__c)){
                    DemingShareRecordShare.add(DemingEmailServiceClass.CreateShareRecord(DemObj.EditShareWithUser__c, 'Edit', DemObj.Id));
                   
                }
                if(String.isNotBlank(DemObj.ReadShareWithUser__c) &&  DemObj.CreatedById != DemObj.EditShareWithUser__c  && DemObj.EditShareWithUser__c != DemObj.ReadShareWithUser__c){
                    DemingShareRecordShare.add(DemingEmailServiceClass.CreateShareRecord(DemObj.ReadShareWithUser__c, 'Edit', DemObj.Id));
                    
                }
                
                if(String.isNotBlank(DemObj.EditShareWithUserSpFound__c)  &&  DemObj.CreatedById != DemObj.EditShareWithUser__c && DemObj.EditShareWithUser__c != DemObj.EditShareWithUserSpFound__c){
                    DemingShareRecordShare.add(DemingEmailServiceClass.CreateShareRecord(DemObj.EditShareWithUserSpFound__c, 'Edit', DemObj.Id));
                    
                }    
                 
			    if(String.isNotBlank(DemObj.AccountCoordinatorUserId__c)  &&  DemObj.CreatedById != DemObj.AccountCoordinatorUserId__c && DemObj.EditShareWithUser__c != DemObj.AccountCoordinatorUserId__c){
                    DemingShareRecordShare.add(DemingEmailServiceClass.CreateShareRecord(DemObj.AccountCoordinatorUserId__c, 'Edit', DemObj.Id)); 
                } */
				 
             }   
            
           if(DemingListToUpdate.size()>0){ 
                  update DemingListToUpdate;
           }
             
           /*if(DemingShareRecordShare.size()>0){
               try{
                   List<Deming__Share> TempList = new List<Deming__Share>();
                   TempList.addAll(DemingShareRecordShare);
                   Insert  TempList; 
               }
               catch(Exception e){
                   System.debug('Error While share Record of deming'+e);
               }
                
            }*/
   
    }

    global void finish(Database.BatchableContext BC){
        
			String TemplateId= EmialTemplateCadd__c.getValues('TemplateId').CADDEmailTemplateId__c;
            String PDLTemplateId=EmailTemplatePrepondedPD__c.getValues('TemplateId').Template_ID__c;
            if(toAddressCustomerRequested.size()>0){
                    String toString = '';
                    for(String s:toAddressCustomerRequested) {
                       toString += (toString==''?'':',')+s;
                    }
                    Deming_Log__c testObj= new Deming_Log__c();
                    testObj.TO_Email_ID__c=toString;
                    testObj.User__c=UserId;
                    testObj.Reason_Code__c='Customer Request';
                    
                   String ccString='';
                   if(ccAddressCustomerRequested.size() >0 ){
                       for(String s:ccAddressCustomerRequested) {
                          ccString += (ccString==''?'':',')+s;
                       }
                       testObj.ccAddress__c=ccString;
                   }
                    String CustomerName='';
                    if(customerNameCustomerRequested.size()>0){
                        
                        for(String s : customerNameCustomerRequested){
                        CustomerName += (CustomerName==''?'':',')+s;
                        }
                        testObj.Customer_Names__c=CustomerName; 
                        testObj.Customer_Names__c =JSON.serialize(customerNameCustomerRequested);
                       
                    }
                   if(testObj != null){
                    insert testObj;
                   }  
            } 
            
            
            if(toAddressNonCustomerRequested.size()>0){
                String toString = '';
                for(String s:toAddressNonCustomerRequested) { 
                       toString += (toString==''?'':',')+s;
                }
					Deming_Log__c testObj= new Deming_Log__c();
					testObj.TO_Email_ID__c=toString;
					testObj.User__c=UserId;
					testObj.Reason_Code__c='Non Customer Requested';
					
				if(ccAddressNonCustomerRequested != null && ccAddressNonCustomerRequested.Size()>0){
					String ccString='';
					for(String s:ccAddressNonCustomerRequested) {
                       ccString += (ccString==''?'':',')+s;
                    }
					testObj.ccAddress__c=ccString;
				}
                if(customerNameNonCustomerRequested.size()>0){
                    String CustomerName='';
                    for(String s : customerNameNonCustomerRequested){ 
                        CustomerName += (CustomerName==''?'':',')+s;
                    }
                    testObj.Customer_Names__c=CustomerName;
                    testObj.Customer_Names__c=JSON.serialize(customerNameNonCustomerRequested);
                    
                }
               
                    if(testObj != null){
                        insert testObj;
                    }
                
               }
			   
			   
			   
			   if(toAddressPdLessRdd.size()>0){
                String toString = '';
                for(String s:toAddressPdLessRdd) { 
                       toString += (toString==''?'':',')+s;
                }
                Deming_Log__c testObj= new Deming_Log__c();
                testObj.TO_Email_ID__c=toString;
                testObj.User__c=UserId;
                testObj.Reason_Code__c='Pd Less Then Rdd';
				
                
				if(ccAddressPdLessRdd != null && ccAddressPdLessRdd.size()>0){
					String ccString='';
					for(String s:ccAddressPdLessRdd) {
                       ccString += (ccString==''?'':',')+s;
                    }
                    testObj.ccAddress__c=ccString;
				}
                
                
                if(customerNamePdLessRdd.size()>0){
                    String CustomerName='';
                    for(String s : customerNamePdLessRdd){
                        CustomerName += (CustomerName==''?'':',')+s; 
                    }
                    testObj.Customer_Names__c=CustomerName;
                    testObj.Customer_Names__c=JSON.serialize(customerNamePdLessRdd);
                    
                    
                } 

                if(testObj != null){
                    insert testObj;
                }
                
             }
        
         
        if(IdSetOfUser.size()>0){ 
            Database.executeBatch(new DemingNotificationAndSharing(IdSetOfUser,ValidateMCN,ValidateIndustry,ValidateReasonCode,MCNSet,IndustrySet,ReasonCodeSet,CustomerRequestSet,NonCustomerRequestSet));       
        }   
    }  
}