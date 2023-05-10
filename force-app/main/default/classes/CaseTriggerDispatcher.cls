/*************************************************************************************************************************************
# Modification History : 

Story No#         Date            DevName             Description
EBA_SF-1895     22nd March 2022   Puneet Bhatia       Added changes to prevent Email-to-Case duplicate case creation
**************************************************************************************************************************************/

public class CaseTriggerDispatcher extends TriggerHandlerBase {
    private static CaseTriggerHandler caseHndlr;
    
    /************************************** CASE AFTER INSERT *************************************
  * Description : Handle MACC,Marketo,CCADD and VOC Functionality
  *************************************************************************************************/
    public override void afterInsert() {
        caseHndlr = (caseHndlr != null) ? caseHndlr : new CaseTriggerHandler(); 
        List<Case> cases = (List<Case>) Trigger.new;
        //caseHndlr.sendDisputeToCCADD(cases);//was written in CaseTrigger before EBA_SF-680
        CasesEscalatedToNotification.casesEscalatedToNotificationInsertCase(cases);//was written in CaseTrigger before EBA_SF-680
        MaccChatHandler.sendEmailNotificationToAgentManager(cases);//was written in CaseTrigger before EBA_SF-680
        //was Written in MarketoCaseTrigger before EBA_SF-680//
        if(ExistingLeadContactHelper.isfirstMarketo==true){
            ExistingLeadContactHelper.leadAndContactWithEmail(cases);
            ExistingLeadContactHelper.isfirstMarketo=false;
        }
        
        caseHndlr.runSFSupportAssignmentRule(cases);
        //was Written in MarketoCaseTrigger before EBA_SF-680//
    }    
  /*************************************************************************************************/
    /************************************** CASE BEFORE INSERT *************************************
  * Description : Handle MACC, CCADD, IPT and VOC Functionality                    
  *************************************************************************************************/
    public override void beforeInsert() { 
      caseHndlr = (caseHndlr != null) ? caseHndlr : new CaseTriggerHandler(); 
        List<Case> cases = (List<Case>) Trigger.new;
        caseHndlr.hndlEmailtoCase(cases); //added changes to prevent Email-to-Case duplicate case creation
        MaccChatHandler.restrictPickListField(cases);//was written in CaseTrigger before EBA_SF-680
        caseHndlr.disputeAnlystFieldPop(cases);//was written in CaseTrigger before EBA_SF-680
        caseHndlr.assignVOCCaseFnctnAreaLOB(cases);//was written in linkCaseWithNPSSurveyResult before EBA_SF-680
        caseHndlr.updateCaseOwnerAndAssign(cases);//was written in updateCaseOwnerAndAssign before EBA_SF-680
        LinkCaseWithNPSSurveyResultHandler.updateCaseOwner(cases);//was Written in linkCaseWithNPSSurveyResult before EBA_SF-680
        LinkCaseWithNPSSurveyResultHandler.updateContactOwnerEmail(cases);//was Written in linkCaseWithNPSSurveyResult  before EBA_SF-680
    }
    
    /************************************** CASE BEFORE UPDATE***********************************
* Description :Handle MACC and CCADD Functionality
*************************************************************************************************/
    
    public override void beforeUpdate() {
       caseHndlr = (caseHndlr != null) ? caseHndlr : new CaseTriggerHandler(); 
       List<Case> cases = (List<Case>) Trigger.new;
       System.debug('>>>>' + cases[0].ownerId);
       Map<Id,Case> oldCaseMap = (Map<Id,Case>) Trigger.oldMap;
       MaccChatHandler.restrictPickListField(cases);//was Written in CaseTrigger before EBA_SF-680
       caseHndlr.disputeAnlystFieldPopUpdt(cases,oldCaseMap);//was Written in CaseTrigger before EBA_SF-680
       LinkCaseWithNPSSurveyResultHandler.updateContactOwnerEmail(cases);//was Written in linkCaseWithNPSSurveyResult before EBA_SF-680
    }
    /************************************** CASE AFTER UPDATE *************************************
  * Description : Handle MACC,VOC,CCADD and IPT Record Type
  ************************************************************************************************* */
    public override void afterUpdate() {
        caseHndlr = (caseHndlr != null) ? caseHndlr : new CaseTriggerHandler(); 
        List<Case> cases = (List<Case>) Trigger.new;
         Map<Id,Case> oldCaseMap = (Map<Id,Case>) Trigger.oldMap;
        caseHndlr.maccSndAlertToAgentMngr(cases,oldCaseMap);//was Written in CaseTrigger before EBA_SF-680
       caseHndlr.sendDisputesCCADD(cases,oldCaseMap);//was Written in CaseTrigger before EBA_SF-680
        CasesEscalatedToNotification.casesEscalatedToNotificationUpdateCase(cases, oldCaseMap);//was Written in CaseTrigger before EBA_SF-680
        CCAD_disputeEmailNotifications.DisputeClosure_Notifications(cases,oldCaseMap);//was Written in CaseTrigger before EBA_SF-680
        caseHndlr.closeEmail(cases,oldCaseMap);//was Written in closeEmail before EBA_SF-680
        caseHndlr.VoCCasesRecordType(cases,oldCaseMap);//was Written in linkCaseWithNPSSurveyResult before EBA_SF-680
        if(DisputeUtil.getDspROR() == 'SF') {
            caseHndlr.Dispute_syncToERPCloud(cases, oldCaseMap, false);
        }
    }
}