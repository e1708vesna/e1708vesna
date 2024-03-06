({
	getPrintableViewFileIdFromApex : function(component) {
        var action = component.get("c.getPrintableViewFileId");
	    action.setParams({ 
	        "uacId": component.get("v.recordId")
	    });
        
        action.setCallback(this, function(response) {
            $A.get("e.force:closeQuickAction").fire();
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
            	$A.get('e.force:refreshView').fire();
                $A.get('e.lightning:openFiles').fire({
                    recordIds: [response.getReturnValue()]
                });        
            }
        });
        $A.enqueueAction(action);
    },
})