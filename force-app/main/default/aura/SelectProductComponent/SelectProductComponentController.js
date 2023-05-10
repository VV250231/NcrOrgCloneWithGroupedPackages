({
    doInit : function(component, event, helper) {
       
         helper.ReInitiate(component, event);
        
        /*$A.createComponent(
            "c:CustomAccordian",
            {
                "modalMessage": "findableAuraId",
                "onclick": component.getReference("c.handlePress"),
                "OppId":component.get("v.recordId") 

                //"HeaderValue": component.get("v.HeaderValue")
                
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
        );*/
    }, 
    
    handlerDeleteSelectedProduct : function(component, event, helper){
    	
        var BundleProductsToDelete =component.get("v.BundleProductsToDelete");
        BundleProductsToDelete[event.getParam("ProductIdstoDelete")] = event.getParam("Status");
        component.set("v.BundleProductsToDelete",BundleProductsToDelete);
        
	},
    DeleteSelectedProduct:function(component,event,helper){
	    var myMap = component.get("v.BundleProductsToDelete");
        
        var Obj=[];
                for (var key in myMap){
                    
                    if(myMap[key] == true && myMap[key] != ''){
                        Obj.push({Id:key,Status:myMap[key]});
                    }
  
                }
        
        var myMap_Product = component.get("v.BundleProductsToItemToSchedule");
        var Obj_Product=[];
        
        for (var key in myMap_Product){
                    
                    if(myMap_Product[key] == true && myMap_Product[key] != ''){
                        Obj_Product.push({Id:key,Status:myMap_Product[key]});
                    }
  
                }
        
        if(Obj.length > 0 || Obj_Product.length > 0){
            var action = component.get("c.DeleteProductFromBundle");    
            action.setParams({  
            MapForDelete : JSON.stringify(Obj),
            MapOfBundleProductForDelete :   JSON.stringify(Obj_Product) 
            });
               
            action.setCallback(this, function(a) {
                if (a.getState() === "SUCCESS") {            
                    $A.get("e.force:refreshView").fire();
                }    
            });
            $A.enqueueAction(action);
        }
        else{
            
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Please select Bundle or Product to Delete.",
                "Category" : "Warning",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();
        }
        
    },
    
    saveBundle:function(component,event,helper){
      
        var bndl = component.get("v.NewBundleName"); 
        if(bndl == null || bndl== ''){
            
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Please Enter Name",
                "Category" : "Warning",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();
        }
        else{
            component.set("v.ToggleSpinner",'show');
        var action = component.get("c.InsertBundle");    
        action.setParams({  
        BundleName : component.get("v.NewBundleName")
    	});
           
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {            
				var togglerefresh=component.get("v.RefreshBundleParentComponent");
                component.set("v.RefreshBundleParentComponent",!togglerefresh);
                component.set("v.ToggleSpinner",'hide');
                            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                            FloatMsgEvent.setParams({
                                "Msg" : "Bundle Added Succesfully.",
                                "Category" : "Success",
                                "isShow" : "True"
                            });
                            FloatMsgEvent.fire();
                            } 
            component.set("v.NewBundleName",'');
    	});
    	$A.enqueueAction(action);
            
        
        }
        
        
        
    },
    CreateNewBundle:function(component,event,helper){
       var ToggleNewBundle= component.get("v.ToggleNewBundle");
        component.set("v.ToggleNewBundle", ToggleNewBundle == 'hide' ? 'show' : 'hide'); 
    },
    handlerAddBundleProduct_To_ItemToSchedule:function(component,event,helper){
        var BundleProductsToItemToSchedule =component.get("v.BundleProductsToItemToSchedule");
        BundleProductsToItemToSchedule[event.getParam("Bindle_Id")] = event.getParam("Bundle_Status");
        component.set("v.BundleProductsToItemToSchedule",BundleProductsToItemToSchedule);
    },
    AddBundleProductItemToSchedule:function(component,event,helper){
        //alert(component.get("v.oppo.Id"));
        var myMap = component.get("v.BundleProductsToItemToSchedule");
        var Obj=[];
                for (var key in myMap){
                    
                    if(myMap[key] == true && myMap[key] != ''){
                        Obj.push({Id:key,Status:myMap[key]});
                        
                    }
  
                }
        if(Obj.length > 0)
        {
        var action = component.get("c.AddBundleProductToItemToSchedule");    
        action.setParams({  
        MapForInsert : JSON.stringify(Obj),
        OpportunityId:  component.get("v.oppo.Id")  
    	});
           
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {            
				$A.get("e.force:refreshView").fire();
            }    
    	});
    	$A.enqueueAction(action);
        }
        else{
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Please select Bundle to add",
                "Category" : "Warning",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();
        }
        
    },
    showhelpwindow : function(component, event, helper){
        component.set("v.togglehelp","true");
        
    },
    hidehelpwindow : function(component, event, helper){
        component.set("v.togglehelp","false");
    },
    swaphelpvideo : function(component, event, helper){
        var t =   event.currentTarget.id ;
        if(t=='pshelp_p1'){ component.set("v.togglevideop1",true);component.set("v.togglevideop2",false);component.set("v.togglevideop3",false);component.set("v.togglevideop4",false);}
        if(t=='pshelp_p2'){ component.set("v.togglevideop1",false);component.set("v.togglevideop2",true);component.set("v.togglevideop3",false);component.set("v.togglevideop4",false);}
        if(t=='pshelp_p3'){ component.set("v.togglevideop1",false);component.set("v.togglevideop2",false);component.set("v.togglevideop3",true);component.set("v.togglevideop4",false);}
        if(t=='pshelp_p4'){ component.set("v.togglevideop1",false);component.set("v.togglevideop2",false);component.set("v.togglevideop3",false);component.set("v.togglevideop4",true);}
    },
    SentForSchedule:function(component, event, helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:PS_Scheduler_New",
           
            componentAttributes: {
            recordId: component.get("v.OppId"),
            ScreenName: 'PS'
            }
        });
        evt.fire();
    },
    CreateDynamicSearch:function(component, event, helper){  
        
         $A.createComponent(
            "c:PS_Search_new", 
            {
                "OpportunityId":component.get("v.OppId"),
                "TriggerScreenName":'ADD PRODUCT',
                "isCommunityUser":component.get("v.isCommunityUser"),
                "IPTPartnerCommunityUrl":component.get("v.IPTPartnerCommunityUrl")
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
    },
    ItemToSchedulePrds:function(cmp,event,helper){
         var value = event.getParam("ScheduleItemProducts");
         cmp.set("v.ScheduleProducts",value);
       
    },
    handleMyFavouriteCmpEvent:function(cmp,event,helper){
        
        
    },
    handleValueChange:function(cmp,event,helper){
        //alert('Pankaj Kashyap');
        cmp.set("v.showErrorIndicator",true);
    },
    navigatetoopportunity : function(component, event, helper){
        var t = component.get("v.ToggleSubmit");
        
        
        if(t)
        {	
            var oppid = component.get("v.OppId");
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": oppid
            });
            navEvt.fire();
        }
        else
        {
            var $j = jQuery.noConflict();
            var id=component.get("v.OppId");
            $j(location).attr('href','/'+id);
        }
    },
    reInit:function(cmp,event,helper){
        
         helper.ReInitiate(cmp,event);
    }
})