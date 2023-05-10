({
    doInit : function(component, event, helper) {
        var getSettingsAction = component.get("c.getSubsOnlyProd");
        getSettingsAction.setCallback(this, function(response) {
            if (component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                
                component.set("v.subsOnlyProdNames" ,response.getReturnValue().ProductNames);
                component.set("v.subsOnlyRevenueTypes" ,response.getReturnValue().RevenueTypes);
                console.log("Subscription Setting loaded.");
            } else {
                //console.log("Failed to load Subscription Setting.");
            }
        });      
        
        $A.enqueueAction(getSettingsAction);       
    },
    
    passRecordId: function(component, event, helper){ 
        
        component.set("v.isCompLoaded", false); 
        component.set("v.passId", event.getParam("passRecordId"));
        component.set("v.tabLabel", "Package-25"); 
        helper.helperMethod(component, event, helper);
        helper.loadData(component, event, helper); 
        
        //console.log(component.get("v.passId"));
        
    },    
    
    exposeLoadData : function(component,event,  helper) {
       
        helper.loadData(component, event, helper);
    },
    
    selectAll : function(component, event, helper){
        var opts=[];
        var abc= event.getSource();
        if(abc.get("v.value")){
            var inputsel = component.get("v.ProductList");
            for(var i=0;i< inputsel.length;i++){ 
                var value=inputsel[i].value;
                
                opts.push({value : true, quantity: inputsel[i].quantity,unitPrice: inputsel[i].unitPrice,totalValue: inputsel[i].totalValue,ProductName:inputsel[i].ProductName,ProductId:inputsel[i].ProductId,OliId:inputsel[i].OliId});
                
            }
            component.set("v.ProductList", opts);  
        }   
        
        else{
            var inputsel = component.get("v.ProductList");
            for(var i=0;i< inputsel.length;i++){  
                var value=inputsel[i].value;
                opts.push({value: false, quantity: inputsel[i].quantity,unitPrice: inputsel[i].unitPrice,totalValue: inputsel[i].totalValue,ProductName:inputsel[i].ProductName,ProductId:inputsel[i].ProductId,OliId:inputsel[i].OliId});
            }
            component.set("v.ProductList", opts); 
        }  
    },
    
    SelectforFavroute : function(component, event, helper){
       
        var opts=[];
        var inputsel = component.get("v.ProductList");
        if(inputsel.length<=0){
            
            /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "There are no products in Items to Schedule.",
                "Category" : "Warning",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();*/
            var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Warning!",
       		 		"message": "There are no products in Items to Schedule.",
        			"type":"warning"
   			 		});
    				toastEvent.fire();
        }
        
        // component.set("v.ShowHideSpinner",true);
        for(var i=0;i< inputsel.length;i++){
            
            if( inputsel[i].value === true){  
                
                opts.push(inputsel[i].ProductId);
            }   
        }
        var action = component.get("c.SelectforFavroute1"); 
        action.setParams({ 
            
            SelectedProductid :opts 
            
        });
        action.setCallback(this, function(a) {
            
            if (a.getState() === "SUCCESS") {
                //Added for Exception handeling
                if (!a.getReturnValue()) {
                    var appEvent = $A.get("e.c:schEvent");
                    appEvent.setParams({
                        "schMessage": 'Pankaj Kashyap'
                    });
                    appEvent.fire();
                  /*var allChk = component.find("TheCheckBox");
                 allChk.set("v.value", false);
                 var rowChk = component.find("rowCheckBox");
                 for (var i = 0; i < rowChk.length; i++) {
                      if (rowChk[i].get("v.value")) {
                       rowChk[i].set("v.value", false);
                      }
                 }*/
                //component.set("v.SelectAll",true);
                if (opts.length >= 1 && inputsel.length >= 1) {
                    
                   /* var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg": "Products Added to Favorites Succesfully From Item to schedule.",
                        "Category": "Success",
                        "isShow": "True"
                    });
                    FloatMsgEvent.fire();*/
                    var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success!!",
                    message: 'Products Added to Favorites Successfully From Item to schedule.',
                    type: "Success"
                });
                toastEvent.fire();
                } else {
                    /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg": "No Product is Selected, Please Select the Product To Make Favourite.",
                        "Category": "Warning",
                        "isShow": "True"
                    });
                    FloatMsgEvent.fire();*/
                    var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "warning!!",
                    message: 'No Product is Selected, Please Select the Product To Make Favourite.',
                    type: "Warning"
                });
                toastEvent.fire();
                }
            } else {
                FloatMsgEvent.setParams({
                    "Msg": a.getReturnValue(),
                    "Category": "Error",
                    "isShow": "True"
                });
                FloatMsgEvent.fire();
            }
            //End of Exception Handeling
            
        } else if(a.getState() === "ERROR") {
            
            var errors = a.getError();
            if (errors){
                
                if (errors[0] && errors[0].message) {
                    alert("Error message: " + 
                          errors[0].message +'Reload Page');
                }
            } else {
                console.log("Unknown error");
                alert('4');
            }
        }
            else
            {
                alert('Error'+a.getReturnValue());
            }  
            component.set("v.ShowHideSpinner",false);    
        });
        
        $A.enqueueAction(action);
    },
    
    handleApplicationEvent : function(cmp, event, helper) {
        var ProdIds = event.getParam("ProductIds");        
        var screenName = event.getParam("screenName");		
        cmp.set("v.screenName",screenName);
        cmp.set("v.SelectAll",false); //EBA_SF-1141       
        console.log(event.getParam("qtyTypeArray"));
        
        var catmMnths=cmp.get("v.oppMonths"); // by stuti 2279
        
        
        // ProdIds = event.getParam("ProductIds");         
        var action = cmp.get("c.InsertOpportunityLineItem");
        action.setParams({            
            Product_Selected_From_Favorite_Section :ProdIds,
            Oppid :cmp.get("v.passId") ,
            subsciptionValArray : event.getParam("HasSubsciption"),
            ServLineItemTypeArray : event.getParam("ServLineItemTypeArray"),
            HWMMntcTypeArray : event.getParam("HWMMntcTypeArray"),
            qtyTypeArray : event.getParam("qtyTypeArray")
        }); 
        if($A.util.isEmpty(catmMnths) & cmp.get("v.isCatm")){
            var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Error!",
       		 		"message": "Contract Months is empty",
        			"type":"error"
   			 		});
    				toastEvent.fire();
        }
