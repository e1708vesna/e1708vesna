/**
 * @description This is the main Opportunity handler. Its purpose is to filter the opportunities and redirect them to a helper class.
 * @author BRITE
 */
trigger OpportunityTrg on Opportunity (before insert, before update, before delete, after delete, after undelete, after insert, after update) {
	
    //System.debug('*** Opportunity Trigger: before=' + Trigger.isBefore + '; insert=' + Trigger.isInsert + '; update=' + Trigger.isUpdate);

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            OpportunityHelper.updateFieldsOnInsert(Trigger.new);
            
        }
        if (Trigger.isUpdate) {
            OpportunityHelper.storeTeamMembers(Trigger.new);
            OpportunityHelper.updateFieldsOnUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            OpportunityHelper.beforeDelete(Trigger.oldMap);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            //if (partnerUtility.updateReferral) {
            //    OpportunityHelper.updateReferral(Trigger.new, null);
            //}
            //CampaignInfluenceHelper.insertRelatedCampaigns(Trigger.new);
            CustomHistoryUtility.logHistoryAfterInsert(Trigger.new);
        }
        
        if (Trigger.isUpdate) {
            OpportunityHelper.validateTeamMembers(Trigger.new);
            OpportunityHelper.afterUpdate(Trigger.new, Trigger.oldMap);
            //if (partnerUtility.updateReferral) {
            //	OpportunityHelper.updateReferral(Trigger.new, Trigger.oldMap);
            //}
            CustomHistoryUtility.logHistoryAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        
        if (Trigger.isDelete) {
            Set<Id> idSet = new Set<Id>();
            for (OpportunityLineItem oli : [SELECT Id FROM OpportunityLineItem WHERE OpportunityId in: Trigger.oldMap.keySet() ALL ROWS]){
                idSet.add(oli.Id);
            }
            idSet.addAll(Trigger.oldMap.keySet());
            CustomHistoryHelper.deleteRelatedCustomHistory(idSet);
            CustomHistoryUtility.logHistoryAfterDelete(Trigger.old);
        }
        if (Trigger.isUndelete) {
            Set<Id> idSet = new Set<Id>();
            for (OpportunityLineItem oli : [SELECT Id FROM OpportunityLineItem WHERE OpportunityId in: Trigger.newMap.keySet()]){
                idSet.add(oli.Id);
            }
            idSet.addAll(Trigger.newMap.keySet());
            CustomHistoryHelper.undeleteRelatedCustomHistory(idSet);
        }
    }
    
}