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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityMonitor: UIActivityIndicatorView!

    // picker constants
    let continentPicks: [ChallengeSet] = [.northAmerica, .southAmerica, .africa, .asia, .oceania, .europe]
    let monthPicks: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let yearPicks: [Int] = {
        var result: [Int] = []
        let year = Calendar.current.component(.year, from: Date())
        for n in 2019 ..< year+1 { result.append(n) }
        return result
    }()

    var minMonth: Date!
    private var activitiesInFlight = 0

    // tableview constants
    let cellReuseIdentifier = "leaderboardCell"

    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 90
        minMonth = startOfMonth(year: 2019, month: 4) // we didn't collect stats before this
    }

    override func viewWillAppear(_ animated: Bool) {
        pickerView.selectRow(3, inComponent: 0, animated: false) // min month
        pickerView.selectRow(0, inComponent: 1, animated: false) // min year
        pickerView.selectRow(500, inComponent: 2, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = yearPicks.last!
        let currentContinent = continentPicks[500 % continentPicks.count]
        pickerView.selectRow(currentMonth - 1, inComponent: 0, animated: true) // most recent month
        pickerView.selectRow(yearPicks.count - 1, inComponent: 1, animated: true) // most recent year
        pickerView.selectRow(500, inComponent: 2, animated: true) // somewhere in the middle
        showActivity(true)
        LeaderboardDataCache.shared.fetch(month: currentMonth, year: currentYear, continent: currentContinent) { success in
            self.showActivity(false)
            self.tableView.reloadData()
        }
    }

    private func showActivity(_ active: Bool){
        activitiesInFlight = activitiesInFlight + ( active ? 1 : -1 )
        let animate = activitiesInFlight > 0
        activityMonitor.isHidden = !animate
        animate ? activityMonitor.startAnimating() : activityMonitor.stopAnimating()
    }
}

// MARK: TableViewDelegate
extension LeaderboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        LeaderboardDataCache.shared.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! LeaderboardCell
        cell.set(scoreRow: LeaderboardDataCache.shared.data[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = tableView.frame.size.height
        let contentYoffset = tableView.contentOffset.y
        let distanceFromBottom = tableView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            showActivity(true)
            LeaderboardDataCache.shared.fetchNextPage() { success in
                self.showActivity(false)
                guard success else { return }
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: PickerViewDelegate
extension LeaderboardViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let monthIndex = pickerView.selectedRow(inComponent: 0)
        let year = yearPicks[pickerView.selectedRow(inComponent: 1)]
        let selected = startOfMonth(year: year, month: monthIndex + 1)
        let continent = continentPicks[pickerView.selectedRow(inComponent: 2) % continentPicks.count]

        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        let maxAllowed = startOfMonth(year: currentYear, month: currentMonth + 1)

        guard selected < maxAllowed else {
            pickerView.selectRow(currentMonth - 1, inComponent: 0, animated: true) // most recent month
            pickerView.selectRow(yearPicks.count - 1, inComponent: 1, animated: true) // most recent year
            showActivity(true)
            return LeaderboardDataCache.shared.fetch(month: currentMonth, year: currentYear, continent: continent) { success in
                self.showActivity(false)
                self.tableView.reloadData()
            }
        }
        guard selected >= minMonth else {
            pickerView.selectRow(3, inComponent: 0, animated: true) // min month
            pickerView.selectRow(0, inComponent: 1, animated: true) // min year
            showActivity(true)
            return LeaderboardDataCache.shared.fetch(month: 4, year: 2019, continent: continent) { success in
                self.showActivity(false)
                self.tableView.reloadData()
            }
        }

        showActivity(true)
        LeaderboardDataCache.shared.fetch(month: monthIndex+1, year: year, continent: continent) { success in
            self.showActivity(false)
            self.tableView.reloadData()
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 3 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return monthPicks.count
        case 1: return yearPicks.count
        default: return 1000
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return monthPicks[row]
        case 1: return String(yearPicks[row])
        default: return continentPicks[row % continentPicks.count].rawValue
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
            let continent = continentPicks[row % continentPicks.count]
            let imageView = UIImageView(frame: contentFrame)
            imageView.contentMode = .scaleAspectFit
            imageView.image = continent.toPickerImage()
            element.addSubview(imageView)
        } else {
            let label = UILabel(frame: contentFrame)
            let text = component == 1 ? String(yearPicks[row]) : monthPicks[row]
            let textAttrs = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIConstants.amaticBold(size: 35)]
            label.attributedText = NSAttributedString(string: text, attributes: textAttrs)
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
