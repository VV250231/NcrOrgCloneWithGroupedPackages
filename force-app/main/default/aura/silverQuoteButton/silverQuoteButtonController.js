({
    doInit : function(component, event, helper) {
    component.set("v.currentOpportunityId",component.get("v.recordId"));
        var isSliverQuote=component.get('v.oppRecord.Silver_Opportunity_flag__c');
        var primaryQuote=component.get('v.oppRecord.SBQQ__PrimaryQuote__c');
        var cpqFlag=component.get('v.oppRecord.CPQ__c');
        
        if(primaryQuote && cpqFlag)
        {
            component.set("v.showSilverQuoteButton", false);
        }
    },
    
    mapSFFieldsToSilver : function(component, event, helper) {  
        component.set("v.isSpinner", true);  
        var action = component.get("c.addProduct");
        action.setParams({ oppId : component.get("v.currentOpportunityId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var responeValues=response.getReturnValue();
            if (state === "SUCCESS") {
                 helper.launchSilver(component);
                 window.setTimeout(
                    $A.getCallback(function() {
                        component.set("v.isSpinner", false);
                    }), 5000
                );
                
                if(responeValues==true){   	
                    console.log('Product Added !!');
                }
            }
            
            else{
                var errors = response.getError();
                console.log(errors[0].message);
                window.setTimeout(
                    $A.getCallback(function() {
                        component.set("v.isSpinner", false);
                    }), 5000
                );
            }
        });
        
         $A.enqueueAction(action);
       
    }
 })