/*
##################################################################################################
# Project Name..........: BPM Automation
# File............................: BPMLinkLinestoHeaderBatch.cls                                                        
# Created by................: Varsha Pal                                                                   
# Created Date...........: 01/16/2020 (MM/DD/YYYY)                                                                             
# Last Modified by......:  Yogesh Singh
# Last Modified Date..: 04/07/2021 (MM/DD/YYYY)
# Description...............: This class is used to link all BPM Annuity Lines(Child) to BPM Annuity(parent) as all the data
is full load daily from iPass(Delete and inserting new BPM Annuity Lines) and creating new BPM Annuity if there is no BPM Annuity
associated with the new full contract nbr coming from lines(EDW) and storing all the fields which are same for all lines associated to BPM Annuity(Parent)
#last change............for the story EBA_SF-1225 on 04/06/2021 (MM/DD/YYYY) by Varsha Pal
#last change............for the story EBA_SF-1227 on 04/07/2021 (MM/DD/YYYY) by Yogesh Singh
#Test class.............BPM_Alert_Aging_HistoryTest
##################################################################################################
*/
public class BPMLinkLinestoHeaderBatch implements Database.Batchable<sObject>,Database.Stateful, schedulable{
    public DateTime StartTime= System.now();
    public string msg = ' ';
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select id,full_contract_nbr__c,Offering_Account_Type_Code__c,Approved_Date_Time__c,Header_Billing_Period_Name__c,Contract_Nbr__c,Contract_Nbr_Modifier__c,Cust_Po_Nbr_Rqrd_Flag__c,Cust_Po_Nbr__c,Signed_Date__c,Status_Code__c,Region_Desc__c,Country_Code__c,Bill_To_Pnt_Cust_Ind_Name__c,Invoice_Rule_Name__c,Short_Desc__c,Customer_Name__c,Customer_Nbr__c,Contract_Start_Date__c,Contract_End_Date__c,Contracted_Expected_Renewal_Date__c,Interface_Offset_Day_Nbr__c,Subtotal_Amt_Usd__c,Contract_Subtype_Code__c,Contract_Duration__c,BPM_Annuity_Header__c,Billed_Amt_Usd__c,Comment__c from BPM_Annuity_Line__c');
    }
    
    public void execute(Database.BatchableContext BC, List<BPM_Annuity_Line__c> scope){
        try{
            Map<String,String> fullContractBPMMap = new Map<String,String>();
            Map<String,String> customerNameMap = new Map<String,String>();
            Map<String,ID> bpmParentIdMap = new Map<String,ID>();
            for(BPM_Annuity_Line__c bpmLine : scope){
                if(bpmLine.Customer_Nbr__c!=null){
                    customerNameMap.put(bpmLine.Customer_Nbr__c,null);
                }
                if(bpmLine.Full_Contract_Nbr__c!=null){
                    fullContractBPMMap.put(bpmLine.Full_Contract_Nbr__c,null);
                }
            }
            for(BPM_Annuity__c bpm : [Select Id,Full_Contract_Nbr_CH__c from BPM_Annuity__c where Full_Contract_Nbr_CH__c in:fullContractBPMMap.keyset()]){
                bpmParentIdMap.put(bpm.Full_Contract_Nbr_CH__c,bpm.Id);
            }
            for(Account acc:[Select name,Master_Customer_Number__c from Account where Master_Customer_Number__c in:customerNameMap.keyset()]){
                customerNameMap.put(acc.Master_Customer_Number__c,acc.name);
            }
            Map<Id,BPM_Annuity__c> bpmParentMap = new Map<Id,BPM_Annuity__c>();
            List<BPM_Annuity__c> bpmParentList = new List<BPM_Annuity__c>();
            for(BPM_Annuity_Line__c bpmLine : Scope){
                if(bpmLine.Customer_Nbr__c!=null){
                    if(customerNameMap.get(bpmLine.Customer_Nbr__c)!=null){
                        bpmLine.Customer_Name__c = customerNameMap.get(bpmLine.Customer_Nbr__c);
                    }
                }  
                BPM_Annuity__c bpm = new BPM_Annuity__c();
                if(bpmParentIdMap.get(bpmLine.Full_Contract_Nbr__c)!=null){
                    bpm.id = bpmParentIdMap.get(bpmLine.Full_Contract_Nbr__c);
                }
                bpm.Acctg_Rule_CH__c = bpmLine.Offering_Account_Type_Code__c;
                bpm.Approved_Date_CH_BPM__c = Date.valueof(bpmLine.Approved_Date_Time__c);
                bpm.Billing_Period_Name_CH__c = bpmLine.Header_Billing_Period_Name__c;
                bpm.Contract_Nbr_CH_BPM__c = bpmLine.Contract_Nbr__c;
                bpm.Contract_Modifier_CH_BPM__c = bpmLine.Contract_Nbr_Modifier__c;
                bpm.Full_Contract_Nbr_CH__c = bpmLine.Full_Contract_Nbr__c;
                bpm.Name = bpmLine.Full_Contract_Nbr__c;
                //bpm.Hold_Reason_Type__c = bpmLine.Hold_Reason_Description__c;
                bpm.Cust_PO_Nbr_Req_Flag_CH__c = bpmLine.Cust_Po_Nbr_Rqrd_Flag__c;
                bpm.Purchase_Order_Nbr_CH__c= bpmLine.Cust_Po_Nbr__c;
                bpm.Signed_Date_CH__c = bpmLine.Signed_Date__c;
                bpm.Status_CH__c = bpmLine.Status_Code__c;
                bpm.Region__c = bpmLine.Region_Desc__c;
                bpm.Country_Code_C_BPM__c = bpmLine.Country_Code__c;
                bpm.Industry_Group_Name_CH__c = bpmLine.Bill_To_Pnt_Cust_Ind_Name__c;
                bpm.Invoice_Rule_Name_CH__c = bpmLine.Invoice_Rule_Name__c;
                bpm.Short_Desc_CH__c = bpmLine.Short_Desc__c;
                bpm.Cust_Name_CH_BPM__c = bpmLine.Customer_Name__c;
                bpm.Cust_Nbr_CH__c = bpmLine.Customer_Nbr__c;
                bpm.Start_Date_CH__c = bpmLine.Contract_Start_Date__c;
                bpm.End_Date_CH__c = bpmLine.Contract_End_Date__c;
                bpm.Contracted_Expected_Renewal_Date__c = bpmLine.Contracted_Expected_Renewal_Date__c;
                bpm.Interface_Offset_CH__c = bpmline.Interface_Offset_Day_Nbr__c;
                bpm.Subtotal_Amt_US_CH__c = bpmline.Subtotal_Amt_Usd__c;
                bpm.Contract_Sub_Type_CH_BPM__c = bpmline.Contract_Subtype_Code__c;
                bpm.Contract_Duration_CH_BPM__c = bpmline.Contract_Duration__c;
                bpm.Billed_Amt_US_CH_BPM__c = bpmline.Billed_Amt_Usd__c;
                bpm.New_Comments__c = bpmline.Comment__c?.replaceAll('\U001A','').replaceall('\U001E','');
                //EBA_SF-1225
                bpm.Comments_Short__c = bpm.New_Comments__c?.length()>=255 ? bpm.New_Comments__c.substring(0,255): bpm.New_Comments__c;// to store the short comment upto 255 characters
                //EBA_SF-1227
                bpm.Short_Desc_CH__c = bpmline.Short_Desc__c?.replaceAll('\U001A','').replaceall('\U001E','');// to store the short description coming from BPM Annuity Lines
                bpmLine.BPM_Annuity_Header__r = bpm;
                if(bpm.id!=null){
                    bpmParentMap.put(bpm.id,bpm);
                }else{
                    bpmParentList.add(bpm);
                }
            }
            if(!bpmParentMap.isEmpty()){
                bpmParentList.addall(bpmParentMap.values());
            }
            if(!bpmParentList.isEmpty()){
                List<Database.UpsertResult> uList = Database.upsert(bpmParentList,false);
                for (Database.UpsertResult sr : uList) {
                    if (!sr.isSuccess()) {
                        for(Database.Error e : sr.getErrors()) {
                            if(!e.getMessage().contains('duplicates')){
                                msg = 'BPMLinkLinesToHeaderBatch Job Upsert failed due to '+ e.getMessage();
                            }
                        }
                    }
                }
            }
            List<BPM_Annuity_Line__c> bpmLineList = new List<BPM_Annuity_Line__c>();
            for(BPM_Annuity_Line__c bpmLine : scope){
                bpmLine.BPM_Annuity_Header__c = bpmLine.BPM_Annuity_Header__r.id;
                if(bpmLine.BPM_Annuity_Header__c!=null){
                    bpmParentIdMap.put(bpmLine.Full_Contract_Nbr__c,bpmLine.BPM_Annuity_Header__c);
                }
                if(bpmLine.Full_Contract_Nbr__c!=null){
                    if(bpmParentIdMap.get(bpmLine.Full_Contract_Nbr__c)!=null){
                        BPM_Annuity_Line__c bpm = new BPM_Annuity_Line__c(Id= bpmLine.id);
                        bpm.Customer_Name__c = bpmLine.Customer_Name__c;
                        bpm.BPM_Annuity_Header__c = bpmParentIdMap.get(bpmLine.Full_Contract_Nbr__c);
                        bpmLineList.add(bpm);
                    }
                }        
            }
            update bpmLineList;
        }catch(Exception e){
            System.debug('Ex occured '+e.getMessage()+' at '+e.getLineNumber());
            msg = 'BPMLinkLinesToHeaderBatch Job Failed due to '+ e.getMessage() +' at line '+e.getLineNumber(); 
        }
    }
    
    public void finish(Database.BatchableContext BC){
        if(msg.contains('Failed')){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(BPM_Configuration__c.getValues('CAHierarchyJobReciever').values__c.split(','));
            //Changes done by Yogesh - related to Story EBA_SF-1919
            //mail.setOrgWideEmailAddressId('0D270000000XZHr');
            mail.setOrgWideEmailAddressId(NSCCommonInfoUtil.getIdOf('BPMLinkOrgId')); //End changes by Yogesh
            mail.setSubject('BPM Job Failed');
            mail.setPlainTextBody(msg);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                mail
                    });
        }
        else{
            Database.executeBatch(new BPMHeaderLevelCalculationBatch(StartTime));
        }
        
    }
    public void execute(SchedulableContext SC) {
        database.executebatch(new BPMLinkLinestoHeaderBatch());
    }
}