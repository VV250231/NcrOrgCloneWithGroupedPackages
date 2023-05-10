({
	onButtonPressed: function(cmp, event) {
      // Figure out which action was called
      var actionClicked = event.getSource().getLocalId();
      // Fire that action
      var navigate = cmp.get('v.navigateFlow');
      navigate(actionClicked);
   },
   handleChangehelper: function(cmp,event,selectedOptionValue){
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
   }  
    
})