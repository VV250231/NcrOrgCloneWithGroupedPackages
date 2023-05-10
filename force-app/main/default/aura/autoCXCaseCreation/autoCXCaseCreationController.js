({
    caseRecordUpdated : function(component, event, helper) {
         var actionPlanStatus=component.get('v.detractor.Action_Plan_Status__c');
        var caseCloseReason=component.get('v.detractor.Case_Close_Reason__c');
        var caseStatus=component.get('v.detractor.Status');
        var caseOrigin=component.get('v.detractor.Origin');
        var currentCaseRecordTypeId=component.get('v.detractor.RecordTypeId');
        console.log('origin: ',caseOrigin);
        console.log('caseCloseReason: ',caseCloseReason);
        console.log('RecordTypeId: ',currentCaseRecordTypeId);
  		
        if(currentCaseRecordTypeId =='0120g000000N2vRAAS' && event.getParam("changeType") === "CHANGED" && component.get('v.runmodalonce')==true 
           && caseCloseReason=='Fx Action(s) Migrated to Project' && caseStatus=="Closed" && component.get('v.detractor.CX_Case_Number__c')==null)
        {	
            component.set("v.runmodalonce", true);
            component.set("v.show",true);
        }
    } ,
    handleConfirm:function(component,event,helper){  
        var detractorCaseDetails=component.get('v.detractor');
        helper.autoCreateCase(component, detractorCaseDetails);   
    },
    
    closeModal:function(component,event,helper){  
        component.set('v.show', false);   
        component.set("v.runmodalonce", true);
    }
})