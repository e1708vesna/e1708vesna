/**
 * @author (s)    : Brite
 * @description   :
 */

@IsTest
private class ClaimMemberHelperTest {
    @IsTest
    private static void testCopyTeamMembersToClaimMembers() {
        Opportunity opportunity = TestUtil.createOpportunity(TestUtil.createAccount('Test acc', true, true).Id, TestUtil.createUser().Id, true);
		User user1 = TestUtil.createUser3Profile('Adyen v2 Sales', false);
		User user2 = TestUtil.createUser3Profile('Adyen v2 Sales Lead', false);
		User user3 = TestUtil.createUser3Profile('Adyen v2 Account Manager', false);
        System.runAs(new User(Id = UserInfo.getUserId())){
        insert new List<User>{user1, user2, user3};
            }
        OpportunityTeamMember[] otms = new OpportunityTeamMember[]{
            TestUtil.createOpportunityTeamMember(opportunity.Id, user1.Id, 'Opportunity Owner', false),
            TestUtil.createOpportunityTeamMember(opportunity.Id, user2.Id, 'Sales Manager', false),
            TestUtil.createOpportunityTeamMember(opportunity.Id, user3.Id, 'Account Manager', false)
        };

        // trigger the OpportunityTeamMemberConverter through the 'after insert' of the OpportunityTeamMember Trigger
        insert otms;

        ClaimMembers__c[] claimMembers = [SELECT Account__c, Opportunity__c, User__c, OwnerId, Status__c, PosAdvanceClaimStatus__c, EligibleForClaim__c, Percentage__c FROM ClaimMembers__c ORDER BY User__c];

        // assert that two OpportunityTeamMembers have been converted to ClaimMembers
        System.assertEquals(2, claimMembers.size());

        for (Integer i = 0; i < claimMembers.size(); i++) {
            // assert that the conversion and mapping was done correctly
            System.assertEquals(opportunity.AccountId, claimMembers.get(i).Account__c);
            System.assertEquals(opportunity.Id, claimMembers.get(i).Opportunity__c);
            System.assertEquals(otms.get(i).UserId, claimMembers.get(i).User__c);
            System.assertEquals(otms.get(i).UserId, claimMembers.get(i).OwnerId);
            System.assertEquals('No claim started', claimMembers.get(i).Status__c);
            System.assertEquals(null, claimMembers.get(i).PosAdvanceClaimStatus__c);
            // assert that each of the converted ClaimMembers is EligibleForClaim and has a percentage of 50
            System.assertEquals(true, claimMembers.get(i).EligibleForClaim__c);
            System.assertEquals(50, claimMembers.get(i).Percentage__c);

            claimMembers.get(i).EligibleForClaim__c = false;
        }

        // set all EligibleForClaims to false
        update claimMembers;

        // assert that all ClaimMembers are no longer Eligible and don't have a Percentage anymore
        for (ClaimMembers__c claimMember : [SELECT EligibleForClaim__c, Percentage__c FROM ClaimMembers__c]) {
            System.assertEquals(false, claimMember.EligibleForClaim__c);
            System.assertEquals(null, claimMember.Percentage__c);
        }
    }

    @IsTest
    private static void testCopyTeamMembersToClaimMembersExcludedRecordType() {
        Opportunity opportunity = TestUtil.createOpportunity(TestUtil.createAccount('Test acc', true, true).Id, TestUtil.createUser().Id, false);
        opportunity.recordTypeId = Constants.RT_ID_OPP_AM;
        insert opportunity;
        User user1 = TestUtil.createUser3Profile('Adyen v2 Sales', false);
		User user2 = TestUtil.createUser3Profile('Adyen v2 Sales Lead', false);
		User user3 = TestUtil.createUser3Profile('Adyen v2 Account Manager', false);
        System.runAs(new User(Id = UserInfo.getUserId())){
        insert new List<User>{user1, user2, user3};
            }
        OpportunityTeamMember[] otms = new OpportunityTeamMember[]{
            TestUtil.createOpportunityTeamMember(opportunity.Id, user1.Id, 'Opportunity Owner', false),
            TestUtil.createOpportunityTeamMember(opportunity.Id, user2.Id, 'Sales Manager', false),
            TestUtil.createOpportunityTeamMember(opportunity.Id, user3.Id, 'Account Manager', false)
        };

        // trigger the OpportunityTeamMemberConverter through the 'after insert' of the OpportunityTeamMember Trigger
        insert otms;

        ClaimMembers__c[] claimMembers = [SELECT Account__c, Opportunity__c, User__c, OwnerId, Status__c, PosAdvanceClaimStatus__c, EligibleForClaim__c, Percentage__c FROM ClaimMembers__c ORDER BY User__c];

        // assert that two OpportunityTeamMembers have been converted to ClaimMembers
        System.assertEquals(0, claimMembers.size());
    }
    
