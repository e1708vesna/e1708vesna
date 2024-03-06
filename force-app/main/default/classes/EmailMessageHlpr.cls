/*
 * @name EmailMessageHlpr
 * @author Service
 * @group Trigger Handler
 * @description This class implements the logic for the EmailMessage Trigger.
**/
public class EmailMessageHlpr {
    
    /* @Description Clones the related case when the Case has been closed, and should not be reopened anymore. It clones the related case and reparents the EmailMessage.
    * @Param newEmailMessages List of email messages to process
    */
    public static void cloneClosedCaseBeforeInsert(List<EmailMessage> newEmailMessages){
        if (FeatureManagement.checkPermission('BypassCaseTriggerValidationMigration')){
            return;
        }
        try {
            integer caseDescriptionMaxLength = Schema.SObjectType.Case.fields.Description.getLength();
            integer caseSubjectMaxLength = Schema.SObjectType.Case.fields.Subject.getLength();
            Map<Id, Case> clonedCasesByMasterId = new Map<Id, Case>();
            List<EmailMessage> emailMessagesToProcess = new List<EmailMessage>();
            Set<Id> caseIds = new Set<Id>();
            for (EmailMessage em : newEmailMessages){
                if (em.ParentId != null) {
                    caseIds.add(em.ParentId);
                    emailMessagesToProcess.add(em);
                }
            }
            if (caseIds.size() > 0) {
                Map<Id, Case> casesById = new Map<Id, Case>(queryCases(caseIds));
                for (EmailMessage em : emailMessagesToProcess){
                    if (!em.ClonedEmail__c && 
                        em.Incoming && 
                        ( casesById.get(em.ParentId).RecordTypeId == Constants.RT_ID_CASE_SERVICECASE || casesById.get(em.ParentId).RecordTypeId == Constants.RT_ID_CASE_INTERNALCASE || casesById.get(em.ParentId).RecordTypeId == Constants.RT_ID_CASE_SUPPORTCASE) &&
                        ( !casesById.get(em.ParentId).IsShopperCase__c || casesById.get(em.ParentId).ShopperCaseAllowed__c ) &&
                        !'Blocked Email'.equals(casesById.get(em.ParentId).AutoCloseReason__c) &&
                        !em.FromAddress.contains('adyen.com') &&
                        casesById.get(em.ParentId).IsClosed &&
                        casesById.get(em.ParentId).TimeToReopen__c == null
                       ){
                           Case clone = casesById.get(em.ParentId).clone();
                           clonedCasesByMasterId.put(em.ParentId, clone);
                       }
                }
                insert clonedCasesByMasterId.values();
            }
            
            //Reparent the EmailMessage to the newly created Case. Also replace the threading tokens in the emailmessage.
            for (EmailMessage em : emailMessagesToProcess){
                if (clonedCasesByMasterId.containsKey(em.parentId)){
                    String oldThreadingToken = EmailMessages.getFormattedThreadingToken(em.parentId);
                    em.parentId = clonedCasesByMasterId.get(em.parentId).Id;
                    String newThreadingToken= EmailMessages.getFormattedThreadingToken(em.parentId);
                    em.TextBody = em.TextBody?.replace(oldThreadingToken, newThreadingToken);
                    em.HtmlBody = em.HtmlBody?.replace(oldThreadingToken, newThreadingToken);
                    em.Subject = em.Subject?.replace(oldThreadingToken, newThreadingToken);
                }
            }
        }	
        //Catch the error, do not throw an error. Otherwise the emailmessage is lost.
        catch (exception e){
            List<ApexDebugLog.Error> errorLogs = new List<ApexDebugLog.Error>();
                ApexDebugLog.Error errorLog = new ApexDebugLog.Error(
                    	'EmailMessageHlpr',
                        'cloneClosedCaseBeforeInsert',
                        '',
                        e);
                errorLogs.add(errorLog);
                ApexDebugLog.createLog(errorLogs);
        }
    }
    
    
    /* @Description Dynamic Case query. Fields to be queried are retrieved from a fieldset. Fields used in the trigger are hardcoded.
    * @Param caseIds List of cases that should be queried.
    */
    private static List<Case> queryCases(Set<Id> caseIds){
        Set<String> fields = new Set<String>();
        fields.add('Id');
        fields.add('RecordTypeId');
        fields.add('IsShopperCase__c');
        fields.add('ShopperCaseAllowed__c');
        fields.add('IsClosed');
        fields.add('TimeToReopen__c');
        String query = 'SELECT ';
        for (String defaultField : fields){
            query += defaultField + ', ';
        }
        for(Schema.FieldSetMember f : SObjectType.Case.FieldSets.CloneFields.getFields()) {
            if (!fields.contains(f.getFieldPath())){
                query += f.getFieldPath() + ', ';
            }
        }
        query = query.removeEnd(', ');
        query += ' FROM Case WHERE Id in: caseIds';
        return Database.query(query);
    }
    
}