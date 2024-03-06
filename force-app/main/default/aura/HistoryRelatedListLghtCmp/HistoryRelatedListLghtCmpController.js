({
	doInitialization : function (component, event, helper) {
        component.set('v.columns', [
            {label: 'Date', fieldName: 'CreatedDateFormatted', type: 'text', wrapText: true},
            {label: 'Field', fieldName: 'FieldName', type: 'text'},
            {label: 'User', fieldName: 'CreatedByLink', type: 'url', typeAttributes: {
           			label: { fieldName: 'CreatedByName' }
       			}	
            },
            {label: 'Original Value', fieldName: 'OldValue', type: 'text', wrapText: true},
            {label: 'New Value', fieldName: 'NewValue', type: 'text', wrapText: true}
        ]);
        
        
        
        var parentId=component.get("v.recordId");
        var existingRecordArray=[];
        var title="History";
        var action=component.get('c.getHistory');
        var maxItems = component.get("v.maxItems");
        var historyType = component.get("v.historyType");
        console.log('HistoryType: ' + historyType);
        action.setParams({
            parentId : parentId,
            maxItems : maxItems,
            historyType : historyType,
            includeStandardHistory : component.get('v.includeStandardHistory')
        });
        
        action.setCallback(this,function(response){     
            var state=response.getState();
            if(state==="SUCCESS")
            {
                var recordList;
                if (response.getReturnValue().length > maxItems) {
                    recordList = response.getReturnValue().slice(0,maxItems);
                    component.set('v.noRecordsAddition', '+');
                }
                else {
                    recordList = response.getReturnValue();
                    component.set('v.noRecordsAddition', '');
                }
                var timezone = $A.get("$Locale.timezone");
                for (var i = 0; i < recordList.length; i++){
                    
					recordList[i].CreatedDate = $A.localizationService.formatDateTime(recordList[i].CreatedDate);
                    recordList[i].CreatedByName = recordList[i].CreatedByName;
                    recordList[i].CreatedByLink = '/' + recordList[i].CreatedById;
                }
                component.set('v.records', recordList);
            }
            
        });
        $A.enqueueAction(action);
    }
})