public class InvocableDebugSObjecList {
	@InvocableMethod(label='Debug log: sObject List' description='Creates a debug message in the debug log' category='debug')
  	public static void getAccountNames(List<List<sObject>> message) {
        for (List<sObject> m : message){
            System.debug(JSON.serializePretty(m));
        }
    }
    
}