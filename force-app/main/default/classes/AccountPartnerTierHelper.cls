public class AccountPartnerTierHelper {
    
    public static boolean recalculatePartnerTier = true;
    public static final string VALIDATION_MESSAGE = 'You cannot change the Partner Tier on an account with a parent Account.';
    public static void updatePartnerTierBeforeInsertUpdate(List<Account> newlist, Map<Id, Account> oldMap){
        if (!recalculatePartnerTier){ //Do not recalculate tier
            return;
        }
        Map<Id, List<Account>> accountsByUltimateParentID = new Map<Id, List<Account>>();
        for (Account acc : newList){
            if (acc.ParentId != null && ( oldMap == null || oldMap.get(acc.Id).ParentId != acc.ParentId)){
                if (!accountsByUltimateParentID.containsKey(acc.UltimateParentID__c)) {
                    accountsByUltimateParentID.put(acc.UltimateParentID__c, new List<Account>());
                }
                accountsByUltimateParentID.get(acc.UltimateParentID__c).add(acc);
            }
        }
        if (!accountsByUltimateParentID.isEmpty()) {
            for (Account ultimateParentAcc : [SELECT Id, Tier__c, UltimateParentID__c FROM Account WHERE Id in: accountsByUltimateParentID.keySet()]){
                for (Account acc : accountsByUltimateParentID.get(ultimateParentAcc.Id)){
                    acc.Tier__c = ultimateParentAcc.Tier__c;
                }
            }
        }
    }
    
    public static void updatePartnerTierChildsAfterUpdate(List<Account> newList, Map<Id, Account> oldMap){
        Map<String, String> tierByParentAccountId = new Map<String, String>();
        List<Account> accToUpdate = new List<Account>();
        if (!recalculatePartnerTier){ //Do not recalculate tier for child accounts
            return;
        }
        for (Account acc : newList) {
            if (acc.Tier__c != oldMap.get(acc.id).Tier__c){
                if (acc.ParentId == oldMap.get(acc.id).ParentId && acc.ParentId != null ) {
                    acc.addError(VALIDATION_MESSAGE);
                }
                tierByParentAccountId.put(acc.UltimateParentID__c, acc.Tier__c);
            }
            if (acc.parentId != oldMap.get(acc.id).parentId){ //Tier is already set by the before trigger
                tierByParentAccountId.put(acc.UltimateParentID__c, acc.Tier__c); 
            }
        }
        if (!tierByParentAccountId.isEmpty()) {
            for (Account acc : [SELECT Id, Tier__c, UltimateParentID__c FROM Account WHERE UltimateParentID__c in: tierByParentAccountId.keySet()]){
                if (acc.Tier__c != tierByParentAccountId.get(acc.UltimateParentID__c)){
                    acc.Tier__c = tierByParentAccountId.get(acc.UltimateParentID__c);
                    accToUpdate.add(acc);
                }
            }
            AccountPartnerTierHelper.recalculatePartnerTier = false;
            update accToUpdate;
            AccountPartnerTierHelper.recalculatePartnerTier = true;
        }
    }
}