    @IsTest
    private static void testSetEligibleAndPercentage() {
        Opportunity opportunity = TestUtil.createOpportunity(TestUtil.createAccount('Test acc', true, true).Id, TestUtil.createUser().Id, true);

       // User user1 = TestUtil.createUser();
       // User user2 = TestUtil.createUser2();
        User user1 = TestUtil.createUser3Profile('Adyen v2 Sales', false);
        User user2  =   TestUtil.createUser3Profile('Adyen v2 Sales Lead', false);
        System.runAs(new User(Id = UserInfo.getUserId())){
        	insert new List<User>{user1, user2};
            }
        ClaimMembers__c[] claimMembers = new ClaimMembers__c[]{
            new ClaimMembers__c(Account__c = opportunity.AccountId, User__c = user1.Id, ClaimMemberArea__c = 'Belgium'),
            new ClaimMembers__c(Account__c = opportunity.AccountId, User__c = user2.Id, ClaimMemberArea__c = 'Germany')
        };

        OpportunityTeamMember[] otms = new OpportunityTeamMember[]{
            TestUtil.createOpportunityTeamMember(opportunity.Id, user1.Id, 'Opportunity Owner', false),
            TestUtil.createOpportunityTeamMember(opportunity.Id, user2.Id, 'Sales Manager', false)
        };

        insert claimMembers;

        // assert that only the given amount of ClaimMembers have been inserted
        System.assertEquals(claimMembers.size(), [SELECT COUNT() FROM ClaimMembers__c]); 

        insert otms;

        // assert that no OpportunityTeamMembers have been converted to ClaimMembers
        System.assertEquals(claimMembers.size(), [SELECT COUNT() FROM ClaimMembers__c]);

        // assert that both ClaimMembers are Eligible and have a percentage of 70%, as their SalesCountries are different
        for (ClaimMembers__c claimMember : [SELECT EligibleForClaim__c, Percentage__c FROM ClaimMembers__c]) {
            System.assertEquals(true, claimMember.EligibleForClaim__c);
            System.assertEquals(70, claimMember.Percentage__c); 
        }
		Test.startTest();
        ClaimMembers__c[] newClaimMembers = new ClaimMembers__c[]{
            new ClaimMembers__c(Account__c = opportunity.AccountId, User__c = user1.Id, ClaimMemberArea__c = 'Belgium'),
            new ClaimMembers__c(Account__c = opportunity.AccountId, User__c = user2.Id, ClaimMemberArea__c = 'Germany')
        };
        insert newClaimMembers;

        // assert that two more ClaimMembers have been inserted
        System.assertEquals(claimMembers.size() + newClaimMembers.size(), [SELECT COUNT() FROM ClaimMembers__c]);

        // assert that all four are Eligible and have a percentage of 35%, as their SalesCountries are different
        for (ClaimMembers__c claimMember : [SELECT EligibleForClaim__c, Percentage__c FROM ClaimMembers__c]) {
            System.assertEquals(true, claimMember.EligibleForClaim__c);
            System.assertEquals(35, claimMember.Percentage__c);
        }

        // make one of the new ClaimMembers Non-Eligible
        ClaimMembers__c newClaimMember     = newClaimMembers.get(0);
        newClaimMember.EligibleForClaim__c = false;
        update newClaimMember;

        // assert that the rest of the ClaimMembers are still Eligible, but now have a percentage of 46%
        for (ClaimMembers__c claimMember : [SELECT EligibleForClaim__c, Percentage__c FROM ClaimMembers__c]) {
            Boolean isEligible = claimMember.Id != newClaimMember.Id;

            System.assertEquals(isEligible, claimMember.EligibleForClaim__c);
            System.assertEquals(isEligible ? 46.6666666666666666666666666666667 : null, claimMember.Percentage__c);
        }
        
		Test.stopTest();
    }

