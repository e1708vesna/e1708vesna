({
    init : function(component, event, helper) {
        
        
        var sObjectType;
        var recordId;
        try {
            let addressableContext = JSON.parse(window.atob(helper.getParameterByName(component , event, 'inContextOfRef')));
            if (addressableContext.type == "standard__recordPage") {
                var sObjectType = addressableContext.attributes.objectApiName;
                var recordId = addressableContext.attributes.recordId;
            }
        }
        catch (error){
            //do nothing
        }
        var flow = component.find("flowData");
        if (recordId == null) {
            recordId = "";
        }
        var inputVariables = [
            { name : "recordId", type : "String", value: recordId }
        ];
        flow.startFlow("Screen_Create_Handover", inputVariables);
    },
    
    handleClose : function(component, event, helper){
        try {
            let addressableContext = JSON.parse(window.atob(helper.getParameterByName(component , event, 'inContextOfRef')));
            if (addressableContext.type == "standard__recordPage") {
                var sObjectType = addressableContext.attributes.objectApiName;
                var recordId = addressableContext.attributes.recordId;
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": recordId,
                    "slideDevName": "related"
                });
                navEvt.fire();
            }
            else {
                var homeEvt = $A.get("e.force:navigateToObjectHome");
                homeEvt.setParams({
                    "scope": "Handover__c"
                });
                homeEvt.fire();
            }
        }
        catch (error){
            var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({
                "scope": "Handover__c"
            });
            homeEvt.fire();
        }
        //if it is in the a console app:
        helper.closeCurrentTab(component, event, helper);
    },
    handleStatusChange : function (component, event, helper) {
        console.log('status change detected');
        if(event.getParam("status") === "FINISHED") {
            console.log('status change to FinISHED');
            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            var recordId;
            for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                // Pass the values to the component's attributes
                if(outputVar.name === "retRecordId") {
                    recordId = outputVar.value;
                } 
            }
            console.log(recordId);
            console.log(recordId != null);
            if (recordId != null) {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": recordId,
                    "slideDevName": "related"
                });
                navEvt.fire();
            }
            else {
                var homeEvt = $A.get("e.force:navigateToObjectHome");
                homeEvt.setParams({
                    "scope": "Handover__c"
                });
                homeEvt.fire();
            }
            //if it is in the a console app:
            
        	helper.closeCurrentTab(component, event, helper);
            //var dismissActionPanel = $A.get("e.force:closeQuickAction");
            //dismissActionPanel.fire();
        }
    }
})