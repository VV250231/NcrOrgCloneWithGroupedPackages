({
	launchSilver : function(cmp) {
        var silverOrgUrl = $A.get("$Label.c.SilverOrg_URL");
		var action = cmp.get("c.redirectToSilver");
        action.setParams({ oppId : cmp.get("v.currentOpportunityId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var opp;
            if (state === "SUCCESS") {
                opp = response.getReturnValue();
                //alert(JSON.stringify(opp));
                //opp.Contacts__r.Account.Name
                
                if(opp.Contacts__r===undefined){
                    alert('Please assign a primary contact before proceeding');
                }else if(opp.Account===undefined) {
                    alert('Please assign an account before proceeding');
                }else{
                    var accName;
                    if(opp.Contacts__r.Account===undefined){
                        accName =  opp.Account.Name;
                    }else{
                        accName = opp.Contacts__r.Account.Name;
                    }
                    var url ="ct.AccountName="+encodeURIComponent(accName)+
                            "&ct.CurrencyIsoCode="+opp.Contacts__r.CurrencyIsoCode+
                            "&ct.FirstName="+encodeURIComponent(opp.Contacts__r.FirstName)+
                            "&ct.LastName="+encodeURIComponent(opp.Contacts__r.LastName)+
                            "&ct.Phone="+opp.Contacts__r.Phone+
                            "&ct.Email="+encodeURIComponent(opp.Contacts__r.Email)+
                            "&ct.ISPrimary="+opp.Contacts__r.Partner_Primary_Contact__c+
                            "&ct.Active="+opp.Contacts__r.Active_Contact__c+
                            "&ct.Street="+encodeURIComponent(opp.Contacts__r.MailingStreet)+
                            "&ct.City="+encodeURIComponent(opp.Contacts__r.MailingCity)+
                            "&ct.State="+encodeURIComponent(opp.Contacts__r.MailingState)+
                            "&ct.PostalCode="+opp.Contacts__r.MailingPostalCode+
                            "&ct.Country="+encodeURIComponent(opp.Contacts__r.MailingCountry)+
                            "&opp.Owner="+encodeURIComponent(opp.Owner.Name)+
                            "&opp.OpportunityName="+encodeURIComponent(opp.Name)+
                            "&opp.AccountName="+encodeURIComponent(opp.Account.Name)+
                            "&opp.ExpectedBookDate="+opp.CloseDate+
                            "&opp.Currency="+opp.CurrencyIsoCode+
                            "&opp.PrimaryContact="+encodeURIComponent(opp.Contacts__r.Name)+
                            "&opp.PrimaryContactEmail="+encodeURIComponent(opp.Contacts__r.Email)+
                            "&opp.MCN="+opp.Account.Master_Customer_Number__c+
                            "&opp.BillingCity="+encodeURIComponent(opp.Account.BillingCity)+
                            "&opp.BillingCountry="+encodeURIComponent(opp.Account.BillingCountry)+
                            "&opp.BillingPostalCode="+opp.Account.BillingPostalCode+
                            "&opp.BillingState="+encodeURIComponent(opp.Account.BillingState)+
                            "&opp.BillingStreet="+encodeURIComponent(opp.Account.BillingStreet)+
                            "&opp.BillingLatitude="+opp.Account.BillingLatitude+
                            "&opp.ShippingStreet="+encodeURIComponent(opp.Account.ShippingStreet)+
                            "&opp.ShippingCity="+encodeURIComponent(opp.Account.ShippingCity)+
                            "&opp.ShippingState="+encodeURIComponent(opp.Account.ShippingState)+
                            "&opp.ShippingPostalCode="+opp.Account.ShippingPostalCode+
                            "&opp.ShippingCountry="+encodeURIComponent(opp.Account.ShippingCountry)+
                            "&opp.ShippingLatitude="+opp.Account.ShippingLatitude+
                            "&opp.ShippingLongitude="+opp.Account.ShippingLongitude+
                        	"&opp.Industry="+opp.Account.LOB__c+
                        	"&opp.SubIndustry="+opp.Account.Industry+
                            "&opp.EnterpriseOppID="+opp.Id;
                    console.log(url);
                    window.open(""+silverOrgUrl+"/apex/LandingRequestForSilverQuotePage?"+url, '_blank');
                }
            }
            else{
                var errors = response.getError();
                alert(errors[0].message);
            }
        });
        
         $A.enqueueAction(action);	
	}
})