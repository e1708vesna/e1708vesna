({
    doInit : function(component, event, helper) {
        var action = component.get("c.retrieveValues");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var wrapper = response.getReturnValue();
                if (wrapper.error) {
                    component.set("v.errorMessage", wrapper.error);
                }
                else {
                    component.set("v.cnt", wrapper.count + '');
                    if (wrapper.count != 0) {
                        component.set("v.calculatedValue", wrapper.value + '%');
                        component.set("v.mvm", wrapper.mvm + '');
                        component.set("v.vmoa", wrapper.vmoa + '');
                        component.set("v.currentMargin", wrapper.currentMargin + '');
                        component.set("v.additionalMargin", wrapper.additionalMargin + '');
                    }
                    else {
                        component.set("v.calculatedValue", '');
                        component.set("v.mvm", '');
                        component.set("v.vmoa", '');
                        component.set("v.currentMargin", '');
                        component.set("v.additionalMargin", '');
                    }
                }
                component.set("v.confidentialInformationId", wrapper.confidentialInformationId);
                component.set("v.loading", false);
            }
            else if (state === "INCOMPLETE") {
                component.set("v.errorMessage", "Something went wrong");
                console.log("incomplete");
                component.set("v.loading", false);
            }
                else if (state === "ERROR") {
                    var errorMessage = "";
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            errorMessage += errors[0].message;
                        }
                    } else {
                        errorMessage = "Unknown error";
                    }
                    component.set("v.errorMessage", errorMessage);
                    console.log(errorMessage);
                    component.set("v.loading", false);
                }
        });
        $A.enqueueAction(action);
    }
})