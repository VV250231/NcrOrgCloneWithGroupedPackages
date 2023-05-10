({
    InitializeCustGoalRow: function(component, event) {
            var RowItemList = component.get("v.NewCustomerGoalList");
            RowItemList.push({
                'sobjectType': 'SalesSurveyCustomerGoal__c',
                'Name': '',
                'Details__c': '',
                'Aligned_Solution__c': '',
            });
            component.set("v.NewCustomerGoalList", RowItemList);
        },
      fillFinalCustGoalList : function(component){
          var objectArray = [];
           for(var obj2 of component.get("v.NewCustomerGoalList")){
            if(obj2.Name || obj2.Details__c || obj2.Aligned_Solution__c){
                var obj = {
                'Name':obj2.Name,
                'Details__c':obj2.Details__c,
                'Aligned_Solution__c':obj2.Aligned_Solution__c,
                 'id' : ''
            }
            objectArray.push(obj);
            }
        }
        component.set("v.FinalSSCustGoal", objectArray);
      },
    getCustomerGoals : function(component, event, helper){
        var action = component.get("c.getAllSalesSurveyCustomerGoals");
        action.setParams({
            "SalesSurveyid" : component.get("v.SalesSurveyid")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var SSCustGoal = response.getReturnValue();
                var listlenght = SSCustGoal.length;
                var objarray =  [];
                for (var i = 0; i<listlenght; i++){
                    var obj = {
                        'Name':SSCustGoal[i].Name,
                        'Details__c':SSCustGoal[i].Details__c,
                        'Aligned_Solution__c':SSCustGoal[i].Aligned_Solution__c
                     }
                    objarray.push(obj);                  
                 }
                component.set("v.FinalSSCustomerGoaltoShow",objarray);
                    
                }
                else if (state === "ERROR") {
                    console.log('Unknown Error : Record cant be fetched');
                }
            
        });
        $A.enqueueAction(action);
        
    },
    validateNewCustGoal : function (component,event){
        var isValidData = true;
        for(var obj2 of component.get("v.NewCustomerGoalList")){
            if(!obj2.LastName){
                component.set("v.showErrorMessage",true);
                isValidData = false;
            }
        }
        if(isValidData){
            component.set("v.showErrorMessage",false);
            this.FinalSSCustGoal(component);
        }
    },
    showToast : function (title,message,type,mode){
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