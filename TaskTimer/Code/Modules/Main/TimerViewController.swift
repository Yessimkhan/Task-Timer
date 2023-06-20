//
//  TimerViewController.swift
//  TaskTimer
//
//  Created by Yessimkhan Zhumash on 19.06.2023.
//

import UIKit

class TimerViewController: UIViewController {
    
    // MARK: - outlets
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var timerContainerView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var pauseResumeView: UIView!
    @IBOutlet weak var resetVIew: UIView!
    
    @IBOutlet weak var pauseResumeButton: UIButton!
    
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    
    // MARK: - Variables
    
    var taskViewModel: TaskViewModel!
    var totalSeconds = 0 {
        didSet {
            timerSeconds = totalSeconds
        }
    }
    var timerSeconds = 0
    
    let timeAttributes = [NSAttributedString.Key.font: UIFont(name: "Code-Pro-Bold-LC", size: 46), .foregroundColor: UIColor.black]
    let semiBoldAttributes = [NSAttributedString.Key.font: UIFont(name: "Code-Pro-LC", size: 32), .foregroundColor: UIColor.black]
    
    let timerTrackLayer = CAShapeLayer()
    let timerCircleFillLayer = CAShapeLayer()
    var timerState: CountdownState = .suspended
    var countDownTimer = Timer()
    
    lazy var timerEndAnimation: CABasicAnimation = {
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.toValue = 0
        strokeEnd.fillMode = .forwards
        strokeEnd.isRemovedOnCompletion = true
        return strokeEnd
    }()
    
