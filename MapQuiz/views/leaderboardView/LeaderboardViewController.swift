//
//  LeaderboardViewController.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 24/1/20.
//  Copyright © 2020 Phosphorous Labs. All rights reserved.
//

import UIKit

class LeaderboardViewController: UIViewController {

    @IBOutlet weak var pickerView: UIPickerView!

    let continentPicks: [Continent] = [.northAmerica, .southAmerica, .africa, .asia, .oceania, .europe]
    let monthPicks: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let yearPicks: [Int] = {
        var result: [Int] = []
        let year = Calendar.current.component(.year, from: Date())
        for n in 2019 ..< year+1 { result.append(n) }
        return result.reversed()
    }()

    var minMonth: Date!

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        minMonth = startOfMonth(year: 2019, month: 4) // we didn't collect stats before this
    }
}

// MARK: PickerViewDelegate
extension LeaderboardViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let monthIndex = pickerView.selectedRow(inComponent: 0)
        let year = yearPicks[pickerView.selectedRow(inComponent: 1)]
        let selected = startOfMonth(year: year, month: monthIndex + 1)

        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        let maxAllowed = startOfMonth(year: currentYear, month: currentMonth + 1)

        guard selected < maxAllowed else {
            pickerView.selectRow(currentMonth - 1, inComponent: 0, animated: true) // most recent month
            return pickerView.selectRow(0, inComponent: 1, animated: true) // most recent year
        }
        guard selected >= minMonth else {
            pickerView.selectRow(3, inComponent: 0, animated: true) // min month
            return pickerView.selectRow(yearPicks.count - 1, inComponent: 1, animated: true) // min year
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 3 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return monthPicks.count
        case 1: return yearPicks.count
        default: return continentPicks.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return monthPicks[row]
        case 1: return String(yearPicks[row])
        default: return continentPicks[row].toString()
        }
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat { return 80 }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        let width = pickerView.bounds.width
        let height = pickerView.bounds.height/2
        let x = width/3 * CGFloat(component)
        let element = UIView(frame: CGRect(x: x, y: 0, width: width/3, height: height))
        let contentFrame = CGRect(x: 0, y: 0, width: width/3, height: height)

        if component == 2 {
            let continent = continentPicks[row]
            let imageView = UIImageView(frame: contentFrame)
            imageView.contentMode = .scaleAspectFit
            imageView.image = continent.toPickerImage()
            element.addSubview(imageView)
        } else {
            let label = UILabel(frame: contentFrame)
            label.text = component == 1 ? String(yearPicks[row]) : monthPicks[row]
            label.font = UIConstants.amaticBold(size: 35)
            label.textAlignment = .center
            element.addSubview(label)
        }

        return element
    }

    private func startOfMonth(year: Int, month: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = 0
        dateComponents.timeZone = TimeZone(abbreviation: "UTC")
        dateComponents.hour = 0
        dateComponents.minute = 0
        return Calendar.current.date(from: dateComponents)!
    }
}
