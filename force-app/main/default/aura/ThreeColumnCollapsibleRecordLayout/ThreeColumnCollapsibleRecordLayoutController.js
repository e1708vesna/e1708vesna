({
    toggleLeftSection : function(component, event, helper) {
        component.set('v.isLeftSidebarCollapsed', !component.get('v.isLeftSidebarCollapsed'));
    },

    toggleRightSection : function(component, event, helper) {
        component.set('v.isRightSidebarCollapsed', !component.get('v.isRightSidebarCollapsed'));
    }
})