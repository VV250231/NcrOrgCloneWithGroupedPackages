({
    doInit: function(component, event, helper) {           
        var rid = component.get("v.recordId");         
        console.log('Recordid Value: '+ rid);
        component.set('v.recordtypedetails',$A.get("$Label.c.Case_MaccChat_RecordType_Id"));
     //   alert($A.get("$Label.c.Case_MaccChat_RecordType_Id"));              
        var action=component.get('c.searchExistingCase');
        action.setParams({
            chatid:rid,
        });
        action.setCallback(this,function(response){
            var state= response.getState();
            if(state==='SUCCESS'){
                var responeValues=response.getReturnValue(); 
                if (responeValues.length >0){ 
                    component.set("v.caseiddata",responeValues[0].CaseId);
                    console.log ('caseiddata: ',responeValues[0].CaseId);  
                }
            }
            else{
                var errors= response.getError();
                console.log ('Errors'+errors);
            }
        },'ALL');
        
        $A.enqueueAction(action);
        
    }
})