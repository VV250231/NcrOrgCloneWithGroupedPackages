({
	handleShowModal: function(component, evt, helper) {
        var navService = component.find("navService");
        // Uses the pageReference definition in the init handler
        var pageReference = component.get("v.pageReference");
        evt.preventDefault();
        navService.navigate(pageReference);
        /*
        var modalBody;
         $A.createComponent("c:CustomerHierarchy", {recordId:component.get("v.recordId"), showHierarchy:true/*, acc:component.get("v.acc")*//*},
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   component.find('overlayLib').showCustomModal({                       
                       body: modalBody,
                       showCloseButton: true,
                       cssClass: "slds-modal_large ",
                       closeCallback: function() {                          
                       }
                   })
               }
           }); */
    },
    
    generateNavURL : function(cmp, evt, helper) {
    	 var navService = cmp.find("navService");
        var pageReference = {
            
            "type": "standard__component",
            "attributes": {
                "componentName": "c__CustomerHierarchy"    
            },    
            "state": {
                "c__showHierarchy" : "true",
                "c__recordId" :  cmp.get("v.recordId"),
                "c__Seltab" : cmp.get("v.Seltab")
            }
        };
        cmp.set("v.pageReference", pageReference);
        var defaultUrl = "#";
        navService.generateUrl(pageReference)
        .then($A.getCallback(function(url) {
            cmp.set("v.url", url ? url : defaultUrl);
        }), $A.getCallback(function(error) {
            cmp.set("v.url", defaultUrl);
        }));    
    },
    setOppCols: function(cmp,cmap) {
        var action1 = cmp.get("c.getCols");
        action1.setParams({sObjectName : 'Opportunity',fields:cmap.Opportunity.FieldsToDisplay__c,allFields:cmap.Opportunity.FieldsForViewAll__c});
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('rs'+response.getReturnValue());
               	var obj = response.getReturnValue()[0];
                //var obj ='[{ label: "Name", fieldName: "LinkName", type: "url", typeAttributes: {label: { fieldName:"Name" },target: "_top"},sortable: "true"},{label: "Account Name",type: "text",fieldName: "AccountName",sortable: "true"},{label: "Selling Stage",type: "text",fieldName: "StageName",sortable: "true"},{label: "Expected Book Date",type: "date-local",fieldName: "CloseDate",sortable: "true",typeAttributes:{month:"2-digit", day:"2-digit"}},{label: "Amount",type: "CURRENCY",fieldName: "Amount",sortable: "true",cellAttributes: { alignment: "left" }}]';
                var jsonStr = obj.replace(/(\w+:)|(\w+ :)/g, function(matchedStr) {
                    return '"' + matchedStr.substring(0, matchedStr.length - 1) + '":';
                });
               	console.log('obj'+obj);
                obj = JSON.parse(jsonStr);
                var obj1 = response.getReturnValue()[1];
                var jsonStr = obj1.replace(/(\w+:)|(\w+ :)/g, function(matchedStr) {
                    return '"' + matchedStr.substring(0, matchedStr.length - 1) + '":';
                });
                console.log('obj1'+obj1);
                obj1 = JSON.parse(jsonStr);
                cmp.set('v.opptyColumns',obj);
                cmp.set('v.opptyViewAllColumns',obj1);
                cmp.set('v.opptySortingField',cmap.Opportunity.SortingField__c);
                cmp.set('v.opptyFields',cmap.Opportunity.FieldsToDisplay__c);
                cmp.set('v.opptySortDir',cmap.Opportunity.SortedDirection__c);
                cmp.set('v.oppNumRecords',cmap.Opportunity.RecordsCount__c);
				cmp.set('v.alloppfields',cmap.Opportunity.FieldsForViewAll__c);
            }
        });
        $A.enqueueAction(action1); 
    },       
    setConCols: function(cmp,cmap) {
        var action1 = cmp.get("c.getCols");
		action1.setParams({sObjectName : 'Contact',fields:cmap.Contact.FieldsToDisplay__c,allFields:cmap.Contact.FieldsForViewAll__c});
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('rs'+response.getReturnValue());
                var obj = response.getReturnValue()[0];
                var jsonStr = obj.replace(/(\w+:)|(\w+ :)/g, function(matchedStr) {
                    return '"' + matchedStr.substring(0, matchedStr.length - 1) + '":';
                });
                console.log('obj'+obj);
                obj = JSON.parse(jsonStr);
                var obj1 = response.getReturnValue()[1];
                var jsonStr = obj1.replace(/(\w+:)|(\w+ :)/g, function(matchedStr) {
                    return '"' + matchedStr.substring(0, matchedStr.length - 1) + '":';
                });
                console.log('obj1'+obj1);
                obj1 = JSON.parse(jsonStr);
                cmp.set('v.contactColumns',obj);
                cmp.set('v.conViewAllColumns', obj1);
                cmp.set('v.conSortingField',cmap.Contact.SortingField__c);
                cmp.set('v.conFields',cmap.Contact.FieldsToDisplay__c);
                cmp.set('v.conSortDir',cmap.Contact.SortedDirection__c);
                cmp.set('v.conNumRecords',cmap.Contact.RecordsCount__c);
              	cmp.set('v.allconfields',cmap.Contact.FieldsForViewAll__c);
            }
        });
        $A.enqueueAction(action1); 
 
    },       
    setARCols: function(cmp,cmap) {
       var action1 = cmp.get("c.getCols");
		action1.setParams({sObjectName : 'Credit_Detail__c',fields:cmap.Credit_Detail_c.FieldsToDisplay__c,allFields:cmap.Credit_Detail_c.FieldsForViewAll__c});
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('rs'+response.getReturnValue());
                var obj = response.getReturnValue()[0];
                var jsonStr = obj.replace(/(\w+:)|(\w+ :)/g, function(matchedStr) {
                    return '"' + matchedStr.substring(0, matchedStr.length - 1) + '":';
                });
                console.log('obj'+obj);
                obj = JSON.parse(jsonStr);
                var obj1 = response.getReturnValue()[1];
                var jsonStr = obj1.replace(/(\w+:)|(\w+ :)/g, function(matchedStr) {
                    return '"' + matchedStr.substring(0, matchedStr.length - 1) + '":';
                });
                console.log('obj'+obj1);
                obj1 = JSON.parse(jsonStr);
                cmp.set('v.arColumns',obj);
                cmp.set('v.arViewAllColumns', obj1);
                cmp.set('v.arSortingField',cmap.Credit_Detail_c.SortingField__c);
                cmp.set('v.arFields',cmap.Credit_Detail_c.FieldsToDisplay__c);
                cmp.set('v.arSortDir',cmap.Credit_Detail_c.SortedDirection__c);
                cmp.set('v.arNumRecords',cmap.Credit_Detail_c.RecordsCount__c);
                cmp.set('v.allARfields',cmap.Credit_Detail_c.FieldsForViewAll__c);
            }
        });
        $A.enqueueAction(action1); 
 
    }       
})