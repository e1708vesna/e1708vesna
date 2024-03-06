/**
 * @description   : ContentDocumentLink DAO class for retrieving ContentDocumentLink data from the database.
 * @author (s)    : BRITE
 */
public class ContentDocumentLinkDao {
	/**
	 * Get file by linked object Id and Title
	 **/
    public static List<ContentDocumentLink> getContentDocumentLinkList(Id linkedEntityId, String title) {
		return [Select c.Visibility, c.SystemModstamp, c.ShareType, c.LinkedEntityId, c.IsDeleted, c.Id, 
				c.ContentDocumentId, ContentDocument.Title,	ContentDocument.ParentId, ContentDocument.OwnerId, 
				ContentDocument.LastModifiedById, ContentDocument.FileType, ContentDocument.FileExtension,  
				ContentDocument.Description, ContentDocument.CreatedDate, ContentDocument.CreatedById, 
				ContentDocument.ContentSize, ContentDocument.ContentModifiedDate, ContentDocument.LatestPublishedVersionId 
				From ContentDocumentLink c WHERE LinkedEntityId = :linkedEntityId AND ContentDocument.Title = :title];
    }

	/**
	 * Get file by linked object Id and Title
	 **/
    public static List<ContentDocumentLink> getCDLStartWithNameList(Id linkedEntityId, String title) {
		title = title + '%';
		return [Select c.Visibility, c.SystemModstamp, c.ShareType, c.LinkedEntityId, c.IsDeleted, c.Id, 
				c.ContentDocumentId, ContentDocument.Title,	ContentDocument.ParentId, ContentDocument.OwnerId, 
				ContentDocument.LastModifiedById, ContentDocument.FileType, ContentDocument.FileExtension,  
				ContentDocument.Description, ContentDocument.CreatedDate, ContentDocument.CreatedById, 
				ContentDocument.ContentSize, ContentDocument.ContentModifiedDate, ContentDocument.LatestPublishedVersionId 
				From ContentDocumentLink c WHERE LinkedEntityId = :linkedEntityId AND ContentDocument.Title Like :title];
    }

	/**
	 *	Get files by LinkedEntityId and the FileExtension = 'jar'
	 **/
	public static List<ContentDocumentLink> getByLinkedEntityId (Id LinkedEntityId) {
		return [Select c.LinkedEntityId, c.Id, c.ContentDocument.FileExtension, c.ContentDocument.Id, c.ContentDocumentId 
				From ContentDocumentLink c where LinkedEntityId =: LinkedEntityId and ContentDocument.FileExtension = 'jar'];
	}
	
	/**
	 *	Get Contentdocument by Title to retrieve the ContentVersionId
	 **/
	public static List<ContentDocument> getByTitle (String title) {
		return [Select c.Title, c.Id From ContentDocument c where Title =: title];
	}
}