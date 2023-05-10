({
	getPartnerAmbassador : function(component, event, helper) {
        
        helper.getPartnerAmbassadorHelper(component, event, helper);
		
	},
    openAttachmentModal : function(component, event, helper) 
    {
        component.set("v.fileName", null);
        component.set("v.isAttachment", true);
    },
    
    saveFileController: function(component, event, helper) {
        var submitREcord = true ; 
        //alert(component.find("fileId").get("v.files"));
        if(component.find("fileId").get("v.files") == null)
        {
            component.set("v.fileName", "Please Select a File: ");
        }
        else
        { 
            helper.uploadHelper(component, event);
        }
    },
    
    closeDocModal: function(component, event, helper) 
    {
      	component.set("v.isAttachment", false);
    },
    openEdit: function(component, event, helper) 
    {
      	component.set("v.isView", false);
        component.set("v.isEdit", true);
    },
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
    
    openFile : function(component, event, helper) 
    {
        var idx = event.currentTarget;
        var idd = idx.dataset.ids; 
      	var url1="/PartnerCentral/servlet/servlet.FileDownload?file="+idd;
        window.open(url1,'_blank'); 
    },
    
    detailSpotlightRequest : function(component, event, helper)
    {
        component.set("v.isView", true);
        component.set("v.isEdit", false);
		component.set("v.ObjPartnerSpotlight", null);
   		var exbRdId = event.getParam("mdfRecordId");
        component.set("v.partnerSpotlightId", exbRdId);
        
        helper.getPartnerAmbassadorHelper(component, event, helper);
        
        
    },
    cancelRequest : function(component, event, helper) 
    {
      	component.set("v.isView", true);
        component.set("v.isEdit", false);
    },
})