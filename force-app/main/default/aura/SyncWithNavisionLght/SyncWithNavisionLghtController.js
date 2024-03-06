({
    doInit : function(component, event, helper) {        
        helper.getStatus(component);
        helper.addTimer(component);
    },
    syncNav : function(component, event, helper) {
        helper.syncWithNavision(component);
    }
})