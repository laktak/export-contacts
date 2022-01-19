import Contacts
import Foundation
import SwiftyContacts

enum ContactsExport {

  static func main() {

    let group = DispatchGroup()
    group.enter()
    Task {
      do {
        try await run()
      } catch {
        print("Unexpected error: \(error).")
        exit(1)
      }
      group.leave()
    }
    group.wait()
  }

  static func run() async throws {

    let _ = try await requestAccess()
    let contacts = try await fetchContacts()

    let all = contacts.map(encodeContact)

    if let data = try? JSONSerialization.data(
      withJSONObject: all, options: [.sortedKeys, .prettyPrinted])
    {
      if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
        // note json allows the / to be escaped \/ (which swift does)
        print(JSONString)
      }
    }

  }

  static func addLabelValue(dict: inout [String: String], text: String?, value: String) {
    var label = "-"
    if text != nil && text != "" {
      let del = CharacterSet.alphanumerics.inverted
      let passed = text!.unicodeScalars.filter { !del.contains($0) }
      label = String(String.UnicodeScalarView(passed))
    }
    while dict[label] != nil {
      label = label + "."
    }
    dict[label] = value
  }

  static func encodeContact(contact: CNContact) -> [String: Any] {
    var res = [String: Any]()
    if let birthday = contact.birthday?.date {
      let df = DateFormatter()
      df.dateFormat = "yyyy-MM-dd"
      res["birthday"] = df.string(from: birthday)
    }

    if contact.namePrefix != "" {
      res["namePrefix"] = contact.namePrefix
    }

    if contact.givenName != "" {
      res["givenName"] = contact.givenName
    }

    if contact.middleName != "" {
      res["middleName"] = contact.middleName
    }

    if contact.familyName != "" {
      res["familyName"] = contact.familyName
    }

    if contact.previousFamilyName != "" {
      res["previousFamilyName"] = contact.previousFamilyName
    }

    if contact.nameSuffix != "" {
      res["nameSuffix"] = contact.nameSuffix
    }

    if contact.nickname != "" {
      res["nickname"] = contact.nickname
    }

    if contact.jobTitle != "" {
      res["jobTitle"] = contact.jobTitle
    }

    if contact.departmentName != "" {
      res["departmentName"] = contact.departmentName
    }

    if contact.organizationName != "" {
      res["organizationName"] = contact.organizationName
    }

    if contact.note != "" {
      res["note"] = contact.note
    }

    // if let imageData = contact.imageData {
    // res["image"] = imageData.base64EncodedString()
    // }

    if contact.emailAddresses.count > 0 {
      var emailAddresses = [String: String]()
      for (_, emailAddress) in contact.emailAddresses.enumerated() {
        addLabelValue(
          dict: &emailAddresses, text: emailAddress.label, value: (emailAddress.value as String))
      }
      res["emailAddresses"] = emailAddresses
    }
    if contact.phoneNumbers.count > 0 {
      var phoneNumbers = [String: String]()
      for (_, phoneNumber) in contact.phoneNumbers.enumerated() {
        addLabelValue(
          dict: &phoneNumbers, text: phoneNumber.label, value: phoneNumber.value.stringValue)
      }
      res["phoneNumbers"] = phoneNumbers
    }
    if contact.postalAddresses.count > 0 {
      var postalAddresses = [String: String]()
      for (_, postalAddress) in contact.postalAddresses.enumerated() {
        addLabelValue(
          dict: &postalAddresses, text: postalAddress.label,
          value: (CNPostalAddressFormatter.string(from: postalAddress.value, style: .mailingAddress))
        )
      }
      res["postalAddresses"] = postalAddresses
    }

    if contact.urlAddresses.count > 0 {
      var urlAddresses = [String: String]()
      for (_, urlAddress) in contact.urlAddresses.enumerated() {
        addLabelValue(
          dict: &urlAddresses, text: urlAddress.label, value: urlAddress.value as String)
      }
      res["urlAddresses"] = urlAddresses
    }

    if contact.instantMessageAddresses.count > 0 {
      var instantMessageAddresses = [String: String]()
      for (_, instantMessageAddress) in contact.instantMessageAddresses.enumerated() {
        addLabelValue(
          dict: &instantMessageAddresses, text: instantMessageAddress.label,
          value: instantMessageAddress.value.username + " - " + instantMessageAddress.value.service)
      }
      res["instantMessageAddresses"] = instantMessageAddresses
    }

    if contact.socialProfiles.count > 0 {
      var socialProfiles = [String: String]()
      for (_, socialProfile) in contact.socialProfiles.enumerated() {
        addLabelValue(
          dict: &socialProfiles, text: socialProfile.label,
          value: socialProfile.value.username + " - " + socialProfile.value.service)
      }
      res["socialProfiles"] = socialProfiles
    }

    return res
  }
}

ContactsExport.main()
