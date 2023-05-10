({
	doInit: function (cmp, event, helper) {
		helper.getData(cmp);                    
    },
            
    handleSelect: function (cmp, event, helper) {
        var myName = event.getParam('name');
        console.log("You selected: " + myName);
        var selEvent =  $A.get("e.c:HRYRecordSelection");    
        selEvent.setParams({"selRecordId" : myName});
        selEvent.fire(); 
    }
})