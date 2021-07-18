//
//  ClockViewModelProtocol.swift
//  Timer3000
//
//  Created by Jonas Kaiser on 10.04.21.
//

import SwiftUI

enum Time_Unit {
    case minute
    case second
    case hour
}

protocol ClockViewModelProtocol: ObservableObject {
    var minutes_left_double: CGFloat { get set }
    var minutes_left_int: Int { get }
    var minutes_knob_angle: CGFloat { get }
    var minutes_total_double: CGFloat { get }
    var minutes_circle_radius: CGFloat { get }
    
    var seconds_left_double: CGFloat { get set }
    var seconds_left_int: Int { get }
    var seconds_knob_angle: CGFloat { get }
    var seconds_total_double: CGFloat { get }
    var seconds_circle_radius: CGFloat { get }
    
    var hours_left_double: CGFloat { get set }
    var hours_left_int: Int { get }
    var hours_knob_angle: CGFloat { get }
    var hours_total_double: CGFloat { get }
    var hours_circle_radius: CGFloat { get }
    
    var minimum_value: CGFloat { get }
    var knob_radius: CGFloat { get }
    
    var paused: Bool { get set }
    var start_pause: String { get }
    
    var speaker_image: String { get }
    var reset: String { get }
    var reset_time: (Int, Int, Int) { get set }
    
    func slider_change(location: CGPoint, unit: Time_Unit)
    
    func timer_start_stop()
    
    func mute_unmute()
    
    func reset_timer()
    
    func get_defaults()
}
