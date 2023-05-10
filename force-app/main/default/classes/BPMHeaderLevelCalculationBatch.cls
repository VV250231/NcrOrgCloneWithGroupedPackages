/*
##################################################################################################
# Project Name..........: BPM Automation
# File............................: BPMLinkLinestoHeaderBatch.cls                                                        
# Created by................: Varsha Pal                                                                   
# Created Date...........: 01/16/2020 (MM/DD/YYYY)                                                                             
# Last Modified by......:  Varsha Pal
# Last Modified Date..: 04/06/2021 (MM/DD/YYYY)
# Description...............: This class is used to link all BPM Annuity Lines(Child) to BPM Annuity(parent) as all the data
is full load daily from iPass(Delete and inserting new BPM Annuity Lines) and creating new BPM Annuity if there is no BPM Annuity
associated with the new full contract nbr coming from lines(EDW) and storing all the fields which are same for all lines associated to BPM Annuity(Parent)
#last change............for the story EBA_SF-1225 on 04/06/2021 (MM/DD/YYYY)
#Test class.............BPM_Alert_Aging_HistoryTest
##################################################################################################
*/
public class BPMHeaderLevelCalculationBatch implements Database.Batchable<sObject>,Database.Stateful{
    public Integer successCounter = 0;
    public Integer failureCounter = 0; 
    public List<String> errorslist = new List<String>();
    public integer totalSizeRecords=0;
    public DateTime StartTime;
    public DateTime EndTime;
    public BPMHeaderLevelCalculationBatch(DateTime StartTime){
        this.StartTime = StartTime;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator('Select id,Cust_Nbr_CH__c from BPM_Annuity__c');
   }

