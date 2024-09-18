//
//  RecommendRecipeViewCell.swift
//  Meal Preparing
//
//  Created by JoshipTy on 20/8/24.
//

import UIKit
import CoreData
import FirebaseStorage
import FirebaseFirestore

class RecommendRecipeViewCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
        setUIColor()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupViews() {
        contentView.addSubview(titleLabel)
        
    }
    @objc private func handleUserInterfaceStyleChange() {
        setUIColor()
    }
    func setUIColor(){
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        contentView.backgroundColor = isDarkMode ? UIColor(white: 0.1, alpha: 1) : UIColor(white: 1, alpha: 1)
        titleLabel.textColor = isDarkMode ? UIColor(white: 1, alpha: 1) : UIColor(white: 0, alpha: 1)
    }
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.trailing.equalTo(contentView).inset(25)
        }
        
    }
}
