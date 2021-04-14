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
        Int(round(seconds_left_double))
    }
    
    var seconds_knob_angle: CGFloat {
        ((seconds_left_double / seconds_total_double - 1) * (2.0 * .pi) * 180) / .pi
    }
    
    var seconds_total_double: CGFloat = 59.0
    
    var seconds_circle_radius: CGFloat = 210.0
    
    @Published var hours_left_double: CGFloat = 0.0
    var hours_left_int: Int {
        Int(round(hours_left_double))
    }
    
    var hours_knob_angle: CGFloat {
        ((hours_left_double / hours_total_double - 1) * (2.0 * .pi) * 180) / .pi
    }
    
    var hours_total_double: CGFloat = 23.0
    
    var hours_circle_radius: CGFloat = 130.0
    
    @Published var minutes_left_double: CGFloat = 0.0
    var minutes_left_int: Int {
        Int(round(minutes_left_double))
    }
    var minutes_knob_angle: CGFloat {
        ((minutes_left_double / minutes_total_double - 1) * (2.0 * .pi) * 180) / .pi
    }
    @Published var paused: Bool = true
    var start_pause: String {
        paused ? "Start" : "Pause"
    }
    
    var seconds: Int = 0
    var the_timer = Timer()
    
    var speaker_image: String  {
        mute ? "speaker.slash.fill" : "speaker.wave.2.fill"
    }
    
    @Published var mute: Bool = true
    
    let minimum_value: CGFloat = 0.0
    let minutes_total_double: CGFloat = 59.0
    let knob_radius: CGFloat = 15.0
    let minutes_circle_radius: CGFloat = 170.0
    
    let center = UNUserNotificationCenter.current()
    
    let defaults = UserDefaults.standard
    
    public func minutes_slider_change(location: CGPoint) {
        if (!paused) {
            return
        }
        
        // creating vector from location point
        let vector = CGVector(dx: location.x, dy: location.y)
        
        // geting angle in radian need to subtract the knob radius and padding
        let angle = atan2(vector.dy - (knob_radius + 10), vector.dx - (knob_radius + 10)) + .pi/2.0
        
        // convert angle range from (-pi to pi) to (0 to 2pi)
        let fixedAngle = angle < 0.0 ? angle + 2.0 * .pi : angle
        // convert angle value to time value
        let value = (fixedAngle / (2.0 * .pi)) * minutes_total_double
        
        if value >= minimum_value && value <= minutes_total_double {
            minutes_left_double = value
        }
    }
    
    public func hours_slider_change(location: CGPoint) {
        if (!paused) {
            return
        }
        
        // creating vector from location point
        let vector = CGVector(dx: location.x, dy: location.y)
        
        // geting angle in radian need to subtract the knob radius and padding
        let angle = atan2(vector.dy - (knob_radius + 10), vector.dx - (knob_radius + 10)) + .pi/2.0
        
        // convert angle range from (-pi to pi) to (0 to 2pi)
        let fixedAngle = angle < 0.0 ? angle + 2.0 * .pi : angle
        // convert angle value to time value
        let value = (fixedAngle / (2.0 * .pi)) * hours_total_double
        
        if value >= minimum_value && value <= hours_total_double {
            hours_left_double = value
        }
    }
    
    public func seconds_slider_change(location: CGPoint) {
        if (!paused) {
            return
        }
        
        // creating vector from location point
        let vector = CGVector(dx: location.x, dy: location.y)
        
        // geting angle in radian need to subtract the knob radius and padding
        let angle = atan2(vector.dy - (knob_radius + 10), vector.dx - (knob_radius + 10)) + .pi/2.0
        
        // convert angle range from (-pi to pi) to (0 to 2pi)
        let fixedAngle = angle < 0.0 ? angle + 2.0 * .pi : angle
        // convert angle value to time value
        let value = (fixedAngle / (2.0 * .pi)) * seconds_total_double
        
        if value >= minimum_value && value <= seconds_total_double {
            seconds_left_double = value
        }
    }
    
    public func timer_start_stop() {
        if (minutes_left_double > 0 || seconds_left_double > 0 || hours_left_double > 0) {
            paused.toggle()
        } else {
            paused = true
            return
        }
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Notifications allowed!")
            } else {
                print("Notifications disabled!")
            }
        }
        
        var utterance = AVSpeechUtterance(string: "You have \(self.hours_left_int == 0 ? "\(self.minutes_left_int) minutes left." : "\(self.hours_left_int) \(self.hours_left_int == 1 ? "hour" : "hours") left.")")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.3
        let synthesizer = AVSpeechSynthesizer()
        
        
        if (!paused) {
            Timer.every(1.second) { (timer: Timer) in
                self.the_timer = timer
                print("\(self.hours_left_int), \(self.minutes_left_int) minutes an \(self.seconds_left_int) seconds left")
                
                if (self.seconds_left_int == 0) {
                    if (self.minutes_left_int == 0) {
                        if (self.hours_left_int == 0) {
                            self.the_timer.invalidate()
                            self.showNotification()
                            
                            if !self.mute {
                                utterance = AVSpeechUtterance(string: "Your time is up!")
                                utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                                utterance.rate = 0.3
                                synthesizer.speak(utterance)
                            }
                            
                            self.paused = true
                            return
                        }
                        if !self.mute { synthesizer.speak(utterance) }
                        
                        self.hours_left_double -= 1
                        self.minutes_left_double = 59.0
                    } else {
                        if (self.hours_left_int == 0 && (self.minutes_left_int == 30 || self.minutes_left_int == 10)) {
                            if !self.mute { synthesizer.speak(utterance) }
                        }
                        self.minutes_left_double -= 1
                    }
                    
                    self.seconds_left_double = 59.0
                } else {
                    self.seconds_left_double -= 1
                }
                
            }
        } else {
            self.the_timer.invalidate()
        }
    }
    
    public func mute_unmute() {
        mute.toggle()
        defaults.set(mute, forKey: "mute_default")
    }
    
    public func get_defaults() {
        mute = defaults.bool(forKey: "mute_default")
    }
    
    private func showNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Your time is up!"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.001, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
}

