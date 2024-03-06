public class ShareOfWalletSharingUtils {

    
    
    /*Anon apex:
    	Set<Id> idSet = new Set<Id>{'a101w00000FmvZ0AAJ'};
		ShareOfWalletSharingUtils.insertUpdateDeleteSOWShare(idSet);
    */
    @TestVisible private static final String APEXSHARINGREASON = 'AccountTeam__c';
    
    public static void insertUpdateDeleteSOWShare(Set<Id> sowIds){
        if (sowIds == null || sowIds.isEmpty()) {
        	return;
        }
        Map<Id, Map<Id, ShareOfWallet__Share>> sowToOldShareMap;
        Map<Id, Map<Id, ShareOfWallet__Share>> sowToNewShareMap;
        
        
        sowToOldShareMap = getCurrentShares(sowIds);
        sowToNewShareMap = getNewShares(sowIds);
        
        
        List<ShareOfWallet__Share> upsertList = new List<ShareOfWallet__Share>(); //Will be populated by cleanseShares method
        List<ShareOfWallet__Share> deleteList = new List<ShareOfWallet__Share>(); //Will be populated by cleanseShares method
        
        //find difference between the shares and update sharing
        cleanseShares(sowToOldShareMap, sowToNewShareMap, upsertList, deleteList);
        
        
        
        delete deleteList;
        // Insert sharing records and capture save result 
        // The false parameter allows for partial processing if multiple records are passed 
        // into the operation 
        Database.UpsertResult[] lsr = Database.upsert(upsertList, false);
        
        // Create counter
        Integer i=0;
        
        // Process the save results
        for(Database.UpsertResult sr : lsr){
            if(!sr.isSuccess()){
                // Get the first save result error
                Database.Error err = sr.getErrors()[0];
                
                // Check if the error is related to a trivial access level
                // Access levels equal or more permissive than the object's default 
                // access level are not allowed. 
                // These sharing records are not required and thus an insert exception is 
                // acceptable. 
                System.debug('Error occured');
                if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION &&  err.getMessage().contains('AccessLevel')){
                    //User already has access to this record.
                }
                else if (err.getStatusCode() == StatusCode.INACTIVE_OWNER_OR_USER && err.getMessage().contains('inactive user')){
                    //OPeration performed with inactive user, do nothing.
                }
                else {
                    // Throw an error when the error is not related to trivial access level.
                    throw new IllegalArgumentException( //any excpetion will do
                        'An error occured during sharing calculation of the Share of Wallet with Id: ' + upsertList[i].ParentId + '. Unable to grant sharing access due to following exception: ' + err.getMessage());
                }
            }
            i++;
        }   
        
    }
    /*
     * get the preferred share records of a SoW records
     * @param Set<Id> sowIds Ids of SoW records to process
     * @return Map<Id, Map<Id, ShareOfWallet__Share>> Map of Sow to Sharing records
     */
    @TestVisible private static Map<Id, Map<Id, ShareOfWallet__Share>> getNewShares(Set<Id> sowIds){
        //Query ShareOfWallet__c information;
        Map<Id, ShareOfWallet__c> sowMap= new Map<Id, ShareOfWallet__c>([Select Id, AccountPlan__c, AccountPlan__r.Account__c FROM ShareOfWallet__c WHERE Id in: sowIds]);
        Map<Id, List<AccountTeamMember>> accToAccountTeamMembersMap = new Map<Id, List<AccountTeamMember>>();
        Set<Id> accIdSet = new Set<Id>();
        Map<Id, Map<Id, AccountTeamMember>> sowToUserMap = new Map<Id, Map<Id, AccountTeamMember>>();
        Map<Id, Map<Id, ShareOfWallet__Share>> sowToNewShareMap = new Map<Id, Map<Id, ShareOfWallet__Share>>();
        
        
        //populate the accIdSet
        for (ShareOfWallet__c sow : sowMap.values()){
            if (sow.AccountPlan__r != null && sow.AccountPlan__r.Account__c != null) {
            	accIdSet.add(sow.AccountPlan__r.Account__c);
            }
        }
        //Query ShareOfWallet__share information and populate accToAccountTeamMembersMap
        for (AccountTeamMember atm : [SELECT Id, AccountId, UserId, AccountAccessLevel From AccountTeamMember WHERE AccountId in : accIdSet]){
            if (accToAccountTeamMembersMap.containsKey(atm.AccountId)){
                accToAccountTeamMembersMap.get(atm.AccountId).add(atm);
            }
            else {
                List<AccountTeamMember> teamMemberList = new List<AccountTeamMember>();
                teamMemberList.add(atm);
                accToAccountTeamMembersMap.put(atm.AccountId, teamMemberList);
            }
        }
        
        //Loop through all ShareOfWallets and populate the sowToNewShareMap;
        for (ShareOfWallet__c sow : sowMap.values()){
            //Check if there are accountTeamMembers
            Id sowAccountId;
            if (sow.AccountPlan__r != null && sow.AccountPlan__r.Account__c != null) {
                sowAccountId = sow.AccountPlan__r.Account__c;
            }
            if (sowAccountId != null && accToAccountTeamMembersMap.containsKey(sowAccountId)){
                List<AccountTeamMember> teamMemberList = accToAccountTeamMembersMap.get(sowAccountId);
                for (AccountTeamMember atm : teamMemberList){
                    ShareOfWallet__share atmShare = new ShareOfWallet__share();
                    atmShare.UserOrGroupId = atm.UserId;
                    atmShare.ParentId = sow.Id;
                    atmShare.AccessLevel = atm.AccountAccessLevel;//Read/Edit
                    atmShare.RowCause = APEXSHARINGREASON;
                    if (sowToNewShareMap.containsKey(atmShare.ParentId)){
                        sowToNewShareMap.get(atmShare.ParentId).put(atmShare.UserOrGroupId, atmShare);
                    }
                    else {
                        Map<Id, ShareOfWallet__Share> userToShareMap = new Map<Id, ShareOfWallet__Share>();
                        userToShareMap.put(atmShare.UserOrGroupId, atmShare);
                        sowToNewShareMap.put(atmShare.ParentId, userToShareMap);
                    }
                }
            }
        }
        return sowToNewShareMap;
    }
    
    /*
     * get the current share records of SoW records
     * @param Set<Id> sowIds Ids of SoW records to process
     * @return Map<Id, Map<Id, ShareOfWallet__Share>> Map of Sow to Sharing records
     */
    @TestVisible private static Map<Id, Map<Id, ShareOfWallet__Share>> getCurrentShares(Set<Id> sowIds) {
        Map<Id, Map<Id, ShareOfWallet__Share>> sowToOldShareMap= new Map<Id, Map<Id, ShareOfWallet__Share>>();
        //Query ShareOfWallet__share information and populate sowToOldShareMap
        for (ShareOfWallet__Share sowShare : [SELECT UserOrGroupId, RowCause, ParentId, Id, AccessLevel FROM ShareOfWallet__Share c WHERE ParentId in: sowIds AND RowCause =: APEXSHARINGREASON]){
            if (sowToOldShareMap.containsKey(sowShare.ParentId)){
                sowToOldShareMap.get(sowShare.ParentId).put(sowShare.UserOrGroupId, sowShare);
            }
            else {
                Map<Id, ShareOfWallet__Share> userToShareMap = new Map<Id, ShareOfWallet__Share>();
                userToShareMap.put(sowShare.UserOrGroupId, sowShare);
                sowToOldShareMap.put(sowShare.ParentId, userToShareMap);
            }
            
        }
        return sowToOldShareMap;
    }
    
    //parameters should not be null
    @TestVisible private static void cleanseShares(Map<Id, Map<Id, ShareOfWallet__Share>> existingShares, Map<Id, Map<Id,ShareOfWallet__Share>> newShares, List<ShareOfWallet__Share> upsertList, List<ShareOfWallet__Share> deleteList){
        
        //Check existing shares if they are still in the new situation, if not delete them.
        for (Id existingSowId : existingShares.keySet()){
            Map<Id, ShareOfWallet__Share> existingSharesMap = existingShares.get(existingSowId);
            Map<Id, ShareOfWallet__Share> newSharesMap = newShares.get(existingSowId);
            for (Id userId : existingSharesMap.keySet()){
                if (newSharesMap == null || !newSharesMap.containsKey(userId)){
                    deleteList.add(existingSharesMap.get(userId));
                }
            }
            
        }
        
        //Check new shares if they are already in the existing situation, if so update, if not insert them.
        for (Id newSowId : newShares.keySet()){
            Map<Id, ShareOfWallet__Share> existingSharesMap = existingShares.get(newSowId);
            Map<Id, ShareOfWallet__Share> newSharesMap = newShares.get(newSowId);
            for (Id userId : newSharesMap.keySet()){
                //if it is not already there, insert
                if (existingSharesMap == null || !existingSharesMap.containsKey(userId)){
                    upsertList.add(newSharesMap.get(userId));
                }
                //else if access is different: update
                else {
                    ShareOfWallet__Share newShare = newSharesMap.get(userId);
                    ShareOfWallet__Share existingShare = existingSharesMap.get(userId);
                    if (newShare.AccessLevel != existingShare.AccessLevel){
                        existingShare.AccessLevel = newShare.AccessLevel; //update the existing to preserve the id;
                        upsertList.add(existingShare);
                    }
                }
            }
            
        }
        
    }
}