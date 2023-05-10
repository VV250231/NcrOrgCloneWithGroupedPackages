({
	handleLikeButtonClick : function (cmp) {
        cmp.set('v.liked', !cmp.get('v.liked'));
    },
    handleAnswerButtonClick: function (cmp) {
        cmp.set('v.answered', !cmp.get('v.answered'));
    }, 
    
    confirmYesSubcription : function(component, event, helper) {
       var confirmSub = component.get("v.confirmSubscription");
       var confirmSrv = component.get("v.confirmService");
       var servType = component.find("servType");
       var confirMntcType = component.get("v.confirmHWMMntc");
       var mntcType = component.find("mntcType");
       var qtyType = component.find("qtyType");
       var confirmQtyTypModal = component.get("v.confirmQtyTypModal");
       if(confirmQtyTypModal) {
	   		var confirmQtyTypModal1= component.find("qtyType").get("v.value");  
       }
        
        
       if ((confirmSrv && !servType.checkValidity()) || (confirMntcType && !mntcType.checkValidity()) || (confirmQtyTypModal && !qtyType.checkValidity()) || confirmQtyTypModal1 =='' ) {
           
      		var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Error!!",
       		 		"message": "This is reqired field, please select any value.",
        			"type":"error"
   			 		});
    				toastEvent.fire();
           
           
       } else {
      	    helper.handleSubsciption(component, event, component.get("v.isSubscriptionLine")) ;
       }
    },
    
    confirmNoSubscription : function(component, event, helper) {
       
        helper.handleSubsciption(component, event, false) ;
    } ,
    
	 AddProductToSchedule:function(cmp, event, helper) {
		var	TriggerScreenName=cmp.get("v.TriggerScreenName");
        cmp.set("v.SeletedProductCount",parseInt(0)); 
		var myEvent = $A.get("e.c:AddRemoveProduct");
		myEvent.setParams({"ProductId": cmp.get("v.ProductId"),
						   "ProductName":cmp.get("v.ProductName"),
						   "Index":cmp.get("v.Index")
						  }); 
		
		
		if(cmp.get("v.IsSchedule")){ 
			/*if(TriggerScreenName == 'ADD PRODUCT'){
				var appEvent1 = $A.get("e.c:ceEventDelete");
				appEvent1.setParams({
					"ProductIds" : cmp.get("v.ProductId")});
				appEvent1.fire();  
				cmp.set('v.IsSchedule',!cmp.get('v.IsSchedule'));
				myEvent.fire(); 
			}                
		   
			else{
				
				var appEvent1 = $A.get("e.c:RemoveScheduleEvent");
				appEvent1.setParams({
					"ProductIds" : cmp.get("v.ProductId")});
				appEvent1.fire();
				cmp.set('v.IsSchedule',!cmp.get('v.IsSchedule'));
				myEvent.fire();
			}*/
			cmp.set("v.ConfirmForUnschedule",true);  
		}
		
		else{
			var isSubscPrd = false, isServPrd = false, isCnctHWMProd = false, isQtyTypProd=false;             
			if(!$A.util.isEmpty(cmp.get("v.ServiceOfferCatogery")) && !$A.util.isEmpty(cmp.get("v.renewablRevnTypes")) && cmp.get("v.renewablRevnTypes").includes(cmp.get("v.ServiceOfferCatogery")) && (!cmp.get("v.isCatm"))) {

				isServPrd = true;    
			}

			if(cmp.get("v.sampleObj").avail_Subscription == true && !cmp.get("v.isCatm")) {
				isSubscPrd = true;   
			}
             
            
             if(!cmp.get("v.isCatm")){
            if(cmp.get("v.sampleObj").availAsConnectedHWM == true) {               
				isCnctHWMProd = true;   
			}
             }
             if(cmp.get("v.isCatm")){                
				isQtyTypProd = true;   
			}
			
			if(isSubscPrd || isServPrd || isCnctHWMProd || isQtyTypProd) { 
				helper.handleSubsProd(cmp,event,helper, isSubscPrd, isServPrd, isCnctHWMProd, isQtyTypProd);
			} else  {
				helper.handleSubsciption(cmp, event, false) ;
			} 
			
			/* if(TriggerScreenName == 'ADD PRODUCT'){
				var appEvent = $A.get("e.c:ceEvent");
				appEvent.setParams({
					"ProductIds" : cmp.get("v.ProductId")});  
				appEvent.fire(); 
			}
			
			
			else{
				//alert(TriggerScreenName);
				var appEvent1 = $A.get("e.c:InsertScheduleEvent");
				appEvent1.setParams({
					"ProductIds" : cmp.get("v.ProductId")});
				appEvent1.fire();  
			}
		   
			 var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
					FloatMsgEvent.setParams({
						"Msg" : "Products Added to Items to schedule Successfully.",
						"Category" : "Success",
						"isShow" : "True"
			});
			
			FloatMsgEvent.fire();
			cmp.set('v.IsSchedule',!cmp.get('v.IsSchedule'));
			myEvent.fire();   */
		}  
        
    },
    AddProductToFav:function(cmp,event,helper){
        
        var myEvent = $A.get("e.c:AddRemoveProduct");
        myEvent.setParams({"ProductId": cmp.get("v.ProductId"),
                           "ProductName":cmp.get("v.ProductName"),
                           "Index":cmp.get("v.Index")
                          });
        
        if(cmp.get("v.IsFav")){
          
            var action = cmp.get("c.RemoveFavourite");
            //action.setStorable();
            action.setParams({ "ProductId": cmp.get("v.ProductId") });
            action.setCallback(this, function (response) {
                var state = response.getState();
                    if(cmp.isValid() && state === "SUCCESS") {
                       
                         var appEvent1 = $A.get("e.c:psaddfavEvent_PS");
                         appEvent1.fire(); 
                         cmp.set("v.IsFav",!cmp.get("v.IsFav"));
                         myEvent.fire(); 
                    }
                
                  
           });
           $A.getCallback(function() {
               $A.enqueueAction(action);
           })(); 
            
        } 
        else{
            
            var action = cmp.get("c.addFavourite");
            //action.setStorable();
            action.setParams({ "ProductId": cmp.get("v.ProductId") });
            action.setCallback(this, function (response) {
                var state = response.getState();
                    if(cmp.isValid() && state === "SUCCESS") {
                       
                         var appEvent1 = $A.get("e.c:psaddfavEvent_PS");
                         appEvent1.fire(); 
                         cmp.set("v.IsFav",!cmp.get("v.IsFav"));
                         myEvent.fire(); 
                        
                    } else if (response.getState() == "ERROR") {
                        console.log(response.getError());
                    }      
           });
           $A.getCallback(function() {
               $A.enqueueAction(action);
           })(); 
            
        }
        cmp.set("v.SeletedProductCount",parseInt(0));
        cmp.set("v.SelectAll",false);
        cmp.set("v.DisableBulkProcess",false);
    },
    onCheck:function(cmp,event,helper){
        
        cmp.set('v.IsCheckBoxSelected',!cmp.get('v.IsCheckBoxSelected'));
    },
    SingleScheduleProduct:function(cmp,event,helper){
        helper.SingleScheduleProduct(cmp,event);
    },
    closeAlertWindow:function(cmp,event,helper){
        cmp.set("v.ConfirmForUnschedule",false);
    },
    onSelectProduct:function(cmp,event,helper){
        
        if(cmp.get("v.IsCheckBoxSelected")){
            
             cmp.set("v.SeletedProductCount",parseInt(cmp.get("v.SeletedProductCount") + 1));
        }
        else{
            //cmp.set("v.SeletedProductCount")-1;
            //cmp.set("v.SeletedProductCount",Integer.valueOf(cmp.get("v.SeletedProductCount")-1);
            cmp.set("v.SeletedProductCount",parseInt(cmp.get("v.SeletedProductCount") - 1));
        }
       // alert(cmp.get("v.SeletedProductCount"));
        if(parseInt(cmp.get('v.SeletedProductCount')) < parseInt(cmp.get('v.TotalResultSetCount'))){
           cmp.set("v.SelectAll",false);
        }
        else if(parseInt(cmp.get('v.SeletedProductCount')) === parseInt(cmp.get('v.TotalResultSetCount'))){
             cmp.set("v.SelectAll",true);
        }
        if(parseInt(cmp.get("v.SeletedProductCount")) > 20){
            
            cmp.set("v.DisableBulkProcess",true);
        }  
        else{
            cmp.set("v.DisableBulkProcess",false);
        }
    }
})