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

  static func fixLabel(index: Int, text: String?) -> String {
    if text != nil {
      let del = CharacterSet.alphanumerics.inverted
      let passed = text!.unicodeScalars.filter { !del.contains($0) }
      return "\(index)-" + String(String.UnicodeScalarView(passed))

    } else {
      return "\(index)"
    }
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
      for (index, emailAddress) in contact.emailAddresses.enumerated() {
        emailAddresses[fixLabel(index: index, text: emailAddress.label)] =
          (emailAddress.value as String)
      }
      res["emailAddresses"] = emailAddresses
    }
    if contact.phoneNumbers.count > 0 {
      var phoneNumbers = [String: String]()
      for (index, phoneNumber) in contact.phoneNumbers.enumerated() {
        phoneNumbers[fixLabel(index: index, text: phoneNumber.label)] =
          phoneNumber.value.stringValue
      }
      res["phoneNumbers"] = phoneNumbers
    }
    if contact.postalAddresses.count > 0 {
      var postalAddresses = [String: String]()
      for (index, postalAddress) in contact.postalAddresses.enumerated() {
        postalAddresses[fixLabel(index: index, text: postalAddress.label)] =
          (CNPostalAddressFormatter.string(from: postalAddress.value, style: .mailingAddress))
      }
      res["postalAddresses"] = postalAddresses
    }

    if contact.urlAddresses.count > 0 {
      var urlAddresses = [String: String]()
      for (index, urlAddress) in contact.urlAddresses.enumerated() {
        urlAddresses[fixLabel(index: index, text: urlAddress.label)] = urlAddress.value as String
      }
      res["urlAddresses"] = urlAddresses
    }

    if contact.instantMessageAddresses.count > 0 {
      var instantMessageAddresses = [String: String]()
      for (index, instantMessageAddress) in contact.instantMessageAddresses.enumerated() {
        instantMessageAddresses[fixLabel(index: index, text: instantMessageAddress.label)] =
          instantMessageAddress.value.username + " - " + instantMessageAddress.value.service
      }
      res["instantMessageAddresses"] = instantMessageAddresses
    }

    if contact.socialProfiles.count > 0 {
      var socialProfiles = [String: String]()
      for (index, socialProfile) in contact.socialProfiles.enumerated() {
        socialProfiles[fixLabel(index: index, text: socialProfile.label)] =
          socialProfile.value.username + " - " + socialProfile.value.service
      }
      res["socialProfiles"] = socialProfiles
    }

    return res
  }
}

ContactsExport.main()
