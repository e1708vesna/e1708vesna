({
	createInvoiceFile : function(component) {
        var action = component.get("c.createInvoiceFileApex");
	    action.setParams({ 
	        "invoiceId": component.get("v.recordId")
	    });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                this.downloadCsv(response.getReturnValue());
            	$A.get('e.force:refreshView').fire();
            	$A.get("e.force:closeQuickAction").fire();
            } else {
            	$A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    downloadCsv : function(csvWraper) {
        // 6. To download table in CSV format.
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvWraper.csv);
        hiddenElement.target = '_blank';
        hiddenElement.download = csvWraper.title +'.csv'; 
        hiddenElement.click();
    }
})