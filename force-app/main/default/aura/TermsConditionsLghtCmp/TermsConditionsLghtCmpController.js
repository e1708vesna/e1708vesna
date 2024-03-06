({
    doInit : function(component, event, helper) {
    	helper.getTermsAndConditionsFileId(component);
    	helper.getFieldParams(component);
    	helper.getUac(component);        
    },
    openSingleFile: function(component, event, helper) {
    	$A.get('e.lightning:openFiles').fire({
    		recordIds: [component.get("v.termAndConditionsFileId")]
    	});
    },
	cancelButton : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
	acceptButton : function(component, event, helper) {
		helper.acceptTAC(component);
	},
	handleFlowStatusChange : function (component, event) {
		if(event.getParam("status") === "FINISHED") {
           	//$A.get('e.force:refreshView').fire();
           	//$A.get("e.force:closeQuickAction").fire();
		}
	}
})