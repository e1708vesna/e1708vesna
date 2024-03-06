@isTest
public class LeanDataCustomInterfaceTest {
    public static testMethod void runTest(){
        LeanDataCustomInterface myCI = new LeanDataCustomInterface();

        Opportunity newOpp = new Opportunity();
        newOpp.Name = 'Sample Opp';
        newOpp.StageName = 'SCOTSMAN';
        newOpp.CloseDate = date.newInstance(2099,1, 1);
        newopp.RegionCountry__c = 'NL';
        insert newOpp;

        OpportunityTeamMember OpportunityTeam1 = new OpportunityTeamMember();
        OpportunityTeam1.OpportunityId = newOpp.Id;
        OpportunityTeam1.UserId = UserInfo.getUserId();
        insert OpportunityTeam1;
        myCI.getCustomNotificationOptions();
        myCI.customNotificationRule((SObject)newOpp, new Map<String,SObject>{'L2O' => newOpp},'Opportunity Team', new Map<String,Object>());
        myCI.customNotificationRule( (SObject)newOpp, new Map<String,SObject>() , 'Invalid Name', new Map<String,Object>());
    }    
}