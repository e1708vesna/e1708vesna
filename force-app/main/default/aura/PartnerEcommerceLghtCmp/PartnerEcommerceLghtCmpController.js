({
    doInit : function(component, event, helper) {
        console.log('init');
        component.set('v.columns', [
            {label: 'Partner Name', fieldName: 'partnerName', type: 'text'},
            {label: 'Account name', fieldName: 'url', type: 'url', typeAttributes: {
           						label: { fieldName: 'accountName' },
                				target: '_blank'
            }},
            {label: 'Platform Partner?', fieldName: 'platform', type: 'boolean'},
            
            
            
            
        ]);
        helper.init(component, event, helper);
    },
            
    getSelectedRows: function(component, event, helper){
        
        component.set("v.error", "");
        let lines = [];
        var datatable = component.find("dataTable");
        lines = datatable.getSelectedRows();
        console.log(JSON.stringify(lines));
        if (lines.length > 0) {
            helper.insertPartners(component, event, helper, lines);
        }
    }
})