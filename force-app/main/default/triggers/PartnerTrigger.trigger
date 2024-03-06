trigger PartnerTrigger on Partner__c (before insert, before update, after insert, after update, after delete) {
/*
    if (Trigger.isbefore) {
        if (Trigger.isInsert) {
            PartnerUtility.setMatchKey(Trigger.new);
            
            if (PartnerUtility.updateReferral) {
                PartnerUtility.newReferralPartner(Trigger.new, null);
            }
        }
        if (Trigger.isUpdate) {
            PartnerUtility.setMatchKey(Trigger.new);
            if (PartnerUtility.updateReferral) {
                PartnerUtility.newReferralPartner(Trigger.new, Trigger.oldMap);
            }
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
        }
        if (Trigger.isUpdate) {
            if (PartnerUtility.updateReferral) {
                PartnerUtility.removeReferralPartner(Trigger.new, Trigger.oldMap);
            }
        }
        if (Trigger.isDelete){
            if (PartnerUtility.updateReferral) {
                PartnerUtility.afterDeletePartners(Trigger.Old);
            }
        }
    }*/
}