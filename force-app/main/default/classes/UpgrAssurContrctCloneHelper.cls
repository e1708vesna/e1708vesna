/**
 * @description   : Class for the functionality Ugrade Assurance Contract clone
 * @author (s)    : Brite
 */
 public without sharing class UpgrAssurContrctCloneHelper {

    /**
     * Clone Active UAC Contract
     */
    public static String clone (Id uacId) {
        String status = '';
        UpgradeAssuranceContract__c uac;
        Integer thisYear = Date.today().Year();
        List<UpgradeAssuranceContract__c> uacList = [
                SELECT u.YourReference__c, u.YourOrder__c, u.Version__c, u.UpgradeAssuranceValue__c, u.Status__c, u.StartDate__c, 
                        u.StartDateLine__c, u.Stage__c, u.SignedDate__c, u.SignedBy__c, u.RecordTypeId, u.PercentageDiscountDate__c, 
                        u.PartnerDiscountPercentage__c, u.OutstandingLineAmount__c, u.NavisionUaNumber__c, u.Name, u.LineAmount__c,
                         u.LicenseeName__c, u.License__c, u.IsDeleted, u.Invoice__c, u.Id, 
                         u.Handler__c, u.FlatFeeUa__c, u.Exception__c, u.EndDate__c, u.EndDateLine__c, u.EndCustomer__c, 
                         u.Email__c, u.DocumentType__c, u.Currency__c, u.ContractDuration__c, 
                         u.ChannelPartner__c, u.CalculationPercentage__c, u.CalculationMethod__c, u.Billing__c, u.BillingValueUa__c, 
                         u.Approved__c, u.AdditionalConditions__c, u.BillingPercentage__c,
                         u.AdditionalConditionsReason__c, u.Active__c, u.AcceptTermsAndConditions__c  
                FROM UpgradeAssuranceContract__c u 
                WHERE Id = :uacId];
        if (!uacList.IsEmpty()) {
            uac = uacList[0];
            Id rtIdActivatedContract = RecordTypeUtil.getRecordTypeIdByDevName ('Activated_Contract', UpgradeAssuranceContract__c.getSObjectType());

            //if (!uac.Active__c) {
            //    status += 'Upgrade Assurance Contract is not active\n';
            //}
            if (uac.RecordTypeId != rtIdActivatedContract) {
                status += 'Upgrade Assurance Contract has no Activated Contract Record Type\n';
            }
            //if (uac.StartDateLine__c == null || uac.StartDateLine__c.year() != thisYear) {
            //    status += 'Upgrade Assurance Contract is not from current year (StartDateLine)\n';
            //}
            
            /**
                Als de end date leeg is dan mag je 'm clonen
                Als de end date > this year, dan mag je 'm clonen
                Als de end date <= this year, dan mag je 'm NIET clonen
            */
            if ( uac.EndDate__c != null && uac.EndDate__c.Year() <= thisYear) {
                status += 'Upgrade Assurance Contract is ended (EndDate)\n';
            }

            Id rtIdClonedContract = RecordTypeUtil.getRecordTypeIdByDevName ('Cloned_Contract', UpgradeAssuranceContract__c.getSObjectType());
            List<UpgradeAssuranceContract__c> uacExistList = [SELECT Id, License__c FROM UpgradeAssuranceContract__c WHERE License__c = :uac.License__c AND RecordTypeId = :RtIdClonedContract AND StartDateLine__c = NEXT_YEAR];
            if (!uacExistList.IsEmpty()) {
                status += 'Cloned Upgrade Assurance Contract exists\n';
            }
            if (status == '') {
                status = cloneUpgradeAssuranceContract (uacList);
            }
        } else {
            status += 'Upgrade Assurance Contract ' + uacId + 'not found\n';
        }
        return status;
    }

    /**
     * Clone UAC Contracts
     * @description : Called by scheduler and manual button to clone UpgradeAssuranceContract
     **/
    public static String cloneUpgradeAssuranceContract (List<UpgradeAssuranceContract__c> uacList) {
        String uacIdCloned = '';
        Integer thisYear = Date.today().Year();
        Id rtIdClonedContract = RecordTypeUtil.getRecordTypeIdByDevName ('Cloned_Contract', UpgradeAssuranceContract__c.getSObjectType());
        
        List<UpgradeAssuranceContract__c> uacCloneToSaveList = new List<UpgradeAssuranceContract__c>();

        //recheck existing cloned Upgrade Assurance Contracts       
        List<UpgradeAssuranceContract__c> uacExistList = [SELECT Id, License__c FROM UpgradeAssuranceContract__c WHERE RecordTypeId = :RtIdClonedContract AND StartDateLine__c = NEXT_YEAR];
        Set<Id> licenseIdSet = new Set<Id>();
        for (UpgradeAssuranceContract__c uac : uacExistList) {
            if (uac.License__c != null) {
                licenseIdSet.add(uac.License__c);
            }
        }
        
        for (UpgradeAssuranceContract__c uac : uacList) {
            //filter existing
            if (!licenseIdSet.contains (uac.License__c)) {
                //check the current date
                if ( uac.EndDate__c == null || uac.EndDate__c.Year() > thisYear) {
                    uac.ParentUAC__c = uac.Id;
                    uac.Id = null;
                    uac.stage__c = 'New';
                    uac.RecordTypeId = rtIdClonedContract;
                    
                    uac.StartDateLine__c = Date.newInstance((uac.EndDateLine__c.year()+1), 1, 1); 
                    uac.invoice__c = null;
                    uacCloneToSaveList.add(uac);
                }
            }
        }
        
        try {
            String errMsg = '';
            String suc6Msg = '';
            Integer errCnt = 0;
            Integer suc6Cnt = 0;
            Integer i = 0;
        
            if (!uacCloneToSaveList.isEmpty()) {
                Database.SaveResult[] srList = Database.insert(uacCloneToSaveList, false);
                i = 0;
                for(Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful
                        suc6Cnt++;
                        suc6Msg += uacCloneToSaveList[i].Name + '|' + uacCloneToSaveList[i].License__c + '\t'; 
                        uacIdCloned = uacCloneToSaveList[i].Id;
                    }
                    else {
                        errCnt++;
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            errMsg += uacCloneToSaveList[i].Name + '|' + uacCloneToSaveList[i].License__c + '|' + err.getStatusCode() + ': ' + err.getMessage() + '\t';
                        }
                        errMsg += '\n';
                    }
                    i++;
                }
            } else {
                uacIdCloned += 'Clone already exist\n';
            }
            if (suc6Cnt!=0) {
                System.debug('Successfully cloned ' + suc6Cnt + ' Upgrade Assurance Contracts');
                CustomLog.create(CustomLog.INFO, 'Successfully cloned ' + suc6Cnt + ' Upgrade Assurance Contracts', suc6Msg, '');
            }
            if (errMsg!='') {
                System.debug(errMsg);
                CustomLog.create(CustomLog.ERROR, 'Failed cloning ' + errCnt + ' Upgrade Assurance Contracts', errMsg, '');
                uacIdCloned += errMsg;
            }
        } catch (exception ex) {
            System.debug('Cloning Upgrade Assurance Contracts failed at: ' + ex.getMessage() + ' | ' + ex.getLineNumber());
            CustomLog.create(CustomLog.ERROR, 'Cloning Upgrade Assurance Contracts failed at: ', ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());
        } finally {
            CustomLog.commitLog();
        }
        return uacIdCloned;
    }
}