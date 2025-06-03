//
//  UserDetailViewController.swift
//  TymeXGitHubUserViewer
//
//  Created by LONGPHAN on 3/6/25.
//

import UIKit
import Kingfisher

class UserDetailViewController: UIViewController {
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var avatarParentView: UIView!
    @IBOutlet weak var avatarImv: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var followerParentView: UIView!
    @IBOutlet weak var followingParentView: UIView!
    
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var blogContentLabel: UILabel!
    // MARK: - Variables
    private let viewModel: UserDetailViewModel
    
    // MARK: - Init
    init(viewModel: UserDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: UserDetailViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        bindData()
    }
    
    // MARK: - Function
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
        followerParentView.layer.cornerRadius = followerParentView.layer.bounds.height / 2
        followingParentView.layer.cornerRadius = followingParentView.layer.bounds.height / 2
    }
    
    private func bindData() {
        let input = UserDetailViewModel.Input()
        
        let output = viewModel.transform(input: input)
        
        let userDetail = output.userDetail
        
        title = userDetail.name
        nameLabel.text = userDetail.login
        locationLabel.text = userDetail.location
        followerCountLabel.text = userDetail.followers?.description ?? ""
        followingCountLabel.text = userDetail.following?.description ?? ""
        blogContentLabel.text = userDetail.html_url
        if let urlStr = userDetail.avatar_url, let url = URL(string: urlStr) {
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
