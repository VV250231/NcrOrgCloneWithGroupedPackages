({   
    invoke : function(cmp, event, helper) { 
        var obj=JSON.parse(cmp.get("v.InvoiceDate"));
        helper.serverSideCall(cmp,'ParseDataToDisputeObj',{ TableDataJson : JSON.stringify(obj),DisputeCaseId : cmp.get("v.recordId") })
            .then(function(result){ 
                             //alert(result); 
                           //alert('>>>'+result);
              })
            
            //system.debug('Invice Data Json'+cmp.get("v.InvoiceDate"));
            
           // Get the record ID attribute
           var record = cmp.get("v.recordId");
           //alert(cmp.get("v.recordId"));
           // Get the Lightning event that opens a record in a new tab
           var redirect = $A.get("e.force:navigateToSObject");
           
           // Pass the record ID to the event
           redirect.setParams({
              "recordId": record
           });
            //alert('1');    
           // Open the record
           redirect.fire();
        //alert('2');
	}

})