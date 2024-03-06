({
    onWorkAssigned : function( component, event, helper ) {
        let paramStr = JSON.stringify(event.getParams(), null, 4); 
        var action = component.get("c.getAgentWorkDetails");
        action.setParams({ agentWorkId : event.getParams().workId });
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var workRecord = response.getReturnValue();
                if (workRecord && (workRecord.IsStatusChangeInitiated || workRecord.IsOwnerChangeInitiated )) {
                    var omniAPI = component.find("omniToolkit");
                        omniAPI.acceptAgentWork({workId: event.getParams().workId}).then(function(res) {
                            //Log something if you want.
                        }).catch(function(error) {
                            console.log(error);
                        });      
                }
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})