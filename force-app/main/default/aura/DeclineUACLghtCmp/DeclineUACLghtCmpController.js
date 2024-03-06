({
    doInit : function(component, event, helper) {
    	helper.getUac(component);        
    },
	cancelButton : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
	acceptButton : function(component, event, helper) {
		helper.setDeclined(component);
	}
})