else{      
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") { 
                if (!a.getReturnValue()) {
                    console.log('going to fetch inside PS 1 screen');
                    helper.loadData(cmp, event, helper);
                    //Sent response to Favorite section
                    $A.get("e.c:ConfirmOliInsert").setParams({
                        "Confirm": "True",	
                        "screenName": cmp.get("v.screenName")
                    }).fire();
                    
                    // Added for OLI type change start
                    /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Product Added To Schedule Successfully.",
                        "Category" : "Success",
                        "isShow" : "True"
                    }); 
                    FloatMsgEvent.fire();*/
                    //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Success!",
       		 		"message": "Product Added To Schedule Successfully.",
        			"type":"success"
   			 		});
    				toastEvent.fire();
                    // Added for OLI type change start
                } else {
                    /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg": a.getReturnValue(),
                        "Category": "Error",
                        "isShow": "True"
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
            } 
            else if (a.getState() === "ERROR") { 
                
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg": "Error returned from server.Please contact to your admin.",
                    "Category": "Error",
                    "isShow": "True"
                });
                FloatMsgEvent.fire();
            }                 
        }); 
    }
        $A.enqueueAction(action); 
    },
    handleApplicationEventDelete: function(cmp, event, helper) {
        var ProdIds = new Array();
        ProdIds = event.getParam("ProductIds");
        var action = cmp.get("c.removeSchedule");
        action.setParams({
            SelectedProductid: ProdIds,
            recordId: cmp.get("v.passId")
            
        });
        action.setCallback(this, function(a) {
            if (a.getReturnValue() === "SUCCESS") {
                // cmp.set("v.ShowHideSpinner",false); 
            }else if(a.getReturnValue() === "ERROR"){
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg": "Error returned from server.Please contact to your admin.",
                    "Category": "Error",
                    "isShow": "True"
                });
                FloatMsgEvent.fire();
            }
            helper.loadData(cmp, event, helper);
        });
        $A.enqueueAction(action);
        
    },
    
    totalvaluecalculate:function(component, event, helper){
        var opts=[];
        var inputsel = component.get("v.ProductList");
        var ErrorMessage='';
        for(var i=0;i< inputsel.length;i++){
            
            if(inputsel[i].quantity == null){
                ErrorMessage='Show Error';
                
                opts.push({value: false, quantity: inputsel[i].quantity,unitPrice: inputsel[i].unitPrice,totalValue: inputsel[i].totalValue,ProductName:inputsel[i].ProductName,ProductId:inputsel[i].ProductId,OliId:inputsel[i].OliId,Eroorvalue:true});
            }
            else{ 
                var denominator = Math.pow(10, 0);
                var newunitprice=inputsel[i].unitPrice;
                var newtotalvalue=inputsel[i].totalValue;
                // santosh jha
                //var rounded_number = Math.round(newunitprice * denominator)/denominator;
                //var rounded_number2= Math.round(newtotalvalue * denominator)/denominator;
                
                var rounded_number = (newunitprice * denominator)/denominator;
                var rounded_number2= (newtotalvalue * denominator)/denominator;
          
                opts.push({value: false, quantity: inputsel[i].quantity,unitPrice: rounded_number,totalValue: rounded_number2,ProductName:inputsel[i].ProductName,ProductId:inputsel[i].ProductId,OliId:inputsel[i].OliId,Eroorvalue:false});
            }
            
        } 
        component.set("v.ProductList", opts);	        	
        if(ErrorMessage=='Show Error'){
            //alert('Opportunity line item Qunatity is required');
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "OpportunityLineItem Quantity is Required.",
                "Category" : "Warning",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();
            
        }
        else{
            helper.totalvaluecalculate(component, event, helper);
        }
        
    },
    SelectforDelete:function(component, event, helper){
        helper.SelectforDelete(component, event, helper);
        //console.log(component.get("v.ProductList"));	  	 
    },
    SentForSchedule:function(component, event, helper){
         event.preventDefault();  
        var navService = component.find( "navServicePSCall" ); 
        
        if(component.get("v.isCommunityUser")){
            var pageReferencepss = {  
                type: "comm__namedPage",  
                attributes: {  
                    pageName: "productschedulernewpage"  
                },  
                state: {  
                    Opportuntyid:  component.get("v.passId"),
                    ScreenName: 'PS',
                    IsCommunityUser: true
                }  
            };  
            sessionStorage.clear();
            console.log( 'State is ' + JSON.stringify( pageReferencepss.state ) );  
        }
        
        else{
            var pageReferencepss = {
                type: 'standard__component',
                attributes: {
                    componentName: 'c__PS_Scheduler_New',   
                },
                state: {
                    "c__Opportuntyid":  component.get("v.passId"),
                    "c__ScreenName": 'PS',
                    "c__IsCommunityUser": false
                }
            };  
        }
        
        navService.navigate( pageReferencepss );  
        //helper.SentForSchedule(component, event, helper);
        
    },
    totalvaluecalculateNew:function(component, event, helper){
        var opts=[];
        var inputsel = component.get("v.ProductList");
        var ErrorMessage='';
        for(var i=0;i< inputsel.length;i++){
            
            if(inputsel[i].quantity == null){
                ErrorMessage='Show Error';
                
                opts.push({value: false, quantity: inputsel[i].quantity,unitPrice: inputsel[i].unitPrice,totalValue: inputsel[i].totalValue,ProductName:inputsel[i].ProductName,ProductId:inputsel[i].ProductId,OliId:inputsel[i].OliId,Eroorvalue:true});
            }
            else{ 
                var denominator = Math.pow(10, 0);
                var newunitprice=inputsel[i].unitPrice;
                var newtotalvalue=inputsel[i].totalValue;
		// EBA_SF-2340 TCV remove round off
                var rounded_number = (newunitprice * denominator)/denominator;
                var rounded_number2= (newtotalvalue * denominator)/denominator;
                opts.push({value: false, quantity: inputsel[i].quantity,unitPrice: rounded_number,totalValue: rounded_number2,ProductName:inputsel[i].ProductName,ProductId:inputsel[i].ProductId,OliId:inputsel[i].OliId,Eroorvalue:false});
            }
            
        } 
        component.set("v.ProductList", opts);	        	
        if(ErrorMessage=='Show Error'){
            //alert('Opportunity line item Qunatity is required');
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "OpportunityLineItem Quantity is Required.",
                "Category" : "Warning",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();
            
        }
        else{
            helper.totalvaluecalculateNew(component, event, helper);
        }
    },
    destoryCmp : function (component, event, helper) {
        console.log('destoryCmp>>>>>>>');
        //component.destroy();
    },
    /*showProduct : function (component, event, helper) {
        var clickedTab =event.target.name;
        if(clickedTab=='product'){        
            component.set("v.isShowProduct", true);
        }
        else if(clickedTab=='package'){ 
            component.set("v.isShowProduct", false);  
        }
    }, */
    
    showProductTabsection: function(component, event, helper) {
        
        var oldLineItemIdValue = event.getParam("oldOppLineItemId");
        if(oldLineItemIdValue !=null) {
            
            var action = component.get("c.deletePackage") ;
            action.setParams({
                packageOliId : oldLineItemIdValue,
                recordId : component.get("v.passId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var returnValue = response.getReturnValue();
                if(state == 'SUCCESS') {   
                    debugger;
                    helper.loadData(component, event, helper);
                }
            });  $A.enqueueAction(action);
            
        } 
        
        else if(oldLineItemIdValue ==null){
            helper.loadData(component, event, helper);   
        }
    },
    
    validateProductLines : function(component, event, helper) {
       helper.validateProductLines(component, event, helper);
    },
    
    
    validateCATMNoOfTerms : function(component, event, helper) {
        var productList = component.get("v.ProductList");
        var errMsgs = [];
        var oppNoOfTerms, isTermExist = false, isValOpp = true;
        console.log(JSON.stringify(productList));
        
        if(!$A.util.isEmpty(productList)) {           
             for(var i=0;i< productList.length;i++) {
                 
                 if(!$A.util.isEmpty(productList[i].OneTimeFee) && parseInt(productList[i].OneTimeFee) != 0 && !$A.util.isEmpty(productList[i].unitPrice) && parseInt(productList[i].unitPrice) != 0) {
                     isValOpp = false;
                     errMsgs.push('Product:'+ productList[i].ProductName + '-' + 'Either one time fee or monthly fee should be populated');  
                     
                 } else if(!$A.util.isEmpty(productList[i].unitPrice) && parseInt(productList[i].unitPrice) > 0 && productList[i].NoOfTerms !== oppNoOfTerms) {
                    
                      if(isTermExist && productList[i].NoOfTerms != oppNoOfTerms) {
                        isValOpp = false;
                        errMsgs.push('All Cardtronics products with Monthly fee should have same number of terms !!'); 
                        
                       var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'All Cardtronics products with Monthly fee should have same number of terms !!',
                            duration:'3000',                          
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        }); 
                        toastEvent.fire();  
                          
                     } else {                      
                    	isTermExist = true;
                        oppNoOfTerms = productList[i].NoOfTerms;
                     }     
                 }
             }
        }
        component.set('v.errMsgLst', errMsgs); 
        component.set('v.hasError', !isValOpp); 
       
        return isValOpp;
    },
    
   oppMonthChange :  function(component, event, helper) {
        var isCompLoaded = component.get("v.isCompLoaded"); 
        if(!isCompLoaded) return;
       
        var oppMnths =  event.getParam("value");
      	var productList = component.get("v.ProductList");       
        var updateProdList = [];
       
       if(!$A.util.isEmpty(productList)) {
            //validate child components
            var childCmp = component.find('prdSelChild');            
            if(!$A.util.isEmpty(childCmp) && childCmp.length > 0) {
                childCmp.forEach(function(item) {
                    item.oppTermChange();
                });
            }
            helper.validateProductLines(component, event, helper);
       }
       
       if($A.util.isUndefinedOrNull(oppMnths) ||  oppMnths == '') {
           oppMnths = 0;
       }
        
        if(!$A.util.isEmpty(productList)) {           
             for(var i=0;i< productList.length;i++) {
                 productList[i].NoOfTerms = oppMnths;  
                 if($A.util.isEmpty(productList[i].errorMsg)) {
                
                    var OneTimeFee= productList[i].OneTimeFee;
                    var NoOfTerms= productList[i].NoOfTerms 
                    var OliId = productList[i].OliId;
                    var Quantity= productList[i].quantity;      
                    var UnitPrice= productList[i].unitPrice;
            
                    var UnitPricefloat=parseFloat(UnitPrice);
                    if(component.get("v.isCatm"))
                        UnitPrice=(isNaN(UnitPricefloat)) ? '' : UnitPricefloat.toFixed(4);
                    else
                        UnitPrice=(isNaN(UnitPricefloat)) ? '' : UnitPricefloat.toFixed(2);
                     
                    var Totalvalue=productList[i].totalValue; 
                    var denominator = Math.pow(10, 0);   
                    // santosh jha
                     //var Quantitynew = Math.round(Quantity * denominator)/denominator;
                    //var UnitPricenew= Math.round(UnitPrice * denominator)/denominator;
                     
                     var Quantitynew = (Quantity * denominator)/denominator;
                    var UnitPricenew= (UnitPrice * denominator)/denominator;
                     
                    var AvailableforSubscription=productList[i].AvailableforSubscription 
                    var ProductCatogery = productList[i].ProductCatogery;
                    var isCATMPrd = productList[i].isCATMProduct;
                    var isCATMOpp = component.get("v.isCatm");
    
                    if(!Number.isInteger(Quantity) && Quantity!=null){
                        productList[i].quantity = Math.round(Quantity);           
                    }  else if(Quantity != null && Quantity != 0 && Quantity > 0){
                        productList[i].quantity = Math.round(parseInt(Quantitynew));           
                    }
    
                    if(UnitPrice == null) { 
                        productList[i].unitPrice = Math.round(0);
                    } else if(Math.sign(UnitPrice) == -1 ){
                        productList[i].unitPrice = '';                   
                        productList[i].unitPrice = UnitPrice; 
                    } else{
                        productList[i].unitPrice = '';                      
                        productList[i].unitPrice = (UnitPrice * 1); // added by stuti for story 2279
                    }
                                     
                    Quantity= productList[i].quantity;      
                    UnitPrice=productList[i].unitPrice;  
                    Totalvalue=productList[i].totalValue;                
                    
                    if(Quantity != null && UnitPrice !=null && Totalvalue != null && Quantity != 0 && Quantity > 0 ){            
                        if(AvailableforSubscription || ProductCatogery == 'Cloud' || isCATMPrd) {                        
                            
                            if(isCATMOpp) {
                                 productList[i].totalValue = ((UnitPrice*NoOfTerms*Quantity) + (OneTimeFee*Quantity)).toFixed(2);  
                                 productList[i].totalACV = (NoOfTerms > 12 ? (UnitPrice*12*Quantity) : (UnitPrice*NoOfTerms*Quantity)).toFixed(2); 
                            } else {
                            //santosh jha
                                //productList[i].totalValue = (Math.round(UnitPrice*NoOfTerms*Quantity) + Math.round(OneTimeFee));
                            productList[i].totalValue = ((UnitPrice*NoOfTerms*Quantity) + (OneTimeFee)).toFixed(2);
                            productList[i].totalACV = (NoOfTerms > 12 ? (UnitPrice*12*Quantity) : (UnitPrice*NoOfTerms*Quantity)).toFixed(2);
                            }
                        } else{
                            //santosh jha
                            //productList[i].totalValue = Math.round(Quantity*UnitPrice);  
                             productList[i].totalValue = (Quantity*UnitPrice);
                             productList[i].totalACV = (Quantity*UnitPrice);
                        }
                        
                        if(Number.isInteger(Quantity) ) {                            
                            updateProdList.push(productList[i]);  
                            
                        }   
              
                    }
                 }
                 
             }
        }

		 if(!$A.util.isEmpty(updateProdList) || !$A.util.isEmpty(component.get('v.OppRecdId'))) {
             component.set("v.showSpinner", true); 
             var jsonString='';             
             if(!$A.util.isEmpty(updateProdList)) {
             	jsonString = JSON.stringify(updateProdList);    
             }
             
                var timer = component.get('v.timerId'); 
                clearTimeout(timer);
                 
                var timer = setTimeout(function(){                     
                   helper.UpdateLineItems(component, jsonString, oppMnths);
                     
                    clearTimeout(timer);
                    component.set('v.timerId', null);
                     
                }, 500);			
            	component.set('v.timerId', timer);
         }
        component.set("v.ProductList",productList);
       
      
   }
    
})