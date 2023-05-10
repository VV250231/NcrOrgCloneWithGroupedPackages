({
	 handleShowModal: function(component, evt, helper) {
        var modalBody;
         $A.createComponent("c:Tableau_c360", {recordId:component.get("v.recordId"), showDashboard:true, acc:component.get("v.acc")},
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   component.find('overlayLib').showCustomModal({                       
                       body: modalBody,
                       showCloseButton: true,
                       cssClass: "slds-modal--large slds-scrollable",
                       closeCallback: function() {                          
                       }
                   })
               }
           });
    }
})