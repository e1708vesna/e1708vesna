({
    invoke : function(component, event, helper) {
        console.log('nav to url');
        /*return new Promise(function(resolve, reject) {
            window.open( '/flow/CASE_BulkMergeCases?ids=5007E00000EGk82QAD,5007E00000EGFDnQAP', '_blank', features = '');
            resolve();
            
        });*/
        /*$A.get("e.force:navigateToURL").setParams({ 
                "url": "/flow/CASE_BulkMergeCases?ids=5007E00000EGk82QAD,5007E00000EGFDnQAP" 
            }).fire();*/
        
        return new Promise(function(resolve, reject) {        
            
            var url = component.get("v.url");
            var mode = component.get("v.mode");
            var target = '_blank';
            var features = '';
            
            switch (mode) {
                case 'replace':
                    target = '_self';
                    break;
                case 'newWindow':
                    features = features + 'height=100';
                    break;
                default:
                    break;
            }
    
            window.open( url, target, features );
            resolve();
               
        });
    }
})