({   handleSubsProd : function(cmp, successCallback, helper, isSubscPrd, isServPrd, isCnctHWMProd, isQtyTypProd) {	
        	
         var getSettingsAction = cmp.get("c.getSubsOnlyProd");	
   		 getSettingsAction.setCallback(this, function(response) {	
            	
       	if (cmp.isValid() && response !== null && response.getState() == 'SUCCESS') {	
            cmp.set("v.subsOnlyProdNames" ,response.getReturnValue().ProductNames);	
            cmp.set("v.subsOnlyRevenueTypes" ,response.getReturnValue().RevenueTypes);	
            console.log('----'+response.getReturnValue().ProductNames+'-----'+response.getReturnValue().RevenueTypes);	
            if(isSubscPrd && !response.getReturnValue().ProductNames.includes(cmp.get("v.ProductName")) && !response.getReturnValue().RevenueTypes.includes(cmp.get("v.ServiceOfferCatogery"))){	
                  console.log("........");	
                   cmp.set("v.confirmSubscription" , true);	
                   cmp.set("v.confirmService" , isServPrd);
                   cmp.set("v.confirmHWMMntc" , isCnctHWMProd);	
                   cmp.set("v.confirmQtyTypModal" , isQtyTypProd);
                //this.handleSubsciption(cmp, event, false ) ; 	
            } else if (isServPrd || isCnctHWMProd || isQtyTypProd) {
           		cmp.set("v.confirmService" , isServPrd);	    
                cmp.set("v.confirmHWMMntc" , isCnctHWMProd);
                cmp.set("v.confirmQtyTypModal" , isQtyTypProd);
            }
            else {              
              this.handleSubsciption(cmp, event, false) ;  	
            }
            console.log("Subscription Setting loaded.");	
        	} else {	
            console.log("Failed to load Subscription Setting.");	
        	}	
    	});	
   		$A.enqueueAction(getSettingsAction);	
	},
	 SingleScheduleProduct: function(cmp,event) {
        var	TriggerScreenName=cmp.get("v.TriggerScreenName"); 
        var myEvent = $A.get("e.c:AddRemoveProduct");
            myEvent.setParams({"ProductId": cmp.get("v.ProductId"),
                           "ProductName":cmp.get("v.ProductName"),
                           "Index":cmp.get("v.Index")
                          });
		if(TriggerScreenName == 'ADD PRODUCT'){
                    var appEvent1 = $A.get("e.c:ceEventDelete");
                    appEvent1.setParams({
                        "ProductIds" : cmp.get("v.ProductId")});
                    appEvent1.fire();  
                    cmp.set('v.IsSchedule',!cmp.get('v.IsSchedule'));
                    myEvent.fire(); 
                    cmp.set("v.ConfirmForUnschedule",false);
                }                
               
        else{
                    
                    var appEvent1 = $A.get("e.c:RemoveScheduleEvent");
                    appEvent1.setParams({
                        "ProductIds" : cmp.get("v.ProductId")});
                    appEvent1.fire();
                    cmp.set('v.IsSchedule',!cmp.get('v.IsSchedule'));
                    myEvent.fire();
                    cmp.set("v.ConfirmForUnschedule",false);
                }
	} ,
    
    handleSubsciption : function(cmp, event, finalVal) {        
        
         var TriggerScreenName=cmp.get("v.TriggerScreenName");
        
        var myEvent = $A.get("e.c:AddRemoveProduct");
            myEvent.setParams({"ProductId": cmp.get("v.ProductId"),
                           "ProductName":cmp.get("v.ProductName"),
                           "Index":cmp.get("v.Index")
                          }); 
        if(TriggerScreenName == 'ADD PRODUCT'){
            		var selLineItemType = cmp.get("v.selectLineItemType");
                    var selHWMMntcType = cmp.get("v.selectHWMMntcType");
                    var tempItemType = [selLineItemType]; 
            	    var tempHWMMntcType = [selHWMMntcType]; 
            		var tempBol = [finalVal] ;
            		var qtyTyp = cmp.get("v.qtyTyp");
            		var tempQtyTyp = [qtyTyp];
                    var appEvent = $A.get("e.c:ceEvent");
                    appEvent.setParams({
                        "ProductIds" : cmp.get("v.ProductId") ,
                        "HasSubsciption" : tempBol,
                        "ServLineItemTypeArray" : tempItemType,
                        "HWMMntcTypeArray" : tempHWMMntcType,
                        "qtyTypeArray":tempQtyTyp
                    });  
                    appEvent.fire(); 
                }
                
                
                else{
                    var selLineItemType = cmp.get("v.selectLineItemType");
                    var selHWMMntcType = cmp.get("v.selectHWMMntcType");
                    var tempItemType = [selLineItemType];
                    var tempHWMMntcType = [selHWMMntcType];
                    var tempBoolean = [finalVal] ;
                    var qtyTyp = cmp.get("v.qtyTyp");
            		var tempQtyTyp = [qtyTyp];
                    //tempBoolean = t
                    //alert(TriggerScreenName);
                    var appEvent1 = $A.get("e.c:InsertScheduleEvent");
                    appEvent1.setParams({
                        "ProductIds" : cmp.get("v.ProductId") ,
                        "hasSubscription" : tempBoolean,
                        "ServLineItemTypeArray" : tempItemType,
                        "HWMMntcTypeArray" : tempHWMMntcType,
                        "qtyTypeArray":tempQtyTyp
                    });
                    appEvent1.fire();  
                }
               
                /* commented for OLI type change 
                 // Products Added to Items to schedule Successfully
                 var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                        FloatMsgEvent.setParams({
                            "Msg" : "Products Added to schedule Successfully.",
                            "Category" : "Success",
                            "isShow" : "True"
                }); 
                FloatMsgEvent.fire();*/
        
                cmp.set('v.IsSchedule',!cmp.get('v.IsSchedule'));
                myEvent.fire();    
    }
})