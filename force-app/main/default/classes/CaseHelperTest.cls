@IsTest
public class CaseHelperTest {

    
    @IsTest public static void setUserOnCase(){
       //create a User 
       
        User salesUser   = TestUtil.createUser3Profile('Adyen v2 Salessupport', true);
            
        //create a Case
        
        Case cs = new Case(
            Subject = 'I need help',
            Description = 'I would like some help please!',
        	SuppliedEmail = salesUser.Email);
           
            Test.startTest();
            insert cs;
            Test.stopTest();
            
            cs = [SELECT Id, User__c FROM Case WHERE Id = :cs.Id];
            system.assertEquals(salesUser.Id, cs.User__c);
     
    }
}