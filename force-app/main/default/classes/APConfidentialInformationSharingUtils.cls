public class APConfidentialInformationSharingUtils {

    
    
    /*Anon apex:
        Set<Id> idSet = new Set<Id>{'a101w00000FmvZ0AAJ'};
        ShareOfWalletSharingUtils.insertUpdateDeleteciShare(idSet);
    */
    @TestVisible private static final String APEXSHARINGREASON = 'AccountTeam__c';
    
    public static void insertUpdateDeleteCiShare(Set<Id> recordIds){
        if (recordIds == null || recordIds.isEmpty()) {
            return;
        }
        Map<Id, Map<Id, APConfidentialInformation__Share>> ciToOldShareMap;
        Map<Id, Map<Id, APConfidentialInformation__Share>> ciToNewShareMap;
        
        ciToOldShareMap = getCurrentShares(recordIds);
        ciToNewShareMap = getNewShares(recordIds);
        
        List<APConfidentialInformation__Share> upsertList = new List<APConfidentialInformation__Share>(); //Will be populated by cleanseShares method
        List<APConfidentialInformation__Share> deleteList = new List<APConfidentialInformation__Share>(); //Will be populated by cleanseShares method
        
        //find difference between the shares and update sharing
        
        ApexSharingUtils.cleanseShares(ciToOldShareMap, ciToNewShareMap, upsertList, deleteList);     
        
        
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
                        'An error occured during sharing calculation of the AP Confidential Information record with Id: ' + upsertList[i].ParentId + '. Unable to grant sharing access due to following exception: ' + err.getMessage());
                }
            }
            i++;
        }   
        
    }
    /*
     * get the preferred share records of a ci records
     * @param Set<Id> recordIds Ids of ci records to process
     * @return Map<Id, Map<Id, APConfidentialInformation__Share>> Map of ci to Sharing records
     */
    @TestVisible private static Map<Id, Map<Id, APConfidentialInformation__Share>> getNewShares(Set<Id> recordIds){
        //Query APConfidentialInformation__c information;
        Map<Id, APConfidentialInformation__c> ciMap= new Map<Id, APConfidentialInformation__c>([Select Id, (SELECT ID, Account__c FROM Account_Plans__r) FROM APConfidentialInformation__c WHERE Id in: recordIds]);
        Map<Id, List<AccountTeamMember>> accToAccountTeamMembersMap = new Map<Id, List<AccountTeamMember>>();
        Set<Id> accIdSet = new Set<Id>();
        Map<Id, Map<Id, AccountTeamMember>> ciToUserMap = new Map<Id, Map<Id, AccountTeamMember>>();
        Map<Id, Map<Id, APConfidentialInformation__Share>> ciToNewShareMap = new Map<Id, Map<Id, APConfidentialInformation__Share>>();
        
        
        //populate the accIdSet
        for (APConfidentialInformation__c ci : ciMap.values()){
            if (ci.Account_Plans__r != null && ci.Account_Plans__r.size()>0){
                for (AccountPlan__c ap : ci.Account_Plans__r){
                    accIdSet.add(ap.Account__c);
                }
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
        
        //Loop through all ShareOfWallets and populate the ciToNewShareMap;
        for (APConfidentialInformation__c ci : ciMap.values()){
            Set<Id> accIdsForCi = new Set<Id>();
            if (ci.Account_Plans__r != null && ci.Account_Plans__r.size()>0){
                for (AccountPlan__c ap : ci.Account_Plans__r){
                    accIdsForCi.add(ap.Account__c);
                }
            }
            for (Id accId : accIdsForCi) {
                if (accToAccountTeamMembersMap.containsKey(accId)){
                    List<AccountTeamMember> teamMemberList = accToAccountTeamMembersMap.get(accId);
                    for (AccountTeamMember atm : teamMemberList){
                        APConfidentialInformation__Share atmShare = new APConfidentialInformation__Share();
                        atmShare.UserOrGroupId = atm.UserId;
                        atmShare.ParentId = ci.Id;
                        atmShare.AccessLevel = 'Edit';//atm.AccountAccessLevel;//Read/Edit
                        atmShare.RowCause = APEXSHARINGREASON;
                        if (ciToNewShareMap.containsKey(atmShare.ParentId)){
                            ciToNewShareMap.get(atmShare.ParentId).put(atmShare.UserOrGroupId, atmShare);
                        }
                        else {
                            Map<Id, APConfidentialInformation__Share> userToShareMap = new Map<Id, APConfidentialInformation__Share>();
                            userToShareMap.put(atmShare.UserOrGroupId, atmShare);
                            ciToNewShareMap.put(atmShare.ParentId, userToShareMap);
                        }
                    }
                }
            }
        }
        return ciToNewShareMap;
    }
    
    /*
     * get the current share records of ci records
     * @param Set<Id> recordIds Ids of ci records to process
     * @return Map<Id, Map<Id, APConfidentialInformation__Share>> Map of ci to Sharing records
     */
    @TestVisible private static Map<Id, Map<Id, APConfidentialInformation__Share>> getCurrentShares(Set<Id> recordIds) {
        Map<Id, Map<Id, APConfidentialInformation__Share>> ciToOldShareMap= new Map<Id, Map<Id, APConfidentialInformation__Share>>();
        //Query ShareOfWallet__share information and populate ciToOldShareMap
        for (APConfidentialInformation__Share ciShare : [SELECT UserOrGroupId, RowCause, ParentId, Id, AccessLevel FROM APConfidentialInformation__Share c WHERE ParentId in: recordIds AND RowCause =: APEXSHARINGREASON]){
            if (ciToOldShareMap.containsKey(ciShare.ParentId)){
                ciToOldShareMap.get(ciShare.ParentId).put(ciShare.UserOrGroupId, ciShare);
            }
            else {
                Map<Id, APConfidentialInformation__Share> userToShareMap = new Map<Id, APConfidentialInformation__Share>();
                userToShareMap.put(ciShare.UserOrGroupId, ciShare);
                ciToOldShareMap.put(ciShare.ParentId, userToShareMap);
            }
            
        }
        return ciToOldShareMap;
    }
}