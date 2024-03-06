/**
 * @description Test helper class to create test data for services team. 
 * @Author BRITE
 */
@isTest
public class ServicesTestUtil {

    public static final String SERVICE_AGENT_PERMISSION_SET_GROUP_NAME = 'ServiceAgentSupport';

    private static Map<String, Id> userRoleIdByName;
    private static Map<String, Id> permissionSetIdByName = new Map<String, Id> ();
    private static Map<String, Id> permissionSetGroupIdByDevName = new Map<String, Id> ();

    private static Boolean hasCalculatedPermissionSetGroups = false;
    /**
     * @description Will trigger a recalculation of permission set groups. <br />
     * This is especially relevant when deploying changes to permission set groups, because Salesforce needs to determine the impact of the change. <br />
     * While doing that, the status will be Updating, which will result in an error when trying to assign that permission set group to a user.
     *
     * @param permissionSetGroupIds List of ids of permission set groups that need to be recalculated
     */
    public static void  calculatePermissionSetGroups(List<String> permissionSetGroupIds){
        // Make sure the permission set group is done calculating before assigning to the user.
        // This is especially relevant during deployments with changes to the permission set group
        if (!hasCalculatedPermissionSetGroups) {
            Test.calculatePermissionSetGroup(permissionSetGroupIds);
            hasCalculatedPermissionSetGroups = true;
        }
    }
    /**
     * @description Retrieve a service channel that is linked to the object Case.
     */
    public static ServiceChannel caseServiceChannel {
        get {
            if (caseServiceChannel == null) {
                caseServiceChannel = [SELECT Id, MasterLabel, DeveloperName FROM ServiceChannel WHERE RelatedEntity = 'Case' LIMIT 1];
            }
            return caseServiceChannel;
        }
        private set;
    }
    
    /**
     * @description Retrieve a queue for cases. 
     *              Field QueueId contains the ID of the queue.
     */
    public static QueueSObject caseQueue {
        get {
            if (caseQueue == null) {
                caseQueue = [SELECT QueueId, Queue.Name, Queue.DeveloperName FROM QueueSObject WHERE SobjectType = 'Case' LIMIT 1];
            }
            return caseQueue;
        }
        private set;
    }
    /**
     * @description Retrieve id for the indicated profile.
     */
    public static Id getUserRoleId(String name) {
        if (userRoleIdByName == null) {
            userRoleIdByName = new Map<String, Id> ();
            for (UserRole ur : [SELECT Id, Name FROM UserRole ORDER BY Name]) {
                userRoleIdByName.put(ur.Name, ur.Id);
            }
        }

        return userRoleIdByName.get(name);
    }

    /**
     * @description Get record type ID.
     *              TODO: build in 'caching'
     * 
     * @param sobjectName Name of the SObject to retrieve the record type id for
     * @param developerName Developer name of the record type
     */
    public static Id getRecordTypeId(String sobjectName, String developerName) {
        List<RecordType> recordTypes = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = :sobjectName AND DeveloperName =  :developerName];
        
