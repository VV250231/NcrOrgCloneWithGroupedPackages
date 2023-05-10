({
       
    checkUSMOpportunity : function(cmp,event, helper) {
             // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var recordId = cmp.get("v.recordId");
        var action = cmp.get("c.checkUSMOpportunity");
        action.setParams({ opportunityId : recordId });
         // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                var response = response.getReturnValue();
                console.log("From server: " + response);
                if(response != null){
                    console.log(JSON.stringify(response));
                    cmp.set("v.isUSMOpportunity",response);
                }
               
            }
            else if (state === "INCOMPLETE") {
                // do something
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
    
     checkClosedOpp : function(cmp,event, helper) {
             // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var recordId = cmp.get("v.recordId");
        var action = cmp.get("c.checkClosedOpportunity");
        action.setParams({ opportunityId : recordId });
         // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                var response = response.getReturnValue();
                console.log("From server: " + response);
                if(response != null){
                    console.log(JSON.stringify(response));
                    cmp.set("v.isClosed",response);
                }
               
            }
            else if (state === "INCOMPLETE") {
                // do something
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
    
    checkEngagement : function(cmp,event, helper) {
             // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var recordId = cmp.get("v.recordId");
        var action = cmp.get("c.checkEngagedService");
        action.setParams({ opportunityId : recordId });
         // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                var response = response.getReturnValue();
                console.log("From server: " + response);
                if(response != null){
                    console.log(JSON.stringify(response));
                    if(response != null && response.USM_Opportunity_Number__c != null){
                        cmp.set("v.isEngaged",true);
                        cmp.set("v.usmNumber",response.USM_Opportunity_Number__c);
                        var usmOppUrl = "https://ncrsmaprod.service-now.com/u_opportunity_list.do?sysparm_query=%5EGOTOnumberLIKE" + response.USM_Opportunity_Number__c +"%5EORDERBYnumber&sysparm_offset=&sysparm_list_mode=grid";
                        cmp.set("v.usmOpportunity",usmOppUrl);
                    }
                    
                }
               
            }
            else if (state === "INCOMPLETE") {
                // do something
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

       }
})