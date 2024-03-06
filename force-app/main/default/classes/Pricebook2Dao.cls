/**
 * @description Pricebook2 DAO class for retrieving Pricebook2 data from the database.
 * @author BRITE
 */
public class Pricebook2Dao {
    
    /**
     * @description Returns a map of currency by pricebook. Currency code is retrieved from the pricebook name.
     *              Standard pricebook will be mapped to key 'Standard'.
     */
    public static Map<String, Pricebook2> getPricebook2Map() {
        List<Pricebook2> pricebooks = [SELECT Id, Name, CurrencyIsoCode 
                                       FROM Pricebook2
                                       ORDER BY Name];
                                       
        Pattern pat = Pattern.compile('Adyen ([a-zA-Z]{3}) Price Book');
        Matcher mat;
                                       
        // convert to a map
        Map<String, Pricebook2> pricebook2Map = new Map<String, Pricebook2> ();
        for (Pricebook2 pb : pricebooks) {
            mat = pat.matcher(pb.Name);
            if (mat.find()) {
                pricebook2Map.put(mat.group(1), pb);
            } else {
                pricebook2Map.put('Standard', pb);
            }
        }
        
        return pricebook2Map;
    } 
    
}