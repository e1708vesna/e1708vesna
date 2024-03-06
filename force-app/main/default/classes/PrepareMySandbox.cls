global class PrepareMySandbox implements SandboxPostCopy {
    
    global void runApexClass(SandboxContext context) {
         
        List<PermissionSet> permissions = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Commercial_ExemptMFA']; 
        //if(permissions.size() )
        List<User> userList = [SELECT Id FROM User WHERE Profile.Name = 'Adyen Salesforce Administrator' and isActive = true];
        
        List<PermissionSetAssignment>  psaList = new List<PermissionSetAssignment>();
        
        for(User u : userList){
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = u.Id;
            psa.PermissionSetId = permissions[0].Id;
            psaList.add(psa);
        }    

        insert psaList;
        
    }
}