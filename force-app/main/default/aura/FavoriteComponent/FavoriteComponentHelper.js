({  getSubsProduct: function(cmp){	
    console.log('hereee2');	
    	
    var getSettingsAction = cmp.get("c.getSubsOnlyProd");	
   		 getSettingsAction.setCallback(this, function(response) {	
            	
       	if (cmp.isValid() && response !== null && response.getState() == 'SUCCESS') {	
            cmp.set("v.subsOnlyProdNames" ,response.getReturnValue().ProductNames);	
            cmp.set("v.subsOnlyRevenueTypes" ,response.getReturnValue().RevenueTypes);	
             	
            console.log('hereee3');	
            }	
           	
    	});	
   		$A.enqueueAction(getSettingsAction);	
	},
  
    getRenewalProducts: function(cmp){
        debugger;
        var getSettingsAction = cmp.get("c.getRnwableProds");
        /***** Stuti-1595 *****/
        getSettingsAction.setParams({'OppId': cmp.get("v.favOppId")});
        /***** Stuti-1595 Ends*****/
            getSettingsAction.setCallback(this, function(response) {
                if (cmp.isValid() && response !== null && response.getState() == 'SUCCESS') {                   
                    cmp.set("v.renewablRevnTypes" ,response.getReturnValue().RnwablRevTypes); 
                    
                    if(!$A.util.isEmpty(response.getReturnValue().OppLineItemTypes)) {
                        var OppLineItemTypes = response.getReturnValue().OppLineItemTypes;
                        var lineItemTypeMap = [];
                        for(var key in OppLineItemTypes){
                            lineItemTypeMap.push({key: key, value: OppLineItemTypes[key]});
                        }
                        cmp.set("v.oppLineItemTypeMap", lineItemTypeMap);
                    }                    
                    console.log('getSubsProduct success');
                    
                    if(!$A.util.isEmpty(response.getReturnValue().HWMMntTypes)) {                        
                    	cmp.set("v.HWMMntcTypes" ,response.getReturnValue().HWMMntTypes); 
                    }
                    //adding qtyTypes CSI 304 by Stuti
                    if(!$A.util.isEmpty(response.getReturnValue().qtyTypes)) {                       
                        var qtyTypeResp = response.getReturnValue().qtyTypes;
                        var qtyTypeMap = [];
                        for(var key in qtyTypeResp){
                            qtyTypeMap.push({key: key, value: qtyTypeResp[key]});
                        }              
                        cmp.set("v.fieldMap", qtyTypeMap);
                    }
                }           
            });
            $A.enqueueAction(getSettingsAction);
	},
  
    getProducts: function(component) {
        var action = component.get("c.getProducts");
        action.setParams({'OppId': component.get("v.favOppId")});
        action.setCallback(this, function(a) {
            component.set("v.WrapperVar", a.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
    
  	PlusIconFirstPhase : function(component, event, helper) {     
        var item= component.get("v.WrapperVar");
        var TheCheckBoxes = component.find("TheCheckBox");
        var tempSubscribeList = [];
        var tempNonSubscribeList = [] ;
        var isAnySubscribeProd = false ,isAnyServiceProd = false, isAnyConnectedHWMProd = false, tempRcrd,confirmSubMdlHdr, isAnyQtyTypeProd=false/*CSI-304 by Stuti*/;
        var isAnyItemSelected  = false; 
        /*CSI-304 by Stuti*/
        
        if(component.get("v.isCatm")){
            isAnyQtyTypeProd = true;
        }
        for(var i=0 ; i < item.length ; i++) {
            if(item[i].Selected == true) {
                 tempRcrd = { ProductId :item[i].Prod.Products__c,
                              ProductName:item[i].Prod.Products__r.Name ,
                              checkOLISubcription : false,
                              isServiceLineItem : false,
                              selectLineItemType : '',
                              isAvlAsCnctHWM : false,
                              selectHWMMntcType : '',
                              isQtyTypApplicable : false,
                              qtyTyp : ''
                            };
                if(!component.get("v.isCatm")){
                    if (component.get("v.renewablRevnTypes").includes(item[i].Prod.Products__r.Service_Offer_Category__c)) {
                    	isAnyServiceProd = true;
                    	tempRcrd.isServiceLineItem = true;     
                	}
                }
                
                if(!component.get("v.isCatm")){
                if(item[i].Prod.Products__r.Available_as_Connected_HWM__c == true) {
                    isAnyConnectedHWMProd = true;  
                	tempRcrd.isAvlAsCnctHWM = true;       
                	}
                }
                if(component.get("v.isCatm")){
                    tempRcrd.isQtyTypApplicable = true;
                }

                if (item[i].Prod.Products__r.Available_for_Subscription__c == true  && (!component.get("v.isCatm"))) {                   
                    tempSubscribeList.push(tempRcrd);
                    //console.log('_____component.get("v.subsOnlyProdNames")'+component.get("v.subsOnlyProdNames")+'_____component.get("v.subsOnlyRevenueTypes")'+component.get("v.subsOnlyRevenueTypes"));
                    if(!component.get("v.subsOnlyProdNames").includes(item[i].Prod.Products__r.Name) && !component.get("v.subsOnlyRevenueTypes").includes(item[i].Prod.Products__r.Service_Offer_Category__c)){
                    //console.log('___item[i].Prod.Products__r.Name'+item[i].Prod.Products__r.Name+'___item[i].Prod.Products__r.RevenueType'+item[i].Prod.Products__r.Service_Offer_Category__c);
                        isAnySubscribeProd = true ;
                       }
                } else  {                    
                    tempNonSubscribeList.push(tempRcrd) ;
                }      
                isAnyItemSelected = true ;
            }
            
        }
        
         if(isAnyItemSelected == false ) {                        
           	 /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
              FloatMsgEvent.setParams({
                "Msg" : "No Product is Selected,Please Select any Product",
                "Category" : "Warning",
                "isShow" : "True"
                });
            FloatMsgEvent.fire(); */
             //Ajay-jul2021
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "title": "Warning!",
                        "message": "No Product is Selected,Please Select any Product",
                        "type":"warning"
                        });
                        toastEvent.fire();

        }
        
        
        component.set("v.selectedSubcrionableProdList" , tempSubscribeList) ;
        component.set("v.selectedNONSubcrionableProdList" , tempNonSubscribeList) ;
        component.set("v.confirmSubscriptionModalFav" , isAnySubscribeProd ) ;
        component.set("v.confirmServTypeSelModalFav" , isAnyServiceProd) ;
        component.set("v.confirmHWMTypeModalFav", isAnyConnectedHWMProd) ; 
        component.set("v.confirmQtyTypModal", isAnyQtyTypeProd);
        
        if(isAnySubscribeProd == false && isAnyServiceProd == false && isAnyConnectedHWMProd == false && isAnyQtyTypeProd == false) {
				helper.PlusIcon(component, event, helper) ;            
        } else {
            if (isAnySubscribeProd == true && isAnyServiceProd == true) {
                confirmSubMdlHdr = "Please select product(s) to be added as a subscription and update the line item type.";       
            } else if (isAnySubscribeProd == true) {
                confirmSubMdlHdr = "Please select product(s) to be added as a subscription.";         
            } else if (isAnyServiceProd == true || isAnyQtyTypeProd == true) {
                confirmSubMdlHdr = "Please update the line item type or qty type of product(s).";          
            }
            component.set("v.confirmSubModalHeader", confirmSubMdlHdr); 	
        }
        if(component.get("v.selectedSubcrionableProdList").length>1){
           component.set("v.multi",true);
           }
    } ,
    
	PlusIcon : function(cmp, event, helper){
        
        var subscriptionList = cmp.get("v.selectedSubcrionableProdList") ;
        var nonSubscriptionList = cmp.get("v.selectedNONSubcrionableProdList") ;
        var finalList, hasError = false;
        if(subscriptionList && subscriptionList) {
            finalList = subscriptionList.concat(nonSubscriptionList) ;
        } else if(subscriptionList) {
            finalList = subscriptionList ;
        } else if(nonSubscriptionList) {
            finalList = nonSubscriptionList ;
        }
        console.log(finalList);
        var tempProdIdsFav = [];
        var tempSubscriptionVals = [] ;
        var tempServLineItemTypes = [];
        var tempHWMMntcTypes =[];
        var tempQtyTypes =[];
        for(var i=0; i<finalList.length ; i++) {
            tempProdIdsFav.push(finalList[i].ProductId) ;
            tempSubscriptionVals.push(finalList[i].checkOLISubcription) ;
            tempServLineItemTypes.push(finalList[i].selectLineItemType);
            tempHWMMntcTypes.push(finalList[i].selectHWMMntcType);
            tempQtyTypes.push(finalList[i].qtyTyp);
            
            if(
                   (finalList[i].isServiceLineItem && $A.util.isEmpty(finalList[i].selectLineItemType))
              	|| (finalList[i].isAvlAsCnctHWM && $A.util.isEmpty(finalList[i].selectHWMMntcType))
              	|| (finalList[i].isQtyTypApplicable && $A.util.isEmpty(finalList[i].qtyTyp))
              ) {
                hasError = true;
                break;
            }
        }
        
        if(hasError) {
        	var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Please select Line Item Type or Maintenance Type or Qty Type for below Service Products",
                "Category" : "Error",
                "isShow" : "True"
            }); 
            FloatMsgEvent.fire(); 
        } else {
            if(tempProdIdsFav.length > 0) {
                var appEvent = $A.get("e.c:ceEvent");
                appEvent.setParams({
                    "ProductIds" : tempProdIdsFav ,
                    "HasSubsciption" :tempSubscriptionVals,
                    "screenName":'Favorite',
                    "ServLineItemTypeArray" : tempServLineItemTypes,
                    "HWMMntcTypeArray" : tempHWMMntcTypes,
                    "qtyTypeArray" :  tempQtyTypes
                });
                appEvent.fire(); 
                /* commented for opp line item type change
                  var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                  FloatMsgEvent.setParams({
                  	"Msg" : "Products Added to Items to schedule Succesfully.",
                    "Category" : "Success",
                     "isShow" : "True"
                  });
                FloatMsgEvent.fire(); */
                 var AllChk = cmp.find("SelectAllCheckBox");
                             AllChk.set("v.value",false);
                
            }
            cmp.set("v.confirmSubscriptionModalFav" , false) ; 
            cmp.set("v.confirmServTypeSelModalFav" , false);
            cmp.set("v.confirmHWMTypeModalFav" , false);
            cmp.set("v.confirmQtyTypModal", false);
    	}
    },
    LikeIcon : function(component, event, helper){
        var item= component.get("v.WrapperVar");
        
        var TheCheckBoxes = component.find("TheCheckBox");
        var ProductsToUnFav = new Array();
        if(item.length>1){
            
            for(var i=0;i<TheCheckBoxes.length;i++){
                if(TheCheckBoxes[i].get("v.value")){
                    ProductsToUnFav.push(TheCheckBoxes[i].get("v.name"));
                }
            }
        }
        else if(item.length==1){ 
           // ProductsToUnFav.push(TheCheckBoxes.get("v.name"));
            ProductsToUnFav.push(item[0].Prod.Products__c);
        }

        if(ProductsToUnFav.length>0){
            var action = component.get("c.UnFavProduct");
            //alert(component.get("v.WrapperVar"));
            action.setParams({ "ProductId": ProductsToUnFav });
            //action.setParams({"OppId": component.get("v.favOppId")}); //BY STUTI 2059 
            action.setCallback(this, function(a) {
                
                if(action.getState() ==='SUCCESS'){
                   //Exception Handling
                    if(!a.getReturnValue()){
                        helper.getProducts(component);
                         /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                         FloatMsgEvent.setParams({
                            "Msg" : "Product Removed From Favorite List Successfully.",
                            "Category" : "Success",
                            "isShow" : "True"
                         });
                         FloatMsgEvent.fire();*/
                        //Ajay-jul2021
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "title": "Success!",
                        "message": "Product Removed From Favorite List Successfully.",
                        "type":"success"
                        });
                        toastEvent.fire();

                         //Uncheck "SelectAllCheckBox" checkbox
                         var AllChk = component.find("SelectAllCheckBox");
                         AllChk.set("v.value",false);
                    }
                    else{
                       /* var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                         FloatMsgEvent.setParams({
                            "Msg" : a.getReturnValue(),
                            "Category" : "Error",
                            "isShow" : "True"
                         });
                         FloatMsgEvent.fire();*/
                         //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Error!",
       		 		"message": a.getReturnValue(),
        			"type":"error"
   			 		});
    				toastEvent.fire();
                    }
                    //End Exception Handling
                } else {
                    var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Something has gone wrong.",
                        "Category" : "Error",
                        "isShow" : "True"
                    });
                    FloatMsgEvent.fire();
                }
               
                
            });  
             
            $A.enqueueAction(action);
           
        }
        else{   
            
            /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "No product is Selected,Please Select the Product to Remove From Favourite List.",
                        "Category" : "Warning",
                        "isShow" : "True"
                    });
                    FloatMsgEvent.fire();*/
            //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Warning!",
       		 		"message": "No product is Selected,Please Select the Product to Remove From Favourite List.",
        			"type":"warning"
   			 		});
    				toastEvent.fire();
        }
        
    },
    fireCheckAllCheckboxes : function(component, event, helper){
        
        var item= component.get("v.WrapperVar");
        
        if(item.length>1){
            var   TheCheckBoxes= component.find("TheCheckBox");            
            for (var i=0;i<TheCheckBoxes.length;i++){               
                TheCheckBoxes[i].set("v.value",true);
            }
        } 
        else if(item.length==1){
            var   TheCheckBoxes= component.find("TheCheckBox"); 
            if(component.find("TheCheckBox")[0]){
               TheCheckBoxes[0].set("v.value",true);   
            }
            else{
                TheCheckBoxes.set("v.value",true); 
            }  
        }  
    },
    fireUncheckAllCheckboxes : function(component, event, helper){
        var item= component.get("v.WrapperVar");
        if(item.length>1){
            var TheCheckBoxes = component.find("TheCheckBox");
            for (var i = 0; i < TheCheckBoxes.length; i++){
                TheCheckBoxes[i].set("v.value",false);
            }  
        } 
        else if(item.length==1){ 
             var TheCheckBoxes = component.find("TheCheckBox");
            if(component.find("TheCheckBox")[0]){
               TheCheckBoxes[0].set("v.value",false);   
            }
            else{
                TheCheckBoxes.set("v.value",false); 
            }
            
            
        }  
    },
    createBundleComponent:function(component,event, helper,Obj){
       
        $A.createComponent(
            "c:AddProductToBundle",
            {
               "SelectedProductForBundle": Obj,
                "OpportunityId":component.get("v.favOppId"),
                "isCommunityUser":component.get("v.isCommunityUser"),   
                "IPTPartnerCommunityUrl":component.get("v.IPTPartnerCommunityUrl"),
                "renewablRevnTypes":component.get("v.renewablRevnTypes"),
                "oppLineItemTypeMap":component.get("v.oppLineItemTypeMap"),
                "TriggerScreenName":component.get("v.TriggerScreenName"),
                "OpportunityId":component.get("v.favOppId"),
                "HWMMntcTypes": component.get("v.HWMMntcTypes")
            },
            function(newButton, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newButton);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
       var AllChk = component.find("SelectAllCheckBox");
       AllChk.set("v.value",false);
       helper.fireUncheckAllCheckboxes(component, event, helper); 
        
    },
  isCatmOpp : function(component, event, helper) {
		 var action = component.get("c.getOpportunity");
        action.setParams({ 
        OppId :component.get("v.favOppId")
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
			
            if(state === "SUCCESS") {  
                component.set("v.isCatm",response.getReturnValue());
                console.log('Test JSon'+JSON.stringify(response.getReturnValue()));
            }
     else if(state === "ERROR") {
                
                var errors = response.getError();
                if (errors){
                    if (errors[0] && errors[0].message) {
                       alert("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    alert('4');
                }
            }
                else{
                    alert('>>>>'+'Please reload the page.');
                }
             //component.set("v.ShowHideSpinner",false);
             
        });     
        $A.enqueueAction(action);
        
                
	}

})