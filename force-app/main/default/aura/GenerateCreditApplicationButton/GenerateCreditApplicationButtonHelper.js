({
    generateCreditApplicationButton : function(component) {
        var action = component.get("c.validateGenerateCreditApplication");
        action.setParams({"oid":component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var opp = response.getReturnValue()
                //alert(quote.SBQQ__PrimaryContact__c);
                var msg;
                if(opp.CPQ__c==true){
                        this.sendLegalDocument(component,opp);
                        //if(quote.qtc_Bill_To_Site__r.AutoPay_Setup__c !='True'){
                        	//this.createUser(component);
                        }else{
                            component.set("v.isNonCPQ",true);
                            msg='You cannot Generate Credit Application on a Non-CPQ opportunity. Please contact your Salesforce Admin team for support.';
                            component.set("v.msg",msg);    
                        }
                    }
            
        });
        $A.enqueueAction(action);
    },
    
    
        
    sendLegalDocument : function(component,opp) {
        //alert('sendLegalDocument :');
        var baseur =$A.get("$Label.c.CLM_DS_BASE_URL");
        var envId = $A.get("$Label.c.CLM_ENV_ID");
        var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    //"url": 'https://uatna11.springcm.com/atlas/doclauncher/eos/Aloha Essential Order Form?aid=6966&eos[0].Id='+quote.Id+'&eos[0].System=Salesforce&eos[0].Type=SBQQ__Quote__c&eos[0].Name='+quote.Name+' '+quote.CreatedDate+'&eos[0].ScmPath=/SalesForce/Account/'+quote.DocuSign_Folder__c
                    "url": baseur+'Credit Check and Personal Guarantee SF?aid='+envId+'&eos[0].Id='+opp.Id+'&eos[0].System=Salesforce&eos[0].Type=Opportunity&eos[0].Name='+opp.Name+' '+opp.CreatedDate+'&eos[0].ScmPath=/Salesforce/Account/'+opp.Account.Name+' '+opp.Account.Master_Customer_Number__c 
                            //https://uatna11.springcm.com/atlas/doclauncher/eos/Credit Check and Personal Guarantee SF?aid=6966&eos[0].Id={!Opportunity.Id}&eos[0].System=Salesforce&eos[0].Type=Opportunity&eos[0].Name={!Opportunity.Name} {!Opportunity.CreatedDate}&eos[0].ScmPath=/Salesforce/Account/{!Account.Name} {!Account.Master_Customer_Number__c}
                });
                urlEvent.fire();
         var dismissActionPanel = $A.get("e.force:closeQuickAction");
         dismissActionPanel.fire();
    }
    
})