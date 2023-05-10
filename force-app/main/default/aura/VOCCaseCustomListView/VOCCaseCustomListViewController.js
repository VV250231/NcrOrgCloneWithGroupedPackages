({

	doInit : function(component, event, helper) {
        component.set("v.spinner", true);
        var action = component.get("c.getCaseList");
         action.setCallback(this,function(response){
            var state =  response.getState();
            console.log('state '+state);
            if(state = 'SUCCESS'){
                component.set("v.CaseList",response.getReturnValue());
                component.set("v.GrandCaseList",response.getReturnValue());
                //alert(JSON.stringify(component.get("v.CaseList")))
                helper.sortHelper(component, event, 'accountName');
            }
         });
        component.set("v.spinner", false);
        $A.enqueueAction(action);
    },
    searchCase : function(component, event, helper) {
        var searchString = component.get("v.SearchCase").toLowerCase();
      //alert(searchString);
        var itemList;
        var originalList;
        itemList = component.get("v.GrandCaseList");
        originalList= component.get("v.GrandCaseList"); 
        var newList = [];
        var item =0;
        var totalitem =itemList.length;
        console.log('totalitem '+totalitem);
        for ( item=0;item<totalitem;item++){
            console.log('items in search '+JSON.stringify(itemList));
            var searchName = '';
            var searchMaster = '';
            searchName = itemList[item].CaseNumber;
            searchMaster = itemList[item].Contact.Name.toLowerCase();
            if(searchName.includes(searchString) || searchMaster.includes(searchString) ){//
                newList.push(itemList[item]);
            }
            component.set('v.CaseList',newList);    
          }
        if(!searchString){
          component.set('v.CaseList',originalList);  
        }
    },
    gotoDetail : function(component, event , helper){
        console.log('gotoDetials ');
        var indexvar = event.currentTarget.id;
        console.log("indexvar:::" + indexvar);
        helper.navigateDetailPage(component,event,indexvar);
    },
    sortCaseNumber : function(component, event, helper) {
           
       component.set("v.selectedTabsoft", 'CaseNumber');
       helper.sortHelper(component, event, 'CaseNumber');
    },
    sortContactName : function(component, event, helper) {
           
       component.set("v.selectedTabsoft", 'Owner_Name__c');
       helper.sortHelper(component, event, 'Owner_Name__c');
    },
})