    public void execute(Database.BatchableContext BC, List<BPM_Annuity__c> scope){
        Map<String,String> CANameMap = new Map<String,String>();
        Map<String,String> CAQLMap = new Map<String,String>();//EBA_SF-1225
        Map<Id,BPM_Annuity__c> bpmMap = new Map<Id,BPM_Annuity__c>();
        Map<Id,String> masterBpmMap = new Map<Id,String>();
        for(BPM_Annuity__c bpm : scope){
            if(!String.isBlank(bpm.Cust_Nbr_CH__c)){
                masterBpmMap.put(bpm.id,bpm.Cust_Nbr_CH__c);
            }
        }
        for(ASM_Role_Hierarchy__c role : [Select Master__c,User_name__c,QuickLook_ID__c from ASM_Role_Hierarchy__c where Master__c in:masterBpmMap.values() and Role_Name__c='Customer Advocate']){
            if(CANameMap.get(role.Master__c)!=null){
                CANameMap.put(role.Master__c,CANameMap.get(role.Master__c)+', '+role.User_Name__c);
            }
            else{
                CANameMap.put(role.Master__c,role.User_Name__c);            
            }
            //EBA_SF-1225
            if(CAQLMap.get(role.Master__c)!=null){
                CAQLMap.put(role.Master__c,CAQLMap.get(role.Master__c)+', '+role.QuickLook_ID__c);
            }else{
                CAQLMap.put(role.Master__c,role.QuickLook_ID__c);
            }
        }
        
        for(AggregateResult res : [SELECT BPM_Annuity_Header__c,MAX(Last_Update__c) maxlastdate,MAX(Hold_Reason_Description__c) holdres FROM BPM_Annuity_Line__c where BPM_Annuity_Header__c in:scope GROUP BY BPM_Annuity_Header__c ]){
            Id bpmId = (Id)res.get('BPM_Annuity_Header__c');
			if(bpmMap.get(bpmId)==null){
                BPM_Annuity__c bpm = new BPM_Annuity__c();
                bpm.Id = bpmId;
                bpm.MaxLastUpdate__c = (Date)res.get('maxlastdate');
                if((String)res.get('holdres')==null){
                	bpm.Hold_Reason_Type__c = 'blank';    
                }else{
                	bpm.Hold_Reason_Type__c = (String)res.get('holdres');
                }
                bpm.ETB_Invoice_Date__c = null;
                bpm.MIN_ETB_Date__c = null;
                bpm.MinInterfaceDate__c = null;
                bpm.MaxInterfaceDate__c = null;
                bpm.MaxExpected_Interface_Date__c = null;
                bpm.MAX_ETB_Date__c = null;
                bpm.MinBillFromDate__c = null;
                bpm.MaxBillFromDate__c = null;
                bpm.MinBillToDate__c = null;
                bpm.MaxBillToDate__c = null;
                bpm.HW_Other_Unbilled_Amount__c = null;
                bpm.Unbilled_Amt__c = null;
                bpm.SW_Unbilled_Amount__c = null;
                bpmMap.put(bpm.id,bpm);
            }
        }
        // Update Min Max based on equipment line
        for(AggregateResult res : [SELECT BPM_Annuity_Header__c, MIN(ETB_Date__c) minetb,MAX(ETB_Date__c) maxetb,Min(Expected_Alert_Trigger_Date__c) minetd,Min(Period_Start_Date__c) MinBillFromDate,Max(Period_Start_Date__c) MaxBillFromDate,Min(Period_End_Date__c) minBillToDate,Max(Period_End_Date__c) maxBillToDate FROM BPM_Annuity_Line__c where BPM_Annuity_Header__c in:scope and Expected_Alert_Trigger_Date__c<=Today and IsEquipmentLine__c=true GROUP BY BPM_Annuity_Header__c ]){
            Id bpmId = (Id)res.get('BPM_Annuity_Header__c');
            if(bpmMap.get(bpmId)!=null){
                bpmMap.get(bpmId).ETB_Invoice_Date__c = (Date)res.get('minetb');
                bpmMap.get(bpmId).MIN_ETB_Date__c = (Date)res.get('minetb');
                bpmMap.get(bpmId).MinInterfaceDate__c = (Date)res.get('minetb');
                bpmMap.get(bpmId).MaxInterfaceDate__c = (Date)res.get('maxetb');
                bpmMap.get(bpmId).MaxExpected_Interface_Date__c = (Date)res.get('maxetb');
                bpmMap.get(bpmId).MAX_ETB_Date__c = (Date)res.get('maxetb');
                bpmMap.get(bpmId).MinBillFromDate__c = (Date)res.get('MinBillFromDate');
                bpmMap.get(bpmId).MaxBillFromDate__c = (Date)res.get('MaxBillFromDate');
                bpmMap.get(bpmId).MinBillToDate__c = (Date)res.get('minBillToDate');
                bpmMap.get(bpmId).MaxBillToDate__c = (Date)res.get('maxBillToDate');
            }
        }

        // update and overide Min,Max based on not equipment line.
        for(AggregateResult res : [SELECT BPM_Annuity_Header__c, MIN(ETB_Date__c) minetb,MAX(ETB_Date__c) maxetb,Min(Expected_Alert_Trigger_Date__c) minetd,Min(Period_Start_Date__c) MinBillFromDate,Max(Period_Start_Date__c) MaxBillFromDate,Min(Period_End_Date__c) minBillToDate,Max(Period_End_Date__c) maxBillToDate FROM BPM_Annuity_Line__c where BPM_Annuity_Header__c in:scope and Expected_Alert_Trigger_Date__c<=Today and IsEquipmentLine__c!=true GROUP BY BPM_Annuity_Header__c ]){
            Id bpmId = (Id)res.get('BPM_Annuity_Header__c');
            if(bpmMap.get(bpmId)!=null){
                bpmMap.get(bpmId).ETB_Invoice_Date__c = (Date)res.get('minetb');
                bpmMap.get(bpmId).MIN_ETB_Date__c = (Date)res.get('minetb');
                bpmMap.get(bpmId).MinInterfaceDate__c = (Date)res.get('minetb');
                bpmMap.get(bpmId).MaxInterfaceDate__c = (Date)res.get('maxetb');
                bpmMap.get(bpmId).MaxExpected_Interface_Date__c = (Date)res.get('maxetb');
                bpmMap.get(bpmId).MAX_ETB_Date__c = (Date)res.get('maxetb');
                bpmMap.get(bpmId).MinBillFromDate__c = (Date)res.get('MinBillFromDate');
                bpmMap.get(bpmId).MaxBillFromDate__c = (Date)res.get('MaxBillFromDate');
                bpmMap.get(bpmId).MinBillToDate__c = (Date)res.get('minBillToDate');
                bpmMap.get(bpmId).MaxBillToDate__c = (Date)res.get('maxBillToDate');
            }
        }
        
        for(AggregateResult res : [SELECT BPM_Annuity_Header__c, Sum(Unbilled_Amt_Usd__c) totalHWUnbilledAmt,Sum(Billed_Amt_Usd__c) totalHWBilledAmt FROM BPM_Annuity_Line__c where BPM_Annuity_Header__c in:scope and Expected_Alert_Trigger_Date__c<=Today and Offering_Account_Type_Code__c Not In ('MH','SS') GROUP BY BPM_Annuity_Header__c ]){
            Id bpmId = (Id)res.get('BPM_Annuity_Header__c');
            if(bpmMap.get(bpmId)!=null){
                //bpmMap.get(bpmId).HW_Other_Billed_Amount__c = (Decimal)res.get('totalHWBilledAmt');
                bpmMap.get(bpmId).HW_Other_Unbilled_Amount__c = (Decimal)res.get('totalHWUnbilledAmt');
               // bpmMap.get(bpmId).Billed_Amt_US_CH_BPM__c = (Decimal)res.get('totalHWBilledAmt');
                bpmMap.get(bpmId).Unbilled_Amt__c = (Decimal)res.get('totalHWUnbilledAmt');
            }
       }
       for(AggregateResult res : [SELECT BPM_Annuity_Header__c, Sum(Unbilled_Amt_Usd__c) totalSWUnbilledAmt,Sum(Billed_Amt_Usd__c) totalSWBilledAmt FROM BPM_Annuity_Line__c where BPM_Annuity_Header__c in:scope and Expected_Alert_Trigger_Date__c<=Today and Offering_Account_Type_Code__c In ('MH','SS') GROUP BY BPM_Annuity_Header__c ]){
            Id bpmId = (Id)res.get('BPM_Annuity_Header__c');
            if(bpmMap.get(bpmId)!=null){
                bpmMap.get(bpmId).SW_Billed_Amount__c = (Decimal)res.get('totalSWBilledAmt');
                bpmMap.get(bpmId).SW_Unbilled_Amount__c = (Decimal)res.get('totalSWUnbilledAmt');
                /*if(bpmMap.get(bpmId).Billed_Amt_US_CH_BPM__c==null){
                    bpmMap.get(bpmId).Billed_Amt_US_CH_BPM__c=0;
                }*/
                if(bpmMap.get(bpmId).Unbilled_Amt__c==null){
                    bpmMap.get(bpmId).Unbilled_Amt__c=0;
                }
                //bpmMap.get(bpmId).Billed_Amt_US_CH_BPM__c += (Decimal)res.get('totalSWBilledAmt');
                if(res.get('totalSWUnbilledAmt')!=null){
                	bpmMap.get(bpmId).Unbilled_Amt__c += (Decimal)res.get('totalSWUnbilledAmt');
                }
            }
       }
       for(BPM_Annuity__c bpm1 : scope){
            Id bpmId = bpm1.id;
			if(bpmMap.get(bpmId)==null){
                BPM_Annuity__c bpm = new BPM_Annuity__c();
                bpm.Id = bpmId;
                bpm.Status_CH__c = null;
                bpm.Hold_Reason_Type__c = null;
                bpm.ETB_Invoice_Date__c = null;
                bpm.MIN_ETB_Date__c = null;
                bpm.MinInterfaceDate__c = null;
                bpm.MaxInterfaceDate__c = null;
                bpm.MaxExpected_Interface_Date__c = null;
                bpm.MAX_ETB_Date__c = null;
                bpm.MinBillFromDate__c = null;
                bpm.MaxBillFromDate__c = null;
                bpm.MinBillToDate__c = null;
                bpm.MaxBillToDate__c = null;
                bpm.HW_Other_Unbilled_Amount__c = null;
                bpm.Unbilled_Amt__c = null;
                bpm.SW_Unbilled_Amount__c = null;
                bpm.Contract_On_Hold__c = false;
                /*bpm.New_Comments__c = null;
                bpm.Short_Desc_CH__c = null;
                bpm.Comments__c = null;
                bpm.Comments_Short__c = null;*/
                //bpm.CA_Name__c = CANameMap.get(masterBpmMap.get(bpmId));
                bpmMap.put(bpm.id,bpm);
            }else{
                bpmMap.get(bpmId).CA_Name__c = CANameMap.get(masterBpmMap.get(bpmId));
                //EBA_SF-1225
                bpmMap.get(bpmId).CA_QlookId__c =  CAQLMap.get(masterBpmMap.get(bpmId));
            }
        }
        System.debug('bpmMap'+bpmMap.size());
        totalSizeRecords += scope.size();
        System.debug('totalSizeRecords'+totalSizeRecords);
        List<Database.SaveResult> updateResults = database.update(bpmMap.values(),false);
        for(Integer i=0;i<updateResults.size();i++){
            if (updateResults.get(i).isSuccess()){
                updateResults.get(i).getId();
                successCounter++;
                System.debug('successCounter'+successCounter);
                
            }else if (!updateResults.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = updateResults.get(i).getErrors().get(0);
                failureCounter++;
                String failedDML = error.getMessage();
                errorslist.add(bpmMap.values().get(i).Id+': Failed because of'+failedDML);
                system.debug('Failed ID'+bpmMap.values().get(i).Id);
            }
            
        }
        
    }

