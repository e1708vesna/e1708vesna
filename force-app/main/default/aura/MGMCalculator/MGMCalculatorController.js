({
    doInit : function(component, event, helper) {
        component.set("v.loading", true);
        var action = component.get("c.initComponent");
        console.log('recordId: ' + component.get("v.recordId"));
        //if (component.get("v.recordId") != null && component.get("v.recordId") != '') {
            action.setParams({ recordId : component.get("v.recordId") });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var wrapper = response.getReturnValue();
                    if (wrapper != null) {
                        if (wrapper.error) {
                            component.set("v.errorMessage", wrapper.error);
                        }
                        else {
                            component.set("v.errorMessage", "");
                            console.log(wrapper.salesChannel);
                            console.log(wrapper.pillar);
                            console.log(wrapper.proccessingVolume);
                            component.set("v.shopperInteraction", wrapper.salesChannel);
                            component.set("v.pillar", wrapper.pillar);
                            component.set("v.monthlyProcessingVolume", wrapper.proccessingVolume);
                            component.set("v.currencyIsoCode", wrapper.currencyIsoCode);
                            
                        }
                    }
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
                        if (errorMessage.includes("You do not have access to the Apex class")){
                            console.log('No Access');
                            console.log($A.get("$Label.c.MGMNoAccess"));
                            errorMessage = $A.get("$Label.c.MGMNoAccess");
                            component.set("v.controllerAccess", false);
                        }
                        component.set("v.errorMessage", errorMessage);
                        console.log(errorMessage);
                        component.set("v.loading", false);
                    }
                component.set("v.loading", false);
            });
            $A.enqueueAction(action);
        //}
        //else {
        //    component.set("v.loading", false);
        //}
    },
    
    retrieveMargin : function(component, event, helper){
        component.set("v.loading", true);
        console.log('component.get("v.monthlyProcessingVolume")');
        console.log(component.get("v.monthlyProcessingVolume"));
        if(component.get("v.monthlyProcessingVolume") == null){
            component.set("v.errorMessage", "You need to fill in the Processing Volume in order to calculate the Expected Margin.");
            component.set("v.loading", false);
            return;
        }
        else {
        var action = component.get("c.calculateMonthlyMargin");
        //(Decimal proccessingVolume, String pillar, String salesChannel
        action.setParams({ proccessingVolume : component.get("v.monthlyProcessingVolume"),
                          pillar : component.get("v.pillar"),
                          salesChannel : component.get("v.shopperInteraction"),
                          currencyIsoCode : component.get("v.currencyIsoCode")
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var wrapper = response.getReturnValue();
                if (wrapper.error) {
                    component.set("v.errorMessage", wrapper.error);
                    component.set('v.ExpectedMonthlyMargin', null);
                }
                else {
                    component.set("v.errorMessage", "");
                    var value = wrapper.monthlyMargin;
                    component.set('v.ExpectedMonthlyMargin', value);
                    component.set('v.returnedCurrencyIsoCode', wrapper.currencyIsoCode);
                }
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
                    if (errorMessage.includes("You do not have access to the Apex class")){
                            console.log('No Access');
                            console.log($A.get("$Label.c.MGMNoAccess"));
                            errorMessage = $A.get("$Label.c.MGMNoAccess");
                            component.set("v.controllerAccess", false);
                    }
                    component.set("v.errorMessage", errorMessage);
                    console.log(errorMessage);
                    component.set("v.loading", false);
                }
            
            component.set("v.loading", false);
        });
        $A.enqueueAction(action);
        }
    },
    
    saveOpportunity : function(component, event, helper){
        
        
        component.set("v.loading", true);
        var action = component.get("c.pushToOpportunity");
        action.setParams({
            recordId : component.get("v.recordId"),
            proccessingVolume : component.get("v.monthlyProcessingVolume"),
            monthlyGrossMargin : component.get("v.ExpectedMonthlyMargin"),
            currencyIsoCode : component.get("v.currencyIsoCode")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "The Opportuntiy has been updated."
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
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
                    errorMessage = "An error occured while updating the opportunity." + errorMessage;
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : "error",
                        "message": errorMessage
                    });
                    toastEvent.fire();
                }
            
            component.set("v.loading", false);
        });
        $A.enqueueAction(action);
        
    }
})