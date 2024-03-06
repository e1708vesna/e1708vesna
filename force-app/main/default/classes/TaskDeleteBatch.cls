/**
 * @description   : Batch Class to delete all Tasks created by Marketo user.
 * @author (s)    : Brite
 **/

global class TaskDeleteBatch implements Database.Batchable<sObject>{

    
    global Database.QueryLocator start(Database.BatchableContext BC){
        DateTime fiveMinutesAgo = DateTime.now().addMinutes(-5);
        String query = 'SELECT ID FROM TASK WHERE CreatedBy.profile.name LIKE \'%marketo%\' AND WhoId != null AND CreatedDate <= :fiveMinutesAgo ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC){
    }
}