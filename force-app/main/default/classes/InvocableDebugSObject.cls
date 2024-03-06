public class InvocableDebugSObject {
	@InvocableMethod(label='Debug log: sObject' description='Creates a debug message in the debug log' category='debug')
  	public static void getAccountNames(List<sObject> message) {
        for (sObject m : message){
            System.debug(JSON.serializePretty(m));
        }
    }
    
}