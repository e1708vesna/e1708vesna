/** Asynchronous Client-Side Controller **/
({
    invoke : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        console.log('workspaceAPI');
        console.log(workspaceAPI);
        console.log(JSON.stringify(workspaceAPI));
        
        console.log(JSON.stringify(workspaceAPI.getFocusedTabInfo().then(function(response) {
            
            console.log('response');
            var focusedTabId = response.tabId;
            console.log(JSON.stringify(focusedTabId));

            //Opening New Tab
            workspaceAPI.openTab({
                url: '#/sObject/0012800000GoPBQAA3/view'
            }).then(function(response) {
                workspaceAPI.focusTab({tabId : response});
            })
            .catch(function(error) {
                console.log(error);
            });

            //Closing old one
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            
            console.log('catch');
            console.log(error);
        })));
    },
    
    openTab : function(component, event, helper) {
        console.log('Button pressed');
        var workspaceAPI = component.find("workspace");
        console.log(JSON.stringify(workspaceAPI)); 
        
        workspaceAPI.openTab({
            url: '/flow/CASE_BulkMergeCases?ids=5007E00000EGk82QAD,5007E00000EGFDnQAP',
            focus: true
        }).then(function(response) {
            console.log(JSON.stringify(response));
            workspaceAPI.getTabInfo({
                tabId: response
            }).then(function(tabInfo) {
            console.log("The recordId for this tab is: " + tabInfo.recordId);
            });
        }).catch(function(error) {
                console.log(error);
        });
    }
})