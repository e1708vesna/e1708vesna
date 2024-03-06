/**
 * @description   : Controller Class for the lightning TermsConditions page
 * @author (s)    : Brite
 */
public with sharing class TermsConditionsLghtCmpCtrl {
        
    @AuraEnabled
    public static String getApexTermsAndConditionsFileId (String title) {
        String contentDocumentId = '';
        //Custom object is used to be able to read internal files
        Id cfmId = CommunityFileMapDao.getIdByDeveloperName('GENERAL');
        List<ContentDocumentLink> contentDocumentLinkList = ContentDocumentLinkDao.getContentDocumentLinkList(cfmId, title);
            
        if (contentDocumentLinkList != null && contentDocumentLinkList.size() > 0) {
            contentDocumentId = contentDocumentLinkList[0].ContentDocumentId;
        }
        return contentDocumentId;
    }
    
    @AuraEnabled
    public static void acceptTermAndConditions (UpgradeAssuranceContract__c upgradeAssuranceContract) {
        //Use subclass to bypass sharing for the the record lock
        try {
            TermsConditionsLghtCmpCtrlHlp.acceptTermAndConditions (upgradeAssuranceContract);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }       

    @AuraEnabled
    public static String acceptTermAndConditionsBulk (List<UpgradeAssuranceContract__c> upgradeAssuranceContractList) {
        //Use subclass to bypass sharing for the the record lock
        return TermsConditionsLghtCmpCtrlHlp.acceptTermAndConditionsBulk (upgradeAssuranceContractList);
    }

    @AuraEnabled
    public static UpgradeAssuranceContract__c getUAC (String upgradeAssuranceContractId) {
        Set<Id> idSet = new Set<Id>();
        idSet.add(upgradeAssuranceContractId);
        
        List<UpgradeAssuranceContract__c> uacList = UpgradeAssuranceContractDao.getById(idSet);
        uacList[0].SignedDate__c = Date.today();
        
        return uacList[0];  
    }       
 
    @AuraEnabled
    public static Map<String, FieldParams> getFieldParams () {
        Map<String,FieldParams> fieldParamsMap = new Map<String,FieldParams>();
        //try {
            String selectedObject = 'UpgradeAssuranceContract__c';
            Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();            
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(selectedObject).getDescribe().fields.getMap();
            for (Schema.SObjectField sfield : fieldMap.Values()) {
                schema.describefieldresult dfield = sfield.getDescribe();
                FieldParams fp = new FieldParams(dfield.getname (), dfield.getLabel (), dfield.getType ());
                fieldParamsMap.put(dfield.getname (), fp);
            }
        //} catch(Exception e){
        //    result += e.getLineNumber() + ' : ' + e.getMessage();
        //}
        
        return fieldParamsMap;
    }
 
 
}