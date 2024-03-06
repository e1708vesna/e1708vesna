/**
 * @description   : Class to test the process custom logging 
 * @author (s)    : BRITE
 */
@isTest
private class CustomLogTest {

    static testMethod void myLogTest() {
    	Test.startTest();
    	Integer count;
    	//test exception without custom settings
		//long text test
		String longTxt;
		for (Integer i=0; i<1000; i++) {
			longTxt += 'aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffgggggggggghhhhhhhhhhiiiiiiiiiijjjjjjjjjj1111111111222222222233333333334444444444';
		}
       	CustomLog.log(CustomLog.DEBUG, longTxt, longTxt, longTxt);
		count = database.countQuery('select count() from CustomLog__c');
		System.assertEquals(1, count, 'One log should be created');
		List<CustomLog__c> csList = [select Type__c, Message__c, Description__c, StackTrace__c from CustomLog__c];
		System.assertEquals(255, csList[0].Message__c.length(), 'Message should be truncated!');
		System.assertEquals(32767, csList[0].Description__c.length(), 'Description should be truncated!');
		System.assertEquals(32767, csList[0].StackTrace__c.length(), 'Stacktrace should be truncated!');
    	
    	//Not needed, replaced to the code itself
    	//CustomLogSettings__c cs = new CustomLogSettings__c(Name='ALL', LogActive__c=true, MaxRecords__c=5);
    	//insert cs;
        Test.stopTest();
   		CustomLogSettings__c cs = CustomLogSettings__c.getValues('ALL');
   		cs.MaxRecords__c=6;
   		update cs;
    	
		for (Integer t=0; t<4; t++) {
        	CustomLog.log(CustomLog.DEBUG, 'Textclass message '+t, 'Long description of the message', null);
		}
		count = database.countQuery('select count() from CustomLog__c');
		System.assertEquals(5, count, '5 logs should be created');
       	CustomLog.log(CustomLog.DEBUG, 'Testclass message 5', 'Long description of the message', null);
		count = database.countQuery('select count() from CustomLog__c');
		System.assertEquals(1, count, 'one log should be created and otherlog should be removed.');
		
    }
    
    static testMethod void myLogTestBulk1() {
    	Test.startTest();
    	Integer count;
    	//test exception without custom settings
		//long text test
		String longTxt;
		for (Integer i=0; i<1000; i++) {
			longTxt += 'aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffgggggggggghhhhhhhhhhiiiiiiiiiijjjjjjjjjj1111111111222222222233333333334444444444';
		}
       	CustomLog.create(CustomLog.DEBUG, longTxt, longTxt, longTxt);
		CustomLog.commitLog();
		count = database.countQuery('select count() from CustomLog__c');
		System.assertEquals(1, count, '1 logs should be created.');
    }
    
    static testMethod void myLogTestBulk2() {
    	Test.startTest();
		CustomLogSettings__c cs = new CustomLogSettings__c(Name='ALL', LogActive__c=true, LogLevel__c='DEBUG', MaxRecords__c=6);
    	insert cs;
    	Integer count;
		for (Integer t=0; t<5; t++) {
        	CustomLog.create(CustomLog.DEBUG, 'Textclass message '+t, 'Long description of the message', null);
		}
		count = database.countQuery('select count() from CustomLog__c');
		System.assertEquals(0, count, 'One log should be created');
		CustomLog.commitLog();
		count = database.countQuery('select count() from CustomLog__c');
		System.assertEquals(5, count, '5 log should be created.');
        Test.stopTest();
		

		for (Integer t=0; t<4; t++) {
        	CustomLog.create(CustomLog.DEBUG, 'Textclass message '+t, 'Long description of the message', null);
		}
		CustomLog.commitLog();
		count = database.countQuery('select count() from CustomLog__c');
		System.assertEquals(4, count, '4 logs should be created and otherlog should be removed.');
		
    }
    
}