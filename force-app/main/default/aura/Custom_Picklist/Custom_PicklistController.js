({
    init: function (cmp) {
        var items = [];
        var i;
        var a=cmp.get("v.options");
        for (i = 0; i < a.length; ++i) {    
            var item = {
                "label": a[i] ,
                "value": a[i]
            };
            items.push(item);
        }
        cmp.set("v.options", items);
        // "values" must be a subset of values from "options"
       
        
    },
    handleValueChange: function (cmp) {
        var items = [];
        var i;
        var a=cmp.get("v.options");
        for (i = 0; i < a.length; ++i) {    
            var item = {
                "label": a[i] ,
                "value": a[i]
            };
            items.push(item);
        }
        cmp.set("v.options", items);
        cmp.set("v.assignValue",'');
        // "values" must be a subset of values from "options"
       
        
    },
    
    handleChange: function (cmp, event) {
        // This will contain an array of the "value" attribute of the selected options
        var selectedOptionValue = event.getParam("value");        
        cmp.set("v.assignValue",selectedOptionValue.toString());
        if(cmp.get("v.notify")==true){
            var compEvent = cmp.getEvent("Event_Notify");
		compEvent.fire(); 
        }
       
    }
})