/**
 * @description   : Controller Class for the lightning DeclineUACLghtCmp page
 * @author (s)    : Brite
 */
public with sharing class DeclineUACLghtCmpCtrl {
    @AuraEnabled
    public static Boolean isDeclined (String upgradeAssuranceContractId) {
        Set<Id> idSet = new Set<Id>();
        idSet.add(upgradeAssuranceContractId);
        
        List<UpgradeAssuranceContract__c> uacList = UpgradeAssuranceContractDao.getById(idSet);
        return uacList[0].Declined__c;  
    }   

    @AuraEnabled
    public static UpgradeAssuranceContract__c getUac (String upgradeAssuranceContractId) {
        Set<Id> idSet = new Set<Id>();
        idSet.add(upgradeAssuranceContractId);        
        return UpgradeAssuranceContractDao.getById(idSet)[0];
    }   
    
    @AuraEnabled
    public static void declineUAC (String upgradeAssuranceContractId, Boolean decline) {
        Set<Id> idSet = new Set<Id>();
        idSet.add(upgradeAssuranceContractId);

        List<UpgradeAssuranceContract__c> uacList = UpgradeAssuranceContractDao.getById(idSet);
        if (uacList[0].EndDate__c == null) {
            DeclineUACLghtCmpCtrlHlp.declineUAC (uacList[0], decline);
        }
    }
    
}