({
	navigateDetailPage : function(component,event,index){
        var record = component.get("v.CaseList");
        var id = record[index].Id;
        console.log('id '+id);
        console.log('Id of account '+id);
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": id,
            "slideDevName": "detail"
        });
        navEvt.fire();        
    },
  
    sortHelper: function(component, event, field) {
        //alert('field: '+field);
      var arrowDirection = component.get("v.arrowDirection");
      var sortAsc = component.get("v.isAsc");  
      var sortField = component.get("v.selectedTabsoft");
        //alert('sortField: '+sortField);
        if(arrowDirection =='arrowup'){
            component.set("v.arrowDirection", 'arrowdown');
        }else{
            component.set("v.arrowDirection", 'arrowup');
        }
         var sortCaseList =  component.get('v.CaseList');
         sortAsc = field == sortField? !sortAsc: true;
          sortCaseList.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        console.log('after sort '+JSON.stringify(sortCaseList));
        component.set("v.isAsc", sortAsc);
        component.set('v.CaseList',sortCaseList); 
        
   },
})