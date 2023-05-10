({
	UpsertRecord : function(cmp,event,RecordValue) {
        var SpinnerId = cmp.find("SpinnerId");
        $A.util.removeClass(SpinnerId,'slds-hide');
		var action = cmp.get("c.UpsertRecord"); 
        //alert(cmp.get("v.OppId"));
        action.setParams({ 
            				RecordValue:RecordValue 

                         });

        action.setCallback(this, function(response) { 
            var state = response.getState();
  
            if (state === "SUCCESS") { 
                    //alert(response.getReturnValue());
                    var appEvent = $A.get("e.c:NotifyCommitmentRisk");
                    appEvent.setParams({
                        "Weightage" : 0 });
                    appEvent.fire();
                
               $A.util.addClass(SpinnerId,'slds-hide'); 
            }
            else if (state === "INCOMPLETE") {
               
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
		
        $A.enqueueAction(action);
	}
})