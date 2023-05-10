({
	doInitialization : function(cmp, event, helper) {
		cmp.set("v.ToggleSpinner",true);
        var parentId=cmp.get("v.recordId");
        var action = cmp.get("c.getConsolatedData");
        action.setParams({ 
            			  recId : parentId ,
                          NoOfRec: '3' 
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var NoOfRecords ;
            if (state === "SUCCESS") { 
                if(response.getReturnValue()){
                   
                  
                    if(response.getReturnValue().length > 0){
                        cmp.set("v.isCpqOpp",response.getReturnValue()[0].IsCpq);
                        cmp.set("v.OpportunityName",response.getReturnValue()[0].OppName);
                  	    cmp.set("v.prdList",response.getReturnValue());
                        cmp.set("v.renderViewAll",true);
                    } 
                   
                }
                cmp.set("v.ToggleSpinner",false); 
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
	},
    navigateToTable:function(cmp, event, helper){
           
       
        var action = cmp.get("c.isCommunity");
        action.setCallback(this, function(response) {
            var isCommunity = response.getReturnValue(); 
            //component.set("v.isCommunityUser",isCommunity);
            //alert(isCommunity); 
            if(isCommunity){
                event.preventDefault();  
                var navService = cmp.find( "navService" ); 
                    var pageReferenceps = {  
                        type: "comm__namedPage",  
                        attributes: {  
                            pageName: "marketproductablecommunity"  
                        },  
                        state: {  
                            OppId:  cmp.get("v.recordId"),
                            isCpqOpp:cmp.get("v.isCpqOpp"),
                            OpportunityName:cmp.get("v.OpportunityName")
                           
                            
                        }  
                 }; 
                navService.navigate( pageReferenceps );
            }
            else{
                var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:MarketProductTable",
                        componentAttributes: {
                            OppId : cmp.get("v.recordId"),
                            isCpqOpp:cmp.get("v.isCpqOpp"),
                            OpportunityName:cmp.get("v.OpportunityName")
                          
                        }
                    });
                    evt.fire();  
            }
        });
        $A.enqueueAction(action);
    }, 
  
})