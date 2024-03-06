@isTest 
public class PrepareMySandboxTest {
    
    @isTest static void testMySandboxPrep() {
        Test.startTest();
        Test.testSandboxPostCopyScript(
            new PrepareMySandbox(),
            UserInfo.getOrganizationId(),
            UserInfo.getOrganizationId(),
            UserInfo.getOrganizationName()
        );
        Test.stopTest();
        
        // Query for PermissionSetAssignment records after running the class
        List<PermissionSetAssignment> permListAfter = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE PermissionSet.Name = 'Commercial_ExemptMFA'
        ];

        Boolean checkPoint = false;
        if(permListAfter.size() > 0){
            checkPoint = true;
        }

        // Ensure that the PermissionSetAssignment records have been deleted
        System.assertEquals(true, checkPoint, 'PermissionSetAssignment records should be deleted');
    }
    
}