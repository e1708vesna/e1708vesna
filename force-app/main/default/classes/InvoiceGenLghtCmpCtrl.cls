/**
 * @description   : Controller Class to generate an invoice file out of connected Upgrade Assurance Contracts
 * @author (s)    : Brite
 */
public with sharing class InvoiceGenLghtCmpCtrl {
	@AuraEnabled
	public static CsvWrapper createInvoiceFileApex(Id invoiceId) {

		List<UpgradeAssuranceContract__c> uacList = [
				SELECT u.Invoice__r.InvoiceFile__c, u.Invoice__r.Status__c, u.Invoice__r.Name, u.Invoice__c, 
						u.ChannelPartner__r.CustomerCode__c, u.EndCustomer__r.Currency__c, 
						u.EndCustomer__r.CustomerCode__c, u.EndCustomer__r.Name, u.EndCustomer__c, u.Name, YourOrder__c,
						u.YourReference__c,  u.License__r.Name, u.Currency__c, u.UpgradeAssuranceValue__c, u.BillingValueUa__c,
						u.StartDateLine__c, u.EndDateLine__c, u.RequestUnlock__c, u.Lock__c , u.CombinedBillingValueUa__c, BillingValueUaInclPartnerDiscount__c
				FROM UpgradeAssuranceContract__c u WHERE u.Invoice__c =: invoiceId];

        CsvWrapper csvWrap = new CsvWrapper();

		if (!uacList.isEmpty()) {
			String csv = '';
			csvWrap.title = uacList[0].Invoice__r.Name;

			//Add Header
			csv += csvWrapData('InvoiceName', false);
			csv += csvWrapData('CustomerCode', false);
			csv += csvWrapData('YourOrder', false);
			csv += csvWrapData('UpgradeAssuranceContractNum', false);
			csv += csvWrapData('EndCustomerCode', false);
			csv += csvWrapData('LicenseNumber', false);
			csv += csvWrapData('BillingValueUaInclPartnerDiscount', false);		//Ex BTW
			csv += csvWrapData('CurrencyCode', false);	
			csv += csvWrapData('StartDateLine', false);	
			csv += csvWrapData('EndDateLine', true);	//Last one with true!
			for (UpgradeAssuranceContract__c uac : uacList) {
				csv += csvWrapData (uac.Invoice__r.Name, false);
				csv += csvWrapData (uac.ChannelPartner__r.CustomerCode__c, false);
				csv += csvWrapData (uac.YourOrder__c, false);
				csv += csvWrapData (uac.Name, false);
				csv += csvWrapData (uac.EndCustomer__r.CustomerCode__c, false);
				csv += csvWrapData (uac.License__r.Name, false);
				csv += csvWrapData (String.valueOf(uac.BillingValueUaInclPartnerDiscount__c), false);
				csv += csvWrapData (uac.Currency__c, false);	
				csv += csvWrapData ('' + uac.StartDateLine__c.day() + '-' + uac.StartDateLine__c.month() + '-' + uac.StartDateLine__c.year(), false);
				csv += csvWrapData ('' + uac.EndDateLine__c.day() + '-' + uac.EndDateLine__c.month() + '-' + uac.EndDateLine__c.year(), true);	//Last one with true!
			}

        	csvWrap.csv = csv;

			Boolean invoiceFile = uacList[0].Invoice__r.InvoiceFile__c;
			InvoiceGenHlp.setInvoiced(invoiceId, invoiceFile, uacList);

		}
		return csvWrap;
	}    

	/* Wrap de csv data as text and add comma or end of line marker*/
	private static String csvWrapData(String cellData, Boolean last) {
		String cellDataWrapped;
		cellDataWrapped = '"' + cellData + '"';
		if (last) {
			cellDataWrapped += '\r\n';
		} else {
			cellDataWrapped += ',';
		}
		return cellDataWrapped;
	}

    /*wrapper class to store csv + title*/ 
    public class CsvWrapper{
        @AuraEnabled public string title{get;set;} 
        @AuraEnabled public string csv{get;set;} 
    }

}