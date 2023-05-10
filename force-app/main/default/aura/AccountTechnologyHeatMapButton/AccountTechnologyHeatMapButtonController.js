({
	showHeatMapModal : function(component, event, helper) {
		var recordId = component.get("v.recordId");
        console.log('recordId>>>>>>>' + recordId);
        var modalHeader; 
        var modalBody;
        var modalFooter;
        $A.createComponents([
            
            ["c:AccountHeatmap",{recordId : recordId}]
            
        ],
                            function(components, status){
                                if (status === "SUCCESS") {
                                   
                                    modalBody = components[0];
                                    
                                    component.find('overlayLib').showCustomModal({
                                        /*header: modalHeader,*/
                                        body: modalBody, 
                                       /* footer: modalFooter, */
                                        showCloseButton: true,
                                        cssClass: "slds-modal_large slds-scrollable",
                                        closeCallback: function() {
                                            

                                        }
                                    });
                                }
                            }
                           );
	}
})