({
    init: function (cmp) {
        var items = [];
        var i;
        var a=cmp.get("v.options");
         if(a == undefined || a == null) {
            debugger ;
            return ;
        }
        for (i = 0; i < a.length; ++i) {    
            var item = {
                "label": a[i] ,
                "value": a[i]
            };
            items.push(item);
        }
        cmp.set("v.options", items);
        // "values" must be a subset of values from "options"
        var s=cmp.get("v.assignValue");
        if(s!=null){
            var l=s.split(";");
            if(l!=null)
            	cmp.set("v.values", l);
       }        
    },
    
    handleChange: function (cmp, event) {
        // This will contain an array of the "value" attribute of the selected options
        var selectedOptionValue = event.getParam("value");
        console.log('selectedOptionValue'+selectedOptionValue);
        var selectedOptionValue1=[] ;
        
        if(!$A.util.isEmpty(cmp.get("v.assignValue"))){
            var assigned=cmp.get("v.assignValue").split(";"); 
            console.log("assigned"+assigned);
            // identify additions or removals
            
            for(var s in selectedOptionValue){
                var found=false;
                for(var t in assigned){
                    if(selectedOptionValue[s]==assigned[t]){
                        found=true;
                        break;
                    }
                }
                if(found==false  && selectedOptionValue[s]=='Other'){
                    cmp.set("v.isOther",true);
                    //skip adding other
                }else{
                    selectedOptionValue1.push(selectedOptionValue[s]); 
                }
                
            } 
            
        }else{
            for(var s in selectedOptionValue){
                if(selectedOptionValue[s]=='Other'){
                    cmp.set("v.isOther",true);
                    //skip adding other
                }else{
                    selectedOptionValue1.push(selectedOptionValue[s]); 
                }
            } 
        }
        
        // put other logic
        //cmp.set("v.isOther",true);
        cmp.set("v.assignValue",selectedOptionValue1.toString().replace(/,/g, ';'));
        cmp.set("v.values",selectedOptionValue1);
    },     
    Cancel: function (cmp) {
        cmp.set("v.isOther",false);
            cmp.set("v.otherOption","");
        
    },
    handleOther: function (cmp, event) {
        var otherOpt='';
        // This will contain an array of the "value" attribute of the selected options
        if(!$A.util.isEmpty(cmp.get("v.otherOption"))){
            otherOpt =': '+cmp.get("v.otherOption");
            var item = {
                "label": 'Other'+otherOpt ,
                "value": 'Other'+otherOpt
            }
            var values=cmp.get("v.values");
            var opts=cmp.get("v.options");
            values.push('Other'+otherOpt);
            opts.push(item);
            cmp.set("v.options",opts);
            cmp.set("v.values",values);
            cmp.set("v.isOther",false);
            cmp.set("v.otherOption","");
            cmp.set("v.assignValue",values.toString().replace(/,/g, ';'));
        }else{
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Other Option is mandatory to fill, If you dont know then use unknown option after cancelling.",
                type:"error"
            });
            toastEvent.fire();
            
        }
        
    }
   
})