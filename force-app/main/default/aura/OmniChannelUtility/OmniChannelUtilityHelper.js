({
    openOmniChannelUtility : function(component) {
        // if the work item is a high prioirty case, open Omni-Channel utility
        console.log('JVG In helper method openOmniChannelUtility');
        let utilityAPI = component.find("utilitybar");
        utilityAPI.getAllUtilityInfo()
            .then( function( response ) {
                // grab utility id of omni-channel
                for (let utilityInfo of response) {
                    console.log('JVG Label: ' + utilityInfo.utilityLabel);
                    if (utilityInfo.utilityLabel.startsWith("Omni-Channel")) {
                        // open omni-channel utility
                        console.log('JVG omni-channel found');
                        utilityAPI.openUtility( {utilityId: utilityInfo.id} );
                        break;
                    }
                }
            })
            .catch(function( error ) {
                console.log( 'Error occurred', JSON.stringify( error ) );
            });        
    }

})