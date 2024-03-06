/**
 * @description   : Contentversion DAO class for retrieving Contentversion data from the database.
 * @author (s)    : BRITE
 */
public class ContentVersionDao {
	/**
	 *	Get Contentversion to retrieve the ContentDocumentId
	 **/
	public static List<ContentVersion> getById (Id contentVersionId) {
		return [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId];
	}
	
	/**
	 *	Get Contentversion by Title to retrieve the ContentVersionId
	 **/
	public static List<ContentVersion> getByTitle (String title) {
		return [Select c.Title, c.Id, c.FileType, c.ContentDocumentId From ContentVersion c where Title =: title];
	}
}