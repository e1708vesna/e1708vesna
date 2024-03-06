/**
 * @description   : MSRP DAO class for retrieving MSRP data from the database.
 * @author (s)    : BRITE
 */
public class MsrpDao {
    /**
     * Get all Msrp by article number set 
     */
	public static List<MSRP__c> getByArticleNumber(Set<String> artNumSet) {
		return [SELECT m.UnitPrice__c, m.StartDate__c, m.SQLTimeStamp__c, m.NavisionMsrpNumber__c,
					m.Name, m.MinimumQuantity__c, m.Id, m.EndDate__c, m.Description__c, m.Description2__c, 
					m.Currency__c, m.ArticleNumber__c, m.Active__c 
				FROM MSRP__c m 
				WHERE ArticleNumber__c in :artNumSet
                ORDER BY ArticleNumber__c, m.Currency__c, MinimumQuantity__c DESC, StartDate__c];
	}
	
    /**
     * Get all Msrp by article number set for the date today 
     */
	public static List<MSRP__c> getByArticleNumberToday(Set<String> artNumSet) {
		Date now = Date.today();
		return [SELECT m.UnitPrice__c, m.StartDate__c, m.SQLTimeStamp__c, m.NavisionMsrpNumber__c,
					m.Name,	m.MinimumQuantity__c, m.Id, m.EndDate__c, m.Description__c, m.Description2__c, 
					m.Currency__c, m.ArticleNumber__c, m.Active__c 
				FROM MSRP__c m 
				WHERE ArticleNumber__c in :artNumSet 
					AND (m.EndDate__c = null OR m.EndDate__c >= :now) 
					AND StartDate__c != null AND StartDate__c <= :now 
				ORDER BY ArticleNumber__c, m.Currency__c, m.MinimumQuantity__c DESC];
	}
	
	/**
     * Get all Msrp by active article number set for the date minDate or later 
     */
	public static List<MSRP__c> getByArticleNumberAndMinStartDate(Set<String> artNumSet, Date minDate) {
        return [SELECT m.UnitPrice__c, m.StartDate__c, m.SQLTimeStamp__c, 
                    m.Name, m.MinimumQuantity__c, m.Id, m.EndDate__c, m.Currency__c, m.ArticleNumber__c
                FROM MSRP__c m 
                WHERE ArticleNumber__c in :artNumSet 
                    AND StartDate__c != null AND StartDate__c <= :minDate
                    AND (EndDate__c = null OR EndDate__c >= :minDate)
                ORDER BY ArticleNumber__c, m.Currency__c, MinimumQuantity__c DESC, StartDate__c];
    }

    /**
     * Get Msrp Article Numbers by Id Set 
     */
	public static List<MSRP__c> getByIdSet(Set<Id> idSet) {
		return [SELECT m.Id, m.ArticleNumber__c, m.Active__c 
				FROM MSRP__c m 
				WHERE Id in :idSet];
	}
    
}