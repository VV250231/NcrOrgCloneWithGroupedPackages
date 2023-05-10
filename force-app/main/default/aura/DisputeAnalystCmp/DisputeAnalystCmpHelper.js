({
	GetUserInfo : function(cmp,event,Quicklookid) {
       
		var action = cmp.get("c.GetUserDetailUsingQuickLookid");
        action.setParams({
            Quklookid : Quicklookid
            
        });
        
        action.setCallback(this, function(response){ 
         	var status = response.getState();
            
            if(status === "SUCCESS"){
                
                
                var responseData = response.getReturnValue();
                if(responseData){
                    //cmp.set("v.RecordData",response.getReturnValue());
                     
                     var UserObj=response.getReturnValue();
                     cmp.set("v.DisputeAnalystUserId",UserObj.Id);
                     cmp.set("v.DisputeAnalysteUserEmail",UserObj.Email);
                     cmp.set("v.RecordData",response.getReturnValue());
                     cmp.set("v.DisputeAnalystUserPhone",UserObj.Phone);
                     cmp.set("v.DisputeAnalysteUserName",UserObj.Quicklook_ID__c);
                     cmp.set("v.DisputeAnalystUserId",UserObj.Id);
                     cmp.set("v.togglephone",false);
                     
                        var appEvent = $A.get("e.c:DisputeAnalysteName");
                        appEvent.setParams({
                            "AnalysteName" : UserObj.Quicklook_ID__c
                          });
                        appEvent.fire();
                }
                
                else{
                    
                    cmp.set("v.DisputeAnalystUserId",'');
                    cmp.set("v.DisputeAnalysteUserEmail",'');
                    cmp.set("v.DisputeAnalystUserPhone",'');
                    cmp.set("v.RecordData",'');
                    cmp.set("v.DisputeAnalysteUserName",'');
                    cmp.set("v.togglephone",true);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Data Not Available', 
                        message:'No Record Found.',
                        duration:' 3000',
                        key: 'info_alt',
                        type: 'warning',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }

            }
        });
        
        $A.enqueueAction(action);
	}
})