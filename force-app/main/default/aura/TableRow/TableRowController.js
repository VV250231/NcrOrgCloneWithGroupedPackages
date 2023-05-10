({
	HandelQuantity : function(component, event, helper) {
        
        var Quantity=component.get("v.Quantity"); 
        var UnitPrice=component.get("v.UnitPrice");
        var denominator = Math.pow(10, 0);   
        var Quantitynew = Math.round(Quantity * denominator)/denominator;
        var UnitPricenew= Math.round(UnitPrice * denominator)/denominator;
        
        if(!Number.isInteger(Quantity) && Quantity!=null){
            component.set("v.Quantity",Math.round(Quantity));
        }
        
        else if(Quantity != null && Quantity != 0 && Quantity > 0){
			    
                component.set("v.Quantity",Math.round(parseInt(Quantitynew)));
                var inputCmp = component.find("Quantity");
                component.set("v.class",'');
        }
        
        else{
            //var inputCmp = component.find("Quantity");
		    //inputCmp.set("v.errors", [{message:"invalid Input"}]);
            component.set("v.class",'error');
            
        }
        
        if(UnitPrice == null){
           
           component.set("v.UnitPrice",Math.round(0)); 
        }
        
        else if(Math.sign(UnitPrice) == -1){
            component.set("v.UnitPrice",'');
            
            component.set("v.UnitPrice",Math.abs(UnitPrice));
        }
        
        else{
            
            component.set("v.UnitPrice",'');
            if(component.get("v.isCatm")) // EBA_SF-2209
            component.set("v.UnitPrice",UnitPrice);
            else
            component.set("v.UnitPrice",Math.round(parseInt(UnitPrice))); 
            
        }
        
        
        if(Quantity != null && UnitPrice !=null && Quantity != 0 && Quantity > 0){
             
            //alert(Quantity);
            var timer = component.get('v.timer');
            clearTimeout(timer);
            
            var timer = setTimeout(function(){
                if(Number.isInteger(Quantity)){
                   //alert(); 
                   //helper.UpdateLineItem(component, event, helper,Math.round(UnitPrice),Math.round(Totalvalue),Math.round(Quantity),OliId);
                   helper.HandelQuantity(component, event, helper); 
                }
    
                clearTimeout(timer);
                component.set('v.timer', null);
            }, 800);
            component.set('v.timer', timer);
            }
        
    },
       
    onIsSelectedAttributeChange:function(component, event, helper){
       //alert(component.get("v.TempSelectAll")); 
       component.set("v.IsSelected",component.get("v.TempSelectAll")); 
    }
    
})