({
	GetRecordValuesHelper : function(cmp) {
		var SectionList=[];
		var action = cmp.get("c.GetCommitmentRiskCustomMetaDataValues");
        //alert(cmp.get("v.OppId"));
        action.setParams({ OppId : cmp.get("v.OppId") });

        action.setCallback(this, function(response) { 
            var state = response.getState();
  			var SumOfAllSectionWeightage=0; 
            if (state === "SUCCESS") { 
                var map = response.getReturnValue();      
                cmp.set("v.myMap",response.getReturnValue());
                console.log(JSON.stringify(response.getReturnValue())); 
                var FirstNumber=0;
                var SecondNumber=0;
                for(var i=0;i<response.getReturnValue().length;i++){
                    //alert(response.getReturnValue()[i].SectionWeightage);
                    FirstNumber=FirstNumber+response.getReturnValue()[i].SectionWeightage;
                    SecondNumber=SecondNumber+response.getReturnValue()[i].SectionWeightageIfyes;
                    //alert(response.getReturnValue()[i].SectionWeightageIfyes);
                }
                SumOfAllSectionWeightage=(SecondNumber/FirstNumber)*100;
                cmp.set("v.SumOfAllSectionWeightage",SumOfAllSectionWeightage);
            }
            else if (state === "INCOMPLETE") {
               
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
		
        $A.enqueueAction(action);
    }
})