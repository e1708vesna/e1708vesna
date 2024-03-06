public class EmailWrapper {
    @AuraEnabled @InvocableVariable
    public String mappingName;
    @AuraEnabled @InvocableVariable
    public Id recordId;
}