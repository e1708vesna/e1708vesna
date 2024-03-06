({
    doInit : function(cmp, event, helper) {
        
        var ref = cmp.get("v.pageReference");
        var state = ref.state; 
        var context = state.inContextOfRef;
        if (context.startsWith("1\.")) {
            context = context.substring(2);
            var addressableContext = JSON.parse(window.atob(context));
            console.log('addressableContext----->'+JSON.stringify(addressableContext));   // you can get your recordId and other things here.
            var recordId = addressableContext.attributes.recordId; console.log(recordId);
            cmp.set("v.recordId", recordId);
        }
        
        var flow = cmp.find("flowData");
        
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : recordId
            }
        ];
        
        flow.startFlow("ScreenNewRelationship", inputVariables );
    },
    
    closeModalOnFinish : function(cmp, event, helper) {
        var recordId = cmp.get("v.recordId");
        
        if(event.getParam("status") === "FINISHED") {
            
            var workspaceAPI = cmp.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            .catch(function(error) {
                console.log(error);
            });
            
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": recordId
            });
            navEvt.fire();
            
            //cmp.get('e.force:refreshView').fire();
        }
    },
    
    hideModal : function(cmp, event, helper){
        var recordId = cmp.get("v.recordId");
        
        $A.util.addClass(cmp.find('modalDialog'), 'removeDisplay');
        $A.util.removeClass(cmp.find('overlay'), 'slds-backdrop--open');
                            
        var workspaceAPI = cmp.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            .catch(function(error) {
                console.log(error);
            });
            
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": recordId
            });
            navEvt.fire();
    

    },
    
        
})