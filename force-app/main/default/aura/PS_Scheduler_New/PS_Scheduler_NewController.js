({
    doInit : function(component, event, helper) {
        helper.ReInitiate(component, event, helper);
        helper.getQuantityTypes(component, event);
        helper.isCatmOpp(component, event, helper);
    },
    selectAll: function(component, event, helper) {
        helper.selectAllHelper(component, event, helper);
    },
    toggleAdjust: function(component, event, helper) {
        console.log('inside toggleAdjust');
        //alert('hi'+component.get("v.dataList").length);
        helper.ToggleAdjustHelper(component, event, helper);
    },
    scrl: function(component, event, helper) {
        helper.scrl(component, event, helper);
    },
    scrollLeft: function(component, event, helper) {
        helper.scrollLeftHelper(component, event, helper);
    },
    scrollRight: function(component, event, helper) {
        helper.scrollRightHelper(component, event, helper);
    },
    updateDate:function(component, event, helper){
        component.set("v.EDD", event.getParam("EDSD"));
        //alert(event.getParam("EDSD"));
        if(event.getParam("EDSD")){
            //$A.get('e.force:refreshView').fire(); 
        }
        
    },
    RefreshView :function(component, event, helper){
        $A.get('e.force:refreshView').fire();  
    },
    
    redirectToOppRecord :function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.OppId"),
            "slideDevName": "related"
        });
        navEvt.fire();
    },
    showMonthModal : function(component, event, helper) {        
        if( component.get( "v.dataList").length>0){
            helper.openMonthModalHelper(component, event, helper);
        }        
    },
    closeMonthModal : function(component, event, helper) {        
        helper.closeMonthModalHelper(component, event, helper);
    },
    addMonthBtnClick : function(component,event,helper){
        helper.addMonthBtnClickHelper(component, event, helper);
    },    
    deleteProduct :function(component, event, helper) { 
        
        helper.deleteProduct(component, event, helper);
    },
    RemoveProduct :function(component, event, helper) { 
        if(component.get("v.dataList").length > 0)
            helper.RemoveProduct(component, event, helper);
        
    }
    ,
   /* RemovePackage :function(component, event, helper) { 
        console.log('*****');
        if(component.get("v.dataList").length > 0){
            helper.setPackageId(component, event, helper);
            helper.RemovePackage(component, event, helper);
        }
    }, */
   handlesInsertOLI : function(component,event,helper){       
        console.log('inside NEw PS event InsertScheduleEvent');
        debugger ;
        var action = component.get("c.InsertOpportunityLineItemPS");
        if(event.getParam("ProductIds") != ''){
            action.setParams({ "Product_Selected_From_Favorite_Section": event.getParam("ProductIds"),
                              "Oppid":component.get("v.OppId") ,
                              "isSubscriptioned" : event.getParam("hasSubscription"),
                              "servLineItemTypes" : event.getParam("ServLineItemTypeArray"),
                              "HWMMntcTypes" : event.getParam("HWMMntcTypeArray"),
                              "qtyTypes" : event.getParam("qtyTypeArray")
                             });
            action.setCallback(this, function(a) {
                if(a.getState() === "SUCCESS"){
                    debugger;
                   //Added for opp line item type change  
                    /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Product Added To Schedule Successfully.",
                        "Category" : "Success",
                        "isShow" : "True"
                    });                    
                    FloatMsgEvent.fire(); */
                    //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Success!",
       		 		"message": "Product Added To Schedule Successfully.",
        			"type":"success"
   			 		});
    				toastEvent.fire();


                    // Added for opp line item type change
                    
                    //Added By Vivek Kumar Start Here		
                    var appEvent = $A.get("e.c:ConfirmOliInsert");		
                    appEvent.setParams({"Confirm" : "True"});		
                    appEvent.fire();		
                    //Changes By Vivek Kumar End Here
                    helper.RePrepareTableHelper(component, event ,a.getReturnValue());
                } 
                else if (a.getState() === "ERROR") { 
                    var errors = action.getError();
                    var errMsg = '';
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            errMsg = errors[0].message;
                        }
                    }
                    //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Error!",
       		 		"message": errMsg,
        			"type":"error"
   			 		});
    				toastEvent.fire();
                    /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                     "Msg": errMsg,
                     "Category": "Error",
                     "isShow": "True"
                    });
                    FloatMsgEvent.fire();*/
                }
            });
            $A.enqueueAction(action);
        }
    },
    OnChangeTotalVal : function(component,event,helper){
        component.set("v.Counter",event.getSource().get("v.labelClass"));
        if(helper.ValidateTotalPrice(component,event,helper)){
            helper.OnChangeTotalVal(component,event,helper);
        } 
    },
    
    //Done by Sushant
    OnChangeNumberOfTerms : function(component,event,helper){
        component.set("v.Counter",event.getSource().get("v.labelClass"));
        debugger;
        /*if(helper.ValidateDataGeneric(component,event,helper,"NumberOfTerms","undefined")){        
            helper.OnChangeNumberOfTerms(component,event,helper);
        }*/
        helper.ValidateDataGeneric(component,event,helper,"NumberOfTerms","undefined");
        helper.OnChangeNumberOfTerms(component,event,helper);
    },
    
    //Done by Ajay
    OnChangeNumberOfTermsPkg : function(component,event,helper){
        
        component.set("v.Counter",event.getSource().get("v.labelClass"));       
        helper.ValidateDataGeneric(component,event,helper,"NumberOfTerms","undefined");
        helper.OnChangeNumberOfTermsPkg(component,event,helper);
    },
    OnChangeOTF: function(component,event,helper){
        component.set("v.Counter",event.getSource().get("v.labelClass"));
        debugger;
        
        /*if(helper.ValidateDataGeneric(component,event,helper,"OneTimeFee","undefined")){        
            helper.OnChangeOTF(component,event,helper);
        }*/
        helper.ValidateDataGeneric(component,event,helper,"OneTimeFee","undefined");       
        helper.OnChangeOTF(component,event,helper);
    },
    //done by sushant ends 
    OnChangeUnitPrice :function(component,event,helper){
        component.set("v.Counter",event.getSource().get("v.labelClass"));
        /* ********************************************
         * ****************************************** */
        var t = event.getSource().get("v.value"); 
        if(t == null)
        {
            var text = 'Please fill Price';
            component.set("v.tooltipcopydist",text);
            component.set("v.tooltipautoschedule",text);
            component.set("v.toggleautoschedule",true); 
            component.set("v.toggledistschedule",true);
            component.set("v.toggleaddmonth",true);
        }
        if(t != null)
        {
            //component.set("v.toggleaddmonth",false); 
            helper.DisableSubmit(component,event,helper);
            helper.checkschedules(component,event,helper);
        }
        /* ********************************************
         * ****************************************** */
        debugger ;
        console.log('inside controller on change unitprice ');
        // not holding calulation
        helper.OnChangeUnitPrice(component,event,helper);
        if(helper.ValidateDataGeneric(component,event,helper,"ProductUnit","undefined")){ 
            //if(helper.ValidateUnitPrice(component,event,helper)){
            console.log('unit price validated :going to call OnChangeUnitPrice');
            
            helper.EnableSubmit(component,event,helper);
        }
        
    }, 
    OnChangeQuantity : function(component,event,helper){ 
        component.set("v.Counter",event.getSource().get("v.labelClass"));
        debugger;
        /* ********************************************
         * ****************************************** */
        var t = event.getSource().get("v.value"); 
        if(t == null){
            
            var text = 'Please fill quantity';
            component.set("v.tooltipcopydist",text);
            component.set("v.tooltipautoschedule",text);
            component.set("v.toggleautoschedule",true); 
            component.set("v.toggleaddmonth",true); 
        }
        if(t != null)
        {
            component.set("v.toggleaddmonth",false); 
            helper.checkschedules(component,event,helper);
        }
        /* ********************************************
         * ****************************************** */
        //Changing top make calculation even if error
        /* if(helper.ValidateDataGenericPositive(component,event,helper,"ProductQty","undefined")){
        //if(helper.ValidateData(component,event,helper)){
            helper.OnChangeQuantity(component,event,helper);
        }*/
        helper.ValidateDataGenericPositive(component,event,helper,"ProductQty","undefined");
        helper.OnChangeQuantity(component,event,helper);
    },
    OnChangeSchQty : function(component,event,helper){
        //alert("hi");
        component.set("v.Counter",event.getSource().get("v.labelClass"));
        if( helper.ValidateSchQty( component,event,helper )){
            helper.OnChangeSchQty(component,event,helper);          
        }
        
    },
    CaptureIndex : function(component,event,helper){
        
        var idx = event.currentTarget;
        var idd=idx.dataset.ids;
        console.log('idd'+idd);
        //  alert('index'+idd);
        component.set("v.Counter",idd);
        console.log('idds'+component.get("v.Counter"));
        helper.EnableSubmit(component,event,helper);
    },
    deleteMonthBtnClick : function(component,event,helper){
        helper.deleteMonthBtnClickHelper(component,event,helper);    
    },
    Submit : function(component,event,helper){ 
        if(component.get("v.dataList").length >0){
            helper.Submit(component,event,helper);
        }
    },
    OpenCopyPasteWindow:function(component,event,helper){         
        helper.OpenCopyPasteWindowHelper(component,event,helper);
    },
    CancelCopyWindow:function(component,event,helper){
        helper.CancelCopyWindowHelper(component,event,helper); 
    },
    pasteData:function(component,event,helper){        
        helper.pasteDatahelper(component,event,helper);
    },
    selectAllcheckBox:function(component,event,helper){
        helper.selectAllcheckBoxhelper(component,event,helper);
        helper.updateButtonhelper(component,event,helper); 
    },
    distributeData:function(component,event,helper){
        
        helper.distributeDatahelper(component,event,helper);
    },
    toggleReadOnlyView:function(component,event,helper){
        helper.toggleReadOnlyViewhelper(component,event,helper);
    },
    toggleEditView:function(component,event,helper){
        helper.toggleEditViewhelper(component,event,helper);
    },
    AdjustQuantity:function(component,event,helper){
        
        helper.AdjustQuantityHelper(component,event,helper);
    },
    closeAutoSchedule:function(component,event,helper){
        helper.closeAutoSchedule(component,event,helper);
    },
    recalculateAutoSchdeuleAfterConfirmation:function(component,event,helper){
        helper.recalculateAutoSchdeuleAfterConfirmation(component,event,helper);
    },
    /* Below code for acheive error pop-notification
    */
    SG_Errorpop : function(component, event, helper) {
       // var m = '/resource/1523608417000/pshelp_p1';
       // component.set("v.helpvideourl",m);
        var $j = jQuery.noConflict();
        var t = $j(location).attr('host');
        var id=component.get("v.OppId");
        $j(window).on("beforeunload", function() {
            return "Changes you made, may not be saved!";
        }); 
        
        
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
    
    
    hidehelpwindow : function(component, event, helper){
        component.set("v.togglehelp","false");
    },
    assigntooltips : function(component, event, helper){
        helper.checkschedules( component, event, helper );
    },
    showhelpwindow : function(component, event, helper){
        component.set("v.togglehelp","true");
        
    },
    addMoreYear : function(component, event, helper){        
        helper.addMoreYearHelper( component, event, helper );
    },
    swaphelpvideo : function(component, event, helper){
        var t =   event.currentTarget.id ;
        if(t=='pshelp_p1'){ component.set("v.togglevideop1",true);component.set("v.togglevideop2",false);component.set("v.togglevideop3",false);component.set("v.togglevideop4",false);}
        if(t=='pshelp_p2'){ component.set("v.togglevideop1",false);component.set("v.togglevideop2",true);component.set("v.togglevideop3",false);component.set("v.togglevideop4",false);}
        if(t=='pshelp_p3'){ component.set("v.togglevideop1",false);component.set("v.togglevideop2",false);component.set("v.togglevideop3",true);component.set("v.togglevideop4",false);}
        if(t=='pshelp_p4'){ component.set("v.togglevideop1",false);component.set("v.togglevideop2",false);component.set("v.togglevideop3",false);component.set("v.togglevideop4",true);}
    },
    updateButton : function(component, event, helper){
        helper.updateButtonhelper(component,event,helper);        
        
    },
    CreateDynamicSearch:function(component, event, helper){
        $A.createComponent(
            "c:GlobalSearch",
            {
                
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
    /************************************************************/
    CreateDynamic_Search:function(component, event, helper){ 
       
        if(component.get("v.toggleWelcomeModal") == true) { 
            component.set("v.toggleWelcomeModal" , false)  ;
        }
        $A.createComponent(
            "c:PS_Search_new",
            {
                "OpportunityId":component.get("v.OppId"),
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
    } ,
      
    closeWelcomeModal : function(component, event, helper)  {
        component.set("v.toggleWelcomeModal" , false) ;
    },
   /* productselected :function(component, event, helper){
        component.set("v.isPackageTab",false);
    },
    packageselected :function(component, event, helper){
        component.set("v.isPackageTab",true);
    }, 
    showDetail :function(component, event, helper){
        helper.setPackageId(component, event, helper);
        component.set("v.isSubPkg", false);
        component.set("v.isOpen",true);
        
    },
    showSubPkgDetail :function(component, event, helper){
        helper.setPackageId(component, event, helper);
        component.set("v.isSubPkg", true);
        component.set("v.isOpen",true);
        
    }, */
    closeModel: function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    
    /************************ Add Subscription - start **********************************/
    /*handleReconfigPKG: function(component, event, helper) {
        var packageLineItemId = event.getParam("packageLineItemId");
        var packageName = event.getParam("packageName");
        component.set("v.isOpen", false);
        helper.showDynamicPackages(component, event, true, packageLineItemId, packageName);
    },
    refreshPageWithPackage: function(component, event, helper) {
        component.set("v.toggleSpinner",true);
        if(!$A.util.isEmpty(event.getParam("oldOppLineItemId"))){
            component.set("v.pkgid",event.getParam("oldOppLineItemId"));
            helper.RemovePackageHelper(component, event, helper);
            helper.RemovePackage(component, event, helper);
            //Delete existing package
        }  
        // add logic to fetch package OLI        
        // add package to list of view
        var action = component.get("c.fetchAddedPackageDetails");
        action.setParams({ 
            "Oppid":component.get("v.recordId") ,
            "masterOLI" : event.getParam("oppLineItemId")
        });
        action.setCallback(this, function(a) {
            if(a.getState() === "SUCCESS"){     
                component.set("v.packageCount", component.get("v.packageCount")+1);
                /*if(!$A.util.isEmpty(event.getParam("oldOppLineItemId"))){}
                    
                
                helper.RePrepareTableHelper(component, event ,a.getReturnValue());                  
                component.set("v.toggleSpinner",false);
            }
        });
        $A.enqueueAction(action)
    },*/
    handleSetActiveSections: function (component,event) {
        var activesec=['Package','Non Cloud Products','Cloud Products'];
        if (!component.get("v.isReadOnlyAllsectionsOpen")){
            component.set("v.isReadOnlyAllsectionsOpen",true);
            component.set("v.openSectionButton",'Close All Sections');
            component.find("accordion").set('v.activeSectionName',activesec);
        }      
        else{
            component.set("v.isReadOnlyAllsectionsOpen",false); 
            component.set("v.openSectionButton",'Open All Sections');
            component.find("accordion").set('v.activeSectionName',''); 
        }
        
 	},
    reInit:function(component,event,helper){
        component.set("v.toggleSpinner","true");
        component.set("v.isCatm" , false) ;       
        helper.ReInitiate(component, event, helper); 
        helper.isCatmOpp(component, event, helper);
    },
    onQtyTypChange:function(component,event,helper){
        helper.EnableSubmit(component,event,helper); 
    },
    oppMonthChange :  function(component, event, helper) { 
        //helper.vldCATMOneTimevsMonhtlyFee(component, event, helper);
   		helper.OnOppMonthChange(component,event,helper);   
    }
 })