/**
 * @description   : Controller Class helper for the lightning TermsConditions page to ignore the record lock
 * @author (s)    : Brite
 */
global without sharing class TermsConditionsLghtCmpCtrlHlp {
    private final static String EMAIL_TEMPLATE_NAME = 'UpgradeAssuranceConfirmation';  


    /**
     * acceptTermAndConditions
     **/
    public static void acceptTermAndConditions (UpgradeAssuranceContract__c upgradeAssuranceContract) {
        //stage to Order
        //recordType to Activated
        Id activatedContractRt = RecordTypeUtil.getRecordTypeIdByDevName('Activated_Contract', UpgradeAssuranceContract__c.getSObjectType());

        if (upgradeAssuranceContract.Stage__c != 'Order' && upgradeAssuranceContract.RecordTypeId != activatedContractRt) {
            upgradeAssuranceContract.Stage__c = 'Order'; 
            upgradeAssuranceContract.RecordTypeId = activatedContractRt;
            upgradeAssuranceContract.SignedDate__c = Date.today();
            upgradeAssuranceContract.RequestUnlock__c = !upgradeAssuranceContract.RequestUnlock__c;
            upgradeAssuranceContract.SendPdf__c=TRUE; 
            update upgradeAssuranceContract;

            if (upgradeAssuranceContract.Email__c != null && upgradeAssuranceContract.Email__c.contains('@')) {
                sendUpgradeAssuranceConfirmation(upgradeAssuranceContract);
            }
        }
    }       

    /**
     * acceptTermAndConditions Bulk
     **/
    public static String acceptTermAndConditionsBulk (List<UpgradeAssuranceContract__c> upgradeAssuranceContractList) {
        String returnValue = '';
        //stage to Order
        //recordType to Activated
        upgradeAssuranceContractList = [SELECT Id, RequestUnlock__c FROM UpgradeAssuranceContract__c WHERE Id IN :upgradeAssuranceContractList];
        Id activatedContractRt = RecordTypeUtil.getRecordTypeIdByDevName('Activated_Contract', UpgradeAssuranceContract__c.getSObjectType());
        for (UpgradeAssuranceContract__c upgradeAssuranceContract : upgradeAssuranceContractList) {     
            upgradeAssuranceContract.Stage__c='Order'; 
            upgradeAssuranceContract.RecordTypeId = activatedContractRt;
            //upgradeAssuranceContract.SignedDate__c = Date.today(); // On bulk it is not signed so no need to set a signedDate
            upgradeAssuranceContract.RequestUnlock__c = !upgradeAssuranceContract.RequestUnlock__c;
            //Auto Approve
            upgradeAssuranceContract.Approved__c = true;
        }
        try {
            update upgradeAssuranceContractList;
        } catch (Exception ex) {
            returnValue = ex.getMessage();
        }       
        
        return returnValue;
    }       

    /**
     * Create confirmation PDF and send this with a e-mail
     * @param 
     */
    private static void sendUpgradeAssuranceConfirmation (UpgradeAssuranceContract__c upgradeAssuranceContract) {
        //Set<Id> idSet = new Set<Id>();
        //idSet.add(upgradeAssuranceContract.Id);        
        //List<UpgradeAssuranceContract__c> uacList = UpgradeAssuranceContractDao.getById(idSet);
        //UpgradeAssuranceContract__c upgradeAssuranceContract = uacList[0];

        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Name = :EMAIL_TEMPLATE_NAME LIMIT 1];   
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();

        String dateFormat = 'yyyy-MM-dd';
        DateTime dt = DateTime.now();
        String strDate = dt.format(dateFormat);

        String filename = upgradeAssuranceContract.Name + '_' + strDate + '.pdf';

        efa.setFileName(filename);

        System.PageReference pageRef = new System.PageReference('/apex/UpgradeAssuranceConfirmation?id=' + upgradeAssuranceContract.Id + '&signedby=' + upgradeAssuranceContract.SignedBy__c + '&SignedDate=' + upgradeAssuranceContract.SignedDate__c);
        if(Test.isRunningTest()) { 
            efa.setBody(blob.valueOf('Unit.Test'));
        } else {
            efa.setBody(pageRef.getContentAsPDF());
        }

        /* save also as file with the UAC */
		ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.ContentDocumentId = null;
        cv.VersionData = efa.getBody();
        cv.Title = fileName;
        cv.PathOnClient = filename;
        insert cv;	

		//Relate the file to the License        
        ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = ContentVersionDao.getById(cv.Id)[0].ContentDocumentId;
		cdl.LinkedEntityId = upgradeAssuranceContract.Id;
		cdl.ShareType = 'V';
		insert cdl;	
        /* */

        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage ();
        msg.setTemplateId (template.Id);
        msg.setTargetObjectId (UserInfo.getUserId()); //  Here you can give Id of  User , Lead , Contact 
        msg.setToAddresses(new String[]{upgradeAssuranceContract.Email__c});
        msg.setWhatId (upgradeAssuranceContract.Id); // TargetObject
        msg.setSaveAsActivity(false);
    
        msg.setFileAttachments (new Messaging.EmailFileattachment[] {efa});

        if (!Test.isRunningTest()) {
            Messaging.sendEmail (new Messaging.SingleEmailMessage[] { msg });        
        }
    }
}