//
//  ClockViewModel.swift
//  Timer3000
//
//  Created by Jonas Kaiser on 10.04.21.
//

import SwiftUI
import Foundation
import AVFoundation
import UserNotifications

class ClockViewModel: ClockViewModelProtocol {
    @Published var seconds_left_double: CGFloat = 0.0
    var seconds_left_int: Int {
        let left = Int(round(seconds_left_double))
        return left == 60 ? 0 : left
    }
    var seconds_knob_angle: CGFloat {
        ((CGFloat(seconds_left_int) / seconds_total_double) * (2.0 * .pi) * 180) / .pi
    }
    var seconds_total_double: CGFloat = 60.0
    var seconds_circle_radius: CGFloat = 210.0
    
    
    @Published var hours_left_double: CGFloat = 0.0
    var hours_left_int: Int {
        let left = Int(round(hours_left_double))
        return left == 24 ? 0 : left
    }
    var hours_knob_angle: CGFloat {
        ((CGFloat(hours_left_int) / hours_total_double) * (2.0 * .pi) * 180) / .pi
    }
    var hours_total_double: CGFloat = 24.0
    var hours_circle_radius: CGFloat = 130.0
    
    @Published var minutes_left_double: CGFloat = 0.0
    var minutes_left_int: Int {
        let left = Int(round(minutes_left_double))
        return left == 60 ? 0 : left
    }
    var minutes_knob_angle: CGFloat {
        ((CGFloat(minutes_left_int) / minutes_total_double) * (2.0 * .pi) * 180) / .pi
    }
    let minutes_total_double: CGFloat = 60.0
    let minutes_circle_radius: CGFloat = 170.0
    
    let minimum_value: CGFloat = 0.0
    let knob_radius: CGFloat = 15.0
    
    var reset_time: (Int, Int, Int) = (0, 0, 0)
    
    
    @Published var paused: Bool = true
    var start_pause: String {
        paused ? "Start" : "Pause"
    }

    @Published var mute: Bool = true
    var speaker_image: String  {
        mute ? "speaker.slash.fill" : "speaker.wave.2.fill"
    }
    var reset: String = "gobackward"
    
    
    var the_timer = Timer()

    let center = UNUserNotificationCenter.current()
    let defaults = UserDefaults.standard
    
    public func slider_change(location: CGPoint, unit: Time_Unit) {
        if (!paused) {
            return
        }
        var total: CGFloat
        
        switch (unit) {
        case .minute:
            total = minutes_total_double
            break
        case .second:
            total = seconds_total_double
            break
        case .hour:
            total = hours_total_double
            break
        }
        
        // creating vector from location point
        let vector = CGVector(dx: location.x, dy: location.y)
        
        // geting angle in radian need to subtract the knob radius and padding
        let angle = atan2(vector.dy - (knob_radius + 10), vector.dx - (knob_radius + 10)) + .pi/2.0
        
        // convert angle range from (-pi to pi) to (0 to 2pi)
        let fixedAngle = angle < 0.0 ? angle + 2.0 * .pi : angle
        // convert angle value to time value
        let value = (fixedAngle / (2.0 * .pi)) * total
        
        if value >= minimum_value && value <= total {
            switch (unit) {
            case .minute:
                minutes_left_double = value
                break
            case .second:
                seconds_left_double = value
                break
            case .hour:
                hours_left_double = value
                break
            }
        }
        self.reset_time = (hours_left_int, minutes_left_int, seconds_left_int)
    }
    
    private func stopwatch_start_stop() {
        print("test1")
        if (!paused) {
            Timer.every(1.second) { (timer: Timer) in
                self.the_timer = timer
                print("Stopwatch starts.")
                
                if self.seconds_left_int == 59 && self.minutes_left_int == 59 && self.hours_left_int == 23 {
                    self.the_timer.invalidate()
                } else if self.minutes_left_int == 59 && self.seconds_left_int == 59 {
                    self.seconds_left_double = 0
                    self.minutes_left_double = 0
                    self.hours_left_double += 1
                } else if self.seconds_left_int == 59 {
                    self.seconds_left_double = 0
                    self.minutes_left_double += 1
                } else {
                    self.seconds_left_double += 1
                }
            }
        } else { self.the_timer.invalidate() }
    }
    
