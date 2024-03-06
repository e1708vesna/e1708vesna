({
    init : function(component, event, helper) {
        
        var action = component.get("c.getEcommercePartnerss");
        var recordId = component.get("v.recordId");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var wrapper = response.getReturnValue();
                
                component.set("v.data", wrapper.partnerData);
                component.set("v.partner404", wrapper.partnersNotFound);
                component.set("v.partnerExisting", wrapper.partnersExisting);
            }
            console.log("Setting spinner false");
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    
    insertPartners : function(component, event, helper, lines) {
        
        component.set("v.showSpinner", true);
        var action = component.get("c.insertPartners");
        var recordId = component.get("v.recordId");
        console.log(JSON.stringify(lines));
        action.setParams({
            recordId: recordId,
            accList: lines
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('success');
                component.set('v.done', true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: 'success',
                    mode: 'dismissible',
                    title: 'Success!',
                    message: 'Partner(s) succesfully created!'
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            }
            else if (state === "ERROR") {
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                // 
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log(JSON.stringify(errors[0]));
                    console.log(errors[0].message);
                    message = errors[0].message;
                }
                component.set("v.error", message);
                // Display the message
                console.error(message);
            }
            
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    
    sortBy: function(field, reverse, primer) {
        var key = primer
        ? function(x) {
            return primer(x[field]);
        }
        : function(x) {
            return x[field];
        };
        
        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
})