({
    UpdateLineItem : function(component,helper,event,UnitPrice,OneTimeFee,NoOfTerms,TotalValue,Quantity ,OliId) {
        //alert("isPackage:"+NoOfTerms);
        if($A.util.isUndefinedOrNull(UnitPrice) || $A.util.isEmpty(UnitPrice)) {
        	UnitPrice = 0    
        }
        component.set("v.showSpinner", true);
        var action = component.get("c.UpdateProductvalue");
        //alert("helper"+component.get("v.qtyTyp"));
        action.setParams({ 
            
            UnitPrice :UnitPrice,
            TotalValue : TotalValue,
            Quantity  : Quantity,
            OneTimeFee : OneTimeFee,
            NoOfTerms : NoOfTerms,
            //NoOfLicenses : NoOfLicenses,
            //MonthlyFee : MonthlyFee,
            OliId: OliId,
            isAvialableForSubscription: component.get("v.AvailableforSubscription"),
            ProductCatogery :   component.get("v.ProductCatogery"),
            //Sites: component.get("v.Sites"),
           // isPackage: component.get("v.isPackage"),
            qtyTyp:component.get("v.qtyTyp"),
            isCATMProduct : component.get("v.isCATMProduct"), 
            isCATMOpp : component.get("v.isCatm") 
            
        });
        
        action.setCallback(this, function(response) {
            component.set("v.showSpinner", false);
            
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
                /*if(refresh){
                    var compEvent = component.getEvent("refreshPackageScreen");
                    compEvent.fire();   
                } */
                      
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
    } ,
	calculateUnitPricevalue : function(component,event,helper) {       
        helper.calculatePrice(component,event,helper);  
    },
    
    calculatePrice : function(component,event,helper) {
        
        var OneTimeFee= component.get("v.OneTimeFee"); 
        //var NoOfTerms= component.get("v.NoOfTerms") > 12 ? 12:component.get("v.NoOfTerms");
        var NoOfTerms= component.get("v.NoOfTerms");  
        //var isPackage= component.get("v.isPackage");
        var OliId = component.get("v.LineItemId"); 
        var Quantity=component.get("v.Quantity");        
        var isCATMPrd = component.get("v.isCATMProduct");
        var isCATMOpp = component.get("v.isCatm");
        var ProductName = component.get("v.ProductName");
        var hasError = false;
        
       /* if(isPackage){
            var Sites= component.get("v.Sites");
            var NoOfLicenses= component.get("v.NoOfLicenses");
        } */
        
        var UnitPrice=component.get("v.UnitPrice");
       
         
        if(!isCATMPrd) {
            if(UnitPrice != null && UnitPrice != 0 && UnitPrice > 0){
                //component.set("v.UnitPrice",Math.round(parseInt(UnitPrice)));
                var inputCmp = component.find("UnitPrice");
                inputCmp.set("v.errors", null);
            }
            
                else{
                    component.set("v.UnitPrice",Math.round(0));
                    var inputCmp = component.find("UnitPrice");
                    inputCmp.set("v.errors", [{message:"Invalid UnitPrice"}]);
                }
        }

        //var UnitPrice=component.get("v.UnitPrice");
        var UnitPricefloat=parseFloat(component.get("v.UnitPrice"));
         
         if(component.get("v.isCatm"))
        var UnitPrice=component.get("v.UnitPrice");
        else
        var UnitPrice=(isNaN(UnitPricefloat)) ? '' : UnitPricefloat.toFixed(2);
        
        var Totalvalue=component.get("v.Totalvalue");
        var denominator = Math.pow(10, 0);   
        var Quantitynew = Math.round(Quantity * denominator)/denominator;
        var UnitPricenew= Math.round(UnitPrice * denominator)/denominator;
        var AvailableforSubscription= component.get("v.AvailableforSubscription");
        var ProductCatogery=component.get("v.ProductCatogery");
        var isCATMPrd = component.get("v.isCATMProduct");

        if(!Number.isInteger(Quantity) && Quantity!=null){
            component.set("v.Quantity",Math.round(Quantity));
        }
        
        else if(Quantity != null && Quantity != 0 && Quantity > 0){
            
            component.set("v.Quantity",Math.round(parseInt(Quantitynew)));
            var inputCmp = component.find("Quantity");
            inputCmp.set("v.errors", null);
        }
        
            else{
                var inputCmp = component.find("Quantity");
                inputCmp.set("v.errors", [{message:"Invalid Quantity"}]);
            }
        
       /* if(isPackage && (NoOfLicenses == null || NoOfLicenses <=0) ){
            
            component.set("v.NoOfLicenses",Math.round(1)); 
        }
        
        // Number of terms Validation in case of products
        if(!isPackage && (NoOfTerms == null || NoOfTerms <=0) && (AvailableforSubscription || ProductCatogery=='Cloud')){
            
            var inputCmp = component.find("NoOfTerms");
            inputCmp.set("v.errors", [{message:"Invalid NoOfTerms"}]); 
        }
        
        else if(!isPackage && (NoOfTerms != null && NoOfTerms != 0 && NoOfTerms > 0) && (AvailableforSubscription || ProductCatogery=='Cloud')){
            
            component.set("v.NoOfTerms",Math.round(parseInt(NoOfTerms)));
            var inputCmp = component.find("NoOfTerms");
            //alert('inputCmp: '+inputCmp);
            inputCmp.set("v.errors", null);
        }
        
        // Number of terms Validation in case of Packages 
        if(isPackage && (NoOfTerms == null || NoOfTerms <=0)){
            
            var inputCmp = component.find("NoOfTerms");
            inputCmp.set("v.errors", [{message:"Invalid NoOfTerms"}]); 
        }
        
        else if(isPackage && (NoOfTerms != null && NoOfTerms != 0 && NoOfTerms > 0)){
            
            component.set("v.NoOfTerms",Math.round(parseInt(NoOfTerms)));
            var inputCmp = component.find("NoOfTerms");
            //alert('inputCmp: '+inputCmp);
            inputCmp.set("v.errors", null);
        }  
        
        if(isPackage && (Sites == null || Sites <=0)){
            component.set("v.Sites",Math.round(parseInt(0)));
            var inputCmp = component.find("Quantity");
            inputCmp.set("v.errors", [{message:"Invalid Sites"}]); 
        }
        
        else if(isPackage && (Sites != null && Sites != 0 && Sites > 0)){
            
            component.set("v.Sites",Math.round(parseInt(Sites)));
            var inputCmp = component.find("Quantity");
            inputCmp.set("v.errors", null);
        } */
        
        ////////////////////////////////////////////////////////////////////////////////////////////////
        /*if(!Number.isInteger(OneTimeFee) && OneTimeFee!=null && OneTimeFee > -1){
            component.set("v.OneTimeFee",Math.round(OneTimeFee));
        }

        else if(OneTimeFee != null && OneTimeFee > -1){
			    
                component.set("v.OneTimeFee",Math.round(parseInt(OneTimeFee)));
                var inputCmp = component.find("OneTimeFee");
                inputCmp.set("v.errors", null);
        }
         
        else{
            var inputCmp = component.find("OneTimeFee");
			inputCmp.set("v.errors", [{message:"Invalid OneTimeFee"}]);
        }
        
        
        
        if(!Number.isInteger(NoOfTerms) && NoOfTerms!=null){
            component.set("v.NoOfTerms",Math.round(NoOfTerms));
        }
          
        else if(NoOfTerms != null){
			    
                component.set("v.NoOfTerms",Math.round(parseInt(NoOfTerms)));
                var inputCmp = component.find("NoOfTerms");
                inputCmp.set("v.errors", null);
        }
         
        else{
            var inputCmp = component.find("NoOfTerms");
			inputCmp.set("v.errors", [{message:"Invalid # Of Terms"}]);
        } */
        ///////////////////////////////////////////////////////////////////////////////////////////////            
        
        if(UnitPrice == null){
            
            component.set("v.UnitPrice",Math.round(0)); 
        }
        
        else if(Math.sign(UnitPrice) == -1 ){
            component.set("v.UnitPrice",'');
            //component.set("v.UnitPrice",Math.abs(UnitPrice));//monthly fee changes
           
            component.set("v.UnitPrice",UnitPrice);
        }
        
        /* else if(isPackage &&  Math.sign(UnitPrice) == -1){
                component.set("v.UnitPrice",'');
                component.set("v.UnitPrice",UnitPrice);
            } */
        
            else{
                component.set("v.UnitPrice",'');
                //component.set("v.UnitPrice",Math.round(parseInt(UnitPrice))); //monthly fee
                component.set("v.UnitPrice",UnitPrice);
            }
        
        
        /*if(UnitPrice == null || UnitPrice < 0){
           
           component.set("v.Totalvalue",Number(0)); 
        }
        
        
        
        else{
            
            component.set("v.Totalvalue",'');
            component.set("v.Totalvalue",Number(UnitPrice));
        }*/
        
        Quantity=component.get("v.Quantity");
        //UnitPrice=Math.abs(component.get("v.UnitPrice"));  //monthly fee chnage
        UnitPrice=component.get("v.UnitPrice");  
        Totalvalue=component.get("v.Totalvalue");
        
         if(isCATMOpp) {
            if(!$A.util.isEmpty(OneTimeFee) && parseFloat(OneTimeFee) != 0 && !$A.util.isEmpty(UnitPrice) && parseFloat(UnitPrice) != 0) {
                component.set("v.errMsg",ProductName + ': ' + 'Either one time fee or monthly fee should be populated.');
                component.set("v.Totalvalue",'');
                hasError = true;
            } else {
                component.set("v.errMsg","");  
                hasError = false;    
            }
            if($A.util.isEmpty(NoOfTerms)){
                 component.set("v.errMsg",ProductName + ': ' + 'Either one time fee or monthly fee should be populated.');
				 hasError = true;
             }
            var prodSelTable = component.get("v.parent");                         
            var valdResp = prodSelTable.valiateCATMProducts(); // validate CATM products no of terms	
        }
        
         if(hasError == false && Quantity != null && UnitPrice !=null && Totalvalue != null && Quantity != 0 && Quantity > 0 ){
            
            //component.set("v.Totalvalue",(Quantity*UnitPrice)*12);  
            // component.set("v.Totalvalue",(Math.round(UnitPrice*NoOfTerms*Quantity) + Math.round(OneTimeFee*Quantity))); 
            // EBA_SF-2050 change done by Kapil Bhati 
             if(AvailableforSubscription || ProductCatogery == 'Cloud' || component.get("v.isCatm")){
                if(component.get("v.isCatm")){                    
                    component.set("v.Totalvalue",((UnitPrice*NoOfTerms*Quantity) + (OneTimeFee*Quantity)).toFixed(2));
                    component.set("v.TotalACVvalue",(NoOfTerms > 12 ? (UnitPrice*12*Quantity) : (UnitPrice*NoOfTerms*Quantity)).toFixed(2)); 
                }
                else{
                    component.set("v.Totalvalue",((UnitPrice*NoOfTerms*Quantity) + (OneTimeFee)).toFixed(2));  
					component.set("v.TotalACVvalue",(NoOfTerms > 12 ? (UnitPrice*12*Quantity) : (UnitPrice*NoOfTerms*Quantity)).toFixed(2));      
                }
                 
                 
            }
            else{
                component.set("v.Totalvalue", (Quantity*UnitPrice)); 
                component.set("v.TotalACVvalue", (Quantity*UnitPrice));
                
            }
          
            var timer = component.get('v.timer');
            clearTimeout(timer);
            
            var timer = setTimeout(function(){
                if(Number.isInteger(Quantity) ){
                    
                //for monthly fee
                //helper.UpdateLineItem(component, event, helper,Math.round(UnitPrice),Math.round(OneTimeFee),Math.round(NoOfTerms),Math.round(Totalvalue),Math.round(Quantity),OliId,Math.round(NoOfLicenses) ,refresh);
                   
                    helper.UpdateLineItem(component, event, helper,UnitPrice,OneTimeFee,Math.round(NoOfTerms),Math.round(Totalvalue),Math.round(Quantity),OliId);
                }
            
            /*if(isPackage && Sites != null && Sites != 0 && Sites > 0 && NoOfTerms != null && NoOfTerms != 0 && NoOfTerms > 0){
                //alert(NoOfTerms);
                helper.UpdateLineItem(component, event, helper,UnitPrice,Math.round(OneTimeFee),Math.round(NoOfTerms),Math.round(Totalvalue),Math.round(Quantity),OliId,Math.round(NoOfLicenses), refresh);
            } */ 
            
            
            
            clearTimeout(timer);
            component.set('v.timer', null);
        }, 700); 
        component.set('v.timer', timer);
    }
        
        
        
    },getQuantityTypes: function(component, event) {
        var action = component.get("c.getQtyTypes");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.fieldMap", fieldMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    validateProduct: function(component, event) {
    	var OneTimeFee= component.get("v.OneTimeFee");
        var NoOfTerms= component.get("v.NoOfTerms");  
        //var isPackage= component.get("v.isPackage");
        var OliId = component.get("v.LineItemId"); 
        var Quantity=component.get("v.Quantity");        
        var isCATMPrd = component.get("v.isCATMProduct");
        var isCATMOpp = component.get("v.isCatm");
        var ProductName = component.get("v.ProductName");
        var hasError = false;

        var UnitPrice=component.get("v.UnitPrice");
      
        var UnitPricefloat=parseFloat(component.get("v.UnitPrice"));
         
        if(component.get("v.isCatm"))
        	var UnitPrice=component.get("v.UnitPrice");
        else
        	var UnitPrice=(isNaN(UnitPricefloat)) ? '' : UnitPricefloat.toFixed(2);
        
        var Totalvalue=component.get("v.Totalvalue");
        var denominator = Math.pow(10, 0);   
        var Quantitynew = Math.round(Quantity * denominator)/denominator;
        var UnitPricenew= Math.round(UnitPrice * denominator)/denominator;
        var AvailableforSubscription= component.get("v.AvailableforSubscription");
        var ProductCatogery=component.get("v.ProductCatogery");
        var isCATMPrd = component.get("v.isCATMProduct");

        if(!Number.isInteger(Quantity) && Quantity!=null){
            component.set("v.Quantity",Math.round(Quantity));
        }
        
        else if(Quantity != null && Quantity != 0 && Quantity > 0){
            
            component.set("v.Quantity",Math.round(parseInt(Quantitynew)));
            
        }

        if(UnitPrice == null){
            
            component.set("v.UnitPrice",Math.round(0)); 
        }
        
        else if(Math.sign(UnitPrice) == -1 ){
            component.set("v.UnitPrice",'');
            //component.set("v.UnitPrice",Math.abs(UnitPrice));//monthly fee changes
           
            component.set("v.UnitPrice",UnitPrice);
        }
        
		else {
			component.set("v.UnitPrice",'');
			//component.set("v.UnitPrice",Math.round(parseInt(UnitPrice))); //monthly fee
			component.set("v.UnitPrice",UnitPrice);
		}
        
        Quantity=component.get("v.Quantity");
        //UnitPrice=Math.abs(component.get("v.UnitPrice"));  //monthly fee chnage
        UnitPrice=component.get("v.UnitPrice");  
        Totalvalue=component.get("v.Totalvalue");
        
         if(isCATMOpp) {
            if(!$A.util.isEmpty(OneTimeFee) && parseFloat(OneTimeFee) != 0 && !$A.util.isEmpty(UnitPrice) && parseFloat(UnitPrice) != 0) {
                component.set("v.errMsg",ProductName + ': ' + 'Either one time fee or monthly fee should be populated.');
                component.set("v.Totalvalue",'');
                hasError = true;
            }
             else {
                component.set("v.errMsg","");  
                hasError = false;    
            }
             if(ProductName==""){
                 hasError = false;
             }
        }
        
         if(hasError == false && Quantity != null && UnitPrice !=null && Totalvalue != null && Quantity != 0 && Quantity > 0 ){
            
            //component.set("v.Totalvalue",(Quantity*UnitPrice)*12);  
            // component.set("v.Totalvalue",(Math.round(UnitPrice*NoOfTerms*Quantity) + Math.round(OneTimeFee*Quantity))); 
            // EBA_SF-2050 change done by Kapil Bhati 
             if(AvailableforSubscription || ProductCatogery == 'Cloud' || component.get("v.isCatm")){
                if(component.get("v.isCatm")){
                    component.set("v.Totalvalue",(Math.round(UnitPrice*NoOfTerms*Quantity) + Math.round(OneTimeFee*Quantity))); 
                }
                else{
                    component.set("v.Totalvalue",(Math.round(UnitPrice*NoOfTerms*Quantity) + Math.round(OneTimeFee)));  
                }
            }
            else{
                component.set("v.Totalvalue",Math.round(Quantity*UnitPrice)); 
                component.set("v.TotalACVvalue",Math.round(Quantity*UnitPrice)); 
            }
		 }
    }
    
    
})