//
//  Extensions.swift
//  TodoApp
//
//  Created by sergey on 28.02.2021.
//

import Foundation
import UIKit
import SwiftUI

extension UIFont {
    var suiFont: Font {
        return Font(self as CTFont)
    }
}

extension View {
    func left() -> some View {
        HStack {
            self
            Spacer()
        }
    }
    func right() -> some View {
        HStack {
            Spacer()
            self
        }
    }
    func top() -> some View {
        VStack {
            self
            Spacer()
        }
    }
    func bottom() -> some View {
        VStack {
            Spacer()
            self
        }
    }
    func topLeft() -> some View {
        VStack {
            HStack {
                self
                Spacer()
            }
            Spacer()
        }
    }
    func topRight() -> some View {
        VStack {
            HStack {
                Spacer()
                self
            }
            Spacer()
        }
    }
    func bottomLeft() -> some View {
        VStack {
            Spacer()
            HStack {
                self
                Spacer()
            }
        }
    }
    func bottomRight() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                self
            }
        }
    }


}
