//
//  MessageView.swift
//  OpenQuizz
//
//  Created by Breuer Dylan on 14/04/2021.
//

import UIKit

class MessageLabel: UILabel {
    enum Style {case correct, incorrect, standard}
    
    var style : Style = .standard {
        didSet {
            setStyle(style)
        }
    }
    
    private func setStyle(_ style : Style) {
        switch style {
            case .correct :
                backgroundColor = #colorLiteral(red: 0.7410294414, green: 0.8781068921, blue: 0.594247818, alpha: 1)
                self.text = "Good job !"
            case .incorrect :
                backgroundColor = #colorLiteral(red: 0.9483795762, green: 0.5319040418, blue: 0.5783907771, alpha: 1)
                self.text = "It's not the correct answer..."
            case .standard :
                backgroundColor = #colorLiteral(red: 0.72609061, green: 0.7454825044, blue: 0.762527287, alpha: 1)
                self.text = ""
        }
    }

}
