({
    init : function (component) {
        // Find the component whose aura:id is "flowData"
        const flow = component.find("flowData");
        // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("CreateAmClaim");
    },
})