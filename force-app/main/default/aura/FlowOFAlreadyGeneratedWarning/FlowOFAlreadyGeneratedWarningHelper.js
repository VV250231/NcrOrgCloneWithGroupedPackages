({ 
 GetQuoteFromId : function(component) {
        var action = component.get("c.getQuote");
        action.setParams({"quoteId":component.get("v.quoteId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var quote = response.getReturnValue();
                component.set("v.Quote",quote);
                if(quote){
                    this.GetQuotesWithCLMDoc(component,quote);
                }
            }
        });
     $A.enqueueAction(action);
	},
    GetQuotesWithCLMDoc:function(component,quote){
       
        let action = component.get("c.getQuotesWithCLMDoc");
        action.setParams({"quote":quote});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                
                let quoteNamesWithDoc = response.getReturnValue();
                console.log('msg' + JSON.stringify(quoteNamesWithDoc));
                let message =  'There is at least one Order Form already generated for the following ';
                let message1 = 'Click <b>Next</b> if you want to continue!';
                if(Object.keys(quoteNamesWithDoc).length !== 0){
                    if(!quote.qtc_Multi_Site__c || quote.qtc_Multi_Site_Relationship__c == 'Child'){
                        message = message.concat('Quote, with the most recently modified one having a Document Status, ');
                        for (var key in quoteNamesWithDoc) {
                            if(quoteNamesWithDoc[key] == 'Completed'){
								message = 'There is already a signed Order Form for this Quote. If you continue, CLM will generate a new version of the Order Form and will void the existing one.';
							}else{
								message = 'There is at least one unsigned Order Form already generated for this Quote. If you continue, that Form will be Voided.';
							}
                        }	
                    }
                    else{
                        message = message.concat('Quotes, with the most recently modified one having a Document Status: <br/>');
                        for (var key in quoteNamesWithDoc) {
                            message = message.concat(key,'&emsp;&emsp;',quoteNamesWithDoc[key], '<br/>' );
                        }
                    }
                    message = message.concat(message1);
                    component.set('v.showDocWarning',true);
                    component.set('v.warningMessage',message);
                }
            }
        });
        $A.enqueueAction(action);
    } ,
   Showwarningmessage:function(component,invokeFromValue){
            var message = '';
            if(invokeFromValue == 'OAuthorizationCompleted'){ 
                message = 'There is already a signed Order Authorization for this Quote.  Click Generate if you want to continue.';   
            }
            if(invokeFromValue == 'OAuthorizationSentForSignature'){ 
                message = 'There is at least one unsigned Order Authorization already generated for this Quote. Click Generate if you want to continue.';
               
            }
            component.set('v.warningMessage',message);
            component.set('v.showDocWarning',true);
    }
})