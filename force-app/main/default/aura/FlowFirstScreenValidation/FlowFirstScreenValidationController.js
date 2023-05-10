({
    init: function(cmp, event, helper) {
        //alert('....'+sessionStorage.getItem('UserSelctedReason'));
        var action = cmp.get("c.getERPSysType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue()=="ERP OnPremise"){
                    cmp.set("v.IsERPCloud",false);
                    if(!cmp.get("v.CountryCodeOption")){
                        helper.getCountryCodeList(cmp);
                        //alert(cmp.get("v.UserSelctedReasonForNextScreen"));
                    }
                    
                    else{
                        var CountryCodeOption = JSON.parse(cmp.get("v.CountryCodeOption"));
                        console.log(CountryCodeOption);
                        var OptionNew = [];
                        for(var i=0; i<CountryCodeOption.length; i++){
                            OptionNew.push({'label':CountryCodeOption[i].label,'value':CountryCodeOption[i].value});
                        }
                        cmp.set("v.options",OptionNew);
                        var availableActions = cmp.get('v.availableActions');
                        cmp.set('v.isValidated',true);   
                        for (var i = 0; i < availableActions.length; i++) {
                            if (availableActions[i] == "PAUSE") {
                                cmp.set("v.canPause", true);
                            } else if (availableActions[i] == "BACK") {
                                cmp.set("v.canBack", true);
                            } else if (availableActions[i] == "NEXT") {
                                cmp.set("v.canNext", true);
                            } else if (availableActions[i] == "FINISH") {
                                cmp.set("v.canFinish", true);
                            }
                        }      
                    }
                }else if(response.getReturnValue()=="ERP Cloud"){
                    //alert(JSON.stringify(cmp.get("v.selItem")));
                    //alert(JSON.stringify(cmp.get("v.accSelItem")));
                    if(cmp.get("v.accMCN")!==undefined){
                    	//cmp.set("v.selItem",{"attributes":{"type":"Account","url":"/services/data/v54.0/sobjects/Account/0017000000Yn8SHAAZ"},"Name":"AT&T GLOBAL NETWORK SERVICES SWEDEN AB","Master_Customer_Number__c":'+cmp.get("v.accMCN")+',"Id":"0017000000Yn8SHAAZ"});
						cmp.set("v.selItem",{"attributes":{"type":"Account","url":"/services/data/v54.0/sobjects/Account/"+cmp.get("v.accId")},"Name":cmp.get("v.accName"),"Master_Customer_Number__c":cmp.get("v.accMCN"),"Id":cmp.get("v.accId")});
                        cmp.set("v.accSelItem",{"val":null,"text":cmp.get("v.accName"),"subtxt":cmp.get("v.accMCN"),"ObjRecord":{"attributes":{"type":"Account","url":"/services/data/v54.0/sobjects/Account/"+cmp.get("v.accId")},"Name":cmp.get("v.accName"),"Master_Customer_Number__c":cmp.get("v.accMCN"),"Id":cmp.get("v.accId")},"objName":"Account"});
                    }
                        cmp.set("v.IsERPCloud",true); 
                    var availableActions = cmp.get('v.availableActions');
                  cmp.set('v.isValidated',true);   
                  for (var i = 0; i < availableActions.length; i++) {
                     if (availableActions[i] == "PAUSE") {
                        cmp.set("v.canPause", true);
                     } else if (availableActions[i] == "BACK") {
                        cmp.set("v.canBack", true);
                     } else if (availableActions[i] == "NEXT") {
                        cmp.set("v.canNext", true);
                     } else if (availableActions[i] == "FINISH") {
                        cmp.set("v.canFinish", true);
                     }
                  }   
                }
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
                 
	},
     handleChange: function (cmp, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
        //alert("Option selected with value: '" + selectedOptionValue + "'");
        cmp.set("v.SelectedCountryCode",selectedOptionValue);
    },
    validateInvoice:function(cmp,event,helper){        
       
        //alert(JSON.stringify(countrycode));
        cmp.set("v.toggleSpinner",true);
        
        //alert(userInput); 
        var userInput = cmp.get('v.textAttribute');
        var patt = new RegExp('^[a-zA-Z\r\n0-9  ,\-~%&$]*$');
         var countrycode;
         var cc = cmp.get("v.SelectedCountryCode");
        if(cc===undefined){
            console.log(cmp.get("v.accSelItem"));
            if(cmp.get("v.accSelItem")!=null){
                countrycode = cmp.get("v.accSelItem").ObjRecord.Master_Customer_Number__c;
                cmp.set('v.accMCN',countrycode);
                cmp.set('v.accId',cmp.get("v.accSelItem").ObjRecord.Id);
                cmp.set('v.accName',cmp.get("v.accSelItem").ObjRecord.Name);                
            }
            else{
                    cmp.set("v.ifInvalidMsg",'Please complete a require fields');
            cmp.set("v.severity",'error');
            cmp.set("v.isValidated",false);
            cmp.set("v.toggleSpinner",false);
                }
        }else if(cc!==undefined){
            countrycode = cc;
        }
        if(typeof countrycode == "undefined"){
            //alert('please complete a require fields');
            cmp.set("v.ifInvalidMsg",'Please complete a require fields');
            cmp.set("v.severity",'error');
            cmp.set("v.isValidated",false);
            cmp.set("v.toggleSpinner",false);
        } 
        
        else if(typeof userInput == "undefined" || userInput == ''){
            //alert('please complete a require fields');
            cmp.set("v.ifInvalidMsg",'Please complete a require fields');
            cmp.set("v.severity",'error');
            cmp.set("v.isValidated",false);
            cmp.set("v.toggleSpinner",false);
        }
       
       
        
        else if(userInput && userInput.length>0) { 
             if(!patt.test(userInput)){
          
               cmp.set("v.ifInvalidMsg",'Enter valid invoice seprated by comma/space/New Line');
               cmp.set("v.severity",'error');
               cmp.set("v.isValidated",false);
               cmp.set("v.toggleSpinner",false); 
            }
             
            
            else{
                		cmp.set("v.nextdisabled",true);
                         helper.serverSideCall(cmp,'validateUserEnteredInvoices',{ userInputData : userInput })
                        .then(function(result){                          
                             //alert(result); 
                            if(result.length>0){
                                if(result.length > 1000){
                                   var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        title : 'Maximum Invoice Limit Hit', 
                                        message:'Number of invoices entered are ' + result.length + ', You can not create dispute when invoice entered are more than 1000',
                                        duration:'3000',
                                        key: 'info_alt',
                                        type: 'error',
                                        mode: 'pester'
                                    });
                                    toastEvent.fire();
                                    cmp.set("v.toggleSpinner",false);
                                }
                                else{
                                     cmp.set("v.toggleSpinner",false);
                                     return helper.serverSideCall(cmp,'authanticateUserEnteredInvoice',{ InvoiceList : result ,CountryCode : countrycode});
                                }
                            }
                            else{
                                cmp.set("v.ifInvalidMsg",'Enter valid invoice seprated by comma/space/New Line');
                                cmp.set("v.severity",'error');
                                cmp.set("v.isValidated",false);
                                cmp.set("v.toggleSpinner",false);
                            }

                        }).then(function(result){ 
                               
                               if(typeof result != "undefined"){                                    
                                     if(result.ErrorCode === 500){
                                           cmp.set("v.ifInvalidMsg",result.displayMsg); 
                                           cmp.set("v.severity",'error');
                                           cmp.set("v.isValidated",false);
                                           //cmp.set("v.DisputeDetails",result.DisputeDetails);
                                           cmp.set("v.toggleSpinner",false);
                               			}
                       
                               		 else if(result.ErrorCode === 400){
                                           cmp.set("v.ifInvalidMsg",result.displayMsg); 
                                           cmp.set("v.severity",'error');
                                           cmp.set("v.isValidated",false);
                                         cmp.set("v.toggleSpinner",false);
                                       }
                       					 else if(result.ErrorCode === 1001 || result.ErrorCode === 900){
                                           cmp.set("v.ifInvalidMsg",result.displayMsg); 
                                           cmp.set("v.severity",'error');
                                           cmp.set("v.isValidated",false);
                                         cmp.set("v.toggleSpinner",false);
                                       }
                                       else if(result.ErrorCode === 600){
                                           cmp.set("v.ifInvalidMsg",result.displayMsg); 
                                           cmp.set("v.severity",'error');
                                           cmp.set("v.isValidated",false);
                                           cmp.set("v.toggleSpinner",false);
                                       }	
                       
                                       else if(result.ErrorCode === 800){
                                           cmp.set("v.ifInvalidMsg",result.displayMsg); 
                                           cmp.set("v.severity",'error');
                                           cmp.set("v.isValidated",false);
                                           cmp.set("v.toggleSpinner",false);
                                       }	
                               
                                      else if(result.ErrorCode === 700){
                                           console.log(result);
                                           cmp.set("v.ifInvalidMsg",result.displayMsg); 
                                           cmp.set("v.severity",'error');
                                           cmp.set("v.isValidated",true);
                                           cmp.set("v.TableDate",JSON.stringify(result.InvoiceDetail));
                                           cmp.set("v.InvoiceMCN",result.InvoiceDetail[0].MCN);
                                           //cmp.set("v.InvoiceCountryCode",result.InvoiceDetail[0].CountryCode);
                                           cmp.set("v.InvoiceCurrencyCode",result.InvoiceDetail[0].CurrencyCode);
                                           cmp.set("v.toggleSpinner",false);
                                           helper.onButtonPressed(cmp,event);
                                      }
                                   
                                      else{
                                           cmp.set("v.ifInvalidMsg",JSON.stringify(result)); 
                                           cmp.set("v.severity",'error');
                                           cmp.set("v.isValidated",false);
                                           cmp.set("v.toggleSpinner",false); 
                                      }
                                   cmp.set("v.DisputeDetailtoDisplay",result);
                                   
                                   
                               } 
                        })
                        // optionally more chainings her*/   
            }
         
        }   
    },
    openDetailComponent:function(cmp,event,helper){
      cmp.set("v.isModalOpen",true);
        
    },
   
    closeModel: function(component, event, helper) {
      // Set isModalOpen attribute to false  
      component.set("v.isModalOpen", false);

   },
     toggleLookup : function(component, event, helper) {
       
        if(component.get("v.toggleLookup") == true){
             component.set("v.toggleLookup",false);
             component.set("v.accSelItem",null);
            component.set("v.selItem",null);
             component.set("v.isNext",true);
            component.set("v.isSave",true);
            //component.set("v.sub_fld_text",null);
        }else{
        	component.set("v.toggleLookup",true);
            component.set("v.accSelItem",null);
            component.set("v.selItem",null);
            component.set("v.isNext",true);
           component.set("v.isSave",true);
        }	
	},
    handleValueChange: function(component, event, helper) {
        component.set("v.isValidated",true);
         component.set("v.nextdisabled",false);
    }
     
})