//
//  EXReactive.swift
//  BFrameTestroject
//
//  Created by paololee on 11/19/25.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIColorWell {
    /// UIColorWell의 색이 변경될 때 이벤트를 방출하는 ControlEvent<UIColor?>
    var colorDidChange: ControlEvent<UIColor?> {
        // UIControl.Event.valueChanged 사용
        let source = controlEvent(.valueChanged)
            .map { [weak base] in
                return base?.selectedColor
            }
        return ControlEvent(events: source)
    }

    /// UIColorWell의 색을 바인딩할 수 있는 Binder
    var selectedColor: Observable<UIColor?> {
        return controlEvent(.valueChanged)
            .map { [weak base] in base?.selectedColor }
            .startWith(base.selectedColor)
    }
    
//    /// UIColorWell의 색을 바인딩할 수 있는 Binder
//    var selectedColor: Binder<UIColor?> {
//        return Binder(self.base) { colorWell, color in
//            colorWell.selectedColor = color
//        }
//    }
}
