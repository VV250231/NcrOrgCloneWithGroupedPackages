({
    doInit:function(component,event,helper){
        var OppId=component.get("v.OpportunityId");
        helper.doInit(component,event,helper,OppId); 
    },
    CloseModelWindow : function (cmp, event) {
        var CloseModel = cmp.get("v.CloseModel");        
        cmp.set("v.CloseModel", CloseModel == 'slds-show'?'slds-hide':'slds-show');
        //cmp.set("v.ToggelBundleComponent", ToggelBundleComponent == 'show'?'hide':'show');
        var appEvent = $A.get("e.c:CustomAccordianRefreshEvent");
                    appEvent.setParams({
                        "message" : "Refresh" 
                         });
         appEvent.fire();
        
        // added as a part of story 2467
        var cbEvent =  cmp.getEvent("closeAddBundle");
	    cbEvent.fire(); 
        
        cmp.destroy();
         
    },
    getSelectProduct:function(component, event, helper){
        helper.getSelectProduct(component, event, helper);
        
    },
    handleClick : function (cmp, event, helper) {
        var buttonstate = cmp.get('v.SelectstatusForProduct');
        cmp.set('v.buttonstate', !buttonstate);
    },
    getSelectBundle:function(component, event, helper){
         helper.getSelectBundle(component, event, helper);
    },
    Save:function(cmp, event, helper){
        
        var myMap = cmp.get("v.Selected_Product");
        var SelectedProductIdSet = new Set();
        for (var key in myMap){
                    
                    if(myMap[key] == true && myMap[key] != ''){
                        SelectedProductIdSet.add(key);
                    }
  
         }
        
        //console.log(JSON.stringify(myMap));
        //console.log(JSON.stringify(cmp.get("v.SelectedProductForBundle")));
        
        //helper.Save(component, event, helper);
        var ResultData=cmp.get("v.SelectedProductForBundle");
        var TempResultDataId=[];
        var IsAllreadySchdeule=false;
        var isAnySubcriptionableProd = false,isAnyServiceProd = false,isAnyConnectedHWMProd = false,tempRcrd, confirmSubMdlHdr, isAnyQtyTypeProd=false/*CSI-304 by Stuti*/;
        var tempSelectedSubscriptionableList = [];
        var tempselectedNONSubcrionableProdList = [];
        /*CSI-304 by Stuti*/
        if(cmp.get("v.isCatm")){
            isAnyQtyTypeProd = true;
        }
        for(var i=0;i<ResultData.length;i++){
       
            if(SelectedProductIdSet.has(ResultData[i].Id)){
                
                 if(ResultData[i].IsCheckBoxSelected == true && (ResultData[i].avail_Subscription == true && ResultData[i].ServiceOfferCatogery != 'Cloud') && !cmp.get("v.isCatm") && (cmp.get("v.subsOnlyProdNames").includes(ResultData[i].ProductName)== true || cmp.get("v.subsOnlyRevenueTypes").includes(ResultData[i].ServiceOfferCatogery)== true ? true:false)) { //EBA_SF-2174 adding check for NCR Payment Processing by Stuti
                     
                 
                tempRcrd = {ProductId:ResultData[i].Id,
                            ProductName:ResultData[i].Name,
                            checkOLISubcription : false,
                            isServiceLineItem : false,
                            selectLineItemType : '',
                            isAvlAsCnctHWM : false,
                            selectHWMMntcType : '',
                            isQtyTypApplicable : false,
                            qtyTyp : ''};
                
                if(!cmp.get("v.isCatm")){
                     if (cmp.get("v.renewablRevnTypes").includes(ResultData[i].ServiceOfferCatogery)) {
                	isAnyServiceProd = true;
                    tempRcrd.isServiceLineItem = true;     
                }
                 }
                     
                if(!cmp.get("v.isCatm")){
                     if(ResultData[i].availAsConnectedHWM == true) {
               		isAnyConnectedHWMProd = true;  
                    tempRcrd.isAvlAsCnctHWM = true;    
                }
                }
                     /*--CSI 304 QTY TYPE ENHANCEMENT by Stuti--*/
                     if(cmp.get("v.isCatm")){
                    tempRcrd.isQtyTypApplicable = true;
                }
                     /*--CSI 304 QTY TYPE ENHANCEMENT Ended--*/
                tempSelectedSubscriptionableList.push(tempRcrd);
     
                isAnySubcriptionableProd = true ;
                
            }  
            else if(ResultData[i].IsCheckBoxSelected == true) {
               tempRcrd = {ProductId:ResultData[i].Id ,
                              ProductName:ResultData[i].Name,
                              checkOLISubcription : false,
                              isServiceLineItem : false,
                              selectLineItemType : '',
                           	  isAvlAsCnctHWM : false,
                              selectHWMMntcType : '',
                           isQtyTypApplicable : false,
                                  qtyTyp : ''
                             };                
                
                	if(!cmp.get("v.isCatm")){
                    if (cmp.get("v.renewablRevnTypes").includes(ResultData[i].ServiceOfferCatogery)) {
                        isAnyServiceProd = true;
                        tempRcrd.isServiceLineItem = true;     
                    }
                    }
                if(!cmp.get("v.isCatm")){
                    if (ResultData[i].availAsConnectedHWM == true) {
                        isAnyConnectedHWMProd = true;     
                        tempRcrd.isAvlAsCnctHWM = true;  
                    }
                }
                /*--CSI 304 QTY TYPE ENHANCEMENT by Stuti--*/
                if(cmp.get("v.isCatm")){
                        tempRcrd.isQtyTypApplicable = true;
                    }
                /*--CSI 304 QTY TYPE ENHANCEMENT logic end--*/
                
                tempselectedNONSubcrionableProdList.push(tempRcrd);
            	} 
            }
            
             
        }
        
        //cmp.set("v.confirmSubscriptionModal", isAnySubcriptionableProd );
        //cmp.set("v.confirmServTypeSelModal", isAnyServiceProd) ;  
       
        cmp.set("v.selectedSubcrionableProdList", tempSelectedSubscriptionableList ) ;
        cmp.set("v.selectedNONSubcrionableProdList", tempselectedNONSubcrionableProdList); 
        cmp.set("v.confirmSubModalHeader", confirmSubMdlHdr);
        
        if(isAnySubcriptionableProd == false && isAnyServiceProd == false && isAnyConnectedHWMProd == false && isAnyQtyTypeProd == false) {
           /*var act = cmp.get("c.BulkschProcessThroughAdd") ;
            act.setParams({
                cmp : cmp ,
               event : event ,
                helper : helper
            });
            $A.enqueueAction( act) ;*/
           
            helper.Save(cmp, event, helper);
        } 
        
        
        else {
             var myMap = cmp.get("v.Selected_Product");
             var MyMap_Bundle = cmp.get("v.Selected_Bundle");
            var Obj=[];
            for (var key in myMap){
                    
                    if(myMap[key] == true && myMap[key] != ''){
                        Obj.push({Id:key,Status:myMap[key]});
                    }
  
            }
            
            var Obj_Bundle= []; 

         
            for (var key in MyMap_Bundle){
                    
                    if(MyMap_Bundle[key] == true && MyMap_Bundle[key] != ''){
                        Obj_Bundle.push({Id:key,Status:MyMap_Bundle[key]});
                    }
  
            }
            
            
            if(Obj_Bundle.length == 0  && Obj.length == 0){
                /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Please select Product and corresponding Bundle",
                        "Category" : "Warning",
                        "isShow" : "True"
                    });
                    FloatMsgEvent.fire();*/
                //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Warning!",
       		 		"message": "Please select Product and corresponding Bundle",
        			"type":"warning"
   			 		});
    				toastEvent.fire();
            }
            
            else if(Obj_Bundle.length == 0){
                /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Please select Bundle",
                        "Category" : "Warning",
                        "isShow" : "True"
                    });
                    FloatMsgEvent.fire();*/
                //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Warning!",
       		 		"message": "Please select Bundle",
        			"type":"warning"
   			 		});
    				toastEvent.fire();

            }
            
            
            else if(Obj.length == 0){
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Please select Product",
                        "Category" : "Warning",
                        "isShow" : "True"
                    });
                    FloatMsgEvent.fire();	
            }
            else{
                    if (isAnySubcriptionableProd == true && isAnyServiceProd == true) {
                    confirmSubMdlHdr = "Please select product(s) to be added as a subscription and update the line item type.";       
                    } else if (isAnySubcriptionableProd == true) {
                        confirmSubMdlHdr = "Please select product(s) to be added as a subscription.";         
                    } else if (isAnyServiceProd == true) {
                        confirmSubMdlHdr = "Please update the line item type of product(s).";          
                    }
                else if (isAnyQtyTypeProd == true) {
                        confirmSubMdlHdr = "Please update the Qty Type of product(s).";          
                    }
                     cmp.set("v.confirmSubscriptionModal", isAnySubcriptionableProd );
                     cmp.set("v.confirmServTypeSelModal", isAnyServiceProd) ;
                	 cmp.set("v.confirmHWMTypeModal", isAnyConnectedHWMProd) ;	
                     cmp.set("v.confirmSubModalHeader", confirmSubMdlHdr);
                	 cmp.set("v.confirmQtyTypModal", isAnyQtyTypeProd);
               }
            	
            }
        cmp.set("v.SelectAllForNBundle",false);
    },
    addAllForSubscription : function(cmp, event, helper) {
        //debugger ;
        var tempList = cmp.get("v.selectedSubcrionableProdList") ;
        if(event.getSource().get("v.checked") == true) {
            for(var i=0; i <tempList.length ;i++ ) {
                tempList[i].checkOLISubcription = true ;
            }
        } else if(event.getSource().get("v.checked") == false) {
            for(var i=0; i <tempList.length ;i++ ) {
                tempList[i].checkOLISubcription = false ;
            }
        }
        
        cmp.set("v.selectedSubcrionableProdList" , tempList);
        
    },
    submitSubcriptionProdsForBundle:function(cmp,event,helper){        
        var subscriptionList = cmp.get("v.selectedSubcrionableProdList");
        var nonSubscriptionList = cmp.get("v.selectedNONSubcrionableProdList") ;
        var finalList = subscriptionList.concat(nonSubscriptionList);
        var Obj=[];
        var Obj_Bundle= []; 
        var hasError = false;
        var MyMap_Bundle = cmp.get("v.Selected_Bundle");
        for(var i=0; i<finalList.length ; i++) {
            
            if(finalList[i].checkOLISubcription){   //
                Obj.push({Id:finalList[i].ProductId,Status:true,isSubricption:finalList[i].checkOLISubcription,LineItemType:finalList[i].selectLineItemType,HWMMntcType:finalList[i].selectHWMMntcType,qtyType:finalList[i].qtyTyp});
            }
            else{
                 Obj.push({Id:finalList[i].ProductId,Status:true,isSubricption:finalList[i].checkOLISubcription,LineItemType:finalList[i].selectLineItemType,HWMMntcType:finalList[i].selectHWMMntcType,qtyType:finalList[i].qtyTyp});
            }
            
            if((finalList[i].isServiceLineItem && $A.util.isEmpty(finalList[i].selectLineItemType))
               	|| (finalList[i].isAvlAsCnctHWM && $A.util.isEmpty(finalList[i].selectHWMMntcType))
              	|| (finalList[i].isQtyTypApplicable && $A.util.isEmpty(finalList[i].qtyTyp))
               )
            { 
                hasError = true;
                break;
            }
        }

        for (var key in MyMap_Bundle){
                    
                    if(MyMap_Bundle[key] == true && MyMap_Bundle[key] != ''){
                        Obj_Bundle.push({Id:key,Status:MyMap_Bundle[key]});
                    }
  
        }
				
        if(hasError) {
        	/*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Plese select Line Item Type for below Service Products",
                "Category" : "Error",
                "isShow" : "True"
            }); 
            FloatMsgEvent.fire();*/
            //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Error!",
       		 		"message": "Please select Line Item Type or Maintenance Type or Qty Type for below Service Products",
        			"type":"error"
   			 		});
    				toastEvent.fire();

        }
		
		
        else{
             
             if(Obj_Bundle.length > 0 && Obj.length > 0){
			 //console.log(JSON.stringify(Obj_Bundle));
                var action = cmp.get("c.AddProductToBundleMethod");
                action.setParams({                    
                    "PrdList" :JSON.stringify(Obj),
                    "BndlList":JSON.stringify(Obj_Bundle)
                    
                });
                 action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var OppId=cmp.get("v.OpportunityId");
                
                    
                    /*var appEvent = $A.get("e.c:EverntFromBundleComptoSearchComp");
                    appEvent.setParams({
                        "CallFromBundleforRefresh" : 'call from child '
                        
                    });
                    appEvent.fire();*/
                
                    var appEvent = $A.get("e.c:CustomAccordianRefreshEvent");
                    appEvent.setParams({
                        "message" : "Refresh" 
                         });
                    appEvent.fire();
                    
                    cmp.set("v.body",'');
                    
                    helper.doInit(cmp, event, helper,OppId);
                        
                /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Product Added Successfully.",
                        "Category" : "Success",
                        "isShow" : "True"
                    });
                    FloatMsgEvent.fire();	*/
                            var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Success!",
       		 		"message": "Product Added Successfully.",
        			"type":"success"
   			 		});
    				toastEvent.fire();
                    MyMap_Bundle={}; 
                    cmp.set("v.Selected_Bundle",MyMap_Bundle); 
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
         cmp.set("v.confirmSubscriptionModal", false) ;
         cmp.set("v.confirmServTypeSelModal", false) ;   
         cmp.set("v.confirmHWMTypeModal", false) ;
         cmp.set("v.confirmQtyTypModal", false); // CSI 304 Qty Type Enhancement Story by Stuti
 
		} 
            
           
        }
           
    }  
    
})