    @IsTest
    private static void testSetEligibleAndPercentageWithRegularClaims() {
        Opportunity opportunity = TestUtil.createOpportunity(TestUtil.createAccount('Test acc', true, true).Id, TestUtil.createUser().Id, true);
        User user               = TestUtil.createUser();

        ClaimMembers__c claimMember1 = new ClaimMembers__c(Account__c = opportunity.AccountId, User__c = user.Id, ClaimMemberArea__c = 'Belgium');
        insert claimMember1;

        System.assertEquals(1, [SELECT COUNT() FROM ClaimMembers__c]);

        for (ClaimMembers__c claimMember : [SELECT EligibleForClaim__c, Percentage__c FROM ClaimMembers__c]) {
            System.assertEquals(true, claimMember.EligibleForClaim__c);
            System.assertEquals(100, claimMember.Percentage__c);
        }


        // insert an Exception Claim for the Account of the Opportunity
        insert new Claim__c(RecordTypeId = Constants.RT_ID_CLAIM_EXCEPTION, Account__c = opportunity.AccountId);

        // insert a new ClaimMember
        ClaimMembers__c claimMember2 = new ClaimMembers__c(Account__c = opportunity.AccountId, User__c = user.Id, ClaimMemberArea__c = 'Belgium');
        insert claimMember2;
		
		Test.startTest();
        // assert that one more ClaimMember has been inserted
        System.assertEquals(2, [SELECT COUNT() FROM ClaimMembers__c]);
        // assert that both ClaimMembers are Eligible with a percentage of 50%
        for (ClaimMembers__c claimMember : [SELECT EligibleForClaim__c, Percentage__c FROM ClaimMembers__c]) {
            System.assertEquals(true, claimMember.EligibleForClaim__c);
            System.assertEquals(50, claimMember.Percentage__c);
        }

        // insert a Regular Claim for the Account of the Opportunity
        insert new Claim__c(RecordTypeId = Constants.RT_ID_CLAIM_REGULAR, Account__c = opportunity.AccountId);
        // insert a new ClaimMember
        ClaimMembers__c claimMember3 = new ClaimMembers__c(Account__c = opportunity.AccountId, User__c = user.Id, ClaimMemberArea__c = 'Belgium');
        insert claimMember3;

        // assert that one more ClaimMember has been inserted
        System.assertEquals(3, [SELECT COUNT() FROM ClaimMembers__c]);

        // assert that all ClaimMembers are Eligible with a percentage of 50%, except for the newly inserted ClaimMember
        for (ClaimMembers__c claimMember : [SELECT EligibleForClaim__c, Percentage__c FROM ClaimMembers__c]) {
            System.assertEquals((claimMember.Id != claimMember3.Id), claimMember.EligibleForClaim__c);
            System.assertEquals((claimMember.Id != claimMember3.Id) ? 50 : null, claimMember.Percentage__c);
        }
        
		Test.stopTest();
    }

