({
	init : function(cmp, event, helper) {
        var cmap;
        var action = cmp.get("c.getConfs");
      	action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmap = response.getReturnValue();
                helper.setOppCols(cmp,cmap);
                helper.setConCols(cmp,cmap);
                helper.setARCols(cmp,cmap);
            }
        });
        $A.enqueueAction(action); 
        cmp.set('v.customActions', [
            { label: 'Custom action', name: 'custom_action' }
        ])        
        /*cmp.set('v.opptyColumns', [
            { label: 'OPPORTUNITY  Name', fieldName: 'LinkName', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_top'} },
            {label: 'Account name', fieldName: 'AccountName', type: 'text',  iconName: 'standard:account'},
            //{ label: 'Account Name', fieldName: 'AccountName', type: 'text' },
            { label: 'Stage', fieldName: 'StageName', type: 'text' },
            { label: 'Amount', fieldName: 'Amount', type: 'currency', cellAttributes: { alignment: 'left' } },
            { label: 'Close Date', fieldName: 'CloseDate', type:"date-local", typeAttributes:{month:"2-digit", day:"2-digit"} },
            { label:'Forecast Category', fieldName: 'Forecast_Category__c',type:"text" }
        ])		

        cmp.set('v.arColumns', [
            { label: 'AR Detail Name', fieldName: 'LinkName', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_top'} },
            { label: 'Customer Balance', fieldName: 'Customer_Balance__c', type:"currency" , cellAttributes: { alignment: 'left' }},
            { label: 'Risk', fieldName: 'Risk_Level__c', type: 'text' },
            { label: 'On Hold', fieldName: 'On_Hold__c', type: 'text' }
        ])	
      
       cmp.set('v.contactColumns',[
            { label: 'CONTACT NAME', fieldName: 'LinkName', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_top'} },           
            { label: 'Title', fieldName: 'Title', type: 'text' },            
            { label: 'Email', fieldName: 'Email', type: 'email'},            
            { label: 'Phone', fieldName: 'Phone', type:'phone' }]);*/
        
	    var pageReference = cmp.get("v.pageReference");
        console.log(JSON.parse(JSON.stringify(pageReference)));
        if(!$A.util.isUndefinedOrNull(pageReference) && !$A.util.isUndefinedOrNull(pageReference.state.c__showHierarchy)) {
            cmp.set("v.showHierarchy", pageReference.state.c__showHierarchy)
            cmp.set("v.recordId", pageReference.state.c__recordId)
        } else {
            helper.generateNavURL(cmp, event, helper);
        }
	},
    handleShowModal : function(component, event, helper) {
        helper.handleShowModal(component, event, helper); 
    },
     
    /*destoryCmp : function (component, event, helper) {
        alert(window.location.href);
        component.destroy();
    },*/
    
     handleRecordSelection : function(cmp, event) {
        var selRecordId = event.getParam("selRecordId");       
        console.log('selRecordId>>' + selRecordId);
        cmp.set('v.recordViewId', selRecordId);
        
    }
    
})