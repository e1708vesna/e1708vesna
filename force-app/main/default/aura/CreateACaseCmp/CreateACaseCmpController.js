({
    doInit : function (cmp, event, helper) {
        
        var sPageURL = decodeURIComponent(window.location.href.substring(1)); console.log(sPageURL); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('/r/'); //Split by & so that you get the key value pairs separately in a list
        console.log(sURLVariables);
        
        var recordId = ' ';
        if(sURLVariables.length > 1){
            recordId = sURLVariables[1].split('/')[1]; 
        }        
        console.log(recordId);
        
        var flow = cmp.find("flowData");
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : recordId
            },
            {
                name : "varURL",
                type : "String",
                value : sPageURL
            }
        ];
        
        flow.startFlow("Create_a_Case_Action", inputVariables );
    },
    
    closeModalOnFinish : function(cmp, event, helper) {
        if(event.getParam("status") === "FINISHED") {
            $A.get("e.force:closeQuickAction").fire();
            var workspaceAPI = cmp.find("workspace");
            workspaceAPI.getEnclosingTabId().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            .catch(function(error) {
                console.log(error);
        });
        }
        
    }
})