    @IsTest
    private static void testErrorForEligibleClaimMembers() {
        Opportunity opportunity = TestUtil.createOpportunity(TestUtil.createAccount('Test acc', true, true).Id, TestUtil.createUser().Id, true);

        User user1 = TestUtil.createUser();
        User user2 = TestUtil.createUser2();

        ClaimMembers__c[] claimMembers = new ClaimMembers__c[]{
            new ClaimMembers__c(Account__c = opportunity.AccountId, User__c = user1.Id, EligibleForClaim__c = true),
            new ClaimMembers__c(Account__c = opportunity.AccountId, User__c = user2.Id, EligibleForClaim__c = true),
            new ClaimMembers__c(Account__c = opportunity.AccountId, User__c = user2.Id, EligibleForClaim__c = true),
            new ClaimMembers__c(Account__c = opportunity.AccountId, User__c = user2.Id, EligibleForClaim__c = true),
            new ClaimMembers__c(Account__c = opportunity.AccountId, User__c = user2.Id, EligibleForClaim__c = true)
        };
        DmlException ex = null;

        try {
            // trying to insert more than four Eligible ClaimMembers should trigger an DmlException
            insert claimMembers;
        } catch (DmlException e) {
            ex = e;
        }

        // assert that an DmlException was thrown
        System.assertNotEquals(null, ex);
        System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
        System.assertEquals('One Account can have only 4 Eligible ClaimMembers at most', ex.getDmlMessage(0));

        // change the last ClaimMember to Non-Eligible, so we can insert all five
        claimMembers.get(4).EligibleForClaim__c = false;
        insert claimMembers;

        ex = null;
        try {
            // changing the one Non-Eligible ClaimMember to an Eligible ClaimMember should trigger an DmlException
            claimMembers.get(4).EligibleForClaim__c = true;
            update claimMembers;
        } catch (DmlException e) {
            ex = e;
        }

        // assert that an DmlException was thrown
        System.assertNotEquals(null, ex);
        System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
        System.assertEquals('One Account can have only 4 Eligible ClaimMembers at most', ex.getDmlMessage(0));
    }

    
    
    
    @IsTest
    private static void testClaimMemberDeletion() {
        System.debug('************************testClaimMemberDeletion*******************');
        Opportunity opportunity = TestUtil.createOpportunity(TestUtil.createAccount('Test acc', true, true).Id, TestUtil.createUser().Id, true);
        System.debug('Queries used after creation of Account, User and Opportunity: ' + Limits.getQueries());
		test.startTest();
        // create six ClaimMembers, the first of which will have a different SalesCountry
        ClaimMembers__c[] claimMembers = new ClaimMembers__c[]{
            new ClaimMembers__c(Account__c = opportunity.AccountId, User__c = TestUtil.createUser2().Id, ClaimMemberArea__c = 'Germany'),
            new ClaimMembers__c(Account__c = opportunity.AccountId, User__c = TestUtil.createUser().Id, ClaimMemberArea__c = 'Belgium'),
            new ClaimMembers__c(Account__c = opportunity.AccountId, User__c = TestUtil.createUser().Id, ClaimMemberArea__c = 'Belgium'),
            new ClaimMembers__c(Account__c = opportunity.AccountId, User__c = TestUtil.createUser().Id, ClaimMemberArea__c = 'Belgium'),
            new ClaimMembers__c(Account__c = opportunity.AccountId, User__c = TestUtil.createUser().Id, ClaimMemberArea__c = 'Belgium'),
            new ClaimMembers__c(Account__c = opportunity.AccountId, User__c = TestUtil.createUser().Id, ClaimMemberArea__c = 'Belgium')
        };
            
        System.debug('Queries used before creation of claimMembers: ' + Limits.getQueries());
        insert claimMembers;
        System.debug('Queries used after creation of claimMembers: ' + Limits.getQueries());

        claimMembers = [SELECT EligibleForClaim__c, Percentage__c, ClaimMemberArea__c FROM ClaimMembers__c];
		Test.stopTest();
        // assert that only the first four ClaimMembers are Eligible and have a percentage of 35, as one of them has a different SalesCountry
        for (Integer i = 0; i < claimMembers.size(); i++) {
            System.assertEquals((i < 4), claimMembers.get(i).EligibleForClaim__c);
            System.assertEquals((i < 4) ? 35 : null, claimMembers.get(i).Percentage__c);
        }

        // delete the one ClaimMember with a different SalesCountry
        System.debug('Queries used before delete of claimMembers: ' + Limits.getQueries());
        delete claimMembers.get(0);
        System.debug('Queries after before delete of claimMembers: ' + Limits.getQueries());

        claimMembers = [SELECT EligibleForClaim__c, Percentage__c, ClaimMemberArea__c FROM ClaimMembers__c];

        // assert that only the first three ClaimMembers are Eligible and have a percentage of 33, as all of them have the same SalesCountry
        for (Integer i = 0; i < claimMembers.size(); i++) {
            System.assertEquals((i < 3), claimMembers.get(i).EligibleForClaim__c);
            System.assertEquals((i < 3) ? 33.3333333333333333333333333333333 : null, claimMembers.get(i).Percentage__c);
        }
        
        System.debug('************************ END testClaimMemberDeletion*******************');
    }

