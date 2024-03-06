({
	syncWithNavision : function(component) {
        if (component.get("v.syncOk")) {
            component.set("v.syncOk", false)

            var action = component.get("c.syncWithNavision");            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    this.enableSyncTimer(component);
                }
            });
            $A.enqueueAction(action);        
        }
    },
    enableSyncTimer : function(component) {
        var self=this;
        var ScrollTime = component.get("v.ScrollTime") * 3;
        var timeoutRef = window.setTimeout($A.getCallback(function() {
            if (component.isValid()) {
                self.enableSync(component, self);
            }
        }), ScrollTime);
    },    
    enableSync : function(component) {
        component.set("v.syncOk", true)
    },
	getStatus : function(component) {
        var action = component.get("c.getStatus");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.sbjList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    addTimer : function(component) {
        var self=this;
        var ScrollTime = component.get("v.ScrollTime");
        var timeoutRef = window.setInterval($A.getCallback(function() {
                if (component.isValid()) {
                    self.timerFired(component, self);
                }
        }), ScrollTime);
    },
    timerFired : function(component, helper) {
        helper.getStatus(component);
    }
})