    lazy var timerResetAnimation: CABasicAnimation = {
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.toValue = 1
        strokeEnd.duration = 1
        strokeEnd.fillMode = .forwards
        strokeEnd.isRemovedOnCompletion = false
        return strokeEnd
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let task = self.taskViewModel.getTask()
//        let task = Task(taskName: "vds", taskDescription: "vs", seconds: 5, taskType: .init(symbolName: "star", typeName: "Develop"), timeStamp: Date().timeIntervalSince1970)
        
        self.totalSeconds = task.seconds
        self.taskTitleLabel.text = task.taskName
        self.descriptionLabel.text = task.taskDescription
        
        self.imageContainerView.layer.cornerRadius = self.imageContainerView.frame.width / 2
        self.imageView.layer.cornerRadius = self.imageView.frame.width / 2
        self.imageView.image = UIImage(systemName: task.taskType.symbolName)
        
        [pauseResumeView, resetVIew].forEach{
            guard let view = $0 else {return}
            view.layer.opacity = 0
            view.isUserInteractionEnabled = false
        }
        
        [playView, pauseResumeView, resetVIew].forEach{ $0?.layer.cornerRadius = 17 }
        
        
        timerView.transform = timerView.transform.rotated(by: 270.degreeToRadians())
        timerLabel.transform = timerLabel.transform.rotated(by: 90.degreeToRadians())
        timerContainerView.transform = timerContainerView.transform.rotated(by: 90.degreeToRadians())
        
        updateLabels()
        addCircles()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.setupLayers()
        }
    }
    
    
    // MARK: - Outlets & Objc Functions
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.timerTrackLayer.removeFromSuperlayer()
        self.timerCircleFillLayer.removeFromSuperlayer()
        countDownTimer.invalidate()
        self.dismiss(animated: true)
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        guard timerState == .suspended else {return}
        self.timerEndAnimation.duration = Double(self.timerSeconds)
        animatePauseButton(symbolName: "pause.fill")
        animatePlayPauseResetView(timePlaying: false)
        startTimer()
        
    }
    
    @IBAction func pauseResumeButtonPressed(_ sender: Any) {
        switch timerState {
            
        case .running:
            self.timerState = .paused
            self.timerCircleFillLayer.strokeEnd = CGFloat(timerSeconds) / CGFloat(totalSeconds)
            self.resetTimer()
            animatePauseButton(symbolName: "play.fill")
        case .paused:
            self.timerState = .running
            self.timerEndAnimation.duration = Double(self.timerSeconds) + 1
            self.startTimer()
            animatePauseButton(symbolName: "pause.fill")
        default: break
        }
    }
    @IBAction func resetButtonPressed(_ sender: Any) {
        self.timerState = .suspended
        self.timerSeconds = self.totalSeconds
        resetTimer()
        
        self.timerCircleFillLayer.add(timerResetAnimation, forKey: "reset")
        animatePauseButton(symbolName: "play.fill")
        animatePlayPauseResetView(timePlaying: true)
    }
    
    
    
    
    // MARK: - Functions
    override class func description() -> String {
        return "TimerViewController"
    }
    
    func setupLayers(){
        let radius = self.timerView.frame.width < self.timerView.frame.height ? self.timerView.frame.width / 2 : self.timerView.frame.height / 2
        let arcPath = UIBezierPath(arcCenter: CGPoint(x: timerView.frame.height / 2, y: timerView.frame.width / 2), radius: radius, startAngle: 0, endAngle: 360.degreeToRadians(), clockwise: true)
        
        self.timerTrackLayer.path = arcPath.cgPath
        self.timerTrackLayer.strokeColor = UIColor(hex: "F2A041").cgColor
        self.timerTrackLayer.lineWidth = 20
        self.timerTrackLayer.fillColor = UIColor.clear.cgColor
        self.timerTrackLayer.lineCap = .round
        
        self.timerCircleFillLayer.path = arcPath.cgPath
        self.timerCircleFillLayer.strokeColor = UIColor.black.cgColor
        self.timerCircleFillLayer.lineWidth = 21
        self.timerCircleFillLayer.fillColor = UIColor.clear.cgColor
        self.timerCircleFillLayer.lineCap = .round
        self.timerCircleFillLayer.strokeEnd = 1
        
        self.timerView.layer.addSublayer(timerTrackLayer)
        self.timerView.layer.addSublayer(timerCircleFillLayer)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut){
            self.timerContainerView.layer.cornerRadius = self.timerContainerView.frame.width / 2
        }
        
    }
    
    func startTimer(){
        updateLabels()
        
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.timerSeconds -= 1
            self.updateLabels()
            if self.timerSeconds == 0 {
                timer.invalidate()
                self.resetButtonPressed(self)
            }
        }
        self.timerState = .running
        self.timerCircleFillLayer.add(self.timerEndAnimation, forKey: "timerEnd")
        
    }
    func updateLabels(){
        let seconds = self.timerSeconds % 60
        let minutes = self.timerSeconds / 60 % 60
        let hours = self.timerSeconds / 3600
        
        if hours > 0 {
            let hoursCount = String(hours).count
            let minutesCount = String(minutes).count
            let secondsCount = String(seconds.appendZeroes()).count
            
            let timeString = "\(hours)h \(minutes)m \(seconds.appendZeroes())s"
            let attributedString = NSMutableAttributedString(string: timeString, attributes: semiBoldAttributes)
            
            attributedString.addAttributes(timeAttributes, range: NSRange(location: 0, length: hoursCount))
            attributedString.addAttributes(timeAttributes, range: NSRange(location: hoursCount + 2, length: minutesCount))
            attributedString.addAttributes(timeAttributes, range: NSRange(location: hoursCount + 2 + minutesCount + 3, length: secondsCount))
            self.timerLabel.attributedText = attributedString
            
        } else {
            let minutesCount = String(minutes).count
            let secondsCount = String(seconds.appendZeroes()).count
            
            let timeString = "\(minutes)m  \(seconds.appendZeroes())s"
            let attributedString = NSMutableAttributedString(string: timeString,attributes: semiBoldAttributes)
            
            attributedString.addAttributes(timeAttributes, range: NSRange(location: 0, length: minutesCount))
            attributedString.addAttributes(timeAttributes, range: NSRange(location: minutesCount + 3, length: secondsCount))
            
            
            self.timerLabel.attributedText = attributedString
        }
    }
    
    func resetTimer(){
        self.countDownTimer.invalidate()
        self.timerCircleFillLayer.removeAllAnimations()
        updateLabels()
    }
    
    func animatePauseButton(symbolName: String){
        UIView.transition(with: pauseResumeButton, duration: 0.3, options: .transitionCrossDissolve){
            self.pauseResumeButton.setImage(UIImage(systemName: symbolName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold, scale: .default)), for: .normal)
        }
    }
    
    func animatePlayPauseResetView(timePlaying: Bool){
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.playView.layer.opacity = timePlaying ? 1 : 0
            self.pauseResumeView.layer.opacity = timePlaying ? 0 : 1
            self.resetVIew.layer.opacity = timePlaying ? 0 : 1
        } completion: { [weak self] _ in
            [self?.pauseResumeView , self?.resetVIew].forEach {
                guard let view = $0 else { return }
                view.isUserInteractionEnabled = timePlaying ? false : true
            }
        }
    }
    func addCircles(){
        let circleLayer = CAShapeLayer()
        circleLayer.path = UIBezierPath(arcCenter: CGPoint(x: 0, y: self.view.frame.height - 140), radius: 120, startAngle: 0, endAngle: 360.degreeToRadians(), clockwise: true).cgPath
        circleLayer.fillColor = UIColor(hex: "F6A63A").cgColor
        circleLayer.opacity = 0.15
        
        let circleLayerTwo = CAShapeLayer()
        circleLayerTwo.path = UIBezierPath(arcCenter: CGPoint(x: 80, y: self.view.frame.height - 60), radius: 110, startAngle: 0, endAngle: 360.degreeToRadians(), clockwise: true).cgPath
        circleLayerTwo.fillColor = UIColor(hex: "F6A63A").cgColor
        circleLayerTwo.opacity = 0.35
        
        self.view.layer.insertSublayer(circleLayer, below: self.view.layer)
        self.view.layer.insertSublayer(circleLayerTwo, below: self.view.layer)
        
        self.view.bringSubviewToFront(descriptionLabel)
    }
    
}
