/**
 * @description Task DAO class for retrieving task data from the database.
 * @author BRITE
 */
public class TaskDao {

    /**
     * @description Get details of the given tasks.
     *
     * @param taskIdSet Set of task ID's for which the details must be retrieved
     */
    public static List<Task> getDetails(Set<Id> taskIdSet) {
        return [SELECT Id, Subject, Description, WhoId, OwnerId, CreatedDate, CreatedById
                FROM Task
                WHERE Id IN :taskIdSet];
    }

}