   public void finish(Database.BatchableContext BC){
       EndTime = System.now();
       string emailBodytoReplaced = 'Total number of records ==> '+totalSizeRecords
        +'<Br/>Number of records succeeded ==> '+successCounter
        +'<Br/>Number of records failed ==> '+failureCounter
       +'<Br/>Start Time ==> '+StartTime
       +'<Br/>End Time ==> '+EndTime;
        System.debug('Total Count'+totalSizeRecords);
            System.debug( 'Failure Count :'+failureCounter);
            System.debug( 'Sucess Count :'+successCounter);
       
            string emailHeader='';
           
            if(failureCounter==0)
            {
                 emailHeader='Batch Job Succeeded';
            } 
            else 
            {
                 emailHeader='Batch Job Failed'; 
                emailBodytoReplaced += '<Br/><Br/> Fix the record and re-run the batch by using below command <Br/> <p style="color:blue"><Br/>database.executebatch(new BPMHeaderLevelCalculationBatch(), 200);</p>';
                emailBodytoReplaced += errorslist[0]+'. Please see apex job for more details';
             }
           
           string emailSubject = emailHeader+' For BPM Calculation Batch';
           string emailSubHeader = emailHeader+' For BPM Calculation Batch';
            EmailTemplate template = [Select id, Body, HtmlValue, Subject from EmailTemplate where name = 'NCR Standard'];
            String EmailBody=template.HtmlValue;

           CommonUtility.sendEmail(emailSubject,emailHeader,emailSubHeader,emailBodytoReplaced,EmailBody,BPM_Configuration__c.getValues('Batch Job Email Receiver List').values__c.split(','));
   }
}