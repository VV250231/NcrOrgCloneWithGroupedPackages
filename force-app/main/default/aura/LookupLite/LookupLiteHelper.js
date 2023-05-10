({
    searchRecordsHelper : function(component, helper) {
        
    },

    // Dynamic creation of div for dropdown list
    dynamicCreation : function(component, recordsList, fieldName) {

    },
    
    getDisputeROR : function(component, event, helper){ 
        debugger;
    	var action = component.get('c.fetchDspROR');
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.DisputeRORSys", response.getReturnValue());    
            } else {
            	var errors = response.getError();
                alert("Error in getting Dispute ROR System:" + errors[0].message);    
            }
        });
         $A.enqueueAction(action);
    },
    
    getSelectedRecordsHelper:function(component, event,recordid){
        var action = component.get('c.fetchSelectedRecord');
        action.setParams({
            'objectName' : component.get('v.objectName'),
            'searchString' : recordid
        });
        action.setCallback(this,function(response){
            var result = response.getReturnValue();
            //alert(result.Id);
            if( event.getParam("Action") === 'Search Customer Contact'){
                 component.set("v.RecordData",result);
                 component.set("v.CustomerContactEmail",result.Email);
                 component.set('v.CustomerContactRecordId',result.Id);
                 component.set("v.CustomerContactName",result.Name);
                 component.set("v.CustomerContactPhone",result.Phone);
            }
            
            if(event.getParam("Action") === 'Search Alternate Contact'){
                component.set("v.RecordDataAlternetContact",result);
                component.set("v.AlternateContactEmail",result.Email);
                component.set('v.AlternateContactRecordId',result.Id);
                component.set("v.AlternateContactName",result.Name);
                component.set("v.AlternateContactPhone",result.Phone);
            }  
            $A.util.addClass(component.find("Spinner"), "slds-hide");
         
        });
         $A.enqueueAction(action);
	},
      onButtonPressed: function(cmp, event) {
      /*// Figure out which action was called
      var actionClicked = event.getSource().getLocalId();
      // Fire that action
      var navigate = cmp.get('v.navigateFlow');
      navigate(actionClicked);*/
      cmp.set("v.ToggleSpinner",true);
      //alert('1');  
      
    
     var CustomerContactName = cmp.get("v.CustomerContactName") !== "" ? cmp.get("v.CustomerContactName") : null; 
     var CustomerContactPhone = cmp.get("v.CustomerContactPhone") !== "" ? cmp.get("v.CustomerContactPhone") : null;    
     var CustomerContactEmail = cmp.get("v.CustomerContactEmail") !== "" ? cmp.get("v.CustomerContactEmail") : null;     

    
    //var AlternateContactName =  cmp.get("v.AlternateContactName");
    //var AlternateContactPhone=  cmp.get("v.AlternateContactPhone");
    //var AlternateContactEmail=  cmp.get("v.AlternateContactEmail"); 
          
    var AlternateContactName = cmp.get("v.AlternateContactName") !== "" ? cmp.get("v.AlternateContactName") : null;
    var AlternateContactPhone = cmp.get("v.AlternateContactPhone") !== "" ? cmp.get("v.AlternateContactPhone") : null;
    var AlternateContactEmail = cmp.get("v.AlternateContactEmail") !== "" ? cmp.get("v.AlternateContactEmail") : null;     
    
    //var DisputeAnalystName= cmp.get("v.DisputeAnalystName");
    //var DisputeAnalystPhone= cmp.get("v.DisputeAnalystPhone");
    //var DisputeAnalystEmail= cmp.get("v.DisputeAnalystEmail");   
   
    var DisputeAnalystName = cmp.get("v.DisputeAnalystName") !== "" ? cmp.get("v.DisputeAnalystName") : null;
    var DisputeAnalystPhone = cmp.get("v.DisputeAnalystPhone") !== "" ? cmp.get("v.DisputeAnalystPhone") : null;
    var DisputeAnalystEmail = cmp.get("v.DisputeAnalystEmail") !== "" ? cmp.get("v.DisputeAnalystEmail") : null;       
          
          
    //var DisputeDetail = cmp.get("v.DisputeDetail"); 
    var DisputeDetail = cmp.get("v.DisputeDetail") !== "" ? cmp.get("v.DisputeDetail") : null;
          
    //var DisputeReason= cmp.get("v.DisputeReason");
    var DisputeReason = cmp.get("v.DisputeReason") !== "" ? cmp.get("v.DisputeReason") : null;
          
    //var MCNForFinalScreen= cmp.get("v.MCNForFinalScreen");
    var MCNForFinalScreen = cmp.get("v.MCNForFinalScreen") !== "" ? cmp.get("v.MCNForFinalScreen") : null;
          
    //var CountryCodeForFinalScreen= cmp.get("v.CountryCodeForFinalScreen");
    var CountryCodeForFinalScreen = cmp.get("v.CountryCodeForFinalScreen") !== "" ? cmp.get("v.CountryCodeForFinalScreen") : null;
          
    //var DisputeDetail= cmp.get("v.DisputeDetail"); 
    var DisputeDetail = cmp.get("v.DisputeDetail") !== "" ? cmp.get("v.DisputeDetail") : null;  
          
    //var CommentQuestion= cmp.get("v.CommentQuestion");
    var CommentQuestion = cmp.get("v.CommentQuestion") !== "" ? cmp.get("v.CommentQuestion") : null;
          
    //var FollowUpQuestion = cmp.get("v.FollowUpQuestion");
    var FollowUpQuestion = cmp.get("v.FollowUpQuestion") !== "" ? cmp.get("v.FollowUpQuestion") : null;
          
    //var DisputedAmount = cmp.get("v.DisputedAmount");
    var DisputedAmount = cmp.get("v.DisputedAmount") !== "" ? cmp.get("v.DisputedAmount") : null;
          
    //var FollowUpAns = cmp.get("v.FollowUpAns");
    var FollowUpAns = cmp.get("v.FollowUpAns") !== "" ? cmp.get("v.FollowUpAns") : null;      
    //var TableDataJson= cmp.get("v.TableDataJson"); 
    var TableDataJson = cmp.get("v.TableDataJson") !== "" ? cmp.get("v.TableDataJson") : null;      
    //var CurrencyCode= cmp.get("v.CurrencyCode");    
    var CurrencyCode = cmp.get("v.CurrencyCode") !== "" ? cmp.get("v.CurrencyCode") : null;      
    //alert('5');          
    //DisputeData;
    //var InvoiceData=[];  
    var DisputeData={Dispute_ID: 0 , Submitter_Name : CustomerContactName , Submitter_Phone_Num : CustomerContactPhone , Submitter_Email : CustomerContactEmail, DisputeReason : DisputeReason,DisputedAmount : DisputedAmount , Alternate_Contact_Name : AlternateContactName , Alternate_Contact_Phone : AlternateContactPhone , Alternate_Contact_Email : AlternateContactEmail , FollowupQuestion : FollowUpQuestion , FollowupAnswer : FollowUpAns,DisputeDetails : DisputeDetail,Dispute_Status:'10', ERP_Dispute_Number : '', Master_Customer_Number : MCNForFinalScreen , Country : CountryCodeForFinalScreen,Currency_Code:CurrencyCode,DisputeAnalystName:DisputeAnalystName,DisputeAnalystPhone:DisputeAnalystPhone,DisputeAnalystEmail : DisputeAnalystEmail};    
    //alert('6');
    //console.log(JSON.stringify(DisputeData));
    //console.log(JSON.stringify(TableDataJson));      
    var action = cmp.get('c.CreateDisputeInCCAD');  
    action.setParams({
            'DisputeData' : JSON.stringify(DisputeData),
            'InvoiceTableDate' : TableDataJson
        });      
    action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('SuccessSSS'+response.getReturnValue().IsValidate);
                if(response.getReturnValue().IsValidate){
                    cmp.set("v.CCADDisputeNo",response.getReturnValue().ValidationMsg);
                    /*var actionClicked = event.getSource().getLocalId();
                    var navigate = cmp.get('v.navigateFlow');
                    navigate(actionClicked);*/
                    var navigate = cmp.get('v.navigateFlow');
                    navigate('NEXT');
                    cmp.set("v.ToggleSpinner",false);
                }
                else{
                  // alert('fail');
                    cmp.set("v.ToggleSpinner",false);
                    var appEvent = $A.get("e.c:DisputeValidationMsg");
                    appEvent.setParams({
                        "DisplayMsg" : response.getReturnValue().ValidationMsg });
                    //appEvent.fire();
                    cmp.set("v.CCADMsg",response.getReturnValue().ValidationMsg);
                    cmp.set("v.ToggleCCADMsg",true);
                    }
            }
            else {
                var errors = response.getError();
                alert("Error message: " + errors[0].message);
                cmp.set("v.ToggleSpinner",false);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);      
   }
})