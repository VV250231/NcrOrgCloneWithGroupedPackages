({
    
    
    searchKeyChange: function(component, event, helper) { 
        
       var myEvent = $A.get("e.c:SearchKeyChange");
       myEvent.setParams({"searchKey": event.target.value});
        //alert(event.target.value);
       myEvent.fire();
        
    },
    removeSearch: function(component, event, helper) {
        
        document.getElementById("sk").value = "";
    }
})