({
	loadOpportunity : function(component) {
		var action = component.get("c.getOpportunity"); 
        var OpportunityIsoArray=[];
        var OpportunityConvertedArray=[];
        action.setParams({  
        OpportunityId : component.get("v.OpportunityId")     
    });
           
        action.setCallback(this, function(a) {
        if (a.getState() === "SUCCESS") {  
       
            OpportunityIsoArray[0]={SolnOppAmount:a.getReturnValue()[0].Soln_Opp_Amount__c,OrderTotal :a.getReturnValue()[0].Orders_Total__c,RecurringRevenueTotal :a.getReturnValue()[0].Recurring_Revenue_Total__c,AnnuityOppAmount:a.getReturnValue()[0].Annuity_Contract__c,SoftwareProducts:a.getReturnValue()[0].Software_Products__c,HardwareProducts:a.getReturnValue()[0].Hardware_Products__c,CloudProducts:a.getReturnValue()[0].Cloud_Products__c,PSProducts:a.getReturnValue()[0].PS_Products__c,ServicesProducts:a.getReturnValue()[0].Services_Products__c,CurrencyIsoCode:a.getReturnValue()[0].CurrencyIsoCode,Solution_Quote_Amount_QUBY__c:a.getReturnValue()[0].Solution_Quote_Amount_QUBY__c,Annuity_Quote_Amount_QUBY__c:a.getReturnValue()[0].Annuity_Quote_Amount_QUBY__c,Software_Products_QUBY__c:a.getReturnValue()[0].Software_Products_QUBY__c,Hardware_Products_QUBY__c:a.getReturnValue()[0].Hardware_Products_QUBY__c,Services_Products_QUBY__c:a.getReturnValue()[0].Services_Products_QUBY__c,Cloud_Products_QUBY__c:a.getReturnValue()[0].Cloud_Products_QUBY__c,PS_Products_QUBY__c:a.getReturnValue()[0].PS_Products_QUBY__c,
                                    HW_R__c:a.getReturnValue()[0].HW_R__c, HW_NR__c:a.getReturnValue()[0].HW_NR__c, SW_R__c:a.getReturnValue()[0].SW_R__c, SW_NR__c:a.getReturnValue()[0].SW_NR__c, PS_R__c:a.getReturnValue()[0].PS_R__c, PS_NR__c:a.getReturnValue()[0].PS_NR__c, Cloud_R__c:a.getReturnValue()[0].Cloud_R__c,TS_NR__c:a.getReturnValue()[0].TS_NR__c, TS_R__c:a.getReturnValue()[0].TS_R__c, HWM_R__c:a.getReturnValue()[0].HWM_R__c, HWM_NR__c:a.getReturnValue()[0].HWM_NR__c, SWM_NR__c:a.getReturnValue()[0].SWM_NR__c, SWM_R__c:a.getReturnValue()[0].SWM_R__c, Managed_Services_NR__c:a.getReturnValue()[0].Managed_Services_NR__c, Managed_Services_R__c:a.getReturnValue()[0].Managed_Services_R__c}; 
			
             OpportunityConvertedArray[0]={SolnOppAmount:a.getReturnValue()[1].Soln_Opp_Amount__c,OrderTotal :a.getReturnValue()[0].Orders_Total__c,RecurringRevenueTotal :a.getReturnValue()[0].Recurring_Revenue_Total__c,AnnuityOppAmount:a.getReturnValue()[1].Annuity_Contract__c,SoftwareProducts:a.getReturnValue()[1].Software_Products__c,HardwareProducts:a.getReturnValue()[1].Hardware_Products__c,CloudProducts:a.getReturnValue()[1].Cloud_Products__c,PSProducts:a.getReturnValue()[1].PS_Products__c,ServicesProducts:a.getReturnValue()[1].Services_Products__c,Solution_Quote_Amount_QUBY__c:a.getReturnValue()[1].Solution_Quote_Amount_QUBY__c,Annuity_Quote_Amount_QUBY__c:a.getReturnValue()[1].Annuity_Quote_Amount_QUBY__c,Software_Products_QUBY__c:a.getReturnValue()[1].Software_Products_QUBY__c,Hardware_Products_QUBY__c:a.getReturnValue()[1].Hardware_Products_QUBY__c,Services_Products_QUBY__c:a.getReturnValue()[1].Services_Products_QUBY__c,Cloud_Products_QUBY__c:a.getReturnValue()[1].Cloud_Products_QUBY__c,PS_Products_QUBY__c:a.getReturnValue()[1].PS_Products_QUBY__c, 
			 HW_R__c:a.getReturnValue()[1].HW_R__c, HW_NR__c:a.getReturnValue()[1].HW_NR__c, SW_R__c:a.getReturnValue()[1].SW_R__c, SW_NR__c:a.getReturnValue()[1].SW_NR__c, PS_R__c:a.getReturnValue()[1].PS_R__c, PS_NR__c:a.getReturnValue()[1].PS_NR__c, Cloud_R__c:a.getReturnValue()[1].Cloud_R__c, TS_NR__c:a.getReturnValue()[1].TS_NR__c, TS_R__c:a.getReturnValue()[1].TS_R__c, HWM_R__c:a.getReturnValue()[1].HWM_R__c, HWM_NR__c:a.getReturnValue()[1].HWM_NR__c, SWM_NR__c:a.getReturnValue()[1].SWM_NR__c, SWM_R__c:a.getReturnValue()[1].SWM_R__c, Managed_Services_NR__c:a.getReturnValue()[1].Managed_Services_NR__c, Managed_Services_R__c:a.getReturnValue()[1].Managed_Services_R__c};  
            component.set("v.opportunity",OpportunityIsoArray[0]);
             component.set("v.opportunity2",OpportunityConvertedArray[0]);
             console.log(a.getReturnValue()[0]);
        	 
        } else if (a.getState() === "ERROR") { 
         
            console.log(a.getError());
            $A.log("Errors", a.getError());
        }     
    });
    $A.enqueueAction(action);
	},
    UserDefaultCurrency:function(component, event, helper){
        var action = component.get("c.getUserLocalCurrenctCode"); 
           
        action.setCallback(this, function(a) {
        if (a.getState() === "SUCCESS") { 
              
              component.set("v.UserCurrenDefaultCurrency",a.getReturnValue());
        } else if (a.getState() === "ERROR") { 
            $A.log("Errors", a.getError());
        }     
    });
    $A.enqueueAction(action);
    },
    
    getFieldsDetail: function(component, event, helper){
    	var action = component.get("c.getFieldsDetailMap");   
        action.setCallback(this, function(a) {
        if (a.getState() === "SUCCESS") { 
        	component.set("v.fieldInfoMap",a.getReturnValue());      
              //component.set("v.UserCurrenDefaultCurrency",a.getReturnValue());
        } else if (a.getState() === "ERROR") { 
            $A.log("Errors", a.getError());
        }     
    });
    $A.enqueueAction(action);    
        
    }
})