({
    onWorkAssigned : function( component, event, helper ) {
        let paramStr = JSON.stringify(event.getParams(), null, 4); 
        console.log('JVG All Params: ' + paramStr);

        // get details of the work item;  and what is the priority of the case
        let workItemId = event.getParam('workItemId');
        if (workItemId.startsWith('500')) {
            // if it is related to a case, retrieve the priority of that case
            console.log('JVG Load record');
            component.set('v.recordId', workItemId);
        }        
    },

    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            // record is loaded
            console.log('JVG Record is loaded successfully.');
            helper.openOmniChannelUtility(component);
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    }

})