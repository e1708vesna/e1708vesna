({
  setDeclined : function(component) {
        var action = component.get("c.declineUAC");
        action.setParams({ 
            "upgradeAssuranceContractId": component.get("v.recordId"),
            "decline": !(component.get("v.declined"))
        });
            
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            } else if (state === "ERROR") { 
                let errors = response.getError();
                console.log(errors);
                //let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    //message = errors[0].message;
                    this.handleErrors(errors);
                }
            }                
        });
        $A.enqueueAction(action);
  },
  getUac : function(component) {
        var action = component.get("c.getUac");
      action.setParams({ 
          "upgradeAssuranceContractId": component.get("v.recordId")
      });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.uac", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
  },
    handleErrors : function(errors) {
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: "Unknown error", // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    } 
})