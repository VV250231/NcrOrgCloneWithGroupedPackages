({
    doInit : function(component, event, helper) {
        var rcrd = component.get("v.recordId");
         helper.getApprovalStatus(component, event, rcrd);
        helper.getLoggedInUserDetail(component, event, helper);
       
       
    },
    sendMail: function(component, event, helper) {
        
        var getEmail = component.get("v.ContactsEmail");
        console.log('***' + getEmail);
        var getSubject = component.get("v.subject");
        var getbody = component.find("emailbody").get("v.value");
        var arr1 = getEmail.split("@");
        var arr2 = getEmail.split(",");
       
        if ($A.util.isEmpty(getEmail) || !getEmail.includes("@") || (arr1.length == arr2.length) || (arr1.length < arr2.length)){
             $A.util.addClass(component.find('emailAlert'), 'slds-show');
        }
        else if($A.util.isEmpty(getbody)){           
            $A.util.addClass(component.find('bodyAlert'), 'slds-show');
        } 
        else if($A.util.isEmpty(getSubject)){
            $A.util.addClass(component.find('subjectAlert'), 'slds-show');
        }             
        else {
                helper.sendEmailHelper(component, arr2, getSubject, getbody );
            }
    }
    
    
})