        if (!recordTypes.isEmpty()) {
            return recordTypes[0].Id;
        }
        return null;
    }

    /**
     * @description Create an account
     *
     * @param accountName Name of the account
     * @param recordTypeId Account record type that should be created. If left blank, the default record type of the user running the test class will be used.
     * @param shouldInsert Should the record be saved in the database?
     */
    public static Account createAccount(String accountName, Id recordTypeId, Boolean shouldInsert) {
        Account acc = new Account (
                Name = accountName,
                BillingCountry = 'Netherlands'
        );
        if (recordTypeId != null) {
            acc.RecordTypeId = recordTypeId;
        }

        if (shouldInsert) {
            insert acc;
        }

        return acc;
    }

    /**
     * @description Create partner type for an account with account type 'Partner' or 'Partner & Merchant'.
     * 
     * @param partnerAccountId Id of the related partner account (mandatory)
     * @param type Type of service (Technology, Service, Value Added Service (VAS), or Undefined)
     * @param subType Subtype of the service
     * @param status Status of the partner type (Active, Inactive, Potential)
     * @param shouldInsert Should the record be saved in the database?
     */
    public static PartnerType__c createPartnerType(Id partnerAccountId, String type, String subType, String status, Boolean shouldInsert) {
        PartnerType__c partnerType = new PartnerType__c (
            Account__c = partnerAccountId,
            Type__c = type,
            SubType__c = subType,
            Status__c = status
        );

        if (shouldInsert) {
            insert partnerType;
        }

        return partnerType;
    }

    /**
     * @description Create a contact
     *
     * @param relatedAccountId Id of the related account
     * @param lName Last name of the contact
     * @param email Email of the contact
     * @param shouldInsert Should the record be saved in the database?
     */
    public static Contact createContact(Id relatedAccountId, String lName, String email, Boolean shouldInsert) {
        Contact con = new Contact (
                    AccountId = relatedAccountId,
                    FirstName = 'Jack',
                    LastName = lName,
                    Email = email,
                    MailingCountry = 'Netherlands'
        );

        if (shouldInsert) {
            insert con;
        }

        return con;
    }    

    /**
     * @description Create a new case
     * 
     * @param recordTypeId Case record type that should be created. If left blank, the default record type of the user running the test class will be used.
     * @param accountId Id of the account record that should be related to the case
     * @param contactId Id of the contact record that should be related to the case
     * @param shouldInsert Should the record be saved in the database?
     */
    public static Case createCase(Id recordTypeId, Id accountId, Id contactId, Boolean shouldInsert) {
        Case c = new Case (
            AccountId = accountId,
            ContactId = contactId
        );
        if (recordTypeId != null) {
            c.RecordTypeId = recordTypeId;
        }

        if (shouldInsert) {
            insert c;
        }

        return c;
    }

    /**
     * @description Create a new user
     * 
     * @param profileName Name of the profile that the user should be created for.
     * @param roleName Name of the role that the user should receive.
     * @param shouldInsert Should the record be saved in the database?
     */
    private static integer userIteration = 0;
    public static User createUser(String profileName, String roleName, Boolean shouldInsert) {
        userIteration++;
        User u = new User(
            ProfileId = TestUtil.getProfile(profileName),
            LastName = 'Test User',
            Email = 'testuser.service@adyen.unittest.fake',
            Username = 'testuser.service.' + System.currentTimeMillis() + userIteration + '@adyen.unittest.fake',
            CompanyName = 'Adyen',
            Alias = 'tstuser',
            TimeZoneSidKey = 'Europe/Amsterdam',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = getUserRoleId(roleName)
        );

        if (shouldInsert) {
            insert u;
        }

        return u;
    }

    public static List<sObject> assignPermissionsToUser(List<User> users, Set<String> permissionSetGroupDevNames, Set<String> permissionSetNames, Boolean shouldInsert) {
        List<PermissionSetAssignment> permissionAssignments = new List<PermissionSetAssignment>();

        Set<Id> permissionSetIds = permissionSetNames == null ? new Set<Id>() : getPermissionSetIds(permissionSetNames);
        Set<Id> permissionSetGroupIds = permissionSetGroupDevNames == null ? new Set<Id>() : getPermissionSetGroupIds(permissionSetGroupDevNames);

        for (User u : users){
            for (Id permissionsetId : permissionSetIds) {
                permissionAssignments.add(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permissionsetId));
            }
            for (Id permissionGroupId : permissionSetGroupIds) {
                permissionAssignments.add(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetGroupId = permissionGroupId));
            }
        }

        if (shouldInsert) {
            insert permissionAssignments;
        }

        return permissionAssignments;
    }
    
    /**
     * @description Get all ID's of the requested permission sets based on their name.
     */
    private static Set<Id> getPermissionSetIds(Set<String> permissionSetNames) {
        Set<Id> permissionSetIds = new Set<Id> ();

        Set<String> lookUpPermissionSets = new Set<String> ();
        for (String psn : permissionSetNames) {
            if (permissionSetIdByName.containsKey(psn)) {
                // id is already known
                permissionSetIds.add(permissionSetIdByName.get(psn));
            } else {
                lookUpPermissionSets.add(psn);
            }
        }

        // retrieve all unknown ids
        if (!lookUpPermissionSets.isEmpty()) {
            for (PermissionSet ps : [SELECT Id, Name FROM PermissionSet WHERE Name IN :lookUpPermissionSets]) {
                permissionSetIds.add(ps.Id);
                permissionSetIdByName.put(ps.Name, ps.Id);
            }
        }

        return permissionSetIds;
    }

    /**
     * @description Get all ID's of the requested permission set groups based on their name.
     */
    private static Set<Id> getPermissionSetGroupIds(Set<String> permissionSetGroupDevNames) {
        Set<Id> permissionSetGroupIds = new Set<Id> ();

        Set<String> lookUpPermissionSetGroups = new Set<String> ();
        for (String psgn : permissionSetGroupDevNames) {
            if (permissionSetGroupIdByDevName.containsKey(psgn)) {
                // id is already known
                permissionSetGroupIds.add(permissionSetGroupIdByDevName.get(psgn));
            } else {
                lookUpPermissionSetGroups.add(psgn);
            }
        }

        // retrieve all unknown ids
        if (!lookUpPermissionSetGroups.isEmpty()) {
            for (PermissionSetGroup psg : [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName IN :lookUpPermissionSetGroups]) {
                permissionSetGroupIds.add(psg.Id);
                permissionSetGroupIdByDevName.put(psg.DeveloperName, psg.Id);
            }
        }
        calculatePermissionSetGroups((List<String>) new List<Id>(permissionSetGroupIds));

        return permissionSetGroupIds;
    }


}