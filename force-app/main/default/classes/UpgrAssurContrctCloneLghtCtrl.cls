/**
 * @description   : Class for the functionality Ugrade Assurance Contract clone
 *					Run every 1 November
 * @author (s)    : Brite
 */
public with sharing class UpgrAssurContrctCloneLghtCtrl {
	@AuraEnabled
	public static String cloneUpgrAssContr(Id upgrAssContrId) {
        return UpgrAssurContrctCloneHelper.clone (upgrAssContrId);
    }
}