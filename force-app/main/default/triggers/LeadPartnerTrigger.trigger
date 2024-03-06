trigger LeadPartnerTrigger on LeadPartner__c (before insert, before update, after insert, after update, after delete) {
    /*if (Trigger.isbefore) {
        if (Trigger.isInsert) {
            LeadPartnerUtility.setMatchKey(Trigger.new);
            LeadPartnerUtility.newReferralPartner(Trigger.new, null);
        }
        if (Trigger.isUpdate) {
            LeadPartnerUtility.setMatchKey(Trigger.new);
            LeadPartnerUtility.newReferralPartner(Trigger.new, Trigger.oldMap);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
        }
        if (Trigger.isUpdate) {
            LeadPartnerUtility.removeReferralPartner(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete){
            if (LeadPartnerUtility.updateReferral) {
                LeadPartnerUtility.afterDeletePartners(Trigger.Old);
            }
        }
    }*/
}