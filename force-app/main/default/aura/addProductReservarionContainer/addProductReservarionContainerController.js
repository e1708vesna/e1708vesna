({
    doInit : function(component, event, helper) {
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        var context = JSON.parse(window.atob(value));
        component.set("v.recordId", context.attributes.recordId);
            
    }
})