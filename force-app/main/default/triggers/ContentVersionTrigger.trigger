/**					
 * @description   : Trigger to force edit rights for all company users
 * @author (s)    : BRITE
 */
trigger ContentVersionTrigger on ContentVersion (after insert, after update) {
    if (trigger.isAfter) {
        if (trigger.isInsert || trigger.isUpdate) {
			ContentVersionHelper.setCommunityFileMapLink(Trigger.New);
        }
	}
}