({
	doInit : function(component, event, helper) {
        helper.getSubsProduct(component);
        helper.getRenewalProducts(component);
        helper.getProducts(component);
        helper.isCatmOpp(component, event, helper);
        
    },
    NavigateToProduct : function(component, event, helper){
        helper.NavigateToProduct(component, event, helper);
    },
    PlusIcon : function(component, event, helper){
        
        var item= component.get("v.WrapperVar");
        debugger ;
        if(item.length>0){
             //helper.PlusIcon(component, event, helper);
             helper.PlusIconFirstPhase(component, event, helper) ;
        }
        else{  
            /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "There are no products in your favourite cart.",
                        "Category" : "Warning",
                        "isShow" : "True"
                    });
                    FloatMsgEvent.fire();*/
            //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Warning!",
       		 		"message": "There are no products in your favourite cart.",
        			"type":"warning"
   			 		});
    				toastEvent.fire();

            
        }
       
    },
    
    submitSubcriptionProds : function(component, event, helper) {       
        component.set("v.isProcessing", true);
        helper.PlusIcon(component, event, helper) ; 
        
    } ,
    
    addAllForSubscription : function(cmp, event, helper) {
        debugger ;
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
        
    } ,
    
    
    LikeIcon : function(component, event, helper){
        var item= component.get("v.WrapperVar");
        if(item.length>0){
             helper.LikeIcon(component, event, helper);
        }
        else{  
            /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "There are no products in your favourite cart.",
                        "Category" : "Warning",
                        "isShow" : "True"
                    });
                    FloatMsgEvent.fire();*/
            //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Warning!",
       		 		"message": "There are no products in your favourite cart.",
        			"type":"warning"
   			 		});
    				toastEvent.fire();

            //component.set("v.ShowNotify", "True");
        }
                        
    },
    fireCheckAllCheckboxes : function(component, event, helper){
           var FireSelectAll = event.getSource();
          
           if(FireSelectAll.get("v.value")){
             helper.fireCheckAllCheckboxes(component, event, helper);
           }else{
             helper.fireUncheckAllCheckboxes(component, event, helper);
           }        
    },
    hideMsg : function(component, event, helper){
         
        //component.set("v.ShowNotify", "False");
        
        //alert(component.get("v.ShowNotify"));
        var fltMsg = component.find( "floatMsg" );
        $A.util.addClass( fltMsg, "slds-hide" );
        component.set("v.body", "");
        
    },
     fireApplicationEvent : function(cmp, event) {
        
        var appEvent = $A.get("e.c:ceEvent");
        appEvent.setParams({
            "message" : "An application event fired me. " +
            "It all happened so fast. Now, I'm everywhere!" });
        appEvent.fire();
    },
    handleschApplicationEvent : function(cmp, event, helper) {
        
        helper.getProducts(cmp);
    },
    //Added by Saritha
    handleSearchFavourite : function(cmp, event, helper) {
       var  ProdIds = event.getParam("ProductIds");  
         var action = cmp.get("c.insertFavourite");
        action.setParams({              
        ProductId :ProdIds,
        OppId : cmp.get("v.favOppId")
        });
        action.setCallback(this, function(a) {
        if (a.getState() === "SUCCESS") {                    
                } else if (a.getState() === "ERROR") {                     
                    $A.log("Errors", a.getError());   
                }                 
            });       
    	 $A.enqueueAction(action);
         helper.getProducts(cmp);
     },

     //Added by Saritha
    handleSearchdeleteFavourite : function(cmp, event, helper) {
       var  ProdIds = event.getParam("ProductIds");  
         var action = cmp.get("c.deleteFavProduct");
        action.setParams({              
        ProductId :ProdIds            
        });
        action.setCallback(this, function(a) {
        if (a.getState() === "SUCCESS") {                    
                } else if (a.getState() === "ERROR") {                     
                    $A.log("Errors", a.getError());   
                }                 
            });       
    	 $A.enqueueAction(action);
         helper.getProducts(cmp);
     },
    UncheckAllSelectedCheckBoxes : function(Component,event, helper){
       var ConfirmMsg = event.getParam("Confirm"); 
        //alert(ConfirmMsg);
        if(ConfirmMsg === "True"){
            helper.fireUncheckAllCheckboxes(Component,event, helper);
        }
    },
    AddFavToBundle:function(component,event, helper){
        var Obj=[];
        var renewablRevnTypes = component.get("v.renewablRevnTypes");
        var item= component.get("v.WrapperVar");
        for(var i=0;i<item.length;i++){
            if(item[i].Selected){
                Obj.push({Id:item[i].Prod.Products__c,Name: item[i].Prod.Products__r.Name,SelectstatusForProduct : false,avail_Subscription:item[i].Prod.Products__r.Available_for_Subscription__c,ServiceOfferCatogery:item[i].Prod.Products__r.Service_Offer_Category__c,IsCheckBoxSelected:item[i].Selected,renewablRevnTypes:renewablRevnTypes, availAsConnectedHWM:item[i].Prod.Products__r.Available_as_Connected_HWM__c});
            }
        }
         
            
        
        if(Obj.length > 0){
            helper.createBundleComponent(component,event, helper,Obj);
        }   
        else{
            /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
              FloatMsgEvent.setParams({
                "Msg" : "No Product is Selected,Please Select any Product",
                "Category" : "Warning",
                "isShow" : "True"
                });
            FloatMsgEvent.fire();*/
            //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Warning!",
       		 		"message": "No Product is Selected,Please Select any Product",
        			"type":"warning"
   			 		});
    				toastEvent.fire();
        }
        
            
    },
    
    
    ontogglechange:function(component,event, helper) {
        var ischecked = component.find('tglbtn').get('v.checked');
        var prdtable = component.find('zui-table'); 
        var icondiv = component.find('icondiv'); 
        
        if(ischecked) {
 			$A.util.removeClass(prdtable,'slds-hide');
            $A.util.removeClass(icondiv,'slds-hide');
        } else {
            $A.util.addClass(prdtable,'slds-hide');
            $A.util.addClass(icondiv,'slds-hide');
        }
    }
})