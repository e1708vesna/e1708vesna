/**
 * Extension class for the UpgradeAssurancePrint VF page
 */
public with sharing class UpgradeAssurancePrintCtrlExt {

    @AuraEnabled
    public static String getPrintableViewFileId (String uacId) {
        Set<Id> idSet = new Set<Id>();
        idSet.add(uacId);

        List<UpgradeAssuranceContract__c> uacList = UpgradeAssuranceContractDao.getById(idSet);

        String dateFormat = 'yyyy-MM-dd';
        DateTime dt = DateTime.now();
        String strDate = dt.format(dateFormat);

        String filename = uacList[0].Name;
		try {
			List<ContentDocument> cdDeleteList = new List<ContentDocument>();
			List<ContentDocumentLink> cdlList = ContentDocumentLinkDao.getCDLStartWithNameList(uacId, filename);
			for (ContentDocumentLink cdl : cdlList) {
				cdDeleteList.add(new ContentDocument(Id = cdl.ContentDocumentId));
			}
			if (!cdDeleteList.isEmpty()) {
				delete cdDeleteList;
			}
		} catch(Exception ex) {
    		System.debug('Delete existing ' + filename + ' failed at: ' + ex.getMessage() + ' | ' + ex.getLineNumber());
            CustomLog.create(CustomLog.ERROR, 'Delete existing ' + filename + ' failed at: ' + ex.getCause(), ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());
        }
        
        filename += '_' + strDate + '.pdf';

        System.PageReference pageRef = new System.PageReference('/apex/UpgradeAssurancePrint?id=' + uacId);
		ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.ContentDocumentId = null;
        if(Test.isRunningTest()) { 
            cv.VersionData = blob.valueOf('Unit.Test');
        } else {
            cv.VersionData = pageRef.getContentAsPDF();
        }
        cv.Title = fileName;
        cv.PathOnClient = filename;
        //cv.firstPublishLocationId = '0051t000000UCgo';
        //cv.OwnerId = '0051t000000UCgo';
        insert cv;	

		//Relate the file to the License        
        ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = ContentVersionDao.getById(cv.Id)[0].ContentDocumentId;
		cdl.LinkedEntityId = uacId;
        cdl.ShareType = 'I';
        cdl.Visibility='AllUsers'; 
        insert cdl;	
 
        return cdl.ContentDocumentId;   //cv.Id;
        
        //return UpgradeAssurancePrintHelper.savePrintableView(uacId);
    }
}