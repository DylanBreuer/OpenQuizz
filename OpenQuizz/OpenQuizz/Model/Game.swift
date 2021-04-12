//
//  Game.swift
//  OpenQuizz
//
//  Created by Breuer Dylan on 12/04/2021.
//

import Foundation

class Game {
    enum State { case ongoing, over }
    
    var score = 0

    private var questions = [Question]()
    private var currentIndex = 0
    var currentQuestion: Question {
        return questions[currentIndex]
    }
    
    var state : State = .ongoing

    func refresh() {
        score = 0
        currentIndex = 0
        state = .ongoing
    }

    func answerCurrentQuestion(with answer: Bool) {
        if currentQuestion.isCorrect == answer {
            score += 1
        }
        goToNextQuestion()
    }

    private func goToNextQuestion() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else {
            finishGame()
        }
    }

    private func finishGame() {
        state = .over
    }
}
