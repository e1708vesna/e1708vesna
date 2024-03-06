/**
 * @author (s)    : Brite
 * @description   : OpportunitySplit Helper class
 */

trigger OpportunityTeamMember on OpportunityTeamMember (after insert, after update, before delete, after delete)
{


    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            ClaimMemberHelper.copyTeamMembersToClaimMembers(Trigger.new);
            CustomHistoryUtility.logHistoryAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {            
            CustomHistoryUtility.logHistoryAfterUpdate(Trigger.new, Trigger.oldMap);
        }
		if (Trigger.isDelete) {
            CustomHistoryUtility.logHistoryAfterDelete(Trigger.old);
            ClaimMemberHelper.updateClaimMemberOpportunity(Trigger.old);
        }

    }
    //if (Trigger.isBefore) {
    //    if (Trigger.isDelete){
    //        ClaimMemberHelper.updateClaimMemberOpportunity(Trigger.oldMap.keySet());
    //    }
    //}
}