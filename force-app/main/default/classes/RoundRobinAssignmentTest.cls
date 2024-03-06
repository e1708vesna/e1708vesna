@isTest
public class RoundRobinAssignmentTest {
    
    
    private static final String groupName = 'testRoundRobinAssignmentGroupTestClass';
    
    @isTest
    private static void assignLeads(){
        /* 
* Step 1: Create Round Robin
* Step 2: Create Round Robin Assignee
* Step 3: Create leads
* Step 4: Call RoundRobinAssignment.assignLeads(List<Id> LeadIds)
*/
        // Setup 3 Test Users 
        // not using testUtil because it cannot handle bulk
        Id profileId = TestUtil.getProfile('Adyen v2 Sales Lead'); 
        List<User> userList = new List<User>();
        
        while (userList.size() < 3) {
            User u = TestUtil.createUser3Profile(profileId, false);
            userList.add(u);
        }
        insert(userList);
        
        
        //Create RoundRobin and assignees
        RoundRobin__c rrAMS = new RoundRobin__c(IsActive__c = true, Name = groupName);
        insert rrAMS;
        RoundRobinAssignee__c rrAssignee1 = new RoundRobinAssignee__c(User__c = userList[0].Id, RoundRobin__c = rrAMS.Id, IsActive__c = true, LastAssigned__c = DateTime.now());
        RoundRobinAssignee__c rrAssignee2 = new RoundRobinAssignee__c(User__c = userList[1].Id, RoundRobin__c = rrAMS.Id, IsActive__c = true, LastAssigned__c = DateTime.now().addDays(-1));
        RoundRobinAssignee__c rrAssignee3 = new RoundRobinAssignee__c(User__c = userList[2].Id, RoundRobin__c = rrAMS.Id, IsActive__c = true, LastAssigned__c = DateTime.now().addDays(-2));
        List<RoundRobinAssignee__c> rrAssigneeList = new List<RoundRobinAssignee__c>();
        rrAssigneeList.add(rrAssignee1);
        rrAssigneeList.add(rrAssignee2);
        rrAssigneeList.add(rrAssignee3);
        insert rrAssigneeList;
        
        
        //create 10 leads
        Group testGroup = new Group(Name= groupName, Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Lead');
            insert testQueue;
        }
        
        List<Lead> ldList = new List<Lead>();
        for (integer i = 0; i < 10; i++){
            Lead ld = TestUtil.createLead('RoundRobin' + i, Constants.RT_ID_LEAD_INBOUND2, false);
            ld.OwnerId = testGroup.Id;
            ldList.add(ld);
        }
        for (integer i = 10; i < 12; i++){
            Lead ld = TestUtil.createLead('RoundRobin' + i, Constants.RT_ID_LEAD_INBOUND2, false);
            ldList.add(ld);
        }
        insert ldList;
        List<Id> ldIdList = new List<Id>();
        for (Lead ld : ldList){
            ldIdList.add(ld.Id);
        }
        //Call RoundRobinAssignment
        RoundRobinAssignment.assignLeads(ldIdList);
        ldList = [Select Id, OwnerId, Owner.Name, RoundRobinName__c From Lead];
        integer ownerOneAssignments = 0;
        integer ownerTwoAssignments = 0;
        integer ownerThreeAssignments = 0;
        integer noOwnerAssignments = 0;
        for (Lead ld : ldList){
            if (ld.OwnerId == userList[0].Id){
                ownerOneAssignments++;
            }
            else if (ld.OwnerId == userList[1].Id){
                ownerTwoAssignments++;
            }
            else if (ld.OwnerId == userList[2].Id){
                ownerThreeAssignments++;
            }
            else {
                noOwnerAssignments++;
            }
        }
        System.assertEquals(3, ownerOneAssignments);
        System.assertEquals(3, ownerTwoAssignments);
        System.assertEquals(4, ownerThreeAssignments);
        System.assertEquals(2, noOwnerAssignments);
        
    }
}