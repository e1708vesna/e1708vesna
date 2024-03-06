@isTest
public class MyTrailheadScheduledAssignmentBatchTest {
    
    @testSetup
    static void testSetup(){
        //Create Badge
        trailheadapp__Badge__c badge = new trailheadapp__Badge__c(Name = 'TestBadge',
                                                                 trailheadapp__API_Name__c='TestBadge',
                                                                 trailheadapp__Description__c = 'Description',
                                                                 trailheadapp__Icon__c = 'Getting Started',
                                                                 trailheadapp__Namespace__c = 'c',
                                                                 trailheadapp__URL__c = 'www.example.com');
        insert badge;
        trailheadapp__Badge__c badge2 = new trailheadapp__Badge__c(Name = 'TestBadge2',
                                                                 trailheadapp__API_Name__c='TestBadg2e',
                                                                 trailheadapp__Description__c = 'Description',
                                                                 trailheadapp__Icon__c = 'Getting Started',
                                                                 trailheadapp__Namespace__c = 'c',
                                                                 trailheadapp__URL__c = 'www.example.com');
        insert badge2;
        
        //Create UserBadgeScheduledAssignment__c
        
        //
        
        String profileName = 'Adyen Employee';
        System.runAs(New User(Id = UserInfo.getUserId())) {
            User newUser = TestUtil.createUser3Profile(profileName, true);
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Id =: Label.MyTrailheadEndUserId];
            insert new PermissionSetAssignment(AssigneeId = newUser.Id, PermissionSetId = ps.Id);
        }
        Integer daysBetween = 0;
        
        insert createBadgeAssignment(badge.Id, daysBetween, 8, profileName);
        insert createBadgeAssignment(badge2.Id, daysBetween, 8, null);
    }
    
    
    static testMethod void TestSchedulableInterface() {  
        test.startTest();
        MyTrailheadScheduledAssignmentBatch scheduleClass = new MyTrailheadScheduledAssignmentBatch ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, scheduleClass);
        
        MyTrailheadScheduledAssignmentBatch obj = new MyTrailheadScheduledAssignmentBatch();
        DataBase.executeBatch(obj); 
        
        test.stopTest();
        List<trailheadapp__User_Badge__c> userBadgeList = [Select Id, trailheadapp__Assigned_Date__c, trailheadapp__Badge__c, trailheadapp__User__c From trailheadapp__User_Badge__c WHERE trailheadapp__User__r.Email = 'testuser3@adyen.dev' AND trailheadapp__User__r.CreatedDate = :Date.today()];
        system.debug(json.serializePretty(userBadgeList));
        //System.assertEquals(2, userBadgeList.size());
    }

    private static UserBadgeScheduledAssignment__c createBadgeAssignment(Id badgeId, Integer assignAfterXDays, Integer dueInXDays, String profileName){
        UserBadgeScheduledAssignment__c badgeAssignment = new UserBadgeScheduledAssignment__c(Name = 'testAssignment',
                                                                                              Badge__c = badgeId,
                                                                                              AssignAfterNDays__c = assignAfterXDays,
                                                                                              DueInNDays__c = dueInXDays,
                                                                                              Profile__c = profileName
                                                                                             );
        return badgeAssignment;
    }
}