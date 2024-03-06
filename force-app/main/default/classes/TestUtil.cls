/**
 * @description   : Test helper class to create test data
 * @author (s)    : BRITE
 */
//@isTest
public class TestUtil {
    
    /**
     * @description Create a Community User inclusing Contact
     *
     * @param accountId Id of the Account of the Community User
     * @param nameSuffix string with a name to get uniqueness when multiple Users are required
     * @param companyName for the user. If the CompanyName == 'Error' then sharing failed (used for error code coverage)
     * @param shouldInsert Should the created record be inserted into the database?
     */
    public static User getCommunityUser(Id accountId, String nameSuffix, String companyName, Boolean shouldInsert) {
        
        Contact co = New Contact(
                            FirstName = 'ContactFirstName' + nameSuffix, 
                            LastName = 'ContactLastName' + nameSuffix, 
                            AccountID = accountId,
                            Title = 'ContactTitle' + nameSuffix,
                            Department = 'ContactDepartment' + nameSuffix,
                            Email = 'a' + nameSuffix + '@b.c',
                            Phone = '0987654321',
                            MobilePhone = '1234567890',
                            Fax = '1122334455',
                            MailingPostalCode = '1000AA',
                            MailingCity = 'Amsterdam',
                            MailingStreet = 'ContactStreet123');
        insert co;

        return getCommunityUser(nameSuffix, companyName, co.Id, shouldInsert);
    }
    public static User getCommunityUserForContact(String nameSuffix, String companyName, Id contactId, Boolean shouldInsert) {
        List<Profile> profileList = [select Id from Profile where name = 'Nedap Customer Community User'];
        
        String em = 'test' + math.random() + nameSuffix + '@testtest.cmmo';
        String lname = 'Test-Last' + nameSuffix;
        user u = New User(
            UserName = 'test_' + math.random() + nameSuffix + '@test.com',
            FirstName = 'Test-First' + nameSuffix,
            LastName = lname,
            CompanyName = companyName,
            Alias = 'test' + nameSuffix,
            email = em,
            CommunityNickName = string.valueOf(math.random()).substring(0,6),
            ProfileID = profileList[0].id,
            TimeZoneSidKey = 'America/New_York', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            ContactID = contactId
            );
        
        if (shouldInsert) {
            insert u;
        }
        return u;
    }
    
    /**
     * @description Create a scheduler setting.
     *
     * @param ssName Scheduler settings name
     * @param shouldInsert Should the created record be inserted into the database?
     */
    public static SchedulerSettings__c createSchedulerSettings (String ssName, Boolean shouldInsert) {
        SchedulerSettings__c ss = new SchedulerSettings__c( Name = ssName, 
                                           AutoReschedule__c = true, 
                                           RescheduleDelayMinutes__c = 1, 
                                           RescheduleDelayHours__c = 1, 
                                           MaxProcessItems__c = 20000, 
                                           BatchSize__c = 200,
                                           LastProcessedId__c = null, 
                                           LastProcessedDateTime__c = DateTime.newInstance(1970, 1, 1, 12, 0, 0), 
                                           MoreHitsAvailableIndicator__c = false,
                                           RetryDelayMinutes__c = 7,
										   FixedTime__c = false,
										   FixedDay__c = false,
										   FixedMonth__c = false,
										   Description__c = ' - ',
                                           LinkedScheduler__c = '');
        if (shouldInsert) {
            insert ss;
        }        
        return ss;
    }
    
    /**
     * @description Create account record
     *
     * @param accName Name of the account
     * @param accRecordTypeId ID of the account record type
     * @param shouldInsert Should the created record be inserted into the database?
     */
    public static Account createAccount (String accName, Id accRecordTypeId, Boolean shouldInsert) {
        Account acc = new Account(Name = accName,
                                  RecordTypeId = accRecordTypeId);
        
        if (shouldInsert) {
            insert acc;
        }
        
        return acc;
    }

    /**
     * @description Create contact record
     *
     * @param fName First name of the contact
     * @param lName Last name of the contact
     * @param emailAddress Email of the contact
     * @param accountId Id of the primary account
     * @param shouldInsert Should the created record be inserted into the database?
     */
    public static Contact createContact (String fName, String lName, String emailAddress, Id accountId, Boolean shouldInsert) {
        Contact con = new Contact(FirstName = fName,
                                  LastName = lName,
                                  Email = emailAddress,
                                  AccountId = accountId);
        
        if (shouldInsert) {
            insert con;
        }
        
        return con;
    }

    /**
     * @description Create account-contact relation record
     *
     * @param accountId Id of the account
     * @param contactId Id of the contact
     * @param shouldInsert Should the created record be inserted into the database?
     */
    public static AccountContactRelation createIndirectAccountContactRelation (Id accountId, Id contactId, Boolean shouldInsert) {
        AccountContactRelation rel = new AccountContactRelation (
                AccountId = accountId,
                ContactId = contactId);
        
        if (shouldInsert) {
            insert rel;
        }
        
        return rel;
    }

    /**
     * @description Create MSRP record, an object to log Product and Price information.
     *
     * @param artNumber Article number
     * @param curr Currency of the unit price
     * @param price Unit price
     * @param minQuantity Minimal quantity to get this unit price
     * @param startDate Start date of this price
     * @param endDate End date of this price
     * @param shouldInsert Should the created record be inserted into the database?
     */
    public static MSRP__c createMSRP (String artNumber, String curr, Decimal price, Integer minQuantity, 
                                    Date startDate, Date endDate, Boolean shouldInsert)  {
        MSRP__c msrp = new MSRP__c (
                                ArticleNumber__c = artNumber,
                                Currency__c = curr,
                                Description__c = 'MSRP description',
                                UnitPrice__c = price,
                                MinimumQuantity__c = minQuantity,
                                StartDate__c = startDate);
        if (endDate != null) {
            msrp.EndDate__c = endDate;
        }
        
        if (shouldInsert) {
            insert msrp;
        }
        
        return msrp;
    }
    
    /**
     * @description Create License record
     *
     * @param licName Name of the license 
     * @param accountId Id of related Account  
     * @param shouldInsert Should the created record be inserted into the database?
     */
    public static License__c createLicense (String licName, Id accountId, Boolean shouldInsert) {
        License__c lic = new License__c (
                                Name = licName,
                                NavisionExternalId__c = licName,
                                Currency__c = 'EUR',
                                EndCustomer__c = accountId,
                                LicenseType__c = 'Open',
                                LicenseTypeCode__c = 'OPEN',
                                LicenseTypeVersion__c = '1',
                                Version__c = '1',
                                VersionDescription__c = 'AEOS');
                                
        if (shouldInsert) {
            insert lic;
        }
        
        return lic;
    }
    
    /**
     * @description Create License Item record
     *
     * @param licItemNbr Number of the license Item 
     * @param licenseId Id of related License  
     * @param msrpId Id of MSRP
     * @param shouldInsert Should the created record be inserted into the database?
     */
    public static LicenseItem__c createLicenseItem (String licItemNbr, String artNo, Id licenseId, Id msrpId, Boolean shouldInsert) {
        LicenseItem__c licItem = new LicenseItem__c(
                                        Name = licItemNbr,
                                        ArtNo__c = artNo,
                                        InitialQuantity__c = 2.0,
                                        LineNumber__c = 'line1',
                                        LicenseTypeVersion__c = 'v1.0', 
                                        NavisionExternalId__c = 'navId' + Math.random(),
                                        PriceDate__c = Date.today(),
                                        Quantity__c = 10,
                                        VersionCode__c = 'VC1-0',
                                        License__c = licenseId,
                                        Item__c = msrpId);
        
        if (shouldInsert) {
            insert licItem;
        }
        
        return licItem;
    }
    
    /**
     * @description Create UpgradeAssuranceContract record
     *
     * @param recordType Id of the upgrade assurance contract record type
     * @param licenseId Id of related License__c record  
     * @param shouldInsert Should the created record be inserted into the database?
     */
    public static UpgradeAssuranceContract__c createUpgradeAssuranceContract (Id recordType, Id licenseId, Boolean shouldInsert) {
        Date dn = Date.today();

        UpgradeAssuranceContract__c uac = new UpgradeAssuranceContract__c(
                                                RecordTypeId = recordType,
                                                Stage__c = 'New',
                                                License__c = licenseId,
                                                StartDate__c = Date.newInstance(dn.year(), dn.month(), 1),
                                                StartDateLine__c = Date.newInstance(dn.year(), dn.month(), 1));
                                                
        if (shouldInsert) {
            insert uac;
        }
        
        return uac;
    }
    
    /**
     * @description Create UpgradeAssuranceContractItem record
     *
     * @param uacItemName Name of the contract item
     * @param uaContractId Id of the upgrade assurance contract record type
     * @param licenseItemId Id of related License__c record  
     * @param shouldInsert Should the created record be inserted into the database?
     */
    public static UpgradeAssuranceContractItem__c createUpgradeAssuranceContractItem (String uacItemName, Id uaContractId, Id licenseItemId, Boolean shouldInsert) {
        UpgradeAssuranceContractItem__c uacItem = new UpgradeAssuranceContractItem__c(
                                            //Name = uacItemName,
	                                        InitialQuantity__c = 2.0,
	                                        LineNumber__c = 'line1',
	                                        UpgradeAssuranceContractTypeVersion__c = 'v1.0', 
	                                        NavisionExternalId__c = 'navId' + Math.random(),
	                                        PriceDate__c = Date.today(),
	                                        Quantity__c = 10,
	                                        UnitPrice__c = 100,
	                                        VersionCode__c = 'VC1-0',
	                                        UpgradeAssuranceContract__c = uaContractId,
	                                        LicenseItem__c = licenseItemId);
	                                        
	    if (shouldInsert) {
	        insert uacItem;
	    }
	    
	    return uacItem;
    }
    
}