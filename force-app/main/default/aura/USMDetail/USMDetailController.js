({
    handleShowModal : function (component, event, helper) { 
        var recordId = component.get("v.recordId");
        console.log('recordId>>>>>>>' + recordId);
        var modalHeader; 
        var modalBody;
        var modalFooter;
        $A.createComponents([
            ["c:usm_modalHeader",{}],
            ["c:usm_modalContent",{oppId : recordId}],
            ["c:usm_modalFooter",{}]
        ],
                            function(components, status){
                                if (status === "SUCCESS") {
                                    modalHeader = components[0];
                                    modalBody = components[1];
                                    modalFooter = components[2];
                                    component.find('overlayLib').showCustomModal({
                                        header: modalHeader,
                                        body: modalBody, 
                                        footer: modalFooter,
                                        showCloseButton: true,
                                        cssClass: "slds-modal--large",
                                        closeCallback: function() {
                                            

                                        }
                                    });
                                } 
                            }
                           );
    },
    
    init : function(component, event, helper) {
             var oppId = component.get("v.oppId");
        console.log('oppId>>>>>>>' + oppId);
        helper.checkUSMOpportunity(component, event, helper);
        helper.checkClosedOpp(component, event, helper);
        helper.checkEngagement(component, event, helper);
       },
     handleUpdateUSMComponent : function(component, event, helper) {
             var oppId = component.get("v.oppId");
        console.log('oppId>>>>>>>' + oppId);
        //helper.checkUSMOpportunity(component, event, helper);
        helper.checkEngagement(component, event, helper);
       },
    handleSpinnerEvent : function(component, event, helper) {
             console.log('handleSpinnerEvent');
        var showSpinner = event.getParam("showSpinner");
        if(showSpinner){
            component.set("v.showSpinner", true);
        }else{
            component.set("v.showSpinner", false);
        }
       },
     
       showAssociationModal: function(component, evt, helper) {var recordId = component.get("v.recordId");
        console.log('recordId>>>>>>>' + recordId);
        var modalHeader;
        var modalBody;
        var modalFooter;
        $A.createComponents([
            ["c:USMLinkModalHeader",{}],
            ["c:USMLinkModalContent",{oppId : recordId}],
            ["c:USMLinkModalFooter",{}]
        ],
                            function(components, status){
                                if (status === "SUCCESS") {
                                    modalHeader = components[0];
                                    modalBody = components[1];
                                    modalFooter = components[2];
                                    component.find('overlayLib').showCustomModal({
                                        header: modalHeader,
                                        body: modalBody, 
                                        footer: modalFooter,
                                        showCloseButton: true,
                                        closeCallback: function() {
                                            

                                        }
                                    });
                                }
                            }
                           );
                                                           }                                                
})