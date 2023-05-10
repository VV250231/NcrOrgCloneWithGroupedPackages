({
	getData : function(component) {
		 var action = component.get("c.pramataGetData");  
        //alert(component.get("v.recordId"));
     	action.setParams({  
       		RecID: component.get("v.recordId")  
     	});  
     	action.setCallback(this, function(a) {  
            var permData = a.getReturnValue();
              for(var i in permData){
                if(permData[i].Pramata_Agg_End_Date__c){
                	var frmdateval=$A.localizationService.formatDate(permData[i].Pramata_Agg_End_Date__c, "MM/DD/YYYY");
                	permData[i].aggEndDate = frmdateval;
                }
                if(permData[i].Pramata_Agg_Start_Date__c){
                	var frmdateval=$A.localizationService.formatDate(permData[i].Pramata_Agg_Start_Date__c, "MM/DD/YYYY");
                	permData[i].aggStartDate = frmdateval;
                }
                if(permData[i].Pramata_Effective_Date__c){
                	var frmdateval=$A.localizationService.formatDate(permData[i].Pramata_Effective_Date__c, "MM/DD/YYYY");
                	permData[i].aggEffectiveDate = frmdateval;
                }
                 if(permData[i].Pramata_Last_Update_Date_Time__c){
                	var frmdateval=$A.localizationService.formatDate(permData[i].Pramata_Last_Update_Date_Time__c, "MM/DD/YYYY");
                	permData[i].aggLastUpdate = frmdateval;
                }
            } 
            component.set("v.approvalList",permData);
             //alert(JSON.stringify(a.getReturnValue()));
           
       	});  
     	$A.enqueueAction(action);
	}
})