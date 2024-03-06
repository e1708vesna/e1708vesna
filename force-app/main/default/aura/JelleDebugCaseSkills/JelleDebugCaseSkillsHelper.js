({
	getSkills : function(cmp) {
		var action = cmp.get("c.serverEcho");
        action.setParams({ caseId : cmp.get("v.recordId") });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var dataList = response.getReturnValue();
                if (dataList) {
                    let i = 0;
                    
                    while (i < dataList.length) {
                        if (dataList[i].Skill){
                            dataList[i].SkillDeveloperName = dataList[i].Skill.DeveloperName;
                            dataList[i].SkillLabel = dataList[i].Skill.MasterLabel;
                        }
                        i++;
                    }
                    cmp.set("v.data", dataList);
                    
                    // You would typically fire a event here to trigger 
                    // client-side notification that the server-side 
                    // action is complete
                }
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        // optionally set storable, abortable, background flag here

        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    }
})