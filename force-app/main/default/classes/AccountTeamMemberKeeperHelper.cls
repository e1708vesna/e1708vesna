public class AccountTeamMemberKeeperHelper {
    private static AccountTeamMemberKeeperHelper instance = null;
    public Map<Id,List<AccountTeamMember>> accountTeamMembersByAccountId {get;private set;}
    
    
    private AccountTeamMemberKeeperHelper(){
        accountTeamMembersByAccountId = new Map<Id,List<AccountTeamMember>>();
    }
    
    /**
* Static method to retreive the instance of the class, this ensures there is always only one instance per transaction.
* @return instance of AccountTeamMemberKeeperHelper.
* */
    public static AccountTeamMemberKeeperHelper getInstance(){
        if(instance == null) instance = new AccountTeamMemberKeeperHelper();
        return instance;
    }
    
    /**
* This method stores the current AccountTeamMembers in memory, so they can be inserted later.
* This method should be called in the before update trigger for each account of which the owner changed.
* @param accountIds Set of accountIds of which the AccountTeamMembers should be stored.
* */
    public void storeAccountTeamMembers(Set<Id> accountIds){
        Set<Id> processedAccountIds = accountTeamMembersByAccountId.keySet();
        for (AccountTeamMember act : AccountTeamMemberDao.getActiveMembersByAccountId(accountIds, processedAccountIds)){
            if (!accountTeamMembersByAccountId.containsKey(act.AccountId)){
                accountTeamMembersByAccountId.put(act.AccountId, new List<AccountTeamMember>());
            }
            accountTeamMembersByAccountId.get(act.AccountId).add(act.clone(false, false, false, false));
        }
    }
    
    /**
* This method commits (reinserts) the stored AccountTeamMembers.
* This method should be called in the after update trigger for each account of which the owner changed.
* @param accountIds Set of accountIds of which the AccountTeamMembers should be reinserted.
* */
    public void commitAccountTeamMembers(Set<Id> accountIds){
        if (accountIds == null || accountIds.isEmpty()){
            return;
        }
        System.debug('Committing Account TeamMembers');
        List<AccountTeamMember> actList = new List<AccountTeamMember>();
        List<AccountTeamMember> currentActList = AccountTeamMemberDao.getActiveMembersByAccountId(accountIds, accountIds); //Why is this there, this won't return any AccountTeamMembers
        
        System.debug('current:');
        System.debug(Json.serializePretty(currentActList));
        Map<Id, Set<Id>> userIdsByAccountIds = new Map<Id, Set<Id>>();
        for (AccountTeamMember act : currentActList){
            if (!userIdsByAccountIds.containsKey(act.AccountId)){
                userIdsByAccountIds.put(act.AccountId, new Set<Id>());
            }
            userIdsByAccountIds.get(act.AccountId).add(act.UserId);
            
        }
        for (Id accountId : accountIds){
            if (accountTeamMembersByAccountId.containsKey(accountId)) {
                for (AccountTeamMember act : accountTeamMembersByAccountId.get(accountId)){
                    if (!userIdsByAccountIds.containsKey(accountId) || !userIdsByAccountIds.get(accountId).contains(act.UserId)){
                        actList.add(act.clone());
                    }
                }
            }
        }
        System.debug('To be inserted:');
        System.debug(Json.serializePretty(actList));
        // Insert sharing records and capture save result 
        // The false parameter allows for partial processing if multiple records are passed 
        // into the operation 
        Database.SaveResult[] lsr = Database.insert(actList, false);
        
        // Create counter
        Integer i=0;
        
        // Process the save results
        for(Database.SaveResult sr : lsr){
            if(!sr.isSuccess()){
                // Get the first save result error
                Database.Error err = sr.getErrors()[0];
                System.debug('Error occured');
                if(!(err.getStatusCode() == StatusCode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY)){
                         // Throw an error when the error is not related to trivial access level.
                         throw new IllegalArgumentException( //any excpetion will do
                             'An error occured inserting AccountTeamMember: ' + actList[i].Id + '. Unable to insert AccountTeamMember due to following exception: ' + err.getMessage() + ' | ' + err.getFields());
                     }
            }
            i++;
        }      
    }
}