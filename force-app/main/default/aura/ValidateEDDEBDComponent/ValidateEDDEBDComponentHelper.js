({
    loadEBDEDD: function(component, event, helper) { 
        
        var action = component.get("c.getOppDetail");   
        debugger ;
        action.setParams({   
            "Oppid" : component.get("v.passId")  
        });    
        
        action.setCallback(this, function(a) { 
            if (a.getState() === "SUCCESS") {
                 component.set("v.dateToday" ,a.getReturnValue().DateTodayVal ) ;
                //Added for greyout
                if(a.getReturnValue().mpOppDetail['Non Admin']){
                   component.set("v.opp", a.getReturnValue().mpOppDetail['Non Admin']);
                   $A.get("e.c:EDDEvent").setParams({
                     "EDSD" : component.get("v.opp.Expected_Delivery_Date__c")
                   }).fire();
                    if(a.getReturnValue().mpOppDetail['Non Admin'].IsClosed === false){
                        this.validateDates(component);
                    } 
                } 
                if(a.getReturnValue().mpOppDetail['Other Admin']){
                   component.set("v.opp", a.getReturnValue().mpOppDetail['Other Admin']);
                   $A.get("e.c:EDDEvent").setParams({
                     "EDSD" : component.get("v.opp.Expected_Delivery_Date__c")
                   }).fire();
                      this.validateDates(component);
                } 
                if(a.getReturnValue().mpOppDetail['Admin']){
                   component.set("v.opp", a.getReturnValue().mpOppDetail['Admin']);
                   $A.get("e.c:EDDEvent").setParams({
                     "EDSD" : component.get("v.opp.Expected_Delivery_Date__c")
                   }).fire();
                   if(a.getReturnValue().mpOppDetail['Admin'].IsClosed === false ){
                        this.validateDates(component);
                   }
                }  
                //Changes done as part of EBA_SF-2428
                if(a.getReturnValue().mpOppDetail['skip EDB admins']){
                   component.set("v.opp", a.getReturnValue().mpOppDetail['skip EDB admins']);
                   $A.get("e.c:EDDEvent").setParams({
                     "EDSD" : component.get("v.opp.Expected_Delivery_Date__c")
                   }).fire();   
                } 
              //End of Greyout
             
            }
            else if (a.getState() === "ERROR") { 
                $A.log("Errors", a.getError());
            }
        }); 
        
        $A.enqueueAction(action); 
    },
    validateDates: function(component, event, helper){
        debugger ;
        //component.get("v.opp.CloseDate"));
       /* var actionDate = component.get("c.getLatestDate") ;
        actionDate.setCallback(this, function(response) { */
            //component.set("v.dateToday" , response.getReturnValue() ) ;
            
             if(component.get("v.opp.CloseDate") < component.get("v.dateToday") ){
            
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Expected Book Date should be in future. Please correct the dates first.",
                "Category" : "Warning",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();        
            component.set("v.showModalA",'Y');
        } 
        //@Ajay EDSD changes
       /* else if((component.get("v.opp.Expected_Delivery_Date__c") <= component.get("v.opp.CloseDate")) || (!component.get("v.opp.Expected_Delivery_Date__c"))){
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Expected Delivery Date should not be less than Expected Book Date. Please correct the dates first.",
                "Category" : "Warning",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();        
            component.set("v.showModalA",'Y');
        }*/
            else{
                       component.set("v.showModalA",'N');
                        var action = component.get("c.ValidateScheduleDate");   
                        action.setParams({   
                            "OpportunityId" : component.get("v.passId")  
                        });
                        action.setCallback(this, function(a) { 
                            if (a.getState() === "SUCCESS") {
                               
                                if((a.getReturnValue()) && component.get("v.showModalA") === "N"){
                            if(component.get("v.callFromSelectPage") == false){
                                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                                FloatMsgEvent.setParams({
                                    "Msg" : "There are schedule dates on this page that are before Expected Delivery Start Date.",
                                    "Category" : "Warning",
                                    "isShow" : "True"
                                });
                                FloatMsgEvent.fire(); 
                            }    
                            
                        }
                        
                    }
                    else if (a.getState() === "ERROR") { 
                        
                    }
                }); 
                $A.enqueueAction(action); 
            }

            
            
            
       // }) ;
       // $A.enqueueAction(actionDate) ;
                 
            
    },
    updateDate:function(component, event, helper)
    { 
        debugger ;
        this.validateDates(component);
        if(component.get("v.showModalA")=='N'){
            
            $A.get("e.c:EDDEvent").setParams({
                "EDSD" : component.get("v.opp.Expected_Delivery_Date__c")
            }).fire();

            var action = component.get("c.saveEbdEdd");
            component.set("v.showModalA",'N');
            var EbdEdd = component.get("v.opp");
            
            action.setParams({"oppo": EbdEdd});        
            
            action.setCallback(this,function(a){     
                if(a.getState() === "SUCCESS"){
                    if(!a.getReturnValue()){
                        var appEvent = $A.get("e.c:PS_RefreshView");
                         appEvent.fire();
                     //Refresh PreviouslyScheduled component - Nagendra
                      var RefreshSchedules = $A.get("e.c:EventRefreshPreviousScheduledFromValidateDate");
                          RefreshSchedules.fire();
                    //End of refresh PreviouslyScheduled component
                     var action = component.get("c.ValidateScheduleDate");   
                        action.setParams({   
                            "OpportunityId" : component.get("v.passId")  
                        });
                        action.setCallback(this, function(a) { 
                            if (a.getState() === "SUCCESS") {
                                if((a.getReturnValue()) && component.get("v.showModalA") === "N"){
                                if(component.get("v.callFromSelectPage") == false){
                                    var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                                    FloatMsgEvent.setParams({
                                        "Msg" : "There are schedule dates on this page that are before Expected Delivery Start Date. Click “SUBMIT” to highlight such schedules",
                                        "Category" : "Warning",
                                        "isShow" : "True"
                                    });
                                    FloatMsgEvent.fire(); 
                                }
                            }
                            
                        }
                        else if (a.getState() === "ERROR") { 
                            alert("Error in val EDDEBD");
                        }
                    }); 
                    $A.enqueueAction(action); 
                    } 
                    else{
                       var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                         FloatMsgEvent.setParams({
                            "Msg" : a.getReturnValue(),
                            "Category" : "Error",
                            "isShow" : "True"
                         });
                         FloatMsgEvent.fire(); 
                    } 
                }
                
                else if (a.getState() === "ERROR") { 
                    $A.log("Errors", a.getError());                
                }     
                
            } );
            $A.enqueueAction(action); 
            
            document.getElementById("backGroundSectionId").style.display = "None";
            document.getElementById("newId").style.display = "None";
        }
        
        
    } 
    
})