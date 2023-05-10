({
    doInit : function(component, event, helper) {
        component.set('v.closeTheLoopRecordTypeId',$A.get("$Label.c.closetheloop"));
        component.set('v.cxRecordTypeId',$A.get("$Label.c.cxCaseRecordId"));
        
        
        var action=component.get('c.getCaseRecord');
        action.setParams({
            recordId:component.get("v.recordId"),
        });
         action.setCallback(this, function(response) {
            var state = response.getState();
             var result=response.getReturnValue();
            if (state === "SUCCESS") {
                if(result.IsClosed){
                   component.set('v.show',false); 
                }
				component.set('v.recordtypeid',result.RecordTypeId);
                component.set('v.parentCaseeid',result.ParentId);
            }

            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action); 
    },
    AssigntoFX : function(component, event, helper) {     
    var closeTheloopRecordTypeId= $A.get("$Label.c.closetheloopchild");
    //alert(component.get("v.recordId"));
       var rId = component.get("v.recordId");
       var action = component.get('c.getCaseRecord'); 
        console.log('this is action ');
        action.setParams({
            recordId : rId
        }); 
        console.log('this is new ');
        action.setCallback(this, function(response) {
            console.log('this is call');
           var state = response.getState();
            //alert(state);
            if(state == 'SUCCESS'){
              var result = response.getReturnValue();
              //alert('result '+result);  
              var createOppEvent = $A.get("e.force:createRecord");       
       		 createOppEvent.setParams({
             "entityApiName": "Case",
             "recordTypeId": closeTheloopRecordTypeId,             
             "defaultFieldValues": {
                'ParentId' : rId,
                 //'Region__c' : result.Region__c,
                 'Functional_Area__c' : result.Functional_Area__c,
                 'Type' : result.Type,
                // 'Account_LOB__c' : result.Account_LOB__c,
                 'Reason_for_Recommend_Rating__c' : result.Reason_for_Recommend_Rating__c,
                 'AccountId' : result.AccountId,
                 'First_Contact_Date__c' : result.First_Contact_Date__c,
                 'Area__c': result.Area__c,
                 'ContactId' : result.ContactId,
                 'Type' : result.Type,
                 'Case_Source__c' : result.Case_Source__c
             }         
       });
       createOppEvent.fire(); 
            } 
        });
        $A.enqueueAction(action);
    },
     CXChildCreation : function(component, event, helper) { 
      var closeTheloopRecordTypeId= $A.get("$Label.c.closetheloopchild");
    //alert(component.get("v.recordId"));
       var rId = component.get("v.recordId");
       var action = component.get('c.getCaseRecord'); 
        console.log('this is action ');
        action.setParams({
            recordId : rId
        }); 
        console.log('this is new ');
        action.setCallback(this, function(response) {
            console.log('this is call');
           var state = response.getState();
            //alert(state);
            if(state == 'SUCCESS'){
              var result = response.getReturnValue();
              //alert('result '+result);  
              var createOppEvent = $A.get("e.force:createRecord");       
       		 createOppEvent.setParams({
             "entityApiName": "Case",
             "recordTypeId":closeTheloopRecordTypeId,             
             "defaultFieldValues": {
                'ParentId' : rId,
                 //'Region__c' : result.Region__c,
                 'Functional_Area__c' : result.Functional_Area__c,
                 'Type' : result.Type,
                // 'Account_LOB__c' : result.Account_LOB__c,
                 'Reason_for_Recommend_Rating__c' : result.Reason_for_Recommend_Rating__c,
                 'AccountId' : result.AccountId,
                 'First_Contact_Date__c' : result.First_Contact_Date__c,
                 'ContactId' : result.ContactId,
                 //'Type' : result.Type,
                 'Case_Source__c' : result.Case_Source__c
             }         
       });
       createOppEvent.fire(); 
            } 
        });
        $A.enqueueAction(action);
    }
    
})