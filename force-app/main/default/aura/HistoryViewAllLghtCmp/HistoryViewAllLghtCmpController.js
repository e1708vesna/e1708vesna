({
	doInit : function(component, event, helper){
        component.set('v.columns', [
            {label: 'Date', fieldName: 'CreatedDateFormatted', type: 'text'},
            {label: 'Field', fieldName: 'FieldName', type: 'text'},
            {label: 'User', fieldName: 'CreatedByLink', type: 'url', typeAttributes: {
           			label: { fieldName: 'CreatedByName' }
       			}	
            },
            {label: 'Original Value', fieldName: 'OldValue', type: 'text', wrapText: true},
            {label: 'New Value', fieldName: 'NewValue', type: 'text', wrapText: true}
            
        ]);
        
        
        var pageReference = component.get("v.pageReference");
        if(pageReference!==undefined && pageReference!==null && pageReference.state!=null)
        {
            var recordId=pageReference.state.c__recordId; 
            component.set("v.recordId",recordId);
            var historyType=pageReference.state.c__historyType; 
            component.set("v.historyType",historyType);
            var includeStandardHistory=pageReference.state.c__includeStandardHistory; 
            component.set("v.includeStandardHistory", includeStandardHistory);
            console.log(component.get("v.includeStandardHistory"));
            
        }
        
        helper.getRecords(component, event, helper);
        
    }
})