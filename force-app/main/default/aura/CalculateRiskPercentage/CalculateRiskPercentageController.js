({
	AddToSection : function(cmp, event, helper) {
        
        var DisplaySectionWeightage=cmp.get("v.DisplaySectionWeightage");
        DisplaySectionWeightage = DisplaySectionWeightage+Number(event.getSource().get("v.text"));
        cmp.set("v.DisplaySectionWeightage",Number(DisplaySectionWeightage));
        var Result = ((cmp.get("v.DisplaySectionWeightage"))/cmp.get("v.WeightagePerSection"))*100;
        cmp.set("v.Result",cmp.get("v.DisplaySectionWeightage"));
        var FieldApi = event.getSource().get("v.name");
        var Recordarray = [];
        var obj = {};
		obj['Id'] = cmp.get("v.RecordId");
        obj[FieldApi]=true;
        obj['Opportunity__c']= cmp.get('v.OppId');
        Recordarray.push(obj);
        //alert('Record Array'+Recordarray);
        console.log('>>>>>>>>>>>>>>>>>'+JSON.stringify(Recordarray));
        helper.UpsertRecord(cmp,event,JSON.stringify(Recordarray));
        
       
	},
    SubtractFromSection:function(cmp, event, helper){
        if(cmp.get("v.Result") > 0){
            
            var DisplaySectionWeightage=cmp.get("v.DisplaySectionWeightage");
            DisplaySectionWeightage = DisplaySectionWeightage-Number(event.getSource().get("v.text"));
            cmp.set("v.DisplaySectionWeightage",Number(DisplaySectionWeightage));
            var Result = ((cmp.get("v.DisplaySectionWeightage"))/cmp.get("v.WeightagePerSection"))*100;
            cmp.set("v.Result",cmp.get("v.DisplaySectionWeightage"));
            var FieldApi = event.getSource().get("v.name");
            var Recordarray = [];
            var obj = {};
            obj['Id'] = cmp.get("v.RecordId");
            obj[FieldApi]=false;
            Recordarray.push(obj);
            helper.UpsertRecord(cmp,event,JSON.stringify(Recordarray));
        }
       
    }
})