({
	cloneUAC : function(component) {
        var action = component.get("c.cloneUpgrAssContr");
	    action.setParams({ 
	        "upgrAssContrId": component.get("v.recordId")
	    });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var status = response.getReturnValue();
                if (status.length == 18) {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                    "recordId": status
                    });
                    navEvt.fire();            
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    component.set("v.status", status);
                }
            } else {
            	component.set("v.status", "Server call failed for Clone Upgrade Assurance Contract");
            }
        });
        $A.enqueueAction(action);
    },
	close : function(component) {
        $A.get("e.force:closeQuickAction").fire();
    }
})