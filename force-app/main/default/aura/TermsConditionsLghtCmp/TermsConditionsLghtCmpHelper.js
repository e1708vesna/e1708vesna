({
	getTermsAndConditionsFileId : function(component) {
        var action = component.get("c.getApexTermsAndConditionsFileId");
        var termAndConditions = $A.get("$Label.c.TermAndConditionsFile");
        console.log('termAndConditions: '+termAndConditions);
	    action.setParams({ 
	        "title": termAndConditions
	    });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.termAndConditionsFileId", response.getReturnValue());
                console.log("termAndConditionsFileId "+response.getReturnValue())
            }
        });
        $A.enqueueAction(action);
	},
	acceptTAC : function(component) {
        var uac = component.get("v.uac");
        if (this.validate(component, uac)==true) {
            var action = component.get("c.acceptTermAndConditions");
            action.setParams({ 
                "upgradeAssuranceContract": component.get("v.uac")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    $A.get('e.force:refreshView').fire();
                    //var flow = component.find("flowData");
                    //flow.startFlow("Accept_Terms");
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
        }
	},
	validate : function(component, uac) {
        var result = true;
       	var inputAcceptCmp = component.find("inputAcceptCmp");
       	var inputSignedByCmp = component.find("inputSignedByCmp");
       	var inputEmailCmp = component.find("inputEmailCmp");
        if (uac.AcceptTermsAndConditions__c) {
        	inputAcceptCmp.set("v.errors", null);
        } else {
        	inputAcceptCmp.set("v.errors", [{message:"Please select Agree before Accept!"}]);
            result = false;
        }
        if (uac.SignedBy__c) {
        	inputSignedByCmp.set("v.errors", null);
        } else {
        	inputSignedByCmp.set("v.errors", [{message:"Please fill in your Name!"}]);
            result = false;
        } 
        if (uac.Email__c) {
        	inputEmailCmp.set("v.errors", null);
        } else {
        	inputEmailCmp.set("v.errors", [{message:"Please fill in your Email!"}]);
            result = false;
        }
        return result;
	},	
	getUac : function(component) {
        var action = component.get("c.getUAC");
	    action.setParams({ 
	        "upgradeAssuranceContractId": component.get("v.recordId")
	    });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.uac", response.getReturnValue());
                if (response.getReturnValue().AcceptTermsAndConditions__c === true) {
                	component.set("v.accepted", true);
                }
            }
        });
        $A.enqueueAction(action);
	},
	getFieldParams : function(component) {
        var action = component.get("c.getFieldParams");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.uacFieldParamsMap", response.getReturnValue());
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