({
	 getCountryCodeList : function(cmp) {
      var ContryCodeOptions=[];
        var action = cmp.get("c.getCountryNameWithCode");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				//alert(response.getReturnValue());
                for(var i=0;i<response.getReturnValue().length; i++){
                    ContryCodeOptions.push({'label':response.getReturnValue()[i].Label,'value':response.getReturnValue()[i].value});
                    
                }
                cmp.set("v.options",ContryCodeOptions);
                cmp.set("v.CountryCodeOption",JSON.stringify(ContryCodeOptions));
                var availableActions = cmp.get('v.availableActions');
                  cmp.set('v.isValidated',true);   
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
         
        
      


    } ,
    
    validateResponse:function(cmp,inputData){
           
            var action = cmp.get("c.validateUserEnteredInvoices");
        	action.setParams({ userInputData : inputData});

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //alert(response.getReturnValue());
                }
                else {
                    console.log("Failed with state: " + state);
                    return null;
                }
            });
            $A.enqueueAction(action);
        
        
        },
    
       serverSideCall : function( cmp, apexAction, params) {
                var p = new Promise( $A.getCallback( function( resolve , reject ) { 
                var action = cmp.get("c."+apexAction+"");
                action.setParams( params );
                action.setCallback( this , function(callbackResult) {                  
                    if(callbackResult.getState()=='SUCCESS') {
                        //alert(callbackResult.getReturnValue());
                         
                        resolve( callbackResult.getReturnValue());
                    }
                    if(callbackResult.getState()=='ERROR') {
                        //console.log('ERROR', callbackResult.getError());                             
                        reject( callbackResult.getError() ); 
                    }
                });
                $A.enqueueAction( action );
            }));
           
            return p;

	},
   onButtonPressed: function(cmp, event) {
      // Figure out which action was called
      
      var actionClicked = event.getSource().getLocalId();
      // Fire that action
      var navigate = cmp.get('v.navigateFlow');
      navigate(actionClicked);
   }
   
})