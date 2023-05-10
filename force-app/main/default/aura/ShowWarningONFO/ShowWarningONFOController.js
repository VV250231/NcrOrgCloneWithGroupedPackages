({
    
 /*   doInit: function(cmp, event, helper) {
       var eventParams = event.getParams();
            if(cmp.get("v.simpleRecord.Project_Template__c") == null){
                alert('hi ');
                this.showToast(cmp, event, helper);
            } 
       
            
    },*/
    
    showToast : function(cmp, event, helper) {
        var changeType = event.getParams().changeType;
         
        if (changeType === "LOADED") {
            var lbl = cmp.get("v.simpleRecord.Project_Template__c");
            cmp.set("v.simpleRecord1",lbl);
                     
        }
          
    var oldValue = cmp.get("v.simpleRecord1");
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": "Info!",
        "message": "The Quote does not contain any Transaction Services and you have chosen Project Template:"+ cmp.get("v.simpleRecord.Project_Template__c")+ " please proceed accordingly..",
        "duration":' 5000',
         "key": 'info_alt',
         "type": 'Warning',
         "mode": 'sticky'
    });
        
        if(oldValue != cmp.get("v.simpleRecord.Project_Template__c")){
         toastEvent.fire()
         cmp.set("v.simpleRecord1",cmp.get("v.simpleRecord.Project_Template__c"));
        }
       
   }

})