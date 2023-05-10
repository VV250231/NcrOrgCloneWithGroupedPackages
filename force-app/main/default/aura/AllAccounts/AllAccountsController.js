({
   search: function(component, event, helper) {
       component.set("v.ofset",0);
               component.set("v.inf",true);
	  helper.getcount(component);
   }
    ,
    more: function(component, event, helper) {
       	component.set("v.ofset",25+component.get("v.ofset"));
        console.log(component.get("v.ofset"));
        component.set("v.inf",false);

        helper.search(component);
       console.log("Called"); 
      //helper.search(component); 
   }
})