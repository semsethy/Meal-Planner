//
//  SpecialCollectionViewCell.swift
//  Meal Preparing
//
//  Created by JoshipTy on 29/7/24.
//

import UIKit

class SpecialCollectionViewCell: UICollectionViewCell {
    let title = UILabel()
    let image = UIImageView()
    let noteCount = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(title)
        contentView.addSubview(image)
        contentView.addSubview(noteCount)
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 10
        title.textAlignment = .center
        noteCount.textAlignment = .center
        noteCount.font = .systemFont(ofSize: 13)
        noteCount.textColor = .gray
        image.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
