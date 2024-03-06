({
	retrieveEnvelopeConfigurations : function(component, event, helper) {
		var action=component.get('c.queryEnvelopeConfigurations');
        action.setParams({
            searchQuery : component.get("v.searchQuery"),
            region : component.get("v.region"),
            contractType : component.get("v.contractType"),
            salesChannel : component.get("v.salesChannel"),
            queryLimit : component.get("v.queryLimit")
        });
        
        action.setCallback(this,function(response){     
            var state=response.getState();
            if(state==="SUCCESS")
            {
                component.set('v.data', response.getReturnValue());
            }
            
        });
        $A.enqueueAction(action);
	},
    
    retrievePickListValues : function(component, event, helper) {
        
                console.log('PickList');
		var action=component.get('c.getPicklistValues');
        action.setCallback(this,function(response){     
            var state=response.getState();
            if(state==="SUCCESS")
            {
                var returnValue = response.getReturnValue();
                var fieldMapRegion = [];
                fieldMapRegion.push({value: "", label: "All"});
                for(var key in returnValue.Region){
                    fieldMapRegion.push({value: key, label: returnValue.Region[key]});
                }
                component.set("v.regionPickListValues", fieldMapRegion);
                var fieldMapContractType = [];
                fieldMapContractType.push({value: "", label: "All"});
                for(var key in returnValue.ContractType){
                    fieldMapContractType.push({value: key, label: returnValue.ContractType[key]});
                }
                component.set("v.contractTypePickListValues", fieldMapContractType);
                var fieldMapSalesChannel = [];
                fieldMapSalesChannel.push({value: "", label: "All"});
                for(var key in returnValue.SalesChannel){
                    fieldMapSalesChannel.push({value: key, label: returnValue.SalesChannel[key]});
                }
                component.set('v.salesChannelPickListValues', fieldMapSalesChannel);
            }
            
        });
        $A.enqueueAction(action);
	}
})