    public func timer_start_stop() {
        paused.toggle()
        
        request_notifications()
        
        let synthesizer = AVSpeechSynthesizer()
        
        print(reset_time)
        
        if reset_time == (0, 0, 0) {
            stopwatch_start_stop()
            return
        }
        
        if (!paused) {
            var boolStart: Bool = true
            
            Timer.every(1.second) { (timer: Timer) in
                self.the_timer = timer
                print("\(self.hours_left_int), \(self.minutes_left_int) minutes an \(self.seconds_left_int) seconds left")
                
                if (self.seconds_left_int == 0) {
                    if (self.minutes_left_int == 0) {
                        if (self.hours_left_int == 0) {
                            self.the_timer.invalidate()
                            self.showNotification()
                            
                            if !self.mute && !boolStart {
                                let speaker_sentence = self.build_sentence("Your time is up!")
                                synthesizer.speak(speaker_sentence)
                            }
                            
                            self.paused = true
                            return
                        }
                        if !self.mute && !boolStart {
                            let speaker_sentence = self.build_sentence("You have \(self.hours_left_int == 0 ? "\(self.minutes_left_int) minutes left." : "\(self.hours_left_int) \(self.hours_left_int == 1 ? "hour" : "hours") left.")")
                            synthesizer.speak(speaker_sentence)
                        }
                        
                        self.hours_left_double -= 1
                        self.minutes_left_double = 59.0
                    } else {
                        if !self.mute && !boolStart && self.hours_left_int == 0 && (self.minutes_left_int == 30 || self.minutes_left_int == 10) {
                            let speaker_sentence = self.build_sentence("You have \(self.hours_left_int == 0 ? "\(self.minutes_left_int) minutes left." : "\(self.hours_left_int) \(self.hours_left_int == 1 ? "hour" : "hours") left.")")
                            synthesizer.speak(speaker_sentence)
                        }
                        self.minutes_left_double -= 1
                    }
                    self.seconds_left_double = 59.0
                } else { self.seconds_left_double -= 1 }
                
                boolStart = false
            }
        } else { self.the_timer.invalidate() }
    }
    
    public func mute_unmute() {
        mute.toggle()
        defaults.set(mute, forKey: "mute_default")
    }
    
    public func reset_timer() {
        if (!paused) { return }
        
        self.hours_left_double = CGFloat(self.reset_time.0)
        self.minutes_left_double = CGFloat(self.reset_time.1)
        self.seconds_left_double = CGFloat(self.reset_time.2)
    }
    
    public func get_defaults() {
        mute = defaults.bool(forKey: "mute_default")
    }
    
    
    
    
    
    private func showNotification() {
        let content = UNMutableNotificationContent()
        if reset_time.0 == 0 && reset_time.1 == 0 {
            content.title = "\(reset_time.2 == 1 ? "The second has" : "\(reset_time.2) seconds have") passed."
        } else if reset_time.0 == 0 {
            content.title = "\(reset_time.1 == 1 ? "The minute" : "\(reset_time.1) minutes") and \(reset_time.2) \(reset_time.2 == 1 ? "second has" : "seconds have") passed."
        } else {
            content.title = "\(reset_time.0 == 1 ? "The hour" : "\(reset_time.0) hours"), \(reset_time.1) \(reset_time.1 == 1 ? "minute" : "minutes") and \(reset_time.2) \(reset_time.2 == 1 ? "second has" : "seconds have") passed."
        }

        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.001, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    private func request_notifications() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Notifications allowed!")
            } else {
                print("Notifications disabled!")
            }
        }
    }
    
    private func build_sentence(_ s: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: s)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.3
        return utterance
    }
}

