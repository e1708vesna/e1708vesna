({
    init : function(component, event, helper) {
        helper.helperMethod(component);
        
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__webPage',
            attributes: {
                url: component.get("v.targetURL")
            }
        };
        component.set("v.pageReference", pageReference);
        // Set the URL on the link or use the default if there's an error
        var defaultUrl = "#";
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                component.set("v.targetURL", url ? url : defaultUrl);
            }), $A.getCallback(function(error) {
                component.set("v.targetURL", defaultUrl);
        }));
    },
    handleClick: function(component, event, helper){
		var urlval = component.get("v.targetURL");
		var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            if(response == true) {
                workspaceAPI.openTab({
                    url: urlval,
                    focus: true
                }).then(function(response) {
                    workspaceAPI.getTabInfo({
                        tabId: response
                    }).then(function(tabInfo) {
                    console.log("The recordId for this tab is: " + tabInfo.recordId);
                    });
                }).catch(function(error) {
                        console.log(error);
                });
			} else {
				window.open(urlval);
			}
        })
        .catch(function(error) {
            console.log(error);
        });
	}   
})