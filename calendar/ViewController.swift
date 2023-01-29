//
//  ViewController.swift
//  calendar
//
//  Created by 7080 on 2022/12/28.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    lazy var datePicker: UIDatePicker = {
        $0.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        $0.calendar = .current
        $0.timeZone = .current
        $0.locale = Locale(identifier: "zh_CN")
        $0.datePickerMode = .date
        return $0
    }(UIDatePicker())
    lazy var detailView: UIView = {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 15
        $0.layer.masksToBounds = true
        return $0
    }(UIView())
    lazy var number: UILabel = {
        $0.font = .systemFont(ofSize: 80, weight: .bold)
        $0.textAlignment = .center
        $0.backgroundColor = .systemGray4
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.textColor = .white
        return $0
    }(UILabel())
    lazy var solarCalendar: UILabel = {
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.textAlignment = .center
        $0.textColor = .white
        return $0
    }(UILabel())
    lazy var chineseZodiac: UILabel = {
        $0.font = .systemFont(ofSize: 44, weight: .bold)
        $0.textAlignment = .center
        $0.textColor = .white
        $0.backgroundColor = .red
        $0.layer.masksToBounds = true
        return $0
    }(UILabel())
    lazy var chineseCalendar: UILabel = {
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.textAlignment = .center
        $0.textColor = .white
        return $0
    }(UILabel())
    lazy var chineseCalendarYear: UILabel = {
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.textAlignment = .center
        $0.textColor = .white
        return $0
    }(UILabel())
    lazy var chineseCalendarMonth: UILabel = {
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.textAlignment = .center
        $0.textColor = .white
        return $0
    }(UILabel())
    lazy var chineseCalendarDay: UILabel = {
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.textAlignment = .center
        $0.textColor = .white
        return $0
    }(UILabel())
    
    let heavenlyStems       = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    let terrestrialBranch   = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
    let zodiacs             = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
    let chineseMonth        = ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"]
    let chineseDay          = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
                               "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                               "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
                
        view.addSubview(datePicker)
        datePicker.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.snp.topMargin)
        }
        
        view.addSubview(detailView)
        detailView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.snp.bottomMargin).inset(10)
            $0.height.equalTo(150)
        }
        
        detailView.addSubview(number)
        number.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview().inset(15)
            $0.width.equalTo(number.snp.height)
        }
        
        detailView.addSubview(solarCalendar)
        solarCalendar.snp.makeConstraints {
            $0.top.equalTo(number).offset(8)
            $0.left.equalTo(number.snp.right)
            $0.right.equalToSuperview()
            $0.height.equalTo(solarCalendar.font.lineHeight)
        }
        
        detailView.addSubview(chineseZodiac)
        chineseZodiac.snp.makeConstraints {
            $0.top.equalTo(solarCalendar.snp.bottom).offset(15)
            $0.left.equalTo(number.snp.right).offset(15)
            $0.bottom.equalToSuperview().inset(15)
            $0.width.equalTo(chineseZodiac.snp.height)
        }
        
        detailView.addSubview(chineseCalendar)
        chineseCalendar.snp.makeConstraints {
            $0.top.equalTo(chineseZodiac)
            $0.left.equalTo(chineseZodiac.snp.right)
        }
        
        detailView.addSubview(chineseCalendarYear)
        chineseCalendarYear.snp.makeConstraints {
            $0.top.equalTo(chineseCalendar)
            $0.left.equalTo(chineseCalendar.snp.right)
            $0.right.equalToSuperview()
            $0.width.height.equalTo(chineseCalendar)
        }
        
        detailView.addSubview(chineseCalendarMonth)
        chineseCalendarMonth.snp.makeConstraints {
            $0.top.equalTo(chineseCalendar.snp.bottom)
            $0.left.equalTo(chineseCalendar)
            $0.width.height.equalTo(chineseCalendar)
            $0.bottom.equalTo(chineseZodiac)
        }
        
        detailView.addSubview(chineseCalendarDay)
        chineseCalendarDay.snp.makeConstraints {
            $0.top.equalTo(chineseCalendarMonth)
            $0.right.equalTo(chineseCalendarYear)
            $0.left.equalTo(chineseCalendarMonth.snp.right)
            $0.height.equalTo(chineseCalendarMonth)
        }
        
        showDetailTime()
    }
    
    func dateToString(date: Date, dateFormat: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }
    
    func stringToDate(string: String, dateFormat: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.date(from: string)
    }
    
    func showDetailTime() {
        guard let date = stringToDate(string: dateToString(date: datePicker.date)) else { return }
        let dateComponents = Calendar.current.dateComponents([.era, .year, .month, .day], from: date)
        let chineseDateComponents = Calendar(identifier: .chinese).dateComponents([.year, .month, .day], from: date)
        
        guard let era = dateComponents.era, let year = dateComponents.year, let month = dateComponents.month, let day = dateComponents.day else { return }
        guard let zhYear = chineseDateComponents.year, let zhMonth = chineseDateComponents.month, let zhDay = chineseDateComponents.day else { return }
        
        number.text = String(format: "%02d", day)
        solarCalendar.text = (era == 1 ? "" : "公元前") + String(format: "%d年%02d月%02d日", year, month, day)
        chineseZodiac.text = zodiacs[(zhYear - 1) % 12]
        chineseCalendar.text = chineseMonth[zhMonth - 1] + chineseDay[zhDay - 1]
        chineseZodiac.superview?.layoutIfNeeded()
        chineseZodiac.layer.cornerRadius = chineseZodiac.frame.width / 2
        
        guard let solarTerms = GetAllSolarTermsJD(year, .SLIGHT_COLD) else { return }
        guard let springBegins = solarTerms.filter({ ($0.solarTerm == .SPRING_BEGINS) }).first else { return }
        
        // 以正月初一为始  干支纪年 （不精确）
//        chineseCalendarYear.text = heavenlyStems[(zhYear - 1) % 10] + terrestrialBranch[(zhYear - 1) % 12] + "年"
        // 以每年的立春为始  干支纪年
        guard let springBeginsDate = stringToDate(string: dateToString(date: springBegins.time)) else { return }
        var getFirst = dateComponents
        getFirst.month = 1
        getFirst.day = 1
        guard let firstDay = Calendar.current.date(from: getFirst) else { return }
        guard let lastYear = Calendar(identifier: .chinese).dateComponents([.year], from: firstDay).year else { return }
        var currentYear = DateComponents()
        currentYear.year = lastYear + 1
        currentYear.month = 1
        currentYear.day = 1
        guard let springFestival = Calendar(identifier: .chinese).date(from: currentYear) else { return }
        var zhCnYear = zhYear
        
        if springFestival < springBeginsDate {  // 先过春节
            if date >= springFestival, date < springBeginsDate {
                zhCnYear = zhYear - 1
            }
        } else if springFestival > springBeginsDate { // 先过立春
            if date >= springBeginsDate, date < springFestival {
                zhCnYear = zhYear + 1
            }
        } else if springFestival == springBeginsDate {  // 立春 和 春节 是同一天
            zhCnYear = zhYear
        }
        let heavenlyStemsIdx = (zhCnYear - 1) % 10
        let terrestrialBranchIdx = (zhCnYear - 1) % 12
        chineseCalendarYear.text = heavenlyStems[heavenlyStemsIdx] + terrestrialBranch[terrestrialBranchIdx] + "年"
        
        // 通过 年干支 计算出正月的 月干支， 后面月份依次累推
        let firstMonthHeavenlyStemsIdx = ((heavenlyStemsIdx % 5) * 12 + 2) % 10
        
        var monthNode = solarTerms.filter { $0.solarTerm.rawValue % 2 == 1 }
        let nodeDates = monthNode.compactMap { stringToDate(string: dateToString(date: $0.time)) }
        nodeDates.enumerated().forEach { monthNode[$0].time = $1 }
        
        guard let nextMonth = monthNode.filter({ $0.time > date }).first else { return }
        var nextMonthIdx = nextMonth.solarTerm.rawValue - 21
        if nextMonthIdx < 0 {
            nextMonthIdx += 24
        }
        nextMonthIdx /= 2
        var monthIdx = nextMonthIdx - 1
        if monthIdx < 0 {
            monthIdx += 12
        }
        
        let monthHeavenlyStemsIdx = (firstMonthHeavenlyStemsIdx + monthIdx) % 10
        let monthTerrestrialBranchIdx = (2 + monthIdx) % 12
        chineseCalendarMonth.text = heavenlyStems[monthHeavenlyStemsIdx] + terrestrialBranch[monthTerrestrialBranchIdx] + "月"
        
        // 高氏日柱公式   r = s / 4 * 6 + 5 * (s / 4 * 3 + u) + 30 * (pow(-1, m) + 1) / 2 + (3 * m - 7) / 5 + d + x
        /*
         各符号意义
         r：日柱的母数，r除以60的余数即是日柱的干支序列数；
         s：公元年数后两位数；
         u：s除以4的余数；
         m：月数
         d：日期数
         x：世纪常数
         为了简化闰日变量的复杂性，增强月基数的规律性，采用将闰日置后的方式进行求解。由于所有的闰日都加设在每个闰年的2月末尾，故可以采用将2月视为上一年的末月，即"14月"的方法，以消除闰日在日柱计算中的复杂插入。相应地，须将1月视为上一年的"13月"，而将每年的3月份视为本年的起始月
         
         比如 计算2008年的2月29日的当日日柱，在计算中应将这天视为2007年的14月29日。则有s=7；u=3；m=14；d=29；x=54，将各项数据代入高氏日柱公式可得：
         r=1×6+5×(1×3+3)+30×1+7+29+54=156
         故156除以60余数为36，即当日日柱为己亥。
         */
        
        // 世纪常数公式 X = 44 * (N - 1) + (N - 1) / 4 + 9
        // N为该年所属世纪数，X为世纪常数的母数。X 除以60的余数即为世纪常数
        
        var solarYear = year
        var solarMonth = month
        let solarDay = day
        if month < 3 {
            solarYear -= 1
            solarMonth += 12
        }
        
        guard let s = Int("\(solarYear)".suffix(2)) else { return }
        let u = s % 4
        let m = solarMonth
        let d = solarDay
        let x = 44 * (solarYear / 100 + 1 - 1) + (solarYear / 100 + 1 - 1) / 4 + 9
//        let r = s / 4 * 6 + 5 * (s / 4 * 3 + u) + 30 * (pow(-1, m) + 1) / 2 + (3 * m - 7) / 5 + d + x   // 新版 swift 不能写较长的计算式 拆分处理
        
        let sum1 = s / 4 * 6
        let sum2 = 5 * (s / 4 * 3 + u)
        let sum3 = 30 * (Int(pow(-1.0, Double(m))) + 1) / 2
        let sum4 = (3 * m - 7) / 5
        let r = sum1 + sum2 + sum3 + sum4 + d + x
        
        let solarDayIdx = r % 60
        let dayHeavenlyStemsIdx = (solarDayIdx - 1) % 10
        let dayTerrestrialBranchIdx = (solarDayIdx - 1) % 12
        chineseCalendarDay.text = heavenlyStems[dayHeavenlyStemsIdx] + terrestrialBranch[dayTerrestrialBranchIdx] + "日"
    }
    
    @objc func dateChanged() {
        showDetailTime()
    }
}

