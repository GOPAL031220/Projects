class ContactModel {
  int? id;
  String? firstname;
  String? lastname;
  String? phone;
  String? email;
  String? company;
  String? street;
  String? city;
  String? state;
  String? zip;
  String? dppath;

  ContactMap() {
    Map<String, dynamic> mapping = <String, dynamic>{};
    mapping['id'] = id;
    mapping['firstname'] = firstname;
    mapping['lastname'] = lastname;
    mapping['phone'] = phone;
    mapping['email'] = email;
    mapping['company'] = company;
    mapping['street'] = street;
    mapping['city'] = city;
    mapping['state'] = state;
    mapping['zip'] = zip;
    mapping['dppath'] = dppath;

    return mapping;
  }
}
