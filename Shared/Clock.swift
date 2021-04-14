//
//  FigmaClock.swift
//  Timer3000
//
//  Created by Jonas Kaiser on 10.04.21.
//

import SwiftUI

struct Clock<M: ClockViewModelProtocol>: View {
    @ObservedObject var model: M
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(#colorLiteral(red: 0.14166666567325592, green: 0.14166666567325592, blue: 0.14166666567325592, alpha: 1)))
                .frame(width: 700, height: 500)
            
            Circle()
                .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.4))
                .frame(width: model.seconds_circle_radius * 2, height: model.seconds_circle_radius * 2, alignment: .center)
            
            Circle()
                .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.4))
                .frame(width: model.minutes_circle_radius * 2, height: model.minutes_circle_radius * 2, alignment: .center)
            
            Button(action: {
                model.mute_unmute()
            }) {
                
                Image(systemName: model.speaker_image)
                    .foregroundColor(.white)
                    .font(.largeTitle)
                
            }
            .buttonStyle(PlainButtonStyle())
            .offset(x: -300, y: -200)
            
            
            
                Button(action: {
                    model.timer_start_stop()
                    print("\(model.paused)")
                }) {
                    ZStack {
                        Circle()
                            .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.4))
                            .frame(width: model.hours_circle_radius * 2, height: model.hours_circle_radius * 2, alignment: .center)
                            
                        VStack {
                            Text(String(format: "%02d:%.02d:%02d", model.hours_left_int, model.minutes_left_int, model.seconds_left_int))
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .font(.custom("SF Pro Display", size: 45))
                            
                            Text(model.start_pause)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .font(.custom("SF Pro Display", size: 20))
                        }
                    }
                }.buttonStyle(PlainButtonStyle())
            
// MARK: Minutes Slider Circle
            
            Group {
            
                Circle()
                    .stroke(Color.gray, style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [3, 23.18]))
                    .frame(width: model.minutes_circle_radius * 2, height: model.minutes_circle_radius * 2)
            
                Circle()
                    .trim(from: 0.0, to:  CGFloat(model.minutes_left_int) / model.minutes_total_double)
                    .stroke(Color.white, lineWidth: 5.0)
                    .foregroundColor(Color(red: 0, green: 0.1, blue: 0.3, opacity: 0.5))
                    .frame(width: model.minutes_circle_radius * 2, height: model.minutes_circle_radius * 2, alignment: .center)
                    .rotationEffect(.degrees(-90))
            
                Circle()
                    .fill(Color.white)
                    .frame(width: model.knob_radius * 2, height: model.knob_radius * 2)
                    .padding(10)
                    .offset(y: -model.minutes_circle_radius)
                    .rotationEffect(Angle.degrees(Double(model.minutes_knob_angle)))
                    .gesture(DragGesture(minimumDistance: 0.0)
                                .onChanged({ value in
                                    model.slider_change(location: value.location, unit: .minute)
                                }))
                
            }
            
// MARK: Hours Slider Circle
            Group {
            
                Circle()
                    .stroke(Color.gray, style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [3, 23.18]))
                    .frame(width: model.hours_circle_radius * 2, height: model.hours_circle_radius * 2)
            
                Circle()
                    .trim(from: 0.0, to:  CGFloat(model.hours_left_int) / model.hours_total_double)
                    .stroke(Color.white, lineWidth: 5.0)
                    .foregroundColor(Color(red: 0, green: 0.1, blue: 0.3, opacity: 0.5))
                    .frame(width: model.hours_circle_radius * 2, height: model.hours_circle_radius * 2, alignment: .center)
                    .rotationEffect(.degrees(-90))
            
                Circle()
                    .fill(Color.white)
                    .frame(width: model.knob_radius * 2, height: model.knob_radius * 2)
                    .padding(10)
                    .offset(y: -model.hours_circle_radius)
                    .rotationEffect(Angle.degrees(Double(model.hours_knob_angle)))
                    .gesture(DragGesture(minimumDistance: 0.0)
                                .onChanged({ value in
                                    model.slider_change(location: value.location, unit: .hour)
                                }))
            }
            
// MARK: Seconds Slider Circle
            
            Group {
            
                Circle()
                    .stroke(Color.gray, style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [3, 23.18]))
                    .frame(width: model.seconds_circle_radius * 2, height: model.seconds_circle_radius * 2)
            
                Circle()
                    .trim(from: 0.0, to:  CGFloat(model.seconds_left_int) / model.seconds_total_double)
                    .stroke(Color.white, lineWidth: 5.0)
                    .foregroundColor(Color(red: 0, green: 0.1, blue: 0.3, opacity: 0.5))
                    .frame(width: model.seconds_circle_radius * 2, height: model.seconds_circle_radius * 2, alignment: .center)
                    .rotationEffect(.degrees(-90))
            
                Circle()
                    .fill(Color.white)
                    .frame(width: model.knob_radius * 2, height: model.knob_radius * 2)
                    .padding(10)
                    .offset(y: -model.seconds_circle_radius)
                    .rotationEffect(Angle.degrees(Double(model.seconds_knob_angle)))
                    .gesture(DragGesture(minimumDistance: 0.0)
                                .onChanged({ value in
                                    model.slider_change(location: value.location, unit: .second)
                                }))
                
            }
            
            }
        .onAppear() {
            model.get_defaults()
        }
        
    }
}

struct FigmaClock_Previews: PreviewProvider {
    static var previews: some View {
        Clock(model: ClockViewModel())
    }
}
