/**
 * @description Test class to verify the correctness of the methods in the class Pricebook2Dao.
 * @author BRITE
 */
@isTest
private class Pricebook2DaoTest {
    
    @isTest(SeeAllData=true) 
    public static void testGetPricebook2Map() {
        Map<String, Pricebook2> resultMap = Pricebook2Dao.getPricebook2Map();
        
        system.assertNotEquals(null, resultMap, 'Result map is null');
        system.assertEquals(false, resultMap.isEmpty(), 'Result map is empty');
        system.assertEquals(true, resultMap.containsKey('EUR'), 'Result map does not contain key EUR... pricebook renamed?');
        system.assertEquals(true, resultMap.containsKey('GBP'), 'Result map does not contain key GBP... pricebook renamed?');
        system.assertEquals(true, resultMap.containsKey('USD'), 'Result map does not contain key USD... pricebook renamed?');
    }
    
}