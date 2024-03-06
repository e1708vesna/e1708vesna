({
    doInit: function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Title', fieldName: 'Title', type: 'text'},
            {label: 'Type', fieldName: 'FileType', type: 'text'},
            {label: 'Size', fieldName: 'FileSize', type: 'text'}
        ]);
        var action = component.get("c.getContentVersions");
        action.setParams({ recordId : component.get("v.recordId") });
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            console.log(response.getState());
            var state = response.getState();
            if (state === "SUCCESS") {
                var files = response.getReturnValue();
                
                //component.set("v.files", response.getReturnValue());
                const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
                const decimals = 0;
                for (var i = 0; i < files.length; i++) {
                    var byteSize = files[i].ContentSize;
                    if (byteSize === 0) return '0 Bytes';
                    
                    const k = 1024;
                    const dm = decimals < 0 ? 0 : decimals;
                    
                    const j = Math.floor(Math.log(byteSize) / Math.log(k));
                    
                    files[i].FileSize = parseFloat((byteSize / Math.pow(k, j)).toFixed(dm)) + ' ' + sizes[j];
                    //Do something
                    //For icon preview: Datatable does not support images. Use lightning web component instead.
                    files[i].previewUrl = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + files[i].LatestPublishedVersionId;
                }
                
                
                component.set("v.files", files);
                
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
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
            component.set('v.showSpinner', false);
        });
        
        // optionally set storable, abortable, background flag here
        
        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    },
    
    handleDownload : function (component, event, helper) {
        console.log('Download button was clicked ');
        
        let lines = [];
        lines = component.find('dataTable').getSelectedRows();
        console.log('Retrieved the selected rows ');
        console.log(lines);
        
        if (typeof lines !== 'undefined' && lines.length > 0) {
            console.log('Selected Rows was an array ');
            console.log(lines.length);
            var urlString = '/sfc/servlet.shepherd/version/download';
            for (var i = 0; i < lines.length; i++){
                console.log(lines[i]);
                console.log(lines[i]["LatestPublishedVersionId"]);
                urlString += '/' + lines[i]["LatestPublishedVersionId"];
            }
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": urlString
            });
            urlEvent.fire();
        }
        else {
            alert('Please select at least one file to download.');
        }
    }
})