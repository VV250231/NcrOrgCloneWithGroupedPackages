({
    doInit : function(component, event, helper) {
        
        var recordId = component.get( "v.recordId" );
		console.log( "record id is " +recordId );
		
        //Setting columns 
        component.set('v.columns', [
            {label: 'Deal Registration #', fieldName: 'linkName', type: 'url', 
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
          //  {label: 'Deal Name', fieldName: 'Deal_Name__c', type: 'text'},
            {label: 'Account Name', fieldName: 'Account_Name_formula__c', type: 'text'},
            {label: 'Customer Name', fieldName: 'End_Customer_Company_Name__c', type: 'text'},
            {label: 'Submission Date', fieldName: 'Partner_Submission_Date__c', type: 'text'},
            {label: 'Status', fieldName: 'Status__c', type: 'text'}
        ]);
        
        var action = component.get("c.getDealRegistration");
        
       	action.setParams({
          	"recId":component.get("v.recordId")
       	});
        
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                 var records =response.getReturnValue();
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
                component.set("v.DealRegistration",records);
            }else{
                console.log("Error");
            }
        });
        $A.enqueueAction(action);
    }
})