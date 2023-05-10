({
	fetchPicklistValues: function(component,objDetails,controllerField, dependentField) {
        // call the server side function  
        var action = component.get("c.getDependentMap");
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function 
        action.setParams({
            'objDetail' : objDetails,
            'contrfieldApiName': controllerField,
            'depfieldApiName1': dependentField,
            'depfieldApiName2': 'Features__c' 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") 
            {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue().mapClassTolstClassType;
                
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set("v.depnedentFieldMap",StoreResponse);
                component.set("v.depnedentFieldMap2",response.getReturnValue().mapClassTolstFeature);
                
                // create a empty array for store map keys(@@--->which is controller picklist values) 
                var listOfkeys = []; // for store all map keys (controller picklist values)
                var ControllerField = []; // for store controller picklist value to set on lightning:select. 
                
                // play a for loop on Return map 
                // and fill the all map key on listOfkeys variable.
                for (var singlekey in StoreResponse) 
                {
                    listOfkeys.push(singlekey);
                }
                
                //set the controller field value for lightning:select
                if (listOfkeys != undefined && listOfkeys.length > 0) 
                {
                    ControllerField.push('-- None --');
                }
                
                for (var i = 0; i < listOfkeys.length; i++) 
                {
                    ControllerField.push(listOfkeys[i]);
                }  
                // set the ControllerField variable values to country(controller picklist field)
                component.set("v.classes", ControllerField);
                
                var listCountryCode = [];
                var listPreviousServiceProvider = [];
                listCountryCode.push('-- None --');
                listPreviousServiceProvider.push('-- None --');
                
                for(var i = 0; i < response.getReturnValue().lstCountryCode.length; i++)
                {
                    listCountryCode.push(response.getReturnValue().lstCountryCode[i]);
                }
                //alert(response.getReturnValue().lstPreviousServiceProvider);
                for(var i = 0; i < response.getReturnValue().lstPreviousServiceProvider.length; i++)
                {
                    listPreviousServiceProvider.push(response.getReturnValue().lstPreviousServiceProvider[i]);
                }
                
                 component.set("v.countryCodes", listCountryCode);
                 component.set("v.previousServiceProviders", listPreviousServiceProvider);
                //component.set("v.objEquipment.Country_Code__c", "US");
                component.find("selectCountryCode").set("v.value", "US");
            }else{
                alert('Something went wrong..');
            }
        });
        $A.enqueueAction(action);
    },
    fetchDepValues: function(component, ListOfDependentFields) 
    {
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        
        if(ListOfDependentFields.length > 1 || ListOfDependentFields.length == 0)
        	dependentFields.push('-- None --');
        else
            component.set("v.objEquipment.Class_Type__c", ListOfDependentFields[0])
        
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.classTypes", dependentFields);
       
    },
    fetchDepValues2: function(component, ListOfDependentFields2) 
    {
        var dependentFields2 = [];
        if(ListOfDependentFields2.length > 1 || ListOfDependentFields2.length == 0)
        	dependentFields2.push('-- None --');
         else
            component.set("v.objEquipment.Features__c", ListOfDependentFields2[0])
        for (var i = 0; i < ListOfDependentFields2.length; i++) {
            dependentFields2.push(ListOfDependentFields2[i]);
        }
        // set the dependentFields2 variable values to store(dependent picklist field) on lightning:select
        component.set("v.features", dependentFields2);
    },
    
    isValidate : function(component, event, helper)
    {
        var numberRegex = /^\d*\.?\d*$/;
        var emailRegex = /[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,3}$/;
    	var submitREcord = true ; 
        //alert(component.find("selectCountryCode").get("v.value"));
       
        if(component.find("Class").get("v.value") == '-- None --')
        {
            //component.find("Class").set("v.errors",[{message:"Please Select Class: "}]);
            component.set("v.isClassError" , true);
            submitREcord = false ;
        }
        else{
            //component.find("Class").set("v.errors", null);
            component.set("v.isClassError" , false);
        }
        //alert('Class Type::'+!component.get("v.bDisabledDependentFld") +'**'+component.find("Class_Type").get("v.value")+'**'+component.get("v.objEquipment.Class_Type__c"));
        //alert('Feature::'+!component.get("v.bDisabledDependentFld2") +'**'+component.find("Features").get("v.value")+'**'+component.get("v.objEquipment.Features__c"));
      	if(!component.get("v.bDisabledDependentFld") && component.find("Class_Type").get("v.value") == '-- None --')
        {
            component.set("v.isClassTypeError", true)
            submitREcord = false ;
        }
        else{
            component.set("v.isClassTypeError", false)
        }
        
        if(!component.get("v.bDisabledDependentFld2") &&  component.get("v.objEquipment.Features__c") == '-- None --')
        {
           	component.set("v.isFeatureError", true)
            submitREcord = false ;
        }
        else{
            component.set("v.isFeatureError", false)
        }
        
        
        
       	if(!component.find("serialNumber").get("v.value"))
        {
            component.find("serialNumber").set("v.errors",[{message:"Please Enter Serial Number: "}]);
            submitREcord = false ;
        }
        else{
            component.find("serialNumber").set("v.errors", null);
        }
        
        
        
        if(!component.find("Customer_Name").get("v.value"))
        {
            component.find("Customer_Name").set("v.errors",[{message:"Please Enter Customer Name: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Customer_Name").set("v.errors",null);
        }
        
        if(!component.find("Installation_Address1").get("v.value"))
        {
            component.find("Installation_Address1").set("v.errors",[{message:"Please Enter Installation Address1: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Installation_Address1").set("v.errors",null);
        }
        
        if(!component.find("Installation_City").get("v.value"))
        {
            component.find("Installation_City").set("v.errors",[{message:"Please Enter Installation City: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Installation_City").set("v.errors",null);
        }
        
        //alert(component.find("selectPreviousServiceProvider").get("v.value") + '===' + component.find("Service_Assumption_Date").get("v.value"));
        if(!component.find("Installation_Date_of_New_Unit").get("v.value") && !component.find("Service_Assumption_Date").get("v.value"))
        {
            component.find("Installation_Date_of_New_Unit").set("v.errors",[{message:"Please Select \"Installation Date of New Unit\" or 'Service assumption date\": "}]);
            submitREcord = false ;
        }
        else if(component.find("Installation_Date_of_New_Unit").get("v.value") != undefined && component.find("Installation_Date_of_New_Unit").get("v.value") != '' &&
                component.find("Installation_Date_of_New_Unit").get("v.value") != null && 
                component.find("Service_Assumption_Date").get("v.value")  != undefined && component.find("Service_Assumption_Date").get("v.value")  != '' &&
               component.find("Service_Assumption_Date").get("v.value")  != null)
        {
           component.find("Installation_Date_of_New_Unit").set("v.errors",[{message:"Please Select \"Installation Date of New Unit\" or \"Service assumption date\": "}]);
           submitREcord = false ;
        }
        else
        {
            component.find("Installation_Date_of_New_Unit").set("v.errors",null);
        }
        //alert(component.find("selectPreviousServiceProvider").get("v.value")+'**'+component.get("v.objEquipment.Previous_Service_Provider__c"));
        if((component.find("Service_Assumption_Date").get("v.value") != undefined && component.find("Service_Assumption_Date").get("v.value") != '' && 
                component.find("Service_Assumption_Date").get("v.value") != null)  && component.find("selectPreviousServiceProvider").get("v.value") == '-- None --')
        {
            //alert(component.find("Service_Assumption_Date").get("v.value") + "-----" + component.get("v.dateDefaultWithTimeString"));
            if(component.find("Service_Assumption_Date").get("v.value") > component.get("v.dateDefaultWithTimeString")){
                component.set("v.isPreviousServiceProviderError" , true);
                //component.find("selectPreviousServiceProvider").set("v.errors",[{message:"Please Select Previous Service Provider: "}]);
                submitREcord = false ;
            }
        }
        else
        {
            component.set("v.isPreviousServiceProviderError" , false);
            //component.find("selectPreviousServiceProvider").set("v.errors",null);
        }
        
        if(component.find("selectPreviousServiceProvider").get("v.value") == 'Other' && !component.find("Previous_Service_Provider_If_Other").get("v.value"))
        {
            component.find("Previous_Service_Provider_If_Other").set("v.errors",[{message:"Required if selected 'Other' above: "}]);
            submitREcord = false ;
        }
        else
        {
            component.find("Previous_Service_Provider_If_Other").set("v.errors",null);
        }
        
        return submitREcord;
    }
})