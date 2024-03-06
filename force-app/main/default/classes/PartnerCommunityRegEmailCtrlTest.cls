@isTest
private class PartnerCommunityRegEmailCtrlTest {

    @isTest
    private static void getterSetterTest() {
        PartnerCommunityRegEmailCtrl ctrl = new PartnerCommunityRegEmailCtrl();
        try {
            // unknown ID
            ctrl.receivingUserId = '0034E00000yGnReQAK';
            system.assertEquals(null, ctrl.lastLoginDate, 'Case 1: last login date');
            system.assertEquals(null, ctrl.receivingUserName, 'Case 1: receiving user name');
            system.assertEquals(null, ctrl.contactFirstName, 'Case 1: contact first name');
        } catch (Exception ex) {
            system.assert(false, 'Case 1: exception thrown: ' + ex.getMessage());
        }
        
        User communityUser = TestUtil.createCommunityUser('uTest', 'Adyen v2 Partner Community User', true);
        ctrl.receivingUserId = communityUser.Id;
        system.assertEquals(null, ctrl.lastLoginDate, 'Case 2: Last login date of a community user');
        // when we create a community, the user hasn't logged in yet
        system.assert(ctrl.receivingUserName.endsWith('@test.com'), 'Case 2: receiving user name');
        system.assertEquals('ContactFirstNameuTest', ctrl.contactFirstName, 'Case 2: contact first name');    
        
        system.assertEquals(UserInfo.getName(), ctrl.currentUserName, 'Current user name');
    }
    
}