@isTest
private class HistoryRelatedListTypeSelectorTest {
	
    
    //Test class just for code coverage. As the return values are heavily dependant on one fields picklist values. If that field would be updated, so would the test class needed to be.
    @isTest
    private static void test(){
        HistoryRelatedListTypeSelector selector = new HistoryRelatedListTypeSelector();
        selector.getDefaultValue();
        selector.getValues();
    }
}