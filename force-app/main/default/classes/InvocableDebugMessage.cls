public class InvocableDebugMessage {
	@InvocableMethod(label='Debug log' description='Creates a debug message in the debug log' category='debug')
  	public static void getAccountNames(List<String> message) {
        for (String m : message){
            System.debug(m);
        }
    }
    
}