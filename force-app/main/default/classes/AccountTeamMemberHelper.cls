/**
 * @description Account Team Member handler to add and remove Users from the team
 * @author Brite
 */
public without sharing class AccountTeamMemberHelper {
    /**
     * AfterInsert, AfterUpdate
     * Remove / Add team members depending on Account ownership
     **/
    public static void updateAccountTeamMember (List<Account> newAccountList, Map<Id,Account> oldAccountMap) {
        String roleName = 'Account Owner';
        String accountAccessLevelInit = 'Edit';
        String caseAccessLevelInit = 'Edit';
        String contactAccessLevelInit = 'Edit';
        String opportunityAccessLevelInit = 'Edit';

        //First get existing teammembers
        Set<Id> accIdSet = new Set<Id>();
        Account oldAcc;
        for (Account newAcc : newAccountList) {
            if (oldAccountMap!=null) {
                oldAcc = oldAccountMap.get (newAcc.Id);
                if (oldAcc.OwnerId != newAcc.OwnerId) {
                    accIdSet.add (newAcc.Id);
                }
            } else {
                accIdSet.add (newAcc.Id);
            }
        }
        Map<String, AccountTeamMember> accountUserAtmMap = new Map<String, AccountTeamMember>();
        //AccountOwnerId can only be a UserId so no checks for groups
        for (AccountTeamMember accTeamMember : [Select Id, AccountId, UserId, TeamMemberRole From AccountTeamMember where AccountId in : accIdSet and TeamMemberRole = :roleName]) {
            accountUserAtmMap.put ('' + accTeamMember.AccountId + accTeamMember.UserId, accTeamMember);
        }
        AccountTeamMember newAtm;
        AccountTeamMember oldAtm;
        List<AccountTeamMember> atmToInsertList = new List<AccountTeamMember>();
        List<AccountTeamMember> atmToDeleteList = new List<AccountTeamMember>();

        Set<Id> inactiveUserIdSet = UserDao.getInactiveUsers();

        if (oldAccountMap==null) {
            //Insert
            for (Account newAcc : newAccountList) {
                if (inactiveUserIdSet.contains(newAcc.OwnerId)) {
                   System.debug(Logginglevel.WARN, 'Inactive user ' + newAcc.OwnerId + ' ignored for AccountTeam to insert'); 
                } else {
                    newAtm = accountUserAtmMap.get ('' + newAcc.Id + newAcc.OwnerId);
                    if (newAtm == null) {
                        //Create new one if not exist yet
                        atmToInsertList.add (new AccountTeamMember (AccountId=newAcc.Id,
                                                UserId=newAcc.OwnerId,
                                                TeamMemberRole = roleName,
                                                AccountAccessLevel = accountAccessLevelInit,
                                                CaseAccessLevel = caseAccessLevelInit,
                                                ContactAccessLevel = contactAccessLevelInit,
                                                OpportunityAccessLevel = opportunityAccessLevelInit
                                                )); 
                    }
                }
            }
        } else {
            //Update
            for (Account newAcc : newAccountList) {
                oldAcc = oldAccountMap.get (newAcc.Id);
                    oldAtm = accountUserAtmMap.get ('' + oldAcc.Id + oldAcc.OwnerId);
                    if (oldAtm != null) {
                        if (oldAcc.OwnerId != newAcc.OwnerId) {
                            atmToDeleteList.add (oldAtm);
                        }
                    } 
                if (inactiveUserIdSet.contains(newAcc.OwnerId)) {
                    System.debug(Logginglevel.WARN, 'Inactive user ' + newAcc.OwnerId + ' ignored for AccountTeam to insert on update'); 
                } else {    
                    newAtm = accountUserAtmMap.get ('' + newAcc.Id + newAcc.OwnerId);
                    if (newAtm == null) {
                        //Create new one if old did not exist
                        atmToInsertList.add (new AccountTeamMember (AccountId=newAcc.Id,
                                                UserId=newAcc.OwnerId,
                                                TeamMemberRole = roleName,
                                                AccountAccessLevel = accountAccessLevelInit,
                                                CaseAccessLevel = caseAccessLevelInit,
                                                ContactAccessLevel = contactAccessLevelInit,
                                                OpportunityAccessLevel = opportunityAccessLevelInit
                                                )); 
                    }
                }
            }
            if (!atmToDeleteList.isEmpty ()) {
                delete atmToDeleteList;
            }        
        }
        if (!atmToInsertList.isEmpty ()) {
            insert atmToInsertList;
        }
    }
}