({
    /**
	 * Map of pre-chat field label to pre-chat field name (can be found in Setup)
	 */
    fieldLabelToName: {
        "First Name": "FirstName",
        "Last Name": "LastName",
        "Email": "Email",
        "Phone": "Phone",
        "Fax": "Fax",
        "Mobile": "MobilePhone",
        "Home Phone": "HomePhone",
        "Other Phone": "OtherPhone",
        "Asst. Phone": "AssistantPhone",
        "Title": "Title",
        "Lead Source": "LeadSource",
        "Assistant": "AssistantName",
        "Department": "Department",
        "Subject": "Subject",
        "Case Reason": "Reason",
        "Type": "Type",
        "Web Company": "SuppliedCompany",
        "Web Phone": "SuppliedPhone",
        "Priority": "Priority",
        "Web Name": "SuppliedName",
        "Web Email": "SuppliedEmail",
        "Company": "Company",
        "Industry": "Industry",
        "Rating": "Rating"
    },
    
    /**
	 * Event which fires the function to start a chat request (by accessing the chat API component)
	 *
	 * @param cmp - The component for this state.
	 */
    onStartButtonClick: function(cmp) {
        var prechatFieldComponents = cmp.find("prechatField");
        console.log(prechatFieldComponents);
        var fields;
        
        // Make an array of field objects for the library
        fields = this.createFieldsArray(prechatFieldComponents);
        
        // If the pre-chat fields pass validation, start a chat
        if(cmp.find("prechatAPI").validateFields(fields).valid) { 
            
            var valid = 'true';
            prechatFieldComponents.forEach(function(element) {
                if(element.get("v.label") === 'Subject' && element.get("v.value") == null) {
                    console.warn("Subject value is not passed.");
                    valid = 'false';
                }
            });
            if (valid == 'true') {
                cmp.find("prechatAPI").startChat(fields);
            }
            
        } else {
            console.warn("Prechat fields did not pass validation!");
        }
    },
    
    /**
	 * Create an array of field objects to start a chat from an array of pre-chat fields
	 * 
	 * @param fields - Array of pre-chat field Objects.
	 * @returns An array of field objects.
	 */
    createFieldsArray: function(fields) {
        if(fields.length) {
            return fields.map(function(fieldCmp) {
                return {
                    label: fieldCmp.get("v.label"),
                    value: fieldCmp.get("v.value"),
                    name: this.fieldLabelToName[fieldCmp.get("v.label")]
                };
            }.bind(this));
        } else {
            return [];
        }
    },
    
    /**
     * Create an array in the format $A.createComponents expects
     * 
     * Example:
     * [["componentType", {attributeName: "attributeValue", ...}]]
     * 
	 * @param prechatFields - Array of pre-chat field Objects.
	 * @returns Array that can be passed to $A.createComponents
     */
    getPrechatFieldAttributesArray: function(prechatFields,user) {
        
        // $A.createComponents first parameter is an array of arrays. Each array contains the type of component being created, and an Object defining the attributes.
        var prechatFieldsInfoArray = [];
        
        // For each field, prepare the type and attributes to pass to $A.createComponents
        prechatFields.forEach(function(field) { 
            var componentName = (field.type === "inputSplitName") ? "inputText" : field.type;
            var componentInfoArray = ["ui:" + componentName];
            var attributes = {
                "aura:id": "prechatField",
                required: field.required,
                label: field.label,
                disabled: (field.name === 'Email' || field.name === 'FirstName' || field.name === 'LastName')? true:field.readOnly,
                maxlength: field.maxLength,
                class: 'field.className',
                value: (field.name === 'FirstName' ?user.fristName:(field.name === 'LastName'?user.lastName:(field.name === 'Email'?user.Email:field.value)))
            };
            
            // Special handling for options for an input:select (picklist) component
            if(field.type === "inputSelect" && field.picklistOptions) attributes.options = field.picklistOptions;
            
            // Append the attributes Object containing the required attributes to render this pre-chat field
            componentInfoArray.push(attributes);
            console.log(componentInfoArray);
            // Append this componentInfoArray to the fieldAttributesArray
            prechatFieldsInfoArray.push(componentInfoArray);
            console.log(prechatFieldsInfoArray);
        });
        
        return prechatFieldsInfoArray;
    }
});