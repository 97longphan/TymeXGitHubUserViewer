//
//  UserListTableViewCellTests.swift
//  TymeXGitHubUserViewer
//
//  Created by LONGPHAN on 3/6/25.
//

import XCTest
@testable import TymeXGitHubUserViewer

final class UserListTableViewCellTests: XCTestCase {
    var cell: UserListTableViewCell!

    override func setUp() {
        super.setUp()

        let bundle = Bundle(for: UserListTableViewCell.self)
        let nib = UINib(nibName: "UserListTableViewCell", bundle: bundle)
        cell = nib.instantiate(withOwner: nil, options: nil).first as? UserListTableViewCell

        cell.awakeFromNib()
    }

    func testConfigure_setsNameAndURL() {
        // Arrange
        let user = User(
            id: 1,
            login: "longphan",
            avatar_url: nil,
            url: "https://github.com/longphan"
        )

        cell.configure(with: user)

        XCTAssertEqual(cell.nameLabel.text, "longphan")
        XCTAssertEqual(cell.urlLabel.text, "https://github.com/longphan")
    }

    func testConfigure_setsPlaceholderAvatarWhenNoURL() {
        let user = User(id: 2, login: "noavatar", avatar_url: nil, url: nil)
        cell.configure(with: user)

        let systemPlaceholder = UIImage(systemName: "person.circle")
        XCTAssertEqual(cell.avatarImv.image?.pngData(), systemPlaceholder?.pngData())
    }

    func testPrepareForReuse_resetsLabelsAndImage() {
        cell.nameLabel.text = "abc"
        cell.urlLabel.text = "xyz"
        cell.avatarImv.image = UIImage(systemName: "star")

        cell.prepareForReuse()

        XCTAssertNil(cell.nameLabel.text)
        XCTAssertNil(cell.urlLabel.text)
        XCTAssertNotNil(cell.avatarImv.image)
    }
}
