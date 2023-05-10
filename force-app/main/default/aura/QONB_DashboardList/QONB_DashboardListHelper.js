({
    convertArrayOfObjectsToCSV : function(component,objectRecords,keys){
        // declare variables
        var csvStringResult, counter, columnDivider, lineDivider;
       
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
 
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        // keys = ['QuoteNo','Owner','OpportunityNumber','OpportunityValue','QuoteTotal','DateModified','HW SW Status','Maintenance Support Status','Financial Call Off' ];
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
           
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
 
              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   } 
                 if(objectRecords[i][skey]){
                      csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                 }else{
                     csvStringResult += ''; 
                 }
               
              
               
               counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
          }// outer main for loop close 
       
       // return the CSV formate String 
        return csvStringResult;        
    },
	expandHelper : function(component, event, helper) {
    	var whichOne = event.getSource().getLocalId();
        if( whichOne == 'section_A_Collapse' ){
            this.showHideThing( component, 'section_A', 'slds-is-expanded', 'slds-is-collapsed' );
            this.showHideThing( component, 'section_A_Collapse', 'slds-hide', '' );
            this.showHideThing( component, 'section_A_Expand', '', 'slds-hide' );
        }
        if( whichOne == 'section_B_Collapse' ){
            this.showHideThing( component, 'section_B', 'slds-is-expanded', 'slds-is-collapsed' );
            this.showHideThing( component, 'section_B_Collapse', 'slds-hide', '' );
            this.showHideThing( component, 'section_B_Expand', '', 'slds-hide' );
        }
        if( whichOne == 'section_C_Collapse' ){
            this.showHideThing( component, 'section_C', 'slds-is-expanded', 'slds-is-collapsed' );
            this.showHideThing( component, 'section_C_Collapse', 'slds-hide', '' );
            this.showHideThing( component, 'section_C_Expand', '', 'slds-hide' );
        }
    },
    collapseHelper : function(component, event, helper) {
    	var whichOne = event.getSource().getLocalId();
        if( whichOne == 'section_A_Expand' ){
            this.showHideThing( component, 'section_A', 'slds-is-collapsed', 'slds-is-expanded');
            this.showHideThing( component, 'section_A_Collapse', '', 'slds-hide' );
            this.showHideThing( component, 'section_A_Expand', 'slds-hide', '' );
        }
        if( whichOne == 'section_B_Expand' ){
            this.showHideThing( component, 'section_B', 'slds-is-collapsed', 'slds-is-expanded');
            this.showHideThing( component, 'section_B_Collapse', '', 'slds-hide' );
            this.showHideThing( component, 'section_B_Expand', 'slds-hide', '' );
        }
        if( whichOne == 'section_C_Expand' ){
            this.showHideThing( component, 'section_C', 'slds-is-collapsed', 'slds-is-expanded');
            this.showHideThing( component, 'section_C_Collapse', '', 'slds-hide' );
            this.showHideThing( component, 'section_C_Expand', 'slds-hide', '' );
        }
    },
    showHideThing : function(component, id, addClassName, removeClassName) {
        var section = component.find( id ); 
        $A.util.removeClass(section, removeClassName);
        $A.util.addClass(section, addClassName);
    }
})