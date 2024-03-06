({
	getRecords : function(component, event, helper) {
		var parentId=component.get("v.recordId");
		var historyType=component.get("v.historyType");
        var existingRecordArray=[];
        var action=component.get('c.getRecordInfoFiltered');
        
        action.setParams({
            parentId : parentId,
            historyType : historyType,
            includeStandardHistory : component.get("v.includeStandardHistory")
        });
        
        action.setCallback(this,function(response){     
            var state=response.getState();
            if(state==="SUCCESS")
            {
                
                component.set('v.objectName', response.getReturnValue()['objectName']);


				var recordList =response.getReturnValue()['records'];
                var timezone = $A.get("$Locale.timezone");
                for (var i = 0; i < recordList.length; i++){
					recordList[i].CreatedDate = $A.localizationService.formatDateTime(recordList[i].CreatedDate);
                    recordList[i].CreatedByName = recordList[i].CreatedByName;
                    recordList[i].CreatedByLink = '/' + recordList[i].CreatedById;
                }
                component.set('v.records', recordList);
                component.set('v.recordName', response.getReturnValue()['recordName']);
                
            }
            
        });
        $A.enqueueAction(action);
	}
})