    @IsTest
    private static void testClaimMemberShare() {
        System.debug('************************testClaimMemberShare*******************');
        //Check if the shares are created 
        Account acc = TestUtil.createAccount('Test acc', true, true);
        Opportunity opp = TestUtil.createOpportunity(acc.Id, TestUtil.createUser().Id, true);

        ClaimMembers__c[] claimMembers;
        //claimMembers = [SELECT Claim__c, EligibleForClaim__c, Percentage__c, ClaimMemberArea__c FROM ClaimMembers__c];
        //system.assertEquals(0, claimMembers.size(), 'No ClaimMembers should exist!');
        List<ClaimMembers__Share> claimMemberShareList;
        //claimMemberShareList = [SELECT c.UserOrGroupId, c.RowCause, c.ParentId, c.Id, c.AccessLevel FROM ClaimMembers__Share c WHERE RowCause = 'Manual'];
        //system.assertEquals(0, claimMemberShareList.size(), 'No Manual share should have created!');

        // create 5 additional ClaimMembers, the first of which will have a different SalesCountry
        
        claimMembers = new ClaimMembers__c[]{
            new ClaimMembers__c(Opportunity__c = opp.Id, Account__c = opp.AccountId, User__c = TestUtil.createUser2().Id, ClaimMemberArea__c = 'Germany'),
            new ClaimMembers__c(Opportunity__c = opp.Id, Account__c = opp.AccountId, User__c = TestUtil.createUser().Id, ClaimMemberArea__c = 'Belgium'),
            new ClaimMembers__c(Opportunity__c = opp.Id, Account__c = opp.AccountId, User__c = TestUtil.createUser().Id, ClaimMemberArea__c = 'Belgium'),
            new ClaimMembers__c(Opportunity__c = opp.Id, Account__c = opp.AccountId, User__c = TestUtil.createUser().Id, ClaimMemberArea__c = 'Belgium'),
            new ClaimMembers__c(Opportunity__c = opp.Id, Account__c = opp.AccountId, User__c = TestUtil.createUser().Id, ClaimMemberArea__c = 'Belgium')
        };
        insert claimMembers;
        System.debug('Queries used after creation of claimMembers: ' + Limits.getQueries());
        //claimMembers = [SELECT Claim__c, EligibleForClaim__c, Percentage__c, ClaimMemberArea__c FROM ClaimMembers__c];
        //system.assertEquals(5, claimMembers.size(), '5 Should have been created!');

        claimMemberShareList = [SELECT c.UserOrGroupId, c.RowCause, c.ParentId, c.Id, c.AccessLevel FROM ClaimMembers__Share c WHERE RowCause = 'Manual'];
        system.assertEquals(25, claimMemberShareList.size(), 'All users should have a share per ClaimMember!');
        Test.startTest();
		System.debug('Queries used before deletion of claimMember: ' + Limits.getQueries());
        //Check if the shares are deleted 
        delete claimMembers[2];

		System.debug('Queries used after deletion of claimMember: ' + Limits.getQueries());
        claimMembers = [SELECT Claim__c, EligibleForClaim__c, Percentage__c, ClaimMemberArea__c FROM ClaimMembers__c];
        system.assertEquals(4, claimMembers.size(), '4 Should still exist!');

        claimMemberShareList = [SELECT c.UserOrGroupId, c.RowCause, c.ParentId, c.Id, c.AccessLevel FROM ClaimMembers__Share c WHERE RowCause = 'Manual'];
        system.assertEquals(16, claimMemberShareList.size(), 'All users should have a share per ClaimMember!');
        //test update User or Opportunity or Claim -> add claim
        //Claim__c claim = new Claim__c(Account__c = acc.Id, Opportunity__c = opp.Id)
        Claim__c claim = new Claim__c(Account__c = acc.Id);
        insert claim;
		
        List<Claim__Share> claimShareList;
        //claimShareList = [SELECT c.UserOrGroupId, c.RowCause, c.ParentId, c.Id, c.AccessLevel FROM Claim__Share c WHERE RowCause = 'Manual'];
        //system.assertEquals(0, claimShareList.size(), 'No Manual share should have created!');
		
        
        
        claimMembers[0].Claim__c = claim.Id;
        claimMembers[1].Claim__c = claim.Id;
        claimMembers[2].Claim__c = claim.Id;
        claimMembers[3].Claim__c = claim.Id;
        update claimMembers;

        claimShareList = [SELECT c.UserOrGroupId, c.RowCause, c.ParentId, c.Id, c.AccessLevel FROM Claim__Share c WHERE RowCause = 'Manual'];
        system.assertEquals(3, claimShareList.size(), 'Claim should be shared with all the eligable ClaimMembers!');

        delete claimMembers[2];

        claimShareList = [SELECT c.UserOrGroupId, c.RowCause, c.ParentId, c.Id, c.AccessLevel FROM Claim__Share c WHERE RowCause = 'Manual'];
        system.assertEquals(2, claimShareList.size(), 'Claim should be shared with all the eligable ClaimMembers!');

        //TODO Delete check?
        System.debug('End Test');
        
		Test.stopTest();
    }
    
    @isTest
    public static void oppClosedLost(){
        Opportunity opportunity = TestUtil.createOpportunity(TestUtil.createAccount('Test acc', true, true).Id, TestUtil.createUser().Id, true);

        
        User testUser = TestUtil.createUser3Profile('Adyen v2 Sales', false);
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert testUser;
        }
        OpportunityTeamMember[] otms = new OpportunityTeamMember[]{
            TestUtil.createOpportunityTeamMember(opportunity.Id, testUser.Id, 'Account Manager', false)
        };
        // trigger the OpportunityTeamMemberConverter through the 'after insert' of the OpportunityTeamMember Trigger
        insert otms;
        
        List<ClaimMembers__c> claimMembers = [SELECT Claim__c, EligibleForClaim__c FROM ClaimMembers__c];
        System.assertEquals(1, claimMembers.size(), 'Expected 1 claimmember');
        for (ClaimMembers__c cm : claimMembers){
            System.assertEquals(true, cm.EligibleForClaim__c, 'Eligble for Claim should be true');
        }
        Test.startTest();
        opportunity.StageName = 'Closed Lost';
        opportunity.LostToCompetitorUnknown__c = true;
        opportunity.Lost_Reason__c = 'Nonresponsive';
        update opportunity;
        Test.stopTest();
        claimMembers = [SELECT Claim__c, EligibleForClaim__c FROM ClaimMembers__c];
        System.assertEquals(1, claimMembers.size(), 'Expected 1 claimmember');
        for (ClaimMembers__c cm : claimMembers){
            System.assertEquals(false, cm.EligibleForClaim__c, 'Eligble for Claim should be false');
        }
    }
    
    @isTest
    public static void oppClosedLostOtherValid(){
        Account acc = TestUtil.createAccount('Test acc', true, true);
        User usr = TestUtil.createUser('test', false);
        User usrOtm = TestUtil.createUser3Profile('Adyen v2 Sales', false);
        User usrOtm2 = TestUtil.createUser3Profile('Adyen v2 Sales', false);
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert new List<User>{usr, usrOtm, usrOtm2};
                }
        Opportunity opportunity = TestUtil.createOpportunity(acc.Id, usr.Id, false);
        Opportunity opportunity2 = TestUtil.createOpportunity(acc.Id, usr.Id, false);
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opportunity);
        oppList.add(opportunity2);
        insert oppList;
        
		
        OpportunityTeamMember otm11 = TestUtil.createOpportunityTeamMember(opportunity.Id, usrOtm.Id, 'Account Manager', false);
        OpportunityTeamMember otm12 = TestUtil.createOpportunityTeamMember(opportunity.Id, usrOtm2.Id, 'Account Manager', false);
        OpportunityTeamMember otm21 = TestUtil.createOpportunityTeamMember(opportunity2.Id, usrOtm.Id, 'Account Manager', false);
        OpportunityTeamMember otm22 = TestUtil.createOpportunityTeamMember(opportunity2.Id, usrOtm2.Id, 'Account Manager', false);
        
        OpportunityTeamMember[] otms = new OpportunityTeamMember[]{
            otm11,
            otm12
        };
        // trigger the OpportunityTeamMemberConverter through the 'after insert' of the OpportunityTeamMember Trigger
        insert otms;
        
        Test.startTest();
        OpportunityTeamMember[] otms2 = new OpportunityTeamMember[]{
            otm21,
            otm22
        };
        insert otms2;
        
        //Regular, nothing happened yet
        List<ClaimMembers__c> claimMembers = [SELECT Claim__c, EligibleForClaim__c, Opportunity__c FROM ClaimMembers__c];
        System.assertEquals(2, claimMembers.size(), 'Expected 2 claimmember');
        for (ClaimMembers__c cm : claimMembers){
            System.assertEquals(true, cm.EligibleForClaim__c, 'Eligble for Claim should be true');
            System.assertEquals(opportunity.Id, cm.Opportunity__c);
        }
        
        
        
        //OpportunityTeamMember is deleted, but there is another valid opportunity
        delete otm12;
        claimMembers = [SELECT Claim__c, EligibleForClaim__c, Opportunity__c FROM ClaimMembers__c];
        System.assertEquals(2, claimMembers.size(), 'Expected 2 claimmember');
        for (ClaimMembers__c cm : claimMembers){
            System.assertEquals(true, cm.EligibleForClaim__c, 'Eligble for Claim should be true');
        }
        
        //Opportunity is lost, but there is still another valid opportunity
        opportunity.StageName = 'Closed Lost';
        opportunity.LostToCompetitorUnknown__c = true;
        opportunity.Lost_Reason__c = 'Nonresponsive';
        update opportunity;
        
        claimMembers = [SELECT Claim__c, EligibleForClaim__c, Opportunity__c FROM ClaimMembers__c];
        System.assertEquals(2, claimMembers.size(), 'Expected 2 claimmember');
        for (ClaimMembers__c cm : claimMembers){
            System.assertEquals(true, cm.EligibleForClaim__c, 'Eligble for Claim should be true');
            System.assertEquals(opportunity2.Id, cm.Opportunity__c);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void claimMemberDelete(){
        
        User user1 = TestUtil.createUser('test', false);
        User user2 = TestUtil.createUser3Profile('Adyen v2 Sales', false);
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert new List<User>{user1, user2};
                }
        Opportunity opportunity = TestUtil.createOpportunity(TestUtil.createAccount('Test acc', true, true).Id, user1.Id, true);
        
        OpportunityTeamMember otms = TestUtil.createOpportunityTeamMember(opportunity.Id, user2.Id, 'Account Manager', false);
        
        // trigger the OpportunityTeamMemberConverter through the 'after insert' of the OpportunityTeamMember Trigger
        insert otms;
        
        List<ClaimMembers__c> claimMembers = [SELECT Claim__c, EligibleForClaim__c FROM ClaimMembers__c];
        System.assertEquals(1, claimMembers.size(), 'Expected 1 claimmember');
        for (ClaimMembers__c cm : claimMembers){
            System.assertEquals(true, cm.EligibleForClaim__c, 'Eligble for Claim should be true');
        }
        delete otms;
        
        claimMembers = [SELECT Claim__c, EligibleForClaim__c FROM ClaimMembers__c];
        System.assertEquals(1, claimMembers.size(), 'Expected 1 claimmember');
        for (ClaimMembers__c cm : claimMembers){
            System.assertEquals(false, cm.EligibleForClaim__c, 'Eligble for Claim should be false');
        }
        
        //Insert the same TeamMember again, check if it updates the EligibleForClaim To true
        otms.Id = null;
        insert otms;
        
        claimMembers = [SELECT Claim__c, EligibleForClaim__c FROM ClaimMembers__c];
        System.assertEquals(1, claimMembers.size(), 'Expected 1 claimmember');
        for (ClaimMembers__c cm : claimMembers){
            System.assertEquals(true, cm.EligibleForClaim__c, 'Eligble for Claim should be true');
        }
    }

}