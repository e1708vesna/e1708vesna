/**
 * @description This is the main Account handler. Its purpose is to filter the accounts and redirect them to a helper class.
 * @author BRITE
 */
trigger AccountTrg on Account (before insert, before update, after insert, after update, before delete, after delete, after undelete) {

//    system.debug('*** Account Trigger: before=' + Trigger.isBefore + '; insert=' + Trigger.isInsert + '; update=' + Trigger.isUpdate);

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            AccountPartnerTierHelper.updatePartnerTierBeforeInsertUpdate(Trigger.new, null);
            //AccountHelper.updateAccountType(Trigger.new); Not needed anymore since the IsPartner checkbox is being removed
            AccountHelper.updateCurrencyIsoCode(Trigger.new);
        }
        if (Trigger.isUpdate) {
            AccountPartnerTierHelper.updatePartnerTierBeforeInsertUpdate(Trigger.new, Trigger.oldMap);
            accountHelper.collectOldAccountStatus(Trigger.old);
            AccountHelper.updateCurrencyIsoCode(Trigger.new);
            AccountHelper.collectAccountTeamMembers(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete){
            AccountHelper.handleBeforeDeleteTrigger(Trigger.old);
        }
    }
    
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            AccountTeamMemberHelper.updateAccountTeamMember(Trigger.new, null);
        }
        if (Trigger.isUpdate) {
            AccountPartnerTierHelper.updatePartnerTierChildsAfterUpdate(Trigger.new, Trigger.oldMap);
            AccountTeamMemberHelper.updateAccountTeamMember(Trigger.new, Trigger.oldMap);
            AccountHelper.updateOwnerRelatedObjects(Trigger.new, Trigger.oldMap);
            AccountHelper.reinsertAccountTeamMembers(Trigger.new, Trigger.oldMap);
            //OpportunityHelper.updateOpportunityName(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete){
            AccountHelper.handleAfterDeleteTrigger(Trigger.old);
            PartnerTypeMergeUtility.afterDeleteMerge(Trigger.old);
            RelationshipMergeUtility.afterDeleteMerge(Trigger.old);
        }
        if (Trigger.isUndelete){
            AccountHelper.afterUndeleteHandler(Trigger.new);
        }
    }
    
    
}