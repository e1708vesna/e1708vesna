global class HistoryRelatedListTypeSelector extends VisualEditor.DynamicPickList{

    global override VisualEditor.DataRow getDefaultValue(){
        List<VisualEditor.DataRow> values = new List<VisualEditor.DataRow>();
		Schema.DescribeFieldResult fieldResult = History__c.ObjectName__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            return new VisualEditor.DataRow(pickListVal.getLabel(), pickListVal.getValue());
		}
        return null;
    }
    
    global override VisualEditor.DynamicPickListRows getValues() {
        List<VisualEditor.DataRow> values = new List<VisualEditor.DataRow>();
		Schema.DescribeFieldResult fieldResult = History__c.ObjectName__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            VisualEditor.DataRow value = new VisualEditor.DataRow(pickListVal.getLabel(), pickListVal.getValue());
            values.add(value);
		}   
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues.addAllRows(values);
        return myValues;
    }
    
}