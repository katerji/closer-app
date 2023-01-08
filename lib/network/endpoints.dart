class Endpoints {
  static const login = 'auth/login';
  static const register = 'auth/register';
  static const getChats = 'chats';
  static const getContacts = 'contacts';
  static const sendInvitation = 'invitation';
  static const getInvitations = 'invitations';

  static getAcceptOrRejectInvitationEndpoint(id) {
    return 'invitation/inviter/$id';
  }
  static getDeleteSentInvitationEndpoint(id) {
    return 'invitation/user/$id';
  }
}
