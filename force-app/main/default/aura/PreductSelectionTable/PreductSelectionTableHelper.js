({
	helperMethod : function(component, event, helper) {
		 var action = component.get("c.getOpportunity");
        action.setParams({ 
        recordId :component.get("v.passId")
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
			
            if(state === "SUCCESS") {  
                var oppRecord = response.getReturnValue();
                 
                if(!$A.util.isUndefinedOrNull(oppRecord)) {
                    component.set("v.isCatm",oppRecord.CATM_Record__c);
                	component.set("v.oppMonths",oppRecord.Contract_Term_Mths__c);
                }
                
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
        
                
	},
    loadData:function(component, event, helper) {
        //var inputsel = component.get("v.ProductList"); 
        //alert('Load Product line items') ;
        //debugger ;
       
        var opts=[];
        var pkgopts=[];
        var scheduledMasterLineIds=[];
        var packageCounter=0;
		var action = component.get("c.getProductList");
        action.setParams({ 
            
        recordId :component.get("v.passId") 
            
        });
        //alert('in parent'+component.get("v.passId"));
        action.setCallback(this, function(response) {
            var state = response.getState();
			
            if(state === "SUCCESS") {  
                console.log('Test JSon'+JSON.stringify(response.getReturnValue()));
                for(var i=0;i<response.getReturnValue().length;i++){ 
                   //alert('isCompanion'+response.getReturnValue()[i].isCompanion);
                   // alert('OneTimeFee'+response.getReturnValue()[i].OneTimeFee);
                    //console.log('inside loaddata HasQuantitySchedule'+response.getReturnValue()[i].HasQuantitySchedule);
                    
       
                    //MasterLineIds which are scheduled
                    /*if(response.getReturnValue()[i].HasQuantitySchedule ){  
                        scheduledMasterLineIds.push(response.getReturnValue()[i].OliId); 
                    } */
                    
                     //if(!response.getReturnValue()[i].HasQuantitySchedule && !response.getReturnValue()[i].isPackage){
                    if(!response.getReturnValue()[i].HasQuantitySchedule){
                        //console.log('@@'+response.getReturnValue()[i].OliId);
                    var denominator = Math.pow(10, 0);
                    if(response.getReturnValue()[i].AvailableforSubscription || response.getReturnValue()[i].ProductCatogery == 'Cloud' || response.getReturnValue()[i].isCATMProduct)   
                    var newunitprice=response.getReturnValue()[i].MonthlyFee;
                    else
                    var newunitprice=response.getReturnValue()[i].unitPrice;
                    var newtotalvalue=response.getReturnValue()[i].totalValue;
                    var totalACVValue = response.getReturnValue()[i].totalACVValue;
                    //console.log('@@newtotalvalue'+response.getReturnValue()[i].newtotalvalue);   
            		//var rounded_number = response.getReturnValue()[i].AvailableforSubscription ? (Math.round(newunitprice * denominator)/denominator)/12 : Math.round(newunitprice * denominator)/denominator ;
                      // start ---EBA_SF-2340  TCV Remove Round off// 
                        if(component.get("v.isCatm"))
                      {
                        var rounded_number2= (newtotalvalue * denominator)/denominator;
                        var rounded_number = response.getReturnValue()[i].AvailableforSubscription ? newunitprice : (response.getReturnValue()[i].ProductCatogery == 'Cloud') ? newunitprice : newunitprice;
                        totalACVValue = (totalACVValue * denominator)/denominator;    
                      }
                     
                       else
                       {
                        var rounded_number2= (newtotalvalue * denominator)/denominator;
                        var rounded_number = response.getReturnValue()[i].AvailableforSubscription ? ((newunitprice * denominator)/denominator) : (response.getReturnValue()[i].ProductCatogery == 'Cloud') ? ((newunitprice * denominator)/denominator) : (newunitprice * denominator)/denominator;
         				totalACVValue = (totalACVValue * denominator)/denominator;
                       }
                       // End ---EBA_SF-2340  TCV Remove Round off//  
                        opts.push({ProductCatogery:response.getReturnValue()[i].ProductCatogery,AvailableforSubscription:response.getReturnValue()[i].AvailableforSubscription,MandateSubscriptioned:component.get("v.subsOnlyProdNames").includes(response.getReturnValue()[i].ProductName)== true || component.get("v.subsOnlyRevenueTypes").includes(response.getReturnValue()[i].productObj.Product2.Service_Offer_Category__c)== true ? true:false,value: response.getReturnValue()[i].value,quantity: response.getReturnValue()[i].quantity,unitPrice: rounded_number,totalValue: rounded_number2.toFixed(2),ProductName:response.getReturnValue()[i].ProductName,ProductId:response.getReturnValue()[i].ProductId,OliId:response.getReturnValue()[i].OliId,Eroorvalue:response.getReturnValue()[i].Eroorvalue,
                                   OneTimeFee:response.getReturnValue()[i].OneTimeFee,NoOfTerms:response.getReturnValue()[i].NoOfTerms,MonthlyFee:response.getReturnValue()[i].MonthlyFee, qtyTyp:response.getReturnValue()[i].qtyTyp, isCATMProduct : response.getReturnValue()[i].isCATMProduct, errorMsg:"", totalACV: totalACVValue.toFixed(2)
                             //,NoOfLicenses:response.getReturnValue()[i].NoOfLicenses//source:response.getReturnValue()[i].source,ListPrice:response.getReturnValue()[i].ListPrice,Discount:response.getReturnValue()[i].Discount,PackageID:response.getReturnValue()[i].PackageID,
                                 //PackageName:response.getReturnValue()[i].PackageName,SubPackageID:response.getReturnValue()[i].SubPackageID,SubPackageName:response.getReturnValue()[i].SubPackageName,MasterLineId:response.getReturnValue()[i].MasterLineId,Sites:response.getReturnValue()[i].Sites,isPackage:response.getReturnValue()[i].isPackage,isCompanion:response.getReturnValue()[i].isCompanion
                                });
                    }
                    
                  // Package details
                   // alert('scheduledMasterLineIds: '+scheduledMasterLineIds);
                 /*if(!response.getReturnValue()[i].HasQuantitySchedule && response.getReturnValue()[i].isPackage &&
                        !scheduledMasterLineIds.includes(response.getReturnValue()[i].MasterLineId)
                   ){
                        //console.log('@@'+response.getReturnValue()[i].OliId);
                    var denominator = Math.pow(10, 0);
                    if(response.getReturnValue()[i].AvailableforSubscription || response.getReturnValue()[i].ProductCatogery == 'Cloud')   
                    var newunitprice=response.getReturnValue()[i].MonthlyFee;
                    else
                    var newunitprice=response.getReturnValue()[i].unitPrice;
                    var newtotalvalue=response.getReturnValue()[i].totalValue;
                    console.log('@@newtotalvalue'+response.getReturnValue()[i].newtotalvalue);   
            		//var rounded_number = response.getReturnValue()[i].AvailableforSubscription ? (Math.round(newunitprice * denominator)/denominator)/12 : Math.round(newunitprice * denominator)/denominator ;
                      var rounded_number = response.getReturnValue()[i].AvailableforSubscription ? (Math.round(newunitprice * denominator)/denominator) : (response.getReturnValue()[i].ProductCatogery == 'Cloud') ? (Math.round(newunitprice * denominator)/denominator) : Math.round(newunitprice * denominator)/denominator;
                      var rounded_number2= Math.round(newtotalvalue * denominator)/denominator;
                      pkgopts.push({ProductCatogery:response.getReturnValue()[i].ProductCatogery,AvailableforSubscription:response.getReturnValue()[i].AvailableforSubscription,value: response.getReturnValue()[i].value,quantity: response.getReturnValue()[i].quantity,unitPrice: rounded_number,totalValue: rounded_number2,ProductName:response.getReturnValue()[i].ProductName,ProductId:response.getReturnValue()[i].ProductId,OliId:response.getReturnValue()[i].OliId,Eroorvalue:response.getReturnValue()[i].Eroorvalue,
                              OneTimeFee:response.getReturnValue()[i].OneTimeFee,NoOfTerms:response.getReturnValue()[i].NoOfTerms,MonthlyFee:response.getReturnValue()[i].MonthlyFee,NoOfLicenses:response.getReturnValue()[i].NoOfLicenses,source:response.getReturnValue()[i].source,ListPrice:response.getReturnValue()[i].ListPrice,Discount:response.getReturnValue()[i].Discount,PackageID:response.getReturnValue()[i].PackageID,PackageName:response.getReturnValue()[i].PackageName,
                              SubPackageID:response.getReturnValue()[i].SubPackageID,SubPackageName:response.getReturnValue()[i].SubPackageName,MasterLineId:response.getReturnValue()[i].MasterLineId,Sites:response.getReturnValue()[i].Sites,isPackage:response.getReturnValue()[i].isPackage,isCompanion:response.getReturnValue()[i].isCompanion
                                });
                    } */ 
                }
                 //console.log('inside loaddata'+JSON.stringify(opts));
                // console.log('inside pkgopts'+JSON.stringify(pkgopts));
                  component.set("v.ProductList", opts); 
                  //component.set("v.PackageList", pkgopts);  
                 
                
                /*for(var i=0;i< pkgopts.length;i++){ 
                    if(pkgopts[i].isPackage === true && pkgopts[i].MasterLineId ==null ){  
                        packageCounter=packageCounter+1; 
                    } 
                } */
                //component.set("v.numberOfPackages", packageCounter); 
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
             component.set("v.isCompLoaded", true); 
             
        });     
        $A.enqueueAction(action); 
    },
    totalvaluecalculate:function(component, event, helper){
        
        var testJson = '{"data": [';
        var inputsel = component.get("v.ProductList");
        for(var i=0;i< inputsel.length;i++){ 

        	testJson += '{';
            testJson += '"value"'+ ":" +false+","; 
            testJson += '"quantity"' + ":"+inputsel[i].quantity+",";
                testJson += '"unitPrice"' + ":"+inputsel[i].unitPrice+",";
                testJson += '"totalValue"' + ":"+inputsel[i].totalValue+",";
                testJson += '"ProductName"' + ":"+ '"' +encodeURI(inputsel[i].ProductName)+'"' + ","
                testJson += '"OliId"' + ":"+ '"' +inputsel[i].OliId+'"' + ","
                testJson += '"ProductId"' + ":" + '"' + inputsel[i].ProductId + '"';
            if( i == inputsel.length - 1){ 
                testJson += '}';
            }else{
            	testJson += '},';    
            }
        }
        testJson += ']}'; 	

         var action = component.get("c.ClientToServerProductSynk");
        action.setParams({ 
            
        		   ProductFinalArray :testJson
        }); 
        
        action.setCallback(this, function(a) {
            	
                if (a.getState() === "SUCCESS") {  
                    
                    
                    var delay = 1000;

                     window.setTimeout(
                     $A.getCallback(function() {
                     if (component.isValid()) {
                         helper.loadData(component, event , helper); 
                      }}),
                      delay);
                    
                    
                    
                    
                   
                    
                } else if (a.getState() === "ERROR") { 
                       
                        alert('Error'+a.getError()[0].message); 
                }
             //component.set("v.ShowHideSpinner",false);    
            });
        	$A.enqueueAction(action);
    },
    SelectforDelete:function(component, event, helper){
        component.set("v.ShowHideSpinner",true); 
        component.set("v.hasError",false); // added for bug 2279 by Stuti
        var opts=[];
        var inputsel = component.get("v.ProductList");
        
         if(inputsel.length<=0){     
             /*   var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
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
        
        for(var i=0;i< inputsel.length;i++){ 
            if(inputsel[i].value === true){  
                               
                            opts.push(inputsel[i].OliId);
                         } 
        }
      
        var action = component.get("c.SelectforDel");
        
        action.setParams({ 
            
        SelectedProductid :opts 
            
        });
        
        action.setCallback(this, function(a) {
           
        if (a.getState() === "SUCCESS") {
            //Added for exception handeling
            if(!a.getReturnValue()){
                   var allChk = component.find("TheCheckBox");
                    allChk.set("v.value",false);
                	
                    helper.loadData(component, event , helper); 
                    if(opts.length>=1 && inputsel.length>=1){
                          /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                            FloatMsgEvent.setParams({
                                "Msg" : "Products Deleted Succesfully From Item to schedule.",
                                "Category" : "Success",
                                "isShow" : "True"
                            });
                            FloatMsgEvent.fire(); */
                        var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success!!",
                    message: 'Products Deleted Successfully From Item to schedule.',
                    type: "Success"
                });
                toastEvent.fire();
                     }
                    else{
                        if(opts.length<=1 && inputsel.length>=1){
                     /*   var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                            FloatMsgEvent.setParams({
                                "Msg" : "No Product is Selected, Please Select the Product to Delete.",
                                "Category" : "Warning",
                                "isShow" : "True"
                            });
                            FloatMsgEvent.fire();*/
                            var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type":"Warning",
                            "title": "warning!",
                            "message": "No Product is Selected, Please Select the Product to Delete."
                        });
                        toastEvent.fire();
                        }
                    }  
                }
                else{
                    /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
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
            //End of exception handeling
              component.set("v.ToggleDeleteAddProduct",false); 
        } 
            else if(a.getState() === "ERROR") {
                 
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
                component.set("v.ToggleDeleteAddProduct",false);
            }
            else
            {
                alert('Error'+a.getReturnValue());
            }  
         component.set("v.ShowHideSpinner",false);    
    }); 
    $A.enqueueAction(action);
    },
    SentForSchedule:function(component, event, helper){
      var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:PS_Scheduler_New",
           
            componentAttributes: {
  			recordId: component.get("v.passId"),
            ScreenName: 'PS'
    	    }
        });
        evt.fire();  
       
     /*if (sforce.one) {
  		 sforce.one.navigateToURL('/apex/SchedulerScreen?id='+component.get("v.passId"));
		} 
        
        var testJson = '{"data": [';
        var inputsel = component.get("v.ProductList");
        for(var i=0;i< inputsel.length;i++){ 

        	testJson += '{';
            testJson += '"value"'+ ":" +false+","; 
            testJson += '"quantity"' + ":"+inputsel[i].quantity+",";
                testJson += '"unitPrice"' + ":"+inputsel[i].unitPrice+",";
                testJson += '"totalValue"' + ":"+inputsel[i].totalValue+",";
                testJson += '"ProductName"' + ":"+ '"' +inputsel[i].ProductName+'"' + ","
                testJson += '"OliId"' + ":"+ '"' +inputsel[i].OliId+'"' + ","
                testJson += '"ProductId"' + ":" + '"' + inputsel[i].ProductId + '"';
            if( i == inputsel.length - 1){ 
                testJson += '}';
            }else{
            	testJson += '},';    
            }
        	} 
        testJson += ']}';
        var appEvent = $A.get("e.c:schedulerEvent");
            appEvent.setParams({
                "jsonString" : testJson 
            });
            appEvent.fire();  */
    },
    
      updateOliTerm : function(component,helper,event,OliId,NoOfTerms){
        var action = component.get("c.updateLineItemTerm");
        action.setParams({ 
            OliId:component.get("v.OliId"),
            NoOfTerms:component.get("v.NoOfTerms")
        });
        action.setCallback(this, function(response) {

            var state = response.getState();
            if (state === "SUCCESS") {
                //alert();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Product Updated',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
             else if (state === "INCOMPLETE") {
                
            }
                else if (state === "ERROR") {
                   
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                            FloatMsgEvent.setParams({
                                "Msg": errors[0].message,
                                "Category": "Error",
                                "isShow": "True"
                            });
                            FloatMsgEvent.fire();
                        }
                    } else {
                        alert("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    UpdateLineItems :  function(component, jsonString, oppMnths) {
        //component.set("v.showSpinner", true); 
        component.find("NoOfTerms").set("v.disabled", true);
        
        var action = component.get("c.saveBulkProduct");     
        action.setParams({    
            oppId : component.get('v.OppRecdId'),            
            isCATMOpp : component.get('v.isCatm'),
            ctrMonths: oppMnths,
            JsonString :jsonString
        });        
        
        action.setCallback(this, function(response) {
            component.set("v.showSpinner", false);
            component.find("NoOfTerms").set("v.disabled", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                 var toastEvent = $A.get("e.force:showToast");
                
                if(!$A.util.isEmpty(component.get("v.ProductList"))) {               
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Opportunity and Products updated successfully',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                } else {
                	toastEvent.setParams({
                        title : 'Success',
                        message: 'Opportunity updated successfully',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });    
                }
                toastEvent.fire();
            }
            else if (state === "INCOMPLETE") {
                
            }
                else if (state === "ERROR") {
                   
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                            FloatMsgEvent.setParams({
                                "Msg": errors[0].message,
                                "Category": "Error",
                                "isShow": "True"
                            });
                            FloatMsgEvent.fire();
                        }
                    } else {
                        alert("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
  
    
    
     validateProductLines : function(component, event, helper) {    
    	var productList = component.get("v.ProductList");
        var showError = false;
        console.log(productList);
        if(!$A.util.isEmpty(productList)) {           
             for(var i=0;i< productList.length;i++) {
                 if(!$A.util.isEmpty(productList[i].errorMsg)) {
                    showError = true;
                 	break;   
                 }
             }
        }
        component.set('v.hasError', false); 
        component.set('v.hasError', showError); 
    }
    
    
})