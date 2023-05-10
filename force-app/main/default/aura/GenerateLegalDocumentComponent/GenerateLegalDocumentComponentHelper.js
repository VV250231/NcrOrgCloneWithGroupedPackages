({ 
    generateLegalDocument : function(component) {
        var action = component.get("c.validateCreditApplicationStatus");
        action.setParams({"qid":component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var quote = response.getReturnValue();
                //alert(quote.SBQQ__PrimaryContact__c);
                component.set("v.Quote",quote);
                var msg;
                if(quote==null){
                    component.set("v.isApproved",true);
                    msg='You can not send out this document for a Payments Only Quote.';
                    component.set("v.msg",msg); 
                }
                else{
                    if(quote.SBQQ__Type__c==='Amendment'){
                        component.set("v.isApproved",true);
                        msg='Legal document is applicable to non-amendment quote only.';
                        component.set("v.msg",msg);    
                    }else if(quote.SBQQ__Primary__c != true){
                        component.set("v.isApproved",true);
                        msg='Order Form cannot be generated on a non-primary quote.'; 
                        component.set("v.msg",msg);    
                    } else if(quote.qtc_Customer_Type__c == 'New' && quote.qtc_New_Aloha_Key_Number__c == null && (quote.qtc_Multi_Site__c==false || quote.qtc_Multi_Site_Relationship__c !='Parent')){
                        component.set("v.isApproved",true);
                        msg='"New Aloha Key Number" is required prior to generating legal documents.';
                        component.set("v.msg",msg);    
                    }else if(quote.qtc_Customer_Type__c == 'Refresh' && (quote.qtc_New_Aloha_Key_Number__c == null || quote.qtc_Existing_Aloha_Key_Number__c == null || quote.qtc_Existing_Hosted_Enterprise_ID__c == null) && (quote.qtc_Multi_Site__c==false || quote.qtc_Multi_Site_Relationship__c !='Parent')){
                        component.set("v.isApproved",true);
                        msg='One or more of the following required fields are missing; New Aloha Key Number, Existing Aloha Key Number, Existing Hosted Enterprise ID.  Please populate the required fields prior to generating legal documents.'; 
                        component.set("v.msg",msg); 
                    }else if(quote.SBQQ__Account__r.Parent != null && quote.SBQQ__Account__r.Parent.Customer_Number__c != null && quote.SBQQ__Account__r.Parent.Customer_Number__c == '41181899'){
                        component.set("v.isApproved",true);
                        msg='Unable to send legal agreement on account that has not been properly defined. Please update customer record or work with sales operations.'; 
                        component.set("v.msg",msg); 
                    }else{
                        
                        if(quote.SBQQ__Account__c!=null){
							
							if(quote.SBQQ__Account__r.MDM_Enterprise_Nbr__c == null || quote.SBQQ__Account__r.MDM_Enterprise_Nbr__c == ''){
								component.set("v.isApproved",true);
								msg='CMDM update required. MDM Enterprise Entity should not be blank.';
								component.set("v.msg",msg);
							}else if(quote.SBQQ__Account__r.MDM_Customer_Entity_Nbr__c == null || quote.SBQQ__Account__r.MDM_Customer_Entity_Nbr__c == ''){
								component.set("v.isApproved",true);
								msg='CMDM update required. MDM Customer Entity should not be blank.';
								component.set("v.msg",msg);
							}else if(quote.SBQQ__Account__r.MDM_Enterprise_Nbr__c == 'EE_PENDING'){
								component.set("v.isApproved",true);
								msg='CMDM update required. MCN ' + quote.SBQQ__Account__r.Master_Customer_Number__c + ' should not be aligned to a temporary Enterprise Entity.';
								component.set("v.msg",msg);
							}else if(quote.SBQQ__Account__r.MDM_Customer_Entity_Nbr__c == 'CE_PENDING'){
								component.set("v.isApproved",true);
								msg='CMDM update required. MCN ' + quote.SBQQ__Account__r.Master_Customer_Number__c + ' should not be aligned to a temporary Customer Entity.';
								component.set("v.msg",msg);
							}else if(quote.qtc_Bill_To_Site__c!=null){
                                //if(quote.SBQQ__Account__r.Credit_Application_Status__c == 'Approved (by D&B)'||quote.SBQQ__Account__r.Credit_Application_Status__c == 'Approved (by Equifax PG)' ){
								if((quote.SBQQ__Account__r.Credit_Application_Status__c != null  && quote.SBQQ__Account__r.Credit_Application_Status__c.startsWith('Approved')) || quote.qtc_Offering__c == 'SW Only'){
									component.set("v.nonPartnerQuote",quote.qtc_Channel_Local_Office_Record_Type__c != 'PARTNER');
									//alert('non partner quote > ' + (quote.qtc_Channel_Local_Office_Record_Type__c != 'PARTNER'));
									if(quote.qtc_Bill_To_Site__r.AutoPay_Setup__c != 'True' && quote.qtc_Bill_To_Site__r.AutoPay_Setup__c != 'Manual'){
										//this.createUser(component,quote);
										this.GetMultiSiteInfo(component,quote);
										this.GetACHContact(component,quote.SBQQ__Account__c);
										this.GetQuotesWithCLMDoc(component,quote);
										component.set("v.isAutoPayNotSetup",true);
									}else{
										this.GetMultiSiteInfo(component,quote);
										 this.GetQuotesWithCLMDoc(component,quote);
										//component.set("v.isGenerateDoc",true);
										component.set("v.isAutoPayNotSetup",false);
										//this.sendLegalDocument(component,quote);
										//this.GetACHContact(component,quote.SBQQ__Account__c);
									}
									if(quote.qtc_Multi_Site__c==true && quote.qtc_Multi_Site_Relationship__c =='Parent'){
										component.set("v.isMultisiteParent",true);
									}else{
										component.set("v.isMultisiteParent",false);
									}
								}else {
									component.set("v.isApproved",true);
									msg='Customer Account not approved for credit - please review credit approval.';
									component.set("v.msg",msg);
								}
							}
                            /*if(quote.ACH_Recipient__c != null){
                                this.validateCustomerEnterprise(component,quote);
                            }*/
							
                        }else if (quote.SBQQ__Account__c==null){
                            component.set("v.isApproved",true);
                            msg='Customer is not associated to the quote - please assign a customer to the quote to proceed.';
                            component.set("v.msg",msg);
                        }
                        /*else if (quote.SBQQ__PrimaryContact__c==null){
                                component.set("v.isApproved",true);
                                msg='Primary Contact is not associated to the quote - please assign a primary contact to the quote to proceed.';
                                component.set("v.msg",msg);
                            }*/
                            else if (quote.qtc_Bill_To_Site__c==null){
                                component.set("v.isApproved",true);
                                msg='Bill to Site is not associated to the quote - please assign a Bill to Site to the quote to proceed.';
                                component.set("v.msg",msg);
                            }
                    }
                }
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    createUser : function(component,quote) {
        this.sendLegalDocument(component,quote);
        var action = component.get("c.newUser");
        action.setParams({"qid":component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('state > ' + state);
            if (state === "SUCCESS") {
                //component.set("v.userList", response.getReturnValue());
                //alert(JSON.stringify(response.getReturnValue()));
                var resp = response.getReturnValue();
                /*console.log('resp'+resp.status);
                var typ;
                if(resp.status==="FAILURE"){
                    typ = "Error";
                }else{
                    typ="Success";
                }
               // alert('createUser status :' + resp.status);
                
                //if(typ==="Success"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": resp.status,
                        "message": resp.msg,
                        "type": typ
                    }); 
                    toastEvent.fire();
                //}*/
            }
        }); 
        $A.enqueueAction(action);
    },
    
    sendLegalDocument : function(component,quote) {
        var selectedACH = null;
        if(component.get("v.isAutoPayNotSetup")){
            selectedACH = component.find("mySelect").get("v.value");	
        }
        if(component.get("v.isAutoPayNotSetup") && (selectedACH == null || selectedACH == '')){
            var msg;
            component.set("v.isACHNotSelected",true);
            msg='Please select ACH.'; 
            component.set("v.achErrorMsg",msg);
        }else{
            //this.handleOrderFormNoteChange(component);
            this.handleQuoteFieldChanges(component);
            var urlEvent = $A.get("e.force:navigateToURL");
            var baseur =$A.get("$Label.c.CLM_DS_BASE_URL");
            var envId = $A.get("$Label.c.CLM_ENV_ID");
            var msRelationship = (quote.qtc_Multi_Site_Relationship__c != null && quote.qtc_Multi_Site_Relationship__c != ''? quote.qtc_Multi_Site_Relationship__c : '' );
            console.log(msRelationship);
            urlEvent.setParams({
                "url": baseur+'Aloha Essential Order Form?aid='+envId+'&eos[0].Id='+quote.Id+'&eos[0].System=Salesforce&eos[0].Type=SBQQ__Quote__c&eos[0].Name='+quote.Name+' '+quote.CreatedDate+'&eos[0].MultiSite='+quote.qtc_Multi_Site__c+'&eos[0].MultiSiteRelationship='+msRelationship+'&eos[0].ScmPath=/SalesForce/Account/'+quote.DocuSign_Folder__c
                
            });
            urlEvent.fire();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }
        
    }/*,//this - handleOrderFormNoteChange should be removed out after testing is done
    handleOrderFormNoteChange:function(component){
    	var orderFormNote = component.find("orderFormNote").get("v.value");
        var action = component.get("c.SaveOrderFormNoteOnQuote");
        action.setParams({
            "OrderFormNote":orderFormNote,
            "qid":component.get("v.recordId")
            
        });
        
        $A.enqueueAction(action);
	}*/,
    handleQuoteFieldChanges:function(component){
        var orderFormNote = component.find("orderFormNote").get("v.value");
        var action = component.get("c.SaveQuoteFields");
        action.setParams({
            "OrderFormNote":orderFormNote,
            "qid":component.get("v.recordId")
        });
        
        $A.enqueueAction(action);
    },
    
    GetACHContact:function (component,Acc){
        var action = component.get("c.GetAllACHContacts");
        var Options = [];
        action.setParams({"AccId":Acc});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                //alert(JSON.stringify(resp));
                if(resp.length > 0){
                     for(var i=0;i<resp.length;i++){
                      
                        Options.push({ label: resp[i].ConName , value:resp[i].ConId });
                    }
                    component.set("v.options",Options);
                }
                
                
                
                else{
                    		var msg;
                            component.set("v.isApproved",true);
                            msg='No ach contact avalable under Customer Account.';
                            component.set("v.msg",msg);
                }
            }
        }); 
        $A.enqueueAction(action);
    },
    /*PP185093 - Code commentedand after discussion with Opp team against SFCPQBLG-393
     * GetACHContact:function (component,Acc){
        var action = component.get("c.GetAllACHContacts");
        var Options = [];
        action.setParams({"AccId":Acc});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                //alert(JSON.stringify(resp));
                if(resp.length > 0){
                    for(var i=0;i<resp.length;i++){
                        
                        Options.push({ label: resp[i].Name , value:resp[i].Id });
                    }
                    component.set("v.options",Options);
                }
                else{
                    var msg;
                    component.set("v.isApproved",true);
                    msg='No ach contact avalable under Customer Account.';
                    component.set("v.msg",msg);
                }
            }
        }); 
        $A.enqueueAction(action);
    },*/
    
    //parent and  AE+PP ignore for table
    GetMultiSiteInfo:function (component,quote){
        var action = component.get("c.getMultiSiteQuote");
        var listofQtObj = [];
        var keyMissingForNew = [];
        var keyMissingForRefresh = [];
        var keyMissingRecords = [];
        var billToValidate = true;
		var skipValidation = false;
        action.setParams({"qId":quote.Id});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseObj = JSON.parse(response.getReturnValue());
               
                if(quote.qtc_Multi_Site__c == true && quote.qtc_Multi_Site_Relationship__c == 'Parent' && responseObj.length == 0){
                    var msg;
                    component.set("v.isApproved",true);
                    msg='No Quotes meet criteria for generating Legal Document. Please review quotes to ensure they are in approved status and properly linked. For further assistance, please reach out to your Sales Operations contact.';
                    component.set("v.msg",msg);
                }else{
                    
                    if(quote.qtc_Multi_Site__c == true && quote.qtc_Multi_Site_Relationship__c == 'Parent'){
						
							for(var y in responseObj){
                                
                                if((responseObj[y].SBQQ__Account__r.Credit_Application_Status__c == null  || !responseObj[y].SBQQ__Account__r.Credit_Application_Status__c.startsWith('Approved')) && responseObj[y].qtc_Offering__c != 'SW Only'){
									 var msg;
									 component.set("v.isApproved",true);
									 msg='Customer Account not approved for credit - please review credit approval.';
									 component.set("v.msg",msg);
									 skipValidation = true;
								   
								}
							}
						
							if(skipValidation == false){
							
									for(var x in responseObj){
										
									   if(responseObj[x].qtc_Customer_Type__c == 'New' && responseObj[x].qtc_New_Aloha_Key_Number__c == null){
										   keyMissingForNew.push(responseObj[x].Name);
									   }
									   if(responseObj[x].qtc_Customer_Type__c == 'Refresh' && (responseObj[x].qtc_New_Aloha_Key_Number__c == null || responseObj[x].qtc_Existing_Aloha_Key_Number__c == null || responseObj[x].qtc_Existing_Hosted_Enterprise_ID__c == null)){
										   keyMissingForRefresh.push(responseObj[x].Name);
									   }
									 
									}
									
									if(keyMissingForNew.length > 0 || keyMissingForRefresh.length > 0){
											component.set('v.alohaKeyErrorMsgColumns', [
											{label: 'Quote Name', fieldName: 'QuoteName', type: 'text',wrapText: true},
											{label: 'Error Message', fieldName: 'Error', type: 'text',wrapText: true}
											]);
									}
									if(keyMissingForNew.length > 0){
										
										component.set("v.isApproved",true);
										billToValidate = false;
										var sobj = {
											QuoteName:keyMissingForNew.toString(),
											Error:'"New Aloha Key Number" is required prior to generating documents.',
										 }
										keyMissingRecords.push(sobj);
										component.set('v.alohaKeyErrorData',keyMissingRecords);
									}
									
									if(keyMissingForRefresh.length > 0){
										
										component.set("v.isApproved",true);
										billToValidate = false;
										var sobj = {
											QuoteName:keyMissingForRefresh.toString(),
											Error:'One or more of the following required fields are missing; New Aloha Key Number, Existing Aloha Key Number, Existing Hosted Enterprise ID.  Please populate the required fields prior to generating documents.',
										 }
										keyMissingRecords.push(sobj);
										component.set('v.alohaKeyErrorData',keyMissingRecords);
									}
							}
                        
                    }
                    if(billToValidate == true){
                        var mapObj = new Map();
                        var temp=true;
                        for(var x in responseObj){
                            var qtNameAndSiteName = [];
                            if(responseObj[x].qtc_Bill_To_Site__c == null){
                                if(mapObj.has('')){
                                    qtNameAndSiteName = mapObj.get('');
                                    qtNameAndSiteName[0] = qtNameAndSiteName[0]+', '+responseObj[x].Name;
                                    mapObj.set('',qtNameAndSiteName);
                                }else{
                                    qtNameAndSiteName[0] = responseObj[x].Name;
                                    qtNameAndSiteName[1] = '';
                                    mapObj.set('',qtNameAndSiteName);
                                }
                            }else{
                                if(responseObj[x].qtc_Bill_To_Site__r.AutoPay_Setup__c!='True' && responseObj[x].qtc_Bill_To_Site__r.AutoPay_Setup__c!='Manual'  && responseObj[x].qtc_Multi_Site_Relationship__c=='Child' && temp ){
                                    this.GetACHContact(component,quote.SBQQ__Account__c);
                                    component.set("v.isAutoPayNotSetup",true);
                                    temp=false;
                                }
                                if(mapObj.has(responseObj[x].qtc_Bill_To_Site__r.Site_Number__c)){
                                    qtNameAndSiteName = mapObj.get(responseObj[x].qtc_Bill_To_Site__r.Site_Number__c);
                                    qtNameAndSiteName[0] = qtNameAndSiteName[0]+', '+responseObj[x].Name;
                                    mapObj.set(responseObj[x].qtc_Bill_To_Site__r.Site_Number__c,qtNameAndSiteName);
                                }else{
                                    qtNameAndSiteName[0] = responseObj[x].Name;
                                    qtNameAndSiteName[1] = responseObj[x].qtc_Bill_To_Site__r.Name;
                                    mapObj.set(responseObj[x].qtc_Bill_To_Site__r.Site_Number__c,qtNameAndSiteName);
                                }
                            }
                        }
                        for(var objVar of mapObj.keys()){
                            var arry = mapObj.get(objVar);
                            var sobj = {
                                QuoteName:arry[0],
                                SiteNo:objVar,
                                SiteName:arry[1]
                            }
                            listofQtObj.push(sobj);
                        }
                        component.set('v.multiSiteDataColumns', [
                            {label: 'Quote name', fieldName: 'QuoteName', type: 'text'},
                            {label: 'Bill to site number', fieldName: 'SiteNo', type: 'text'},
                            {label: 'Bill to site name', fieldName: 'SiteName', type: 'text'}
                        ]);
                        component.set('v.multiSiteData',listofQtObj);
                        console.log('table>>>>>'+listofQtObj);
                    }
                }
                
            }
        }); 
        $A.enqueueAction(action);
    },
    
    GetQuotesWithCLMDoc:function(component,quote){
        let action = component.get("c.getQuotesWithCLMDoc");
        action.setParams({"quote":quote});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let quoteNamesWithDoc = response.getReturnValue();
                console.log('msg' + JSON.stringify(quoteNamesWithDoc));
                let message =  'There is at least one Order Form already generated for the following ';
                let message1 = 'Click <b>Generate</b> if you want to continue!';
                if(Object.keys(quoteNamesWithDoc).length !== 0){
                    if(!quote.qtc_Multi_Site__c || quote.qtc_Multi_Site_Relationship__c == 'Child'){
                        message = message.concat('Quote, with the most recently modified one having a Document Status, ');
                        for (var key in quoteNamesWithDoc) {
							if(quoteNamesWithDoc[key] == 'Completed'){
								message = 'There is already a signed Order Form for this Quote. If you continue, CLM will generate a new version of the Order Form and will void the existing one.';
							}else{
								message = 'There is at least one unsigned Order Form already generated for this Quote. If you continue, that Form will be Voided.';
							}
                            
                        }	
                    }
                    else{
                        message = message.concat('Quotes, with the most recently modified one having Document Status: <br/>');
                        for (var key in quoteNamesWithDoc) {
                            message = message.concat(key,'&emsp;&emsp;',quoteNamesWithDoc[key], '<br/>' );
                        }
                    }
                    message = message.concat(message1);
                    component.set('v.showDocWarning',true);
                    component.set('v.warningMessage',message);
                }
           }
        });
        $A.enqueueAction(action);
    },
	validateCustomerEnterprise:function (component,quote){
        var action = component.get("c.getAccountOfEnterpriseUI");
        var Options = [];
        action.setParams({"quote":quote});
		       
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                if(resp > 0){
					var msg;
                    component.set("v.isApproved",true);
                    msg='CMDM update required. MCNs must be part of the same Enterprise/Customer Entity.';
                    component.set("v.msg",msg);
                     
                }
               
            }
        }); 
        $A.enqueueAction(action);
    }	
})