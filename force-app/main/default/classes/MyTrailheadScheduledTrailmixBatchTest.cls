@isTest
public class MyTrailheadScheduledTrailmixBatchTest {
    
    @testSetup
    static void testSetup(){
        //Create trailheadapp__Trailmix__c
        trailheadapp__Trailmix__c trail1 = new trailheadapp__Trailmix__c(Name = 'TestBadge',
                                                                         trailheadapp__Description__c = 'Description',
                                                                         trailheadapp__URL__c = 'www.example.com',
                                                                         trailheadapp__Created_By_Profile__c = 'System Administrator', 
                                                                         trailheadapp__External_Id__c = '1', 
                                                                         trailheadapp__Slug__c = '1'
                                                                        );
        insert trail1;
        trailheadapp__Trailmix__c trail2 = new trailheadapp__Trailmix__c(Name = 'TestBadge2',
                                                                         trailheadapp__Description__c = 'Description',
                                                                         trailheadapp__URL__c = 'www.example.com',
                                                                         trailheadapp__Created_By_Profile__c = 'System Administrator', 
                                                                         trailheadapp__External_Id__c = '2', 
                                                                         trailheadapp__Slug__c = '1');
        insert trail2;
        
        //Create UserBadgeScheduledAssignment__c
        
        //
        
        String profileName = 'Adyen Employee';
        System.runAs(New User(Id = UserInfo.getUserId())) {
            User newUser = TestUtil.createUser3Profile(profileName, true);
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Id =: Label.MyTrailheadEndUserId];
            insert new PermissionSetAssignment(AssigneeId = newUser.Id, PermissionSetId = ps.Id);
        }
        Integer daysBetween = 0;
        
        insert createTrailMixAssignment(trail1.Id, daysBetween, 8, profileName);
        insert createTrailMixAssignment(trail2.Id, daysBetween, 8, null);
    }
    
    
    static testMethod void TestSchedulableInterface() {  
        test.startTest();
        MyTrailheadScheduledTrailmixBatch scheduleClass = new MyTrailheadScheduledTrailmixBatch ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, scheduleClass);
        
        MyTrailheadScheduledTrailmixBatch obj = new MyTrailheadScheduledTrailmixBatch();
        DataBase.executeBatch(obj); 
        
        test.stopTest();
        List<trailheadapp__Trailmix_Assignment__c> userTrailmixAssignments = [Select Id, trailheadapp__Trailmix__c, trailheadapp__User__c From trailheadapp__Trailmix_Assignment__c WHERE trailheadapp__User__r.Email = 'testuser3@adyen.dev' AND trailheadapp__User__r.CreatedDate = :Date.today()];
        system.debug(json.serializePretty(userTrailmixAssignments));
        //System.assertEquals(2, userBadgeList.size());
    }

    private static TrailmixScheduledAssignment__c createTrailMixAssignment(Id trailmixId, Integer assignAfterXDays, Integer dueInXDays, String profileName){
        TrailmixScheduledAssignment__c trailAssignment = new TrailmixScheduledAssignment__c(                                                                                             Trailmix__c = trailmixId,
                                                                                              AssignAfterNDays__c = assignAfterXDays,
                                                                                              DueInNDays__c = dueInXDays,
                                                                                              Profile__c = profileName
                                                                                             );
        return trailAssignment;
    }
}