({
    /*calculatePkgNumberOfMonths : function(component,event,helper) {
           helper.calculateUnitPricevalue(component,event,helper, true);
        
        
    }, */
    doInit: function(component, event, helper) { 
        //alert();
        //alert(component.get("v.qtyTyp"));
        helper.getQuantityTypes(component, event);
        
    },
    calculateUnitPricevalue : function(component,event,helper) {

       helper.calculateUnitPricevalue(component,event,helper);
        
    },
    calculateTotalvalue : function(component, event, helper){
        var OliId = component.get("v.LineItemId"); 
        var Quantity=component.get("v.Quantity"); 
        //var UnitPrice=component.get("v.UnitPrice");
        var UnitPricefloat=parseFloat(component.get("v.UnitPrice"));
        if(component.get("v.isCatm"))
        var UnitPrice=(isNaN(UnitPricefloat)) ? '' : UnitPricefloat.toFixed(4);
        else
        var UnitPrice=(isNaN(UnitPricefloat)) ? '' : UnitPricefloat.toFixed(2);    
        var Totalvalue=component.get("v.Totalvalue");
        
        var OneTimeFee= component.get("v.OneTimeFee"); 
        var NoOfTerms= component.get("v.NoOfTerms"); 
        // var MonthlyFee= component.get("v.MonthlyFee"); 
        
        var denominator = Math.pow(10, 0); 
        //// EBA_SF-2340 santosh jha
        var Totalvaluenew =  Math.round(Totalvalue * denominator)/denominator; 
        var Quantitynew = Math.round(Quantity * denominator)/denominator;
        
        //var Totalvaluenew =  (Totalvalue * denominator)/denominator; 
        //var Quantitynew = (Quantity * denominator)/denominator;
        
        var ProductCatogery=component.get("v.ProductCatogery");
        var qtyTyp = component.get("v.qtyTyp");
        
        if(Totalvalue == null){
            
            component.set("v.Totalvalue",Math.round(0)); 
        }  
        else if(Math.sign(Totalvalue) == -1){
            component.set("v.Totalvalue",'');
            
            component.set("v.Totalvalue",Math.abs(Totalvalue));
        }
        
            else{
                
                component.set("v.Totalvalue",'');
                
                component.set("v.Totalvalue",Math.round(parseInt(Totalvalue)));
            }

        Quantity=component.get("v.Quantity");
        UnitPrice=component.get("v.UnitPrice");
        Totalvalue=component.get("v.Totalvalue");
        OneTimeFee= component.get("v.OneTimeFee"); 
        NoOfTerms= component.get("v.NoOfTerms"); 
        //var MonthlyFee= component.get("v.MonthlyFee"); 
        
        
        if(Quantity != null && UnitPrice !=null  && Totalvalue != null && Quantity != 0 && Quantity > 0){
            
           if(component.get("v.AvailableforSubscription") || ProductCatogery == 'Cloud' || component.get("v.isCatm")){
                //component.set("v.UnitPrice", Math.round((Totalvalue/Quantity)/12));
                
                //for monthly fee
               // component.set("v.UnitPrice",(parseFloat((Totalvalue-(OneTimeFee*Quantity))/(NoOfTerms*Quantity))).toFixed(2));
                // EBA_SF-2050 change done by Kapil Bhati   
                 
                if(component.get("v.isCatm"))
                component.set("v.UnitPrice",(parseFloat((Totalvalue-(OneTimeFee*Quantity))/(NoOfTerms*Quantity))).toFixed(4));
                else
                component.set("v.UnitPrice",(parseFloat((Totalvalue-(OneTimeFee))/(NoOfTerms*Quantity))).toFixed(2));
                
                //component.set("v.UnitPrice",((Totalvalue-(OneTimeFee*Quantity))/(NoOfTerms*Quantity)));
                //component.set("v.UnitPrice", Math.round(Totalvalue-(OneTimeFee*Quantity)/NoOfTerms*Quantity));
            }
            
            else{
                //for monthly fee
                //component.set("v.UnitPrice", Math.round(Totalvalue/Quantity));
                //component.set("v.UnitPrice", (Totalvalue/Quantity));
                 if(component.get("v.isCatm"))
                component.set("v.UnitPrice", (parseFloat(Totalvalue/Quantity)).toFixed(4));
                else
                component.set("v.UnitPrice", (parseFloat(Totalvalue/Quantity)).toFixed(2));
            }
            
            var OliId = component.get("v.LineItemId"); 
            var Quantity=component.get("v.Quantity"); 
            var UnitPrice=component.get("v.UnitPrice");
            var Totalvalue=component.get("v.Totalvalue");
            
            var timer = component.get('v.timer'); 
            clearTimeout(timer);
            
            var timer = setTimeout(function(){
                if(component.get("v.Quantity")){
                    //Monthly fee
                    //helper.UpdateLineItem(component, event, helper,Math.round(UnitPrice),Math.round(OneTimeFee),Math.round(NoOfTerms),Math.round(Totalvalue),Math.round(Quantity),OliId);
                    helper.UpdateLineItem(component, event, helper,parseFloat(UnitPrice).toFixed(4),Math.round(OneTimeFee),Math.round(NoOfTerms),Math.round(Totalvalue),Math.round(Quantity),OliId);
                }
                
                clearTimeout(timer);
                component.set('v.timer', null);
            }, 500);
            component.set('v.timer', timer);
            
        }    
    },
    onChildAttributeChange:function(component, event, helper){
        component.set("v.IsCheck",component.get("v.ChangeInParent"));
    },
    showPopover:function(component, event, helper){
        component.set('v.ProductPopOver','slds-show');
    },
    hidePopover:function(component, event, helper){
        component.set('v.ProductPopOver','slds-hide');
    },
    
    showPop:function(component, event, helper){
        
    },
   /* openModel: function(component, event, helper) {
       debugger ;
        //alert(component.get('v.ProductName'));
        var lineitemidforPkg=component.get("v.LineItemId");
        component.set("v.packageIdforModalPopup",lineitemidforPkg);
        component.set("v.packageNameforModalPopup",event.target.name);
        component.set("v.isOpen", true);
        //alert('lineitemidforPkg: '+lineitemidforPkg);
       // alert(event.currentTarget.name);
        //alert(component.get("v.isOpen"));
        //component.set("v.packageIdforModalPopup",event.target.title);
    }, 
    
    closeModel: function(component, event, helper) {
        component.set("v.isOpen", false);
    },*/
    
  /*  RemovePackageFromList: function(component, event, helper) {
      //var pkgId=component.get(event.target.title);
      debugger ;
      var action = component.get("c.deletePackage") ;
        action.setParams({
            packageOliId : component.get("v.LineItemId"),
            recordId : component.get("v.mainOppId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnValue = response.getReturnValue();
            if(state == 'SUCCESS') {
               // 
               //helper.removePackageHelper(component, helper) ;
               //$A.enqueueAction(component.get("v.catchParentLoadData")) ; 
               var evt = component.getEvent("refreshPackageScreen") ;
                evt.fire() ;
                $A.get("e.force:showToast").setParams({ title : "Success" , message : "Package deleted successfully", type: 'success',mode: 'pester' }).fire() ; ;
            }
        
        }) ;
        
        $A.enqueueAction(action) ;
      
    }, */
    
    //REconfigure code
    /* handleReconfigPKG: function(component, event, helper) {
    	var packageLineItemId = event.getParam("packageLineItemId");
        var packageName = event.getParam("packageName");
        component.set("v.isOpen", false);
        helper.showDynamicPackages(component, event, true, packageLineItemId, packageName);
    }, */

    handleOnChange:function(component, event, helper) {
        alert(component.get("v.qtyTyp"));
    },
    onOppTermChange : function(component, event, helper) {
        helper.validateProduct(component, event);
    }
})