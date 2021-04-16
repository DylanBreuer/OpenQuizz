//
//  ViewController.swift
//  OpenQuizz
//
//  Created by Breuer Dylan on 11/04/2021.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var questionView: QuestionView!
    @IBOutlet weak var messageLabel: MessageLabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    var game = Game()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = Notification.Name("QuestionsLoaded")
        NotificationCenter.default.addObserver(self, selector: #selector(questionsLoaded), name: name, object: nil)
        startNewGame()
        
        newGameButton.layer.masksToBounds = false
        newGameButton.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        newGameButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        newGameButton.layer.shadowOpacity = 1.0
        newGameButton.layer.shadowRadius = 0.0
        newGameButton.layer.cornerRadius = CGFloat(10)
        
        questionView.layer.cornerRadius = CGFloat(20)
        resultLabel.alpha = 0
        messageLabel.layer.masksToBounds = true
        messageLabel.layer.cornerRadius = CGFloat(20)
        messageLabel.alpha = 0
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragQuestionView(_:)))
        questionView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func questionsLoaded() {
        activityIndicator.isHidden = true
        newGameButton.isEnabled = true
        
        questionView.title = game.currentQuestion.title
    }

    @IBAction func didPressNewGameButton() {
        buttonPressed()
    }

    @IBAction func didReleaseNewGameButton() {
        startNewGame()
        buttonReleased()
    }
    
    private func startNewGame() {
        activityIndicator.isHidden = false
        newGameButton.isEnabled = false
        resultLabel.alpha = 0
        
        questionView.title = "Loading..."
        questionView.style = .standard
        
        scoreLabel.text = "0 / 10"
        scoreLabel.transform = .identity
        
        game.refresh()
    }
    
    private func buttonPressed() {
        newGameButton.transform = CGAffineTransform(translationX: 0, y: 5)
        newGameButton.layer.masksToBounds = true
    }
    
    private func buttonReleased() {
        newGameButton.transform = .identity
        newGameButton.layer.masksToBounds = false
    }
    
    @objc func dragQuestionView(_ sender : UIPanGestureRecognizer) {
        if game.state == .ongoing {
            switch sender.state {
                case .began, .changed:
                    transformQuestionViewWith(gesture: sender)
                case .cancelled, .ended :
                    answerQuestion()
                default:
                    break
            }
        }
    }
    
    private func transformQuestionViewWith(gesture : UIPanGestureRecognizer) {
        let translation = gesture.translation(in: questionView)
        let translationTransform = CGAffineTransform(translationX: translation.x, y: translation.y)
        
        let screenWidth = UIScreen.main.bounds.width
        let translationPercent = translation.x/(screenWidth/2)
        let rotationAngle = (CGFloat.pi / 6) * translationPercent
        let rotationTransform = CGAffineTransform(rotationAngle: rotationAngle)
        
        let transform = translationTransform.concatenating(rotationTransform)
        
        questionView.transform = transform
        
        if translation.x > 0 {
            questionView.style = .correct
        }
        else if translation.x < 0 {
            questionView.style = .incorrect
        }
    }
    
    private func answerQuestion() {
        switch questionView.style {
            case .correct:
                game.answerCurrentQuestion(with: true)
            case .incorrect:
                game.answerCurrentQuestion(with: false)
            case .standard:
                break
        }
        scoreLabel.text = "\(game.score) / 10"
        
        if (self.messageLabel.frame.origin.y + 51) < (self.newGameButton.frame.origin.y - 5) {
            self.messageLabel.isHidden = false
        } else {
            self.messageLabel.isHidden = true
        }
        
        if game.answerIsCorrect {
            messageLabel.style = .correct
        } else {
            messageLabel.style = .incorrect
        }
        UIView.animate(withDuration: 1, animations: {
            self.messageLabel.alpha = 1
        }) {(success) in
            if success {
                UIView.animate(withDuration: 2, delay: 1, animations: {
                    self.messageLabel.alpha = 0
                }) { (success) in
                    if success {
                        if self.game.state == .over {
                            self.displayResult()
                        }
                    }
                }
            }
        }
        
        let screenWidth = UIScreen.main.bounds.width
        var translationTransform = CGAffineTransform()
        
        if questionView.style == .correct {
            translationTransform = CGAffineTransform(translationX: screenWidth, y: 0)
        }
        else if questionView.style == .incorrect {
            translationTransform = CGAffineTransform(translationX: -screenWidth, y: 0)
        }
        
        UIView.animate(withDuration: 0.3, animations : {
            self.questionView.transform = translationTransform
        }) { (success) in
            if success {
                self.showQuestionView()
            }
        }
    }
    
    private func showQuestionView() {
        questionView.transform = .identity
        questionView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        questionView.style = .standard
        
        switch game.state {
        case .ongoing:
            questionView.title = game.currentQuestion.title
        case .over:
            questionView.title = "Game Over"
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.questionView.transform = .identity
        }, completion: nil)
    }
    
    private func displayResult() {
        UIView.animate(withDuration: 5, delay: 0, animations : {
            self.scoreLabel.transform = CGAffineTransform(translationX: 0, y: CGFloat(30)).concatenating(CGAffineTransform(scaleX: 1.5, y: 1.5))
        })
        
        if (self.resultLabel.frame.origin.y + 51) < (self.newGameButton.frame.origin.y - 5) {
            self.resultLabel.isHidden = false
        } else {
            self.resultLabel.isHidden = true
        }
        
        UIView.animate(withDuration: 7, delay: 0, animations: {
            switch self.game.score {
            case 0,1,2 :
                self.resultLabel.text = "Catastrophic..."
            case 3,4 :
                self.resultLabel.text = "You can do better..."
            case 5,6 :
                self.resultLabel.text = "Tell yourself that you've the average."
            case 7,8,9 :
                self.resultLabel.text = "Good game !"
            case 10 :
                self.resultLabel.text = "Perfect !!!"
            default :
                break
            }
            self.resultLabel.alpha = 1
        }, completion: nil)
    }
        
}

