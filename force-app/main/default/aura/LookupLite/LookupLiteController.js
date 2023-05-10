({  
    // To prepopulate the seleted value pill if value attribute is filled
      doInit : function( cmp, event, helper ) {
      // Figure out which buttons to display
      //alert(cmp.get("v.MCNForFinalScreen"));
      //alert(cmp.get("v.CountryCodeForFinalScreen"));
      helper.getDisputeROR(cmp,event,helper);
      var availableActions = cmp.get('v.availableActions');
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
    },
     
    
    handleComponentEvent: function(component,event,helper){
       
            if(!$A.util.isEmpty(event.getParam("ContactId"))){
                helper.getSelectedRecordsHelper(component, event,event.getParam("ContactId"));
            }
            
            else{
                   if( event.getParam("Action") === 'Search Customer Contact'){
                     component.set("v.RecordData",'');
                     component.set("v.CustomerContactEmail",'');
                     component.set('v.CustomerContactRecordId','');
                     component.set("v.CustomerContactName",'');
                     component.set("v.CustomerContactPhone",'');
                }
                
                if(event.getParam("Action") === 'Search Alternate Contact'){
                    component.set("v.RecordDataAlternetContact",'');
                    component.set("v.AlternateContactEmail",'');
                    component.set('v.AlternateContactRecordId','');
                    component.set("v.AlternateContactName",'');
                    component.set("v.AlternateContactPhone",'');
                }  
            }     
    },
    
    validateButtonPressed : function(cmp,event,helper){       
        var CustomContactId = cmp.get("v.CustomerContactRecordId"); 
        var AlternateContactId = cmp.get("v.AlternateContactRecordId");
        var CustomerContactEmail  = cmp.get("v.CustomerContactEmail");
        var CustomerContactPhone = cmp.get("v.CustomerContactPhone");
        
        if((CustomContactId === '') || (typeof CustomContactId === "undefined") ){
            /*var allValid = cmp.find('field').reduce(function (validSoFar, inputCmp) {
                   inputCmp.showHelpMessageIfInvalid();
                   return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
        
                if (allValid) {
                    //alert('All form entries look valid. Ready to submit!');
                } else { */
                    //alert('Please update the invalid form entries and try again.');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info',
                        message: 'Please select customer Contact.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'info',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
           //} 
        }
        
        else if(((CustomContactId !== '') || (typeof CustomContactId !== "undefined")) && (((CustomerContactEmail === '') || (typeof CustomerContactEmail !== "undefined")) || ((CustomerContactPhone === '') || (typeof CustomerContactPhone === "undefined")) )) {
                 
            var allValid = cmp.find('field').reduce(function (validSoFar, inputCmp) {
                   inputCmp.showHelpMessageIfInvalid();
                   return validSoFar && inputCmp.get('v.validity').valid;
                  }, true);
        
                if (allValid) {
                    //alert('All form entries look valid. Ready to submit!');
                     var contactIdsArray = [];
                        var phoneArray = [];
                        var CustomerContactPhone = cmp.get("v.CustomerContactPhone");  
                        var AlternateContactPhone = cmp.get("v.AlternateContactPhone");
                        
                        if(CustomContactId){
                            contactIdsArray.push({CustomContactId});
                        }
                                                  
                        if(AlternateContactId){
                            contactIdsArray.push({AlternateContactId});
                        }
                                    
                       if(CustomerContactPhone){
                            
                            phoneArray.push({CustomerContactPhone});
                        }
                                                  
                        if(AlternateContactPhone){
                           
                            phoneArray.push({AlternateContactPhone});
                        }                        
                         
                        cmp.set("v.ContactIdS",contactIdsArray);  
                        cmp.set("v.PhoneList",phoneArray);
                         var action = cmp.get("c.UpdateContact");
                          // set param to method  
                            action.setParams({
                                'ContactIdS' : CustomContactId,
                                 'AlternateContactId' : AlternateContactId,
                                 'ContactPhone'      :  CustomerContactPhone,
                                 'AlternatePhone' :     AlternateContactPhone,
                                 'InvoiceMCN'  :    cmp.get("v.MCNForFinalScreen")          
                              });
                            
                            action.setCallback(this, function(response) {
                              
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    var storeResponse = response.getReturnValue();
                                     //alert(storeResponse.length);
                                    if(storeResponse.length == 0){ 
                                       
                                        if(cmp.get("v.DisputeRORSys") == 'CCAD') {
                                        	console.log('sending dispute to CCAD');
                                             helper.onButtonPressed(cmp,event);
                                        } else {
                                        	var navigate = cmp.get('v.navigateFlow');
                                            navigate('NEXT');
                                            cmp.set("v.ToggleSpinner",false);
                                        }
                                    }
                                    else if(storeResponse.length > 0 ){
                                        //alert('.......');
                                        cmp.set("v.ConfermationOfApocAndCustContact",storeResponse);
                                        cmp.set("v.isModalOpen",true);
                                    }
                                   
                                }
                               else if (state === "INCOMPLETE") {
                            // do something
                                }
                                else if (state === "ERROR") {
                                    var errors = response.getError();
                                    if (errors) {
                                        if (errors[0] && errors[0].message) {
                                            alert("Error message: " + 
                                                     errors[0].message);
                                        }
                                    } else {
                                       alert("Unknown error");
                                    }
                                }
                            });
                          // enqueue the Action  
                            $A.enqueueAction(action);     
                    
                } 
               else {
                    //alert('Please update the invalid form entries and try again.');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'error',
                        message: 'Customer ContactPhone and Email is Require.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
           } 
        }
       
	},
        
    onBackButtonPressed : function(cmp,event,helper) {
    	var navigate = cmp.get('v.navigateFlow');
        navigate('BACK');
        //cmp.set("v.ToggleSpinner",false);    
    },
        
    onButtonPressed:function(cmp,event,helper){
        if(cmp.get("v.DisputeRORSys") == 'CCAD') {
                                        	console.log('sending dispute to CCAD');
                                             helper.onButtonPressed(cmp,event);
                                        } else {
                                        	var navigate = cmp.get('v.navigateFlow');
                                            navigate('NEXT');
                                            cmp.set("v.ToggleSpinner",false);
                                        }
        //helper.onButtonPressed(cmp,event);
        //var navigate = cmp.get('v.navigateFlow');
        //navigate('BACK');
    },
    CloseWarningPopup :function(cmp,event,helper){
       cmp.set("v.isModalOpen",false);
    },
    ContinueToSubmit : function(cmp,event,helper) {
        /*var navigate = cmp.get('v.navigateFlow');
        navigate('NEXT');*/
        
         //EBA_SF-1541 - Send Dispute to CCAD if CCAD is ROR
         /*cmp.set("v.isModalOpen",false)
         helper.onButtonPressed(cmp,event);*/
         if(cmp.get("v.DisputeRORSys") == 'CCAD') {
             console.log('sending dispute to CCAD');
             cmp.set("v.isModalOpen",false)
             //alert('continue');
             helper.onButtonPressed(cmp,event);
         } else {
             var navigate = cmp.get('v.navigateFlow');
             navigate('NEXT');
             cmp.set("v.ToggleSpinner",false);
         }
    },
        handleDisputeAnalysteName : function(cmp,event,helper){
            var AnalysteName = event.getParam("AnalysteName");
            cmp.set("v.DisputeAnalystName",AnalysteName);
            //alert(AnalysteName);
        }    
    
})