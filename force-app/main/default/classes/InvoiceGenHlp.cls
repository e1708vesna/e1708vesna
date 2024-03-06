/**
 * @description   : Class to update the invoice ignoring the sharing
 * @author (s)    : Brite
 */
public without sharing class InvoiceGenHlp {
    public static void setInvoiced(Id invoiceId, Boolean invoiceFile, List<UpgradeAssuranceContract__c> uacList) {
		if (invoiceFile == null || !invoiceFile) {
			update new Invoice__c (Id=invoiceId, Status__c= 'Invoiced', InvoiceDate__c=DateTime.now(), InvoiceFile__c = true);

			for (UpgradeAssuranceContract__c uac : uacList) {
				uac.Lock__c = true;
				uac.RequestUnlock__c = !uac.RequestUnlock__c;
			}
			update uacList;

			/*
			Approval.LockResult[] lrList = Approval.lock(uacList, false);

			// Iterate through each returned result
			for(Approval.LockResult lr : lrList) {
				if (lr.isSuccess()) {
					// Operation was successful, so get the ID of the record that was processed
					System.debug('Successfully locked account with ID: ' + lr.getId());
				}
				else {
					// Operation failed, so get all errors                
					for(Database.Error err : lr.getErrors()) {
						System.debug('The following error has occurred.');                    
						System.debug(err.getStatusCode() + ': ' + err.getMessage());
						System.debug('Account fields that affected this error: ' + err.getFields());
					}
				}
			}			
			*/
		}  
    }
}