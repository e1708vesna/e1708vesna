({
    doInit : function(component, event, helper) {
        var showSidebar = helper.getCookie('showSidebar');
        component.set('v.showSidebar', showSidebar);
    },

    toggleSection : function(component, event, helper) {
        // update showSidebar variable
        var showSidebar = !component.get('v.showSidebar');
        component.set('v.showSidebar', showSidebar);

        // save as cookie
        helper.setCookie('showSidebar', showSidebar);
    },

})