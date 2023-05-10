({
    
 fetchAccounts : function(component, event, offSetCount) {
  
        var action = component.get("c.getAccountSites");
        action.setParams({
            accId:component.get("v.recordId"),
            "intOffSet" : offSetCount
        });
        
        action.setCallback(this, function(response) {
              var spinner = component.find("mySpinner");
              $A.util.toggleClass(spinner, "slds-hide");
            var state = response.getState();
            if (state === "SUCCESS") {
                var records = response.getReturnValue();
                console.log('total sites>>');
                console.log(records.length);
                console.log(records);              
                records.forEach(function(record){
                    if(record.Primary_Bill_To__c) {
                    	record.PrmryBillTCheck = 'utility:success';                  
                    } 
                    if(record.Primary_Ship_To__c) {
                    	record.PrmryShipToCheck = 'utility:success';                  
                    } 
                    if(record.Primary_Deliver_To__c) {
                    	record.PrmryDlvryToCheck = 'utility:success';                  
                    } 
                    
                    var siteAddress =  !$A.util.isEmpty(record.BillingAddress.street) ? record.BillingAddress.street : ''
                    					+ ", " +  !$A.util.isEmpty(record.BillingAddress.city) ? record.BillingAddress.city : ''
                                        + ", " +  !$A.util.isEmpty(record.BillingAddress.state) ? record.BillingAddress.state : ''
                                        + " " +   !$A.util.isEmpty(record.BillingAddress.postalCode) ? record.BillingAddress.postalCode : '' 
                                        + ", " +  !$A.util.isEmpty(record.BillingAddress.country) ? record.BillingAddress.country : ''; 
                    
                   
                    
                    
                    record.SiteAddress = siteAddress;   
                    
                    
                    
                });
                               
                component.set("v.accountList", records);
                component.set("v.allAccountList", records);
            }
         event.getSource().set("v.isLoading", false);
            
        });
        
        $A.enqueueAction(action);
        
 }
    
})