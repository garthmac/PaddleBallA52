//
//  SettingsViewController.swift
//  
//
//  Created by iMac21.5 on 5/30/15.
//
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var autoStartSwitch: UISwitch!
    @IBOutlet weak var ballsLabel: UILabel!
    @IBOutlet weak var ballStepper: UIStepper!
    @IBOutlet weak var ballRotationSwitch: UISwitch!
    @IBOutlet weak var ballColorLabel: UILabel!
    @IBOutlet weak var ballColorPickerView: UIPickerView!
    @IBOutlet weak var columnsLabel: UILabel!
    @IBOutlet weak var columnSlider: UISlider!
    @IBOutlet weak var courtColorLabel: UILabel!
    @IBOutlet weak var courtColorPickerView: UIPickerView!
    @IBOutlet weak var difficultySelector: UISegmentedControl!
    @IBOutlet weak var highScoreSwitch: UISwitch!
    @IBOutlet weak var paddleColorLabel: UILabel!
    @IBOutlet weak var paddleColorPickerView: UIPickerView!
    @IBOutlet weak var paddleWidthStepper: UIStepper!
    @IBOutlet weak var paddleWidthLabel: UILabel!
    @IBOutlet weak var rowsLabel: UILabel!
    @IBOutlet weak var rowSlider: UISlider!
    @IBOutlet weak var redBlockSwitch: UISwitch!
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var soundChoiceSegControl: UISegmentedControl!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    
    //MARK: - UIPickerViewDataSource
    var pickerDataSource = ["Brown", "Yellow", "Cyan", "Blue", "Green", "Red", "Purple", "Orange", "DarkGray", "LightGray", "White", "Black", "Clear"]
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 1 } //number of wheels in the picker
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    //MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerDataSource[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 { ballColor = pickerDataSource[row] }
        if pickerView.tag == 1 { courtColor = pickerDataSource[row] }
        if pickerView.tag == 2 { paddleColor = pickerDataSource[row] }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ballColorPickerView.dataSource = self
        ballColorPickerView.delegate = self
        courtColorPickerView.dataSource = self
        courtColorPickerView.delegate = self
        paddleColorPickerView.dataSource = self
        paddleColorPickerView.delegate = self
    }
    //When the view will appear (e.g. when switching back from the settings tab), check if something has changed. Reset the changed property. Remove all existing bricks from the view and destroy them. Remove any balls left. Reset the animator and the breakout behavior. Finally, recreate the bricks with the new settings. To be able to reset the breakout behavior, change it from let to var
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Settings().type stuff set here!!!
        autoStart = Settings().autoStart
        balls = Settings().balls
        ballColor = Settings().ballColor
        columns = Settings().columns
        courtColor = Settings().courtColor
        difficulty = Settings().difficulty
        highScoreOn = Settings().highScoreOn
        paddleColor = Settings().paddleColor
        paddleWidthMultiplier = Settings().paddleWidthMultiplier
        paddleWidthStepper.enabled = Settings().paddleWidthUnlockStepper
        redBlockOn = Settings().redBlockOn
        rows = Settings().rows
        soundOn = Settings().soundOn
        speed = Settings().speed
        setPurchasedExtras()
    }
    func setPurchasedExtras() {
//        let achieved = Settings().achieved  //"00000000"
//        let maxSoundTrack = achieved.intAtIndex(1)!
//        if maxSoundTrack > 0 {
//            if let soundTrackControl = self.view.viewWithTag(222) as? UISegmentedControl {
//                for i in 1...maxSoundTrack {
//                    soundTrackControl.setEnabled(true, forSegmentAtIndex: i)
//                }
//            }
//        }
        for string in Settings().myAudios {
            for i in 0..<ShopViewController().audios.count {
                if ShopViewController().audios[i] == string {
                    soundChoiceSegControl.setEnabled(true, forSegmentAtIndex: i)
                }
            }
        }
        let paddleBallTabBarItem = tabBarController!.tabBar.items![1] as! UITabBarItem
        paddleBallTabBarItem.badgeValue = nil
    }
    var ballColor: String {
        get { return ballColorLabel.text! }
        set {
            ballColorLabel.text = "➢ " + newValue
            Settings().ballColor = newValue
        }
    }
    var courtColor: String {
        get { return courtColorLabel.text! }
        set {
            courtColorLabel.text = "➢ " + newValue
            Settings().courtColor = newValue
        }
    }
    var paddleColor: String {
        get { return paddleColorLabel.text! }
        set {
            paddleColorLabel.text = "➢ " + newValue
            Settings().paddleColor = newValue
        }
    }
    var autoStart: Bool {
        get { return autoStartSwitch.on }
        set { autoStartSwitch.on = newValue }
    }
    @IBAction func autoStartChanged(sender: UISwitch) {
        Settings().autoStart = autoStart
    }
    var balls: Int {
        get { return ballsLabel.text!.toInt()! }
        set {
            ballsLabel.text = "\(newValue)"
            ballStepper.value = Double(newValue)
        }
    }
    @IBAction func ballsChanged(sender: UIStepper) {
        balls = Int(sender.value)
        Settings().balls = balls
    }
    var ballRotation: Bool {
        get { return ballRotationSwitch.on }
        set { ballRotationSwitch.on = newValue }
    }
    @IBAction func ballRotationChanged(sender: UISwitch) {
        Settings().ballRotation = ballRotation
    }
    var columns: Int {
        get { return columnsLabel.text!.toInt()! }
        set {
            columnsLabel.text = "\(newValue)"
            columnSlider.value = Float(newValue)
        }
    }
    @IBAction func columnsChanged(sender: UISlider) {
        columns = Int(sender.value)
        Settings().columns = columns
        Settings().changed = true
    }
    var difficulty: Int {
        get { return difficultySelector.selectedSegmentIndex }
        set { difficultySelector.selectedSegmentIndex = newValue }
    }
    @IBAction func difficultyChanged(sender: UISegmentedControl) {
        Settings().difficulty = difficulty
        if difficulty == 0 {
            paddleWidthMultiplier = max(paddleWidthMultiplier, 4)
        }
        else {
            paddleWidthMultiplier = min(paddleWidthMultiplier, 2)
        }
        paddleWidthChanged(paddleWidthStepper)
        Settings().changed = true
    }
    var highScoreOn: Bool {
        get { return highScoreSwitch.on }
        set { highScoreSwitch.on = newValue }
    }
    @IBAction func highScoreOnChanged(sender: UISwitch) {
        Settings().highScoreOn = highScoreOn
    }
    var paddleWidthMultiplier: Int {
        get { return paddleWidthLabel.text!.toInt()! }
        set {
            paddleWidthLabel.text = "\(newValue)"
            paddleWidthStepper.value = Double(newValue)
        }
    }
    let model = UIDevice.currentDevice().model
    @IBAction func paddleWidthChanged(sender: UIStepper) {
        if model.hasPrefix("iPad") {
            paddleWidthMultiplier = min(Int(sender.value), 10) //test 0
        } else {
            paddleWidthMultiplier = min(Int(sender.value), 5) //test 4
        }
        Settings().paddleWidthMultiplier = paddleWidthMultiplier
    }
    var rows: Int {
        get { return rowsLabel.text!.toInt()! }
        set {
            rowsLabel.text = "\(newValue)"
            rowSlider.value = Float(newValue)
        }
    }
    @IBAction func rowsChanged(sender: UISlider) {
        rows = Int(sender.value)
        Settings().rows = rows
        Settings().changed = true
    }
    var score: Int {
        get { return self.score }
        set { self.score = newValue }
    }
    var redBlockOn: Bool {
        get { return redBlockSwitch.on }
        set { redBlockSwitch.on = newValue }
    }
    @IBAction func redBlockChanged(sender: UISwitch) {
        Settings().redBlockOn = redBlockOn
    }
    var soundOn: Bool {
        get { return soundSwitch.on }
        set { soundSwitch.on = newValue }
    }
    @IBAction func soundChanged(sender: UISwitch) {
        Settings().soundOn = soundOn
    }
    var soundChoice: Int {
        get { return soundChoiceSegControl.selectedSegmentIndex }
        set { soundChoiceSegControl.selectedSegmentIndex = newValue }
    }
    @IBAction func soundChoiceChanged(sender: UISegmentedControl) {
        Settings().soundChoice = soundChoice
    }
    var speed: Float {
        get { return speedSlider.value / 100.0}
        set {
            speedSlider.value = newValue * 100.0
            speedLabel.text = "\(Int(speedSlider.value))%"
        }
    }
    @IBAction func speedChanged(sender: UISlider) {
        speed = sender.value / 100.0
        Settings().speed = speed
    }
}

private extension String {
    func charAtIndex(index: Int) -> Character? {   //myString.characterAtIndex(0)!
        var cur = 0
        for char in self {
            if cur == index {
                return char
            }
            cur++
        }
        return nil
    }
    func intAtIndex(index: Int) -> Int? {   //"010".intAtIndex(1)! == 1
        var cur = 0
        for char in self {
            if cur == index {
                return String(char).toInt()
            }
            cur++
        }
        return nil
    }
}

