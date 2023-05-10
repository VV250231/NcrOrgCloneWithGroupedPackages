({
    fetchDepValues: function(component, ListOfDependentFields) {
        
        console.log("==== fetchDepValues ====");
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];       
        
        //component.find("selectPrimarySolutions").set("v.value", '--None--');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            // alert(ListOfDependentFields[i]);
            dependentFields.push(ListOfDependentFields[i]);
        }
        
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.primarySolutions", dependentFields);
        
    },
    fetchDepValues2: function(component, ListOfDependentFields2) {
        console.log("==== fetchDepValues2 ====");
        
        var dependentFields2 = [];
        
        //component.find("selectSecondarySolutions").set("v.value", '--None--');
        for (var i = 0; i < ListOfDependentFields2.length; i++) {
            dependentFields2.push(ListOfDependentFields2[i]);
        }
        // set the dependentFields2 variable values to store(dependent picklist field) on lightning:select
        component.set("v.secondarySolutions", dependentFields2);
    },
    
    
    isValidate : function(component, event, helper){
        console.log("==== isValidate ====");
        
        var numberRegex = /^\d*\.?\d*$/;
        var emailRegex = /[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,3}$/;
        var submitREcord = true ; 
        var Accounttheater =component.get("v.accountTheater");
        var projectedOpportunityValue= component.get("v.projectedOpportunityValue");
        var dealWithMonthlyRecurringRev= component.get("v.dealWithMonthlyRecurringRev");
        
        if(typeof Accounttheater ==='undefined'){
            Accounttheater = ''
        }
        
        var AccountRegion = component.get("v.accountRegion"); 
        if(typeof AccountRegion ==='undefined'){
            AccountRegion = ''
        }
        
        //  if Partner Select Deal Registration Type
        if(component.find("selectDealRegistrationTypes").get("v.value") == '--None--'){
            component.find("selectDealRegistrationTypes").set("v.errors",[{message:"Please Select Deal Registration Type: "}]);
            submitREcord = false ;
        }else{
            component.find("selectDealRegistrationTypes").set("v.errors", null);
        }
        
        // If the Partner Account has Distributors then this field cannot be empty. 
        // If the Partner Account doesn't have a distributor then the field is non-mandatory.
        
        if (component.get("v.distributorList").length > 1 && component.find("selectDistributor").get("v.value") == '--None--') {
            component.find("selectDistributor").set("v.errors",[{message:"Please Select Distributor Name: "}]);
            submitREcord = false ;
        } else{
            component.find("selectDistributor").set("v.errors", null);
        }
        
        // If the Partner Account has Partner Industry then this field cannot be empty. 
        // If the Partner Account doesn't have a Partner Industry then the field is non-mandatory.
        if (component.find("selectPartnerIndustry").get("v.value") == '--None--') {
            component.find("selectPartnerIndustry").set("v.errors",[{message:"Please Select Partner Industry: "}]);
            submitREcord = false ; 
        } else{
            component.find("selectPartnerIndustry").set("v.errors", null);
        }
        
        //if Partner Industry is equal to Hospitality.        
        if(component.find("selectPartnerIndustry").get("v.value") === "Hospitality") {
            
            //If Partner not Enter value in county field. 
            if(!component.find("county").get("v.value")){
                component.find("county").set("v.errors",[{message:"Please Enter County: "}]); 
                submitREcord = false ;
            }else{
                component.find("county").set("v.errors",null);
            }
        }
        
        //If partner Select Country picklist.        
        if(component.find("selectCountries").get("v.value") == '--None--' ||  component.find("selectCountries").get("v.value") === undefined){
            component.find("selectCountries").set("v.errors",[{message:"Please Select Country: "}]);
            submitREcord = false ;
        }else{
            component.find("selectCountries").set("v.errors", null);
        }
        
        //if partner Select Primary Soloutions picklist.
        if(component.find("selectPrimarySolutions").get("v.value") == '--None--' ||  component.find("selectPrimarySolutions").get("v.value") === undefined ){
            component.find("selectPrimarySolutions").set("v.errors",[{message:"Please Select Primary Solution: "}]);
            submitREcord = false ;
        } else{
            component.find("selectPrimarySolutions").set("v.errors", null);
        }
        
        //if Partner Enter Deal Name.        
        if(!component.find("Deal_Name").get("v.value")){
            component.find("Deal_Name").set("v.errors",[{message:"Please Enter Deal Name: "}]);
            submitREcord = false ;
        }else{
            component.find("Deal_Name").set("v.errors", null);
        }
        
        //if Partner Enter Customer Name
        if(!component.find("End_Customer_Company_Name").get("v.value")){
            component.find("End_Customer_Company_Name").set("v.errors",[{message:"Please Enter Customer Name: "}]);
            submitREcord = false ;
        }else{
            component.find("End_Customer_Company_Name").set("v.errors",null);
        }
        
        // Street Address
        if(!component.find("Street_Address").get("v.value"))
        {
            component.find("Street_Address").set("v.errors",[{message:"Please Enter Street Address: "}]);
            submitREcord = false ;
        }else{
            component.find("Street_Address").set("v.errors",null);
        }
        
        //City
        if(!component.find("City").get("v.value"))
        {
            component.find("City").set("v.errors",[{message:"Please Enter City: "}]);
            submitREcord = false ;
        }else{
            component.find("City").set("v.errors",null);
        }
        
        //Postal/Zip Code
        if(!component.find("Postal").get("v.value")){
            component.find("Postal").set("v.errors",[{message:"Please Enter Postal/Zip Code: "}]);
            submitREcord = false ;
        }else{
            component.find("Postal").set("v.errors",null);
        }
        
        //Primary Contact Name
        if(!component.find("Primary_Contact_NameText").get("v.value")){
            component.find("Primary_Contact_NameText").set("v.errors",[{message:"Please Enter Primary Contact Name: "}]);
            submitREcord = false ;
        }else{
            component.find("Primary_Contact_NameText").set("v.errors",null);
        }
        
        //State/Province/Region
        if(!component.find("State").get("v.value")){
            component.find("State").set("v.errors",[{message:"Please Enter State/Province/Region: "}]);
            submitREcord = false ;
        }else{
            component.find("State").set("v.errors",null);
        }
        
        //Decision Maker
        if(!component.find("Key_Decision_Maker").get("v.value"))
        {
            component.find("Key_Decision_Maker").set("v.errors",[{message:"Please Enter Key Decision Maker: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Key_Decision_Maker").set("v.errors",null);
        }
        
        var selectedPI = component.find("selectPartnerIndustry").get("v.value");
        var oppValue = component.find("Projected_Opportunity_Value").get("v.value");
        
        //Opp Value Error 
        var oppValueSection = component.find("oppValueSection");
        var oppError_MSG = component.find("oppError_MSG");
        var oppValueError_MSG = component.find("oppValueError_MSG");
        
        if(typeof oppValue ==='undefined'){
            oppValue ='';
        }else{
            oppValue = oppValue.toString().trim();
        }
        
        // Code added by deeksharth
        if (typeof component.find("addTAM") === "undefined") {
            // don't do anything.
        } else {
            var addTAM = component.find("addTAM").get("v.value");
            if(typeof component.find("addTAM").get("v.value") ==='undefined'){
                addTAM = '';
            }
            if(addTAM =='' && AccountRegion =='NAMER CFI' 
               && component.find("selectPartnerIndustry") 
               && component.find("selectPartnerIndustry").get("v.value") =='Financial' 
               && component.find("addTAM")){
                component.find("addTAM").set("v.errors",[{message:"Please select TAM: "}]);
                submitREcord = false ;
            }else{
                if(component.find("addTAM"))
                    component.find("addTAM").set("v.errors",null);
            }
        }
        
        // Deeksharth Code end here..
        
        // Validate Financial Industry
        if (selectedPI =='Financial') {
            
            //Opportunity Value
            if (!oppValue) { 
                component.find("Projected_Opportunity_Value").set("v.errors",[{message:"Please Enter Opportunity Value: "}]);
                submitREcord = false ;
            } else if (!oppValue.match(numberRegex)) {
                component.find("Projected_Opportunity_Value").set("v.errors",[{message:"Please Enter number only: "}]);
                submitREcord = false ; 
            } else if (parseInt(component.find("Projected_Opportunity_Value").get("v.value")) < projectedOpportunityValue) { //100000
                component.find("Projected_Opportunity_Value").set("v.errors",[{message:"Your Deal Registration does not meet the Minimum Deal Size requirements for Deal Registration. Please consult your CAM.[ Minimum values: Opportunity Value="+projectedOpportunityValue+"]"}]);
                submitREcord = false ;
                
            }else{
                /*
                * Modified By: Ritesh on 26-11-2019
                * @desc : If the user enters the correct value in the field, the error message is also visible
                *         to him, So we need to set the errors value to null.
                */
                component.find("Projected_Opportunity_Value").set("v.errors",null);
            }
            
        } else if (selectedPI =='Retail') {
            
            var retailOppValueSectionVar = component.find("oppValueSection"); 
            var oppError_MSG = component.find("oppError_MSG");
            var oppValueError_MSG = component.find("oppValueError_MSG");                                     
            $A.util.removeClass(retailOppValueSectionVar, 'oppErrorSection');
            $A.util.removeClass(oppError_MSG, 'slds-show');
            $A.util.addClass(oppError_MSG, 'slds-hide');  
            $A.util.removeClass(oppValueError_MSG, 'slds-show');
            $A.util.addClass(oppValueError_MSG, 'slds-hide'); 
            component.find("Projected_Opportunity_Value").set("v.errors",null);
            component.find("Deal_with_Monthly_Recurring_Rev").set("v.errors",null);
            
            var Monthly_Recurring_Rev = component.find("Deal_with_Monthly_Recurring_Rev").get("v.value");
            
            if(typeof Monthly_Recurring_Rev ==='undefined'){
                Monthly_Recurring_Rev ='';
            }else{
                Monthly_Recurring_Rev = Monthly_Recurring_Rev.toString();
            }
            //--simran made changes -> if (!(oppValue || Monthly_Recurring_Rev)) NPC-1541 
            
            if (!oppValue && !Monthly_Recurring_Rev){ 
                
                var retailOppValueSectionVar = component.find("oppValueSection");                                      
                $A.util.addClass(retailOppValueSectionVar, 'oppErrorSection');
                $A.util.removeClass(oppError_MSG, 'slds-hide');
                $A.util.addClass(oppError_MSG, 'slds-show');                      
                submitREcord = false;
                //simran added -- NPC 1541
                component.find("Projected_Opportunity_Value").set("v.errors",[{message:"Entry is required in Opportunity Value or Deal with Monthly Recurring Revenue Field: "}]);
                submitREcord = false;
            } else if (!(oppValue.match(numberRegex) && Monthly_Recurring_Rev.match(numberRegex))){
                
                if (!oppValue.match(numberRegex)) {
                    component.find("Projected_Opportunity_Value").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ; 
                }  else {
                    component.find("Projected_Opportunity_Value").set("v.errors",null); 
                }
                
                if (!Monthly_Recurring_Rev.match(numberRegex)){
                    component.find("Deal_with_Monthly_Recurring_Rev").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ; 
                }  else {
                    component.find("Deal_with_Monthly_Recurring_Rev").set("v.errors",null); 
                }
                
            } //else if ((parseInt(component.find("Projected_Opportunity_Value").get("v.value")) >= 25000 && parseInt(component.find("Deal_with_Monthly_Recurring_Rev").get("v.value")) >= 900) || (parseInt(component.find("Projected_Opportunity_Value").get("v.value")) >= 25000 && isNaN(parseInt(component.find("Deal_with_Monthly_Recurring_Rev").get("v.value"))) )) {
            // else if ((parseInt(component.find("Projected_Opportunity_Value").get("v.value")) >= projectedOpportunityValue && parseInt(component.find("Deal_with_Monthly_Recurring_Rev").get("v.value")) >= dealWithMonthlyRecurringRev) || (parseInt(component.find("Projected_Opportunity_Value").get("v.value")) >= projectedOpportunityValue && isNaN(parseInt(component.find("Deal_with_Monthly_Recurring_Rev").get("v.value"))) )) {
                else if ((parseInt(component.find("Projected_Opportunity_Value").get("v.value")) >= projectedOpportunityValue) || (parseInt(component.find("Deal_with_Monthly_Recurring_Rev").get("v.value")) >= dealWithMonthlyRecurringRev) 
                         || (parseInt(component.find("Projected_Opportunity_Value").get("v.value")) >= projectedOpportunityValue && isNaN(parseInt(component.find("Deal_with_Monthly_Recurring_Rev").get("v.value"))))
                         || (parseInt(component.find("Deal_with_Monthly_Recurring_Rev").get("v.value")) >= dealWithMonthlyRecurringRev && isNaN(parseInt(component.find("Projected_Opportunity_Value").get("v.value"))))
                        ) {      
                    $A.util.removeClass(retailOppValueSectionVar, 'oppErrorSection');
                    $A.util.removeClass(oppError_MSG, 'slds-show');
                    $A.util.addClass(oppError_MSG, 'slds-hide');  
                    $A.util.removeClass(oppValueError_MSG, 'slds-show');
                    $A.util.addClass(oppValueError_MSG, 'slds-hide');
                    
                } //else if ((isNaN(parseInt(component.find("Projected_Opportunity_Value").get("v.value")))) || (parseInt(component.find("Projected_Opportunity_Value").get("v.value")) < 25000) ||  (!(isNaN(parseInt(component.find("Deal_with_Monthly_Recurring_Rev").get("v.value")))) && parseInt(component.find("Deal_with_Monthly_Recurring_Rev").get("v.value")) < 900))
            //else if ((isNaN(parseInt(component.find("Projected_Opportunity_Value").get("v.value")))) || (parseInt(component.find("Projected_Opportunity_Value").get("v.value")) < projectedOpportunityValue) ||  (!(isNaN(parseInt(component.find("Deal_with_Monthly_Recurring_Rev").get("v.value")))) && parseInt(component.find("Deal_with_Monthly_Recurring_Rev").get("v.value")) < dealWithMonthlyRecurringRev)) 
                    else if((isNaN(parseInt(component.find("Projected_Opportunity_Value").get("v.value")))) || (parseInt(component.find("Projected_Opportunity_Value").get("v.value")) < projectedOpportunityValue) || 
                            (isNaN(parseInt(component.find("Deal_with_Monthly_Recurring_Rev").get("v.value")))) || (parseInt(component.find("Deal_with_Monthly_Recurring_Rev").get("v.value")) < dealWithMonthlyRecurringRev) ||  
                            (!(isNaN(parseInt(component.find("Deal_with_Monthly_Recurring_Rev").get("v.value")))) && parseInt(component.find("Deal_with_Monthly_Recurring_Rev").get("v.value")) < dealWithMonthlyRecurringRev) ||
                            (!(isNaN(parseInt(component.find("Projected_Opportunity_Value").get("v.value")))) && parseInt(component.find("Projected_Opportunity_Value").get("v.value")) < projectedOpportunityValue))
                    {  
                        
                        $A.util.addClass(retailOppValueSectionVar, 'oppErrorSection');
                        $A.util.addClass(oppError_MSG, 'slds-show');
                        $A.util.removeClass(oppValueError_MSG, 'slds-hide');
                        $A.util.addClass(oppValueError_MSG, 'slds-show');                      
                        submitREcord = false;
                        
                    }
            
        } else if(selectedPI == 'Hospitality') {
            
            var retailOppValueSectionVar = component.find("oppValueSection");  
            $A.util.removeClass(retailOppValueSectionVar, 'oppErrorSection');
            $A.util.removeClass(oppError_MSG, 'slds-show');
            $A.util.addClass(oppError_MSG, 'slds-hide');  
            $A.util.removeClass(oppValueError_MSG, 'slds-show');
            $A.util.addClass(oppValueError_MSG, 'slds-hide');  
            
            var dataflag = false;
            var isAllData = true;
            
            //checkbox
            var dealwithunit = component.find("Deal_with_3_or_more_units").get("v.value");
            if(typeof dealwithunit == 'undefined'){
                dealwithunit = false;
            } 
            
            //checkbox
            var strategicvalue = component.find("Deals_with_strategic_value_in_marktplce").get("v.value");
            if(typeof strategicvalue  == 'undefined'){
                strategicvalue = false;
            }
            
            var recurringVal = component.find("Deal_with_Monthly_Recurring_Rev").get("v.value");
            if(typeof recurringVal ==='undefined'){
                recurringVal='';
            }else{
                recurringVal = recurringVal.toString();
            }
            
            var strategicVal = component.find("strategic_value").get("v.value");
            if(typeof strategicVal ==='undefined'){
                strategicVal='';
            }else{
                strategicVal = strategicVal.toString();
            }
            
            var units = component.find("Deal_with_3_or_more_units_num").get("v.value");
            if(typeof units ==='undefined'){
                units='';
            }else{
                units = units.toString();
            }
            
            if (!oppValue.match(numberRegex)) {
                component.find("Projected_Opportunity_Value").set("v.errors",[{message:"Please Enter number only: "}]);
                submitREcord = false ;
                isAllData = false;
            }  else {
                component.find("Projected_Opportunity_Value").set("v.errors",null); 
            }
            
            if (!units.match(numberRegex)) {
                component.find("Deal_with_3_or_more_units_num").set("v.errors",[{message:"Please Enter number only: "}]);
                submitREcord = false ; 
                isAllData = false;
            }  else {
                component.find("Deal_with_3_or_more_units_num").set("v.errors",null); 
            }
            
            if (!strategicVal.match(numberRegex)) {
                component.find("strategic_value").set("v.errors",[{message:"Please Enter number only: "}]);
                submitREcord = false ; 
                isAllData = false;
            }  else {
                component.find("strategic_value").set("v.errors",null); 
            }
            
            if (!recurringVal.match(numberRegex)) {
                component.find("Deal_with_Monthly_Recurring_Rev").set("v.errors",[{message:"Please Enter number only: "}]);
                submitREcord = false ; 
                isAllData = false;
            }  else {
                component.find("Deal_with_Monthly_Recurring_Rev").set("v.errors",null); 
            }
            
            if(recurringVal == '' && strategicvalue == false && dealwithunit == false && oppValue == '' && units == ''){
                
                var retailOppValueSectionVar = component.find("oppValueSection");                                      
                $A.util.addClass(retailOppValueSectionVar, 'oppErrorSection');
                $A.util.removeClass(oppError_MSG, 'slds-hide');
                $A.util.addClass(oppError_MSG, 'slds-show'); 
                submitREcord = false ;
                isAllData = false;
                
            }else{
                
                isAllData = true;
                
            }
            
            if (isAllData == true) {
                
                if ((Accounttheater!='CLA' && (parseInt(component.find("Projected_Opportunity_Value").get("v.value")) >= projectedOpportunityValue)) //30000
                    ||(Accounttheater=='CLA' && (parseInt(component.find("Projected_Opportunity_Value").get("v.value")) >= projectedOpportunityValue)) //15000
                    || parseInt(component.find("Deal_with_3_or_more_units_num").get("v.value")) >= 3
                    || dealwithunit == true
                    || (Accounttheater!='CLA' && (parseInt(component.find("Deal_with_Monthly_Recurring_Rev").get("v.value")) >= dealWithMonthlyRecurringRev)) //900
                    || (Accounttheater=='CLA' && (parseInt(component.find("Deal_with_Monthly_Recurring_Rev").get("v.value")) >= dealWithMonthlyRecurringRev)) //250
                    || (strategicvalue == true && strategicVal !='')
                   ) {
                    
                    var retailOppValueSectionVar = component.find("oppValueSection");  
                    $A.util.removeClass(retailOppValueSectionVar, 'oppErrorSection');
                    $A.util.removeClass(oppError_MSG, 'slds-show');
                    $A.util.addClass(oppError_MSG, 'slds-hide');  
                    $A.util.removeClass(oppValueError_MSG, 'slds-show');
                    $A.util.addClass(oppValueError_MSG, 'slds-hide');
                    
                } else {
                    
                    var retailOppValueSectionVar = component.find("oppValueSection");  
                    $A.util.addClass(retailOppValueSectionVar, 'oppErrorSection');
                    $A.util.removeClass(oppValueError_MSG, 'slds-hide');
                    $A.util.addClass(oppValueError_MSG, 'slds-show');
                    submitREcord = false ;
                    
                }
            }
            
        } 
        
        //Probability Score
        var oppProb = component.find("Probability_Score").get("v.value");
        if(oppProb){
            oppProb = oppProb + '';
            if(!oppProb.match(numberRegex))
            {
                component.find("Probability_Score").set("v.errors",[{message:"Please Enter number only: "}]);
                submitREcord = false ;
            }
            else
            {
                component.find("Probability_Score").set("v.errors",null);
            }
        }
        
        //Expected Start Date
        if(!component.find("Expected_Start_Date").get("v.value")){
            component.find("Expected_Start_Date").set("v.errors",[{message:"Please Select Expected Start Date: "}]);
            submitREcord = false ;
        } else{ 
            component.find("Expected_Start_Date").set("v.errors",null);
        }
        
        //Expected Close Date:
        if(!component.find("Estimated_Close_Date").get("v.value")){
            component.find("Estimated_Close_Date").set("v.errors",[{message:"Please Select Expected Close Date: "}]);
            submitREcord = false ;
        } else {
            var date1 = new Date();
            var date2 = new Date(component.find("Estimated_Close_Date").get("v.value"));
            var timeDiff = Math.abs(date2.getTime() - date1.getTime());
            var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
            if (date2 < date1) {
                component.find("Estimated_Close_Date").set("v.errors",[{message:"Expected Close Date must be greater than Today, Please select a valid Close Date:"}]);
                submitREcord = false ;
            } else {   
                component.find("Estimated_Close_Date").set("v.errors",null);
            }
        }
        
        // Who is the competition?
        if(!component.find("PrimaryCompetitor").get("v.value")){
            component.find("PrimaryCompetitor").set("v.errors",[{message:"Please Enter Who is the competition?: "}]);
            submitREcord = false ;
        }else{
            component.find("PrimaryCompetitor").set("v.errors",null);
        } 
        
        console.log('==== Is Record submit ====',submitREcord);
        return submitREcord;
    }
})