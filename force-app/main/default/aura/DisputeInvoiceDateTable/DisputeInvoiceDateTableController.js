({
	doInit : function(cmp, event, helper) {
         var obj=JSON.parse(cmp.get("v.InvoiceTableData"));
         cmp.set("v.CurrencyCode",obj[0].CurrencyCode);
         cmp.set("v.TableDataParesd",obj);
	}
})