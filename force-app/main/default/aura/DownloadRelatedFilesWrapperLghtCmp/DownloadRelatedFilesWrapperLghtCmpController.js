({
	handleExpand : function (component, event, helper) {
        var currentState = component.get('v.isExpanded');
        var nextState = !currentState;
        component.set('v.isExpanded', nextState);
    }
})