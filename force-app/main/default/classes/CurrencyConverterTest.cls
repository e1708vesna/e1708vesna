@isTest
public class CurrencyConverterTest {
	
    @isTest static void testObfuscate(){
        CurrencyConverter cv = new CurrencyConverter();
        System.assertEquals(0.88, cv.convert(1, 'USD', 'EUR'));
        System.assertEquals(1.13, cv.convert(1, 'EUR', 'USD'));
        System.assertEquals(1, cv.convert(1, 'EUR', 'EUR'));
    }
}