//
//  UserListTableViewCell.swift
//  TymeXGitHubUserViewer
//
//  Created by LONGPHAN on 3/6/25.
//

import UIKit
import Kingfisher

class UserListTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var avatarParentView: UIView!
    @IBOutlet weak var avatarImv: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        urlLabel.text = nil
        avatarImv.image = UIImage()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func configureViews() {
        parentView.layer.shadowColor = UIColor.black.cgColor
        parentView.layer.shadowOpacity = 0.12
        parentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        parentView.layer.shadowRadius = 8
        parentView.layer.cornerRadius = 12
        parentView.layer.masksToBounds = false
        avatarParentView.layer.cornerRadius = 8
        avatarImv.clipsToBounds = true
        avatarImv.layer.cornerRadius = avatarImv.layer.bounds.height / 2
    }
    
    func configure(with user: User) {
        nameLabel.text = user.login ?? "Unknown"
        urlLabel.text = user.url ?? ""
        
        if let urlStr = user.avatar_url, let url = URL(string: urlStr) {
            avatarImv.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "person.circle"),
                options: [
                    .cacheOriginalImage
                ]
            )
        } else {
            avatarImv.image = UIImage(systemName: "person.circle")
        }
    }
}
