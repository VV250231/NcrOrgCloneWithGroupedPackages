({
	init: function(cmp, event, helper) { 
        //alert('DisputeFollowUpAnsValue'+cmp.get("v.DisputeFollowUpAnsValue"));
        cmp.set("v.toogleSpinner",true);
        var DisputeReason=[];
        var ReasonQuestionMap = new Map();
        var DisputeCommentMapForReason = new Map();
        var selectReasonAndIdMap = new Map();
     
        
            //alert('>>>>>>'+cmp.get("v.UserSelctedReason"));
               var action = cmp.get("c.getDisputeReason");
               action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //alert(response.getReturnValue());
                    for(var i=0;i<response.getReturnValue().length; i++){
                        DisputeReason.push({'label':response.getReturnValue()[i].Dispute_Reason__c,'value':response.getReturnValue()[i].Id});
                        ReasonQuestionMap.set(response.getReturnValue()[i].Id, response.getReturnValue()[i].Followup_Question__c);
                        DisputeCommentMapForReason.set(response.getReturnValue()[i].Id,response.getReturnValue()[i].Detailed_Question__c);
                        selectReasonAndIdMap.set(response.getReturnValue()[i].Id,response.getReturnValue()[i].ReasonCode__c);
                    }
                    cmp.set("v.options",DisputeReason); 
                    cmp.set("v.Question",ReasonQuestionMap);
                    cmp.set("v.DisputeCommentMapForReason",DisputeCommentMapForReason);
                    cmp.set("v.toogleSpinner",false);
                    cmp.set("v.selectReasonAndIdMap",selectReasonAndIdMap);
                    
                             // Figure out which buttons to display
                  var availableActions = cmp.get('v.availableActions');
                  for (var i = 0; i < availableActions.length; i++) {
                     if (availableActions[i] == "PAUSE") {
                        cmp.set("v.canPause", true);
                     } else if (availableActions[i] == "BACK") {
                        cmp.set("v.canBack", true);
                     } else if (availableActions[i] == "NEXT") {
                        cmp.set("v.canNext", true);
                     } else if (availableActions[i] == "FINISH") {
                        cmp.set("v.canFinish", true);
                     }
                  }
                }
                else {
                    console.log("Failed with state: " + state);
                }
            });
            $A.enqueueAction(action);   
	},
    
      handleChange: function (cmp, event) {
        var selectedOptionValue = event.getParam("value");
        cmp.set("v.UserSelctedReason",selectedOptionValue);
        var myMap = cmp.get("v.Question"); 
        cmp.set("v.ReasonQuestion",myMap.get(selectedOptionValue));
        cmp.set("v.toogleSpinner",true);
        var question =  myMap.get(selectedOptionValue); 
          cmp.set("v.DisputeFollowUpAnsValue",'');  
          if(typeof question !== "undefined"){
            var Reasonoptions =[];
            var ReasonoptionsMap = new Map();  
            var FollowUpQusAndAnsIdMap =  new Map();
            cmp.set("v.RenderDisputeCommenValue",false);
            var action = cmp.get("c.getFollowUpAnsAndDetailQuestion");
        	action.setParams({ DisputeReasonId : selectedOptionValue});

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //alert(response.getReturnValue());
                      
                      for(var i=0;i<response.getReturnValue().length; i++){
                        //alert(response.getReturnValue()[i].Dispute_Reason_and_Question__r.Label);
                    	Reasonoptions.push({'label':response.getReturnValue()[i].Followup_Answer__c,'value':response.getReturnValue()[i].Id});
                     	ReasonoptionsMap.set(response.getReturnValue()[i].Id, response.getReturnValue()[i].Dispute_Detail_Question__c);
                        FollowUpQusAndAnsIdMap.set(response.getReturnValue()[i].Id,response.getReturnValue()[i].Followup_Answer__c);
                        //selectReasonAndIdMap.set(response.getReturnValue()[i].Id,);
               		 }
                    
                    cmp.set("v.Reasonoptions",Reasonoptions);
                    cmp.set("v.DisputeCommentMap",ReasonoptionsMap);
                    cmp.set("v.RenderReasonQuestion",true);
                    cmp.set("v.toogleSpinner",false);
                    cmp.set("v.FollowUpQusAndAnsIdMap",FollowUpQusAndAnsIdMap);
                    var selectReasonAndIdMap= cmp.get("v.selectReasonAndIdMap");
                    //alert(selectReasonAndIdMap.get(selectedOptionValue));
                    cmp.set("v.DisputeReasonValue",selectReasonAndIdMap.get(selectedOptionValue));
                    cmp.set("v.IsFollowUpQuestionIsRequire",true);
                }
                else {
                    console.log("Failed with state: " + state);
                    return null;
                }
            });
            $A.enqueueAction(action);
          }
          
          else{
              var myMap = cmp.get("v.DisputeCommentMapForReason");
              cmp.set("v.RenderReasonQuestion",false);
              cmp.set("v.DisputeComment",myMap.get(selectedOptionValue));
        	  cmp.set("v.RenderDisputeCommenValue",true);
              cmp.set("v.toogleSpinner",false);
              var selectReasonAndIdMap= cmp.get("v.selectReasonAndIdMap");
              //alert(selectReasonAndIdMap.get(selectedOptionValue));
              cmp.set("v.DisputeReasonValue",selectReasonAndIdMap.get(selectedOptionValue));
              cmp.set("v.IsFollowUpQuestionIsRequire",false);
          }
    },
    FollowUpAnsChange:function(cmp, event,helper){
        var selectedOptionValue = event.getParam("value");
        //alert(FollowUpQusAndAnsIdMap.get(selectedOptionValue));
        //alert(selectedOptionValue);
        var FollowUpQusAndAnsIdMap = cmp.get("v.FollowUpQusAndAnsIdMap");
        cmp.set('v.DisputeFollowUpAns',FollowUpQusAndAnsIdMap.get(selectedOptionValue));
        //cmp.set("v.DisputeFollowUpAnsValue",FollowUpQusAndAnsIdMap.get(selectedOptionValue));
        cmp.set("v.DisputeFollowUpAnsValue",selectedOptionValue);
        var myMap=cmp.get("v.DisputeCommentMap");
        cmp.set("v.DisputeComment",myMap.get(selectedOptionValue));
        cmp.set("v.RenderDisputeCommenValue",true);
    },
    validateNext:function(cmp, event,helper){
       
        if(!cmp.get("v.UserSelctedReason")){
            //alert('Please Select Dispute Reason.');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Complete Require Fields', 
                message:'Please Select Dispute Reason.',
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
			
        }
        
        else if( (!cmp.get("v.DisputeFollowUpAnsValue"))  && (cmp.get("v.IsFollowUpQuestionIsRequire") === true)){
            //alert('Please select a follow up Question');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Complete Require Fields', 
                message:'Please select a follow up Question.',
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
        
        else if(!cmp.get("v.DisputeCommenValue")){
            //alert('Please Enter your Comment');  
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Complete Require Fields', 
                message:'Enter your Comment.',
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
       else{
			helper.onButtonPressed(cmp, event);                
       }
        
    },
    validatePrevious:function(cmp, event,helper){
       // alert(cmp.get("v.UserSelctedReason"));
        //sessionStorage.setItem('UserSelctedReason',cmp.get("v.UserSelctedReason"));
        //alert(cmp.get("v.UserSelctedReason"));
        helper.onButtonPressed(cmp, event);
    }
    
})