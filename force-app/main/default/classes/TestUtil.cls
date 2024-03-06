/**
 * @author (s)    : Brite
 * @description   : Test helper class to create test data
 */
@isTest
public class TestUtil {

    private static User adminUser;
    private static Map<String, Profile> profiles = new Map<String, Profile>();

    public static User getAdminUser() {
        if (adminUser == null) {
            adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        }

        return adminUser;
    }

    public static Id getProfile(String name)
    {
        if (!profiles.containsKey(name)) {
            profiles.put(name, [SELECT Id FROM Profile WHERE Name = :name]);
        }

        return profiles.get(name).Id;
    }

    public static User createUser() {
        User u = new User(
            ProfileId           = getProfile('Standard User'),
            LastName            = 'testuser@adyen.dev',
            Email               = 'testuser@adyen.dev',
            Username            = 'testuser@adyen.dev.' + System.currentTimeMillis(),
            CompanyName         = 'Brite',
            Alias               = 'Alias',
            TimeZoneSidKey      = 'Europe/Amsterdam',
            // Sales_Region__c     = 'BE',
            SalesRegion__c      = 'EMEA',
            SalesCountry__c     = 'Belgium',
            SalesArea__c        = 'Belgium',
            SalesOffice__c      = 'Brussels',
            SalesTeam__c        = 'Sales Mid-Market',
            EmailEncodingKey    = 'UTF-8',
            LanguageLocaleKey   = 'en_US',
            LocaleSidKey        = 'en_US',
            DoNotRunFlow__c = true
//            UserRoleId          = r.Id
        );
        insert u;

        return u;
    }
    
    public static User createUser(String suffix, boolean shouldInsert) {
        User u = new User(
            ProfileId           = getProfile('Standard User'),
            LastName            = 'testuser@adyen.dev',
            Email               = 'testuser@adyen.dev',
            Username            = 'testuser@adyen.dev.' + suffix,
            CompanyName         = 'Brite',
            Alias               = 'Alias',
            TimeZoneSidKey      = 'Europe/Amsterdam',
            // Sales_Region__c     = 'BE',
            SalesRegion__c      = 'EMEA',
            SalesCountry__c     = 'Belgium',
            SalesArea__c        = 'Belgium',
            SalesOffice__c      = 'Brussels',
            SalesTeam__c        = 'Sales Mid-Market',
            EmailEncodingKey    = 'UTF-8',
            LanguageLocaleKey   = 'en_US',
            LocaleSidKey        = 'en_US',
            DoNotRunFlow__c = true
//            UserRoleId          = r.Id
        );
        if (shouldInsert) {
            insert u;
        }

        return u;
    }

    public static User createUser2() {
        User u = new User(
            ProfileId           = getProfile('Standard User'),
            LastName            = 'testuser2@adyen.dev',
            Email               = 'testuser2@adyen.dev',
            Username            = 'testuser2@adyen.dev.' + System.currentTimeMillis(),
            CompanyName         = 'Brite',
            Alias               = 'Alias',
            TimeZoneSidKey      = 'Europe/Amsterdam',
            // Sales_Region__c     = 'DE Ent',
            SalesRegion__c      = 'EMEA',
            SalesCountry__c     = 'Germany',
            SalesArea__c        = 'Germany North',
            SalesOffice__c      = 'Berlin',
            SalesTeam__c        = 'Sales Enterprise',
            EmailEncodingKey    = 'UTF-8',
            LanguageLocaleKey   = 'en_US',
            LocaleSidKey        = 'en_US',
            DoNotRunFlow__c = true
//            UserRoleId          = r.Id
        );
        insert u;

        return u;
    }
    
    private static integer user3ProfileIteration = 0;
    public static User createUser3Profile(String profileName, Boolean shouldInsert) {
        user3ProfileIteration++;
        User u = new User(
            ProfileId           = getProfile(profileName),
            LastName            = 'testuser3@adyen.dev',
            Email               = 'testuser3@adyen.dev',
            Username            = 'testuser3@adyen.dev.' + System.currentTimeMillis() + user3ProfileIteration,
            CompanyName         = 'Brite',
            Alias               = 'Alias',
            TimeZoneSidKey      = 'Europe/Amsterdam',
            // Sales_Region__c     = 'BE',
            SalesRegion__c      = 'EMEA',
            SalesCountry__c     = 'Belgium',
            SalesArea__c        = 'Belgium',
            SalesOffice__c      = 'Brussels',
            SalesTeam__c        = 'Sales Mid-Market',
            EmailEncodingKey    = 'UTF-8',
            LanguageLocaleKey   = 'en_US',
            LocaleSidKey        = 'en_US',
            DoNotRunFlow__c = true
//            UserRoleId          = r.Id
        );
        if (shouldInsert) {
            insert u;
        }

        return u;
    }
    
    public static User createUser3Profile(Id profileId, Boolean shouldInsert) {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User u = new User(
            ProfileId           = profileId,
            LastName            = 'testuser3@adyen.dev',
            Email               = 'testuser3@adyen.dev',
            Username            = 'testuser3@adyen.dev.' + uid,
            CompanyName         = 'Brite',
            Alias               = 'Alias',
            TimeZoneSidKey      = 'Europe/Amsterdam',
            // Sales_Region__c     = 'BE',
            SalesRegion__c      = 'EMEA',
            SalesCountry__c     = 'Belgium',
            SalesArea__c        = 'Belgium',
            SalesOffice__c      = 'Brussels',
            SalesTeam__c        = 'Sales Mid-Market',
            EmailEncodingKey    = 'UTF-8',
            LanguageLocaleKey   = 'en_US',
            LocaleSidKey        = 'en_US',
            DoNotRunFlow__c = true
//            UserRoleId          = r.Id
        );
        if (shouldInsert) {
            insert u;
        }

        return u;
    }

    /**
     * @description Create a Community User including Contact
     *
     * @param nameSuffix string with a name to get uniqueness when multiple Users are required
     * @param shouldInsert Should the created record be inserted into the database?
     */
    public static User createCommunityUser(String nameSuffix, String profileName, Boolean shouldInsert) {
        //Create portal account owner
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'testAdy@testAdy.com',
            Alias = 'batman',
            Email='ady.am@adyentest.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruca',
            Lastname='Wayno',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Database.insert(portalAccountOwner1);
        }

        //Database.update new Account(Id = AccountId, OwnerId = portalAccountOwner1.Id);
        //Create account
        Account portalAccount1 = new Account(
            Name = 'TestAccount',
            BillingCountry='Netherlands',
            OwnerId = portalAccountOwner1.Id,
            RecordTypeId = Constants.RT_ID_ACC_PARTNER_V2
        );
        Database.insert(portalAccount1);

        //Account acc2 = [SELECT OwnerId FROM Account WHERE Id = :portalAccount1.Id];
        //System.debug('Portal Account OwnerId: '+acc2.OwnerId);

        Contact co = New Contact(
                            FirstName = 'ContactFirstName' + nameSuffix, 
                            LastName = 'ContactLastName' + nameSuffix, 
                            AccountID = portalAccount1.Id,              //accountId,
                            Title = 'ContactTitle' + nameSuffix,
                            Department = 'ContactDepartment' + nameSuffix,
                            Email = 'a' + nameSuffix + '@b.c',
                            Phone = '0987654321',
                            MobilePhone = '1234567890',
                            Fax = '1122334455',
                            MailingCountry = 'Netherlands',
                            MailingPostalCode = '1000AA',
                            MailingCity = 'Amsterdam',
                            MailingStreet = 'ContactStreet123');
        Database.insert(co);

        List<Profile> profileList = [select Id from Profile where name = :profileName];
        
        String em = 'test' + math.random() + nameSuffix + '@testtest.test';
        String lname = 'Test-Last' + nameSuffix;
        user u = New User(
            UserName = 'test_' + math.random() + nameSuffix + '@test.com',
            FirstName = 'Test-First' + nameSuffix,
            LastName = lname,
            Alias = 'testos',
            email = em,
            CommunityNickName = string.valueOf(math.random()).substring(0,6),
            ProfileID = profileList[0].id,
            TimeZoneSidKey = 'America/New_York', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            ContactID = co.id
            );
        
        if (shouldInsert) {
            System.runAs(new User(Id = UserInfo.getUserId())) {
                insert u;
            }
        }
        return u;
    }

    public static Account createAccount() {
        Account acc = new Account(Name='Test acc', BillingCountry='Netherlands');

        insert acc;

        return acc;
    }

    /**
     * @description Create an account
     *
     * @param name Name of the account
     * @param rtId Account record type that should be created
     * @param shouldInsert Should the record be saved in the database?
     */
    public static Account createAccount(String name, Id rtId, Boolean shouldInsert) {
        Account acc = new Account (
                Name = name,
                BillingCountry = 'Netherlands',
                RecordTypeId = rtId
        );

        if (shouldInsert) {
            insert acc;
        }

        return acc;
    }
    
    /**
     * @description Create an account
     *
     * @param name Name of the account
     * @param rtId Account record type that should be created
     * @param shouldInsert Should the record be saved in the database?
*/
    public static Account createAccount(String name, Boolean isMerchantAccount, Boolean shouldInsert) {
        Account acc = new Account (
            Name = name,
            BillingCountry = 'Netherlands',
            RecordTypeId = Constants.RT_ID_ACC_BUSINESS
        );
        if (isMerchantAccount){ 
            acc.MerchantCoreBusinessModel__c = 'Digital';
        }
        if (shouldInsert) {
            insert acc;
        }

        return acc;
    }

    public static AccountTeamMember createAccountTeamMember(Id accountId, Id userId, boolean writeAccess, boolean shouldInsert){
        AccountTeamMember act = new AccountTeamMember();
        act.AccountId = accountId;
        act.UserId = userId;
        act.AccountAccessLevel = writeAccess ? 'Edit' : 'read';
        if (shouldInsert){
            insert act;
        }
        return act;
    }
    
    public static AccountPlan__c createAccountPlan(String name, Id accountId, boolean shouldInsert){
        AccountPlan__c accountPlan = new AccountPlan__c();
        accountPlan.Account__c = accountId;
        accountPlan.Name = name;
        // Amount of Share of Wallet had to be set because Rollup Helper did not trigger the rollup of Share of Wallets. Needs further investigation moving forward.
        accountPlan.Amount_of_Share_of_Wallet__c = 1;
        if (shouldInsert){
            insert accountPlan;
        }
        return accountPlan;
    }
    
    /**
     * @description Create a contact
     *
     * @param name Name of the contact
     * @param email Email of the contact
     * @param accId Id of the related account
     * @param rtId Contact record type that should be created
     * @param shouldInsert Should the record be saved in the database?
     */
    public static Contact createContact(String lName, String email, Id accId, Boolean shouldInsert) {
        Contact con = new Contact (
                    FirstName = 'Jip',
                    LastName = lName,
                    Email = email,
                    AccountId = accId,
                    MailingCountry = 'Netherlands',
                    Title = 'Manager'
        );
        //JTAL: 2020/04/24 removed recordtype field from initializing.
        if (shouldInsert) {
            insert con;
        }

        return con;
    }


    public static Opportunity createOpportunity(Id accountId, Id ownerId, boolean shouldInsert) {
        Date dt = Date.today().addDays(5);
        Opportunity opp = new Opportunity(
            Name='Test Opportunity',
            AccountId=accountId,
            StageName='SCOTSMAN',
            CloseDate=dt,
            OwnerId=ownerId,
            RegionCountry__c = 'NL',
            RecordTypeId = Constants.RT_ID_OPP_SALES
        );

        if (shouldInsert) {
            insert opp;
        }

        return opp;
    }

    /**
     * @description Create opportunity team member.
     *
     * @param opportunityId Id of the related opportunity
     * @param userId Id of the team member (user)
     * @param teamMemberRole Role of the team member (i.e. Opportunity Owner, Sales Manager, Account Manager, ...)
     * @param isEligibleSplit Sets eligible for split. Depending on the team member role, this value can gets overruled by process builder flow 'Opportunity Team Management'
     * @param shouldInsert True if it should be inserted into the database
     */ 
    public static OpportunityTeamMember createOpportunityTeamMember(Id opportunityId, Id userId, String teamMemberRole, Boolean shouldInsert) {
        OpportunityTeamMember oppTeamMember = new OpportunityTeamMember(
                                                        OpportunityId = opportunityId,
                                                        UserId = userId,
                                                        TeamMemberRole = teamMemberRole);
        if (shouldInsert) {
            insert oppTeamMember;
        }

        return oppTeamMember;
    }
    
    /**
     * @description Create product2.
     * @param name name of the product
     * @param shouldInsert True if it should be inserted into the database
     */ 
    public static Product2 createProduct(String Name, Boolean shouldInsert) {
        Product2 product = new Product2(Name = Name,
                                        ProductCode = Name,
                                        Product_Type__c = 'Service',
                                        isActive = true,
                                        CurrencyIsoCode = 'EUR');
        if (shouldInsert) {
            insert product;
        }

        return product;
    }
    
    /**
     * @description Create PricebookEntry.
    * @param ProductId Id of the Product
    * @param pricebookId Id of the ProductEntry
    * @param shouldInsert True if it should be inserted into the database
    */ 
    public static PricebookEntry  createPricebookEntry(Id ProductId, Id pricebookId, Boolean shouldInsert) {
        PricebookEntry  pbEntry = new PricebookEntry (Pricebook2Id = pricebookId,
                                                      Product2Id = ProductId,
                                                      UnitPrice = 100.00,
                                                      CurrencyIsoCode = 'EUR',
                                                      IsActive = true,
                                                      Product_Cost_Price__c = 20
                                                     );
        if (shouldInsert) {
            insert pbEntry;
        }
        
        return pbEntry;
    }
    
    /**
     * @description Create Opportunity Line Item.
     *
     * @param opportunityId Id of the related opportunity
     * @param PricebookEntryId Id of the related Pricebook Entry
     * @param shouldInsert True if it should be inserted into the database
     */ 
    public static OpportunityLineItem createOpportunityLineItem(Id opportunityId, Id pricebookEntryId, Boolean shouldInsert) {
        OpportunityLineItem lineItem = new OpportunityLineItem(
            OpportunityId = opportunityId,
            PricebookEntryId = pricebookEntryId,
            Quantity = 2
                                                        
        );
        if (shouldInsert) {
            insert lineItem;
        }

        return lineItem;
    }

    /**
     * OBSOLETE: OPPORTUNITY TEAM MEMBER RECORD NEEDS TO HAVE A TEAM MEMBER ROLE.
     */ 
    public static OpportunityTeamMember createOpportunityTeamMember(Id opportunityId, Id UserId) {
        OpportunityTeamMember opportunityTeamMember = new OpportunityTeamMember(
            OpportunityId=opportunityId,
            UserId=UserId
        );
        insert opportunityTeamMember;

        return opportunityTeamMember;
    }

    public static Lead createLead() {
        Lead lead = new Lead(
            Country='Netherlands',
            LastName='TestKevinBrite',
            Company='BriteTest',
            Company_Segment__c='0 - 1 million',
            ProcessedByLeanData__c = true,
            Status = 'Open'
        );

        insert lead;

        return lead;
    }

    /**
     * @description Create a lead
     *
     * @param lName Last name of the lead
     * @param rtId Lead record type that should be created
     * @param shouldInsert Should the record be saved in the database?
     */
    public static Lead createLead (String lName, Id rtId, Boolean shouldInsert) {
        Lead l = new Lead (
                FirstName = 'Jack',
                LastName = lName,
                Company = 'Test company BV',
                Country = 'Netherlands',
                RecordTypeId = rtId,
                Title = 'Title',
                SalesChannelSingle__c = 'Ecom',
                ProcessedByLeanData__c = true,
                Status = 'Open'
        );

        if (shouldInsert) {
            insert l;
        }

        return l;
    }
    
    /**
     * @description Create a Get Feedback
     * @param contactId ID of the contact
     * @param shouldInsert Should the record be saved in the database?
     */    
    public static Get_Feedback__c createGetFeedback (Id accountId, Boolean shouldInsert) {
        Get_Feedback__c fb = new Get_Feedback__c (
                        Name = 'Test Feedback',
                        NPS__c = 10,
                        Account__c = accountId
        );

        if (shouldInsert) {
            insert fb;
        }

        return fb;
    }

    /**
     * @description Create a task
     *
     * @param sub Subject of the task
     * @param whoId Lead or contact Id to relate the task to
     * @param whatId Account, Opportunity, or another object to relate the task to
     * @param status Status of the task ('Open', 'In Progress', 'Completed')
     * @param dueDate Activity date of the task
     * @param shouldInsert Should the record be saved in the database?
     */
    public static Task createTask (String sub, Id whoId, Id whatId, String status, Date dueDate, Boolean shouldInsert) {
        Task t = new Task (
                Subject = sub,
                Description = 'some comments on the task',
                WhoId = whoId,
                WhatId = whatId,
                Status = status,
                ActivityDate = dueDate
        );

        if (shouldInsert) {
            insert t;
        }

        return t;
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
                                           RepeatDelayMinutes__c = 1, 
                                           RepeatDelayHours__c = 1, 
                                           MaxProcessItems__c = 20000, 
                                           LastProcessedId__c = null, 
                                           LastProcessedDateTime__c = DateTime.newInstance(1970, 1, 1, 12, 0, 0), 
                                           MoreHitsAvailableIndicator__c = false,
                                           RetryDelayMinutes__c = 7);

        if (shouldInsert) {
            insert ss;
        }
        
        return ss;
    }
    
    /**
     * @description Create a Handover
     *
     * @param name Name of the Handover  
     * @param shouldInsert Should the record be saved in the database?
     */
    public static Handover__c createHandover(Id accId, Id oppId, Id rtId, Boolean shouldInsert) {
        Handover__c hnd = new Handover__c (
                    Account__c = accId,
                    Opportunity__c = oppId,
                    RecordTypeId = rtId
        );
        if (shouldInsert) {
            insert hnd;
        }

        return hnd;
    }
    
    public static ShareOfWallet__c createShareOfWallet(Id apId, Boolean shouldInsert) {
        ShareOfWallet__c sow = new ShareOfWallet__c(AccountPlan__c = apId);
        if (shouldInsert) {
            insert sow;
        }
        return sow;
    }

    public static List<PartnerType__c> createPartnerType(List<Account> accList, Boolean shouldInsert){
        List<PartnerType__c> pTypeList = new List<PartnerType__c>();
        for (Account acc : accList){
            pTypeList.add(createPartnerType(acc, false));
        }
        if (shouldInsert){
            insert pTypeList;
        }
        return pTypeList;
    }

    public static PartnerType__c createPartnerType(Account acc, Boolean shouldInsert){
        if (acc.Id == null){
            System.assertEquals(true, false, 'Insert the account before assigning a PartnerType');
        }
        PartnerType__c pType = new PartnerType__c(Account__c = acc.Id, Type__c = 'Technology', SubType__c = 'Billing');
        if (shouldInsert){
            insert pType;
        }
        return pType;
    }
}