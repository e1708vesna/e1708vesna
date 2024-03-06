({
	helperMethod : function(component) {
        var action = component.get("c.getPage");
        action.setParams({ targetUrl : component.get("v.sourceURL") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.targetURL", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);		
	}
})