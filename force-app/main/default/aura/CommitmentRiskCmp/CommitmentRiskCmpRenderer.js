({
	afterRender : function(cmp,helper) {
     this.superAfterRender();
	 helper.GetRecordValuesHelper(cmp);      
	},
})