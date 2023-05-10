({
	doInit : function(component, event, helper) {
		
	},
    showDetail: function(component, event, helper) {
    var targetElement = event.target;
        var trimvalue=targetElement.id;
        var str = trimvalue.substring(trimvalue.length-1, trimvalue.length);
        alert('Target>>>'+str);    
    	var arr = [];
    	arr = component.find("main").getElement().childNodes;
        
        for(var cmp in component.find("main").getElement().childNodes) {
           	          
            
            if(parseInt(arr[cmp].id) === 2)
            {
                alert('number'); 
            }

        }
        
    }
})