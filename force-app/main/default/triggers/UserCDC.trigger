trigger UserCDC on UserChangeEvent (after insert) {
	List<UserChangeEvent> eventList = Trigger.new;
    Set<String> userRecordIds = new Set<String>();
    
    for (UserChangeEvent event : eventList) {
        // Get all Record Ids for this change and add to the set
        List<String> changedFields = event.ChangeEventHeader.getchangedfields();
        if (changedFields.contains('ManagerId')){
            userRecordIds.addAll(event.ChangeEventHeader.getrecordids());
        }
    }
    if (userRecordIds.size() > 0) {
        ExceptionRequestSharingUtil shareHelper = ExceptionRequestSharingUtil.getInstance();
        //SELECT ALL Members with the current user. Then select ALL Requests of those accounts
        Set<Id> accountIds = new Set<Id>();
        Set<Id> exceptionRequestIds = new Set<Id>();
        for (ExceptionRequestMember__c member : [SELECT ID, ExceptionRequest__c, ExceptionRequest__r.Account__c FROM ExceptionRequestMember__c WHERE User__c in: userRecordIds]){
            exceptionRequestIds.add(member.ExceptionRequest__c);
            if (member.ExceptionRequest__r.Account__c != null) {
                accountIds.add(member.ExceptionRequest__r.Account__c);
            }
        }
        exceptionRequestIds.addAll((new Map<Id,ExceptionRequest__c>([SELECT Id FROM ExceptionRequest__c WHERE Account__c in: accountIds])).keySet());
        if (exceptionRequestIds.size() > 0 ) {
            shareHelper.storeRecords(exceptionRequestIds);
            shareHelper.commitRecords();
        }
    }
}