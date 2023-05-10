({
    InitializeContactRow: function(component, event) {
        var RowItemList = component.get("v.NewContactList");
        RowItemList.push({
            'sobjectType': 'Contact',
            'FirstName': '',
            'LastName': '',
            'Phone': '',
        });
        component.set("v.NewContactList", RowItemList);
    },
    getExistingContacts : function(component){
        var action = component.get("c.getAllContact");
        action.setParams({
            "AccId":component.get("v.AccountId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ExistingcontactData", response.getReturnValue());
                component.set('v.columns', [
                   
                    {label: 'First Name', fieldName: 'FirstName', type: 'text'},
                    {label: 'Last Name',  fieldName: 'LastName', type: 'text'},
                    {label: 'Phone',  fieldName: 'Phone', type: 'text'}
                ]);
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } else{
                Console.log('Unknown Error');
            }
        });
        $A.enqueueAction(action);
    },
    getExistingSalesSurveyContacts : function(component){
        var action = component.get("c.getAllSalesSurveyContact");
        action.setParams({
            "SalesSurveyid":component.get("v.SalesSurveyid")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"  ) {
                var SSContactList = response.getReturnValue();
                var listLength = SSContactList.length;
                var objectArray = [];
                for (var i = 0; i < listLength; i++) {
                    var obj = {
                        'FirstName':SSContactList[i].First_Name__c,
                        'LastName':SSContactList[i].Last_Name__c,
                        'Phone':''
                    }
                    objectArray.push(obj);
                }
                component.set("v.FinalSSContactsListtoShow", objectArray);
            } else if (state === "ERROR") {
                console.log('Unknown Error : Record cant be fetched'); 
            }
        });
        $A.enqueueAction(action);
    },
    fillFinalContactsList : function(component){
        var objectArray = [];
        for(var obj1 of component.get("v.selectedRows")){
            var obj = {
                'FirstName':obj1.FirstName,
                'LastName':obj1.LastName,
                'Phone':obj1.Phone,
                'Id' : obj1.Id
            }
            objectArray.push(obj);
        }
        for(var obj2 of component.get("v.NewContactList")){
            if(obj2.FirstName || obj2.LastName || obj2.Phone){
                var obj = {
                'FirstName':obj2.FirstName,
                'LastName':obj2.LastName,
                'Phone':obj2.Phone,
                 'Id' : ''
            }
            objectArray.push(obj);
            }
        }
        component.set("v.FinalSSContactsList", objectArray);
    },
    removeBook: function (cmp, row) {
        var rows = cmp.get(' v.FinalSSContactsList');
        var rowIndex = rows.indexOf(row);
        rows.splice(rowIndex, 1);
        cmp.set('v.FinalSSContactsList', rows);
    },
    validateNewContact : function (component,event){
        var isValidData = true;
        for(var obj2 of component.get("v.NewContactList")){
            if(!obj2.LastName){
                component.set("v.showErrorMessage",true);
                isValidData = false;
            }
        }
        if(isValidData){
            component.set("v.showErrorMessage",false);
            this.fillFinalContactsList(component);
        }
    },
    showToast : function(title, message, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode": mode
        });
        toastEvent.fire();
    }
})