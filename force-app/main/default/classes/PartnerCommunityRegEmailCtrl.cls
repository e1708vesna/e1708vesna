public with sharing class PartnerCommunityRegEmailCtrl {

    public String currentUserName { 
            get {
                return UserInfo.getName();
            }
            private set;
    }
    public Id receivingUserId {
            get; 
            set {
                receivingUserId = value;
                List<User> uList = [SELECT Id, Username, LastLoginDate, Contact.FirstName FROM User WHERE Id = :receivingUserId LIMIT 1];
                if (!uList.isEmpty()) {
                    receivingUser = uList[0];
                }
            }
    }
    
    public User receivingUser {get; set;}
    public String receivingUserName {
            get {
                if (receivingUser == null) {
                    return null;
                }
                return receivingUser.Username;
            } 
            private set;
    }

    public DateTime lastLoginDate {
           get {
              if (receivingUser == null) {
                  return null;
              }
              return receivingUser.LastLoginDate;
           } 
           private set;
    }
    public String contactFirstName {
            get {
                if (receivingUser == null) {
                    return null;
                }
                return receivingUser.Contact.FirstName;
            } 
            private set;
    }
    
}