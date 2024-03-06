public class CaseHelper {

    public static void setUserOnCase (List<Case> newCases){
        
List<String> emails = new List<String>();     
Map<String, Id> userEmailToIDMap  = new Map<String, Id>();

for(Case c : newCases){
     emails.add(c.SuppliedEmail);
     }
        
List<User> users = [SELECT Id, Email from user where Email IN :emails];
for(User u : users){
       userEmailToIDMap.put(u.Email, u.Id);
}

for(Case c : newCases){
if(userEmailToIDMap.get(c.SuppliedEmail) != null){
    c.User__c = userEmailToIDMap.get(c.SuppliedEmail);
}
}
                            }
                            }