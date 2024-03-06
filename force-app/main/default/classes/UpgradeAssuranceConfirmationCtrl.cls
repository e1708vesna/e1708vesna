/**
 * @description   : Controller Class helper for the visualforce page TermsConditions page UpgradeAssuranceConfirmation
 * @author (s)    : Brite
 */
public with sharing class UpgradeAssuranceConfirmationCtrl {

    private final UpgradeAssuranceContract__c upgradeAssuranceContract;
    
    public UpgradeAssuranceConfirmationCtrl() {
        upgradeAssuranceContract = [SELECT Id, ChannelPartner__r.Name, signedby__c, SignedDate__c, Name, License__r.name, licenseename__c, StartDate__c
                FROM UpgradeAssuranceContract__c
                WHERE Id = :ApexPages.currentPage().getParameters().get('id')];

        upgradeAssuranceContract.signedby__c = ApexPages.currentPage().getParameters().get('signedby');
        String sDate = ApexPages.currentPage().getParameters().get('SignedDate');
        upgradeAssuranceContract.SignedDate__c = DateTime.newInstance(Integer.valueOf(sDate.substring(0,4)), Integer.valueOf(sDate.substring(5,7)), Integer.valueOf(sDate.substring(8,10)), 12, 0, 0).date();
    }
    
    public UpgradeAssuranceContract__c getUpgradeAssuranceContract() {
        return upgradeAssuranceContract;
    }    
}