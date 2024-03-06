({
	init: function (component, event, helper) {
        /*component.set('v.columns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Description', fieldName: 'Description__c', type: 'text'},
            {label: 'Contract Type', fieldName: 'ContractType__c', type: 'text', initialWidth: 250},
            {label: 'Region', fieldName: 'ContractCountryCurrency__c', type: 'text', initialWidth: 200},
            {label: 'Sales Channel', fieldName: 'SalesChannel__c', type: 'text', initialWidth: 100}
        ]);*/
        component.set('v.columns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Description', fieldName: 'Description__c', type: 'text'}
        ]);
        // Figure out which buttons to display
        var availableActions = component.get('v.availableActions');
        for (var i = 0; i < availableActions.length; i++) {
            if (availableActions[i] == "PAUSE") {
                component.set("v.canPause", true);
            } else if (availableActions[i] == "BACK") {
                component.set("v.canBack", true);
            } else if (availableActions[i] == "NEXT") {
                component.set("v.canNext", true);
            } else if (availableActions[i] == "FINISH") {
                component.set("v.canFinish", true);
            }
        }
        helper.retrievePickListValues(component, event, helper);
        helper.retrieveEnvelopeConfigurations(component, event, helper);
    },
    
    updateSelectedTemplate: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        if (selectedRows.length == 0){
            component.set("v.templateId", "");
        }
        else {
            component.set("v.templateId", selectedRows[0].Id);
        }
    },
    
    
    handleOnChange : function(component, event, helper) {
        var delay = 150;
        
        var timer = component.get('v.timer');
        
        // 0.6 seconds delay after last input
        
        
        
        clearTimeout(timer);
        
        //timer = setTimeout(helper.retrieveEnvelopeConfigurations(component, event, helper), delay);
        timer = setTimeout(
            $A.getCallback(function() {
                helper.retrieveEnvelopeConfigurations(component, event, helper)
            }), 
            delay);
        
        component.set('v.timer', timer);
    },
    
    
    
        
   onButtonPressed: function(component, event, helper) {
      // Figure out which action was called
      var actionClicked = event.getSource().getLocalId();
      // Fire that action
      var navigate = component.get('v.navigateFlow');
      navigate(actionClicked);
   }
})