//
//  Koyomi.swift
//  Pods
//
//  Created by Shohei Yokoyama on 2016/10/09.
//
//

import UIKit

@objc public protocol KoyomiDelegate: class {
    optional func koyomi(koyomi: Koyomi, didSelect date: NSDate, forItemAt indexPath: NSIndexPath)
    optional func koyomi(koyomi: Koyomi, currentDateString dateString: String)
}

public enum KoyomiStyle {
    case monotone, standard, red, orange, yellow, tealBlue, blue, purple, green, pink
    
    var colors: Koyomi.Colors {
        switch self {
        case monotone: return Koyomi.Colors(dayBackgrond: .whiteColor(), weekBackgrond: .whiteColor(), holiday: (UIColor.KoyomiColor.darkGray, UIColor.KoyomiColor.darkGray))
        case standard: return Koyomi.Colors(dayBackgrond: .whiteColor(), weekBackgrond: .whiteColor(), holiday: (UIColor.KoyomiColor.blue, UIColor.KoyomiColor.red))
        case red:      return Koyomi.Colors(dayBackgrond: .whiteColor(), weekBackgrond: UIColor.KoyomiColor.red, week: .whiteColor(), holiday: (UIColor.KoyomiColor.darkGray, UIColor.KoyomiColor.darkGray), separator: UIColor.KoyomiColor.red)
        case orange:   return Koyomi.Colors(dayBackgrond: .whiteColor(), weekBackgrond: UIColor.KoyomiColor.orange, week: .whiteColor(), holiday: (UIColor.KoyomiColor.darkGray, UIColor.KoyomiColor.darkGray), separator: UIColor.KoyomiColor.orange)
        case yellow:   return Koyomi.Colors(dayBackgrond: .whiteColor(), weekBackgrond: UIColor.KoyomiColor.yellow, week: .whiteColor(), holiday: (UIColor.KoyomiColor.darkGray, UIColor.KoyomiColor.darkGray), separator: UIColor.KoyomiColor.yellow)
        case tealBlue: return Koyomi.Colors(dayBackgrond: .whiteColor(), weekBackgrond: UIColor.KoyomiColor.tealBlue, week: .whiteColor(), holiday: (UIColor.KoyomiColor.darkGray, UIColor.KoyomiColor.darkGray), separator: UIColor.KoyomiColor.tealBlue)
        case blue:     return Koyomi.Colors(dayBackgrond: .whiteColor(), weekBackgrond: UIColor.KoyomiColor.blue, week: .whiteColor(), holiday: (UIColor.KoyomiColor.darkGray, UIColor.KoyomiColor.darkGray), separator: UIColor.KoyomiColor.blue)
        case purple:   return Koyomi.Colors(dayBackgrond: .whiteColor(), weekBackgrond: UIColor.KoyomiColor.purple, week: .whiteColor(), holiday: (UIColor.KoyomiColor.darkGray, UIColor.KoyomiColor.darkGray), separator: UIColor.KoyomiColor.purple)
        case green:    return Koyomi.Colors(dayBackgrond: .whiteColor(), weekBackgrond: UIColor.KoyomiColor.green, week: .whiteColor(), holiday: (UIColor.KoyomiColor.darkGray, UIColor.KoyomiColor.darkGray), separator: UIColor.KoyomiColor.green)
        case pink:     return Koyomi.Colors(dayBackgrond: .whiteColor(), weekBackgrond: UIColor.KoyomiColor.pink, week: .whiteColor(), holiday: (UIColor.KoyomiColor.darkGray, UIColor.KoyomiColor.darkGray), separator: UIColor.KoyomiColor.pink)
        }
    }
}

public enum SelectionStyle {
    case single, multiple, none
}

@IBDesignable
final public class Koyomi: UICollectionView {
    struct Colors {
        let dayBackgrond: UIColor
        let weekBackgrond: UIColor
        
        let week: UIColor
        let weekday: UIColor
        let holiday: (saturday: UIColor, sunday: UIColor)
        let otherMonth: UIColor
        
        let separator: UIColor
        
        init(dayBackgrond: UIColor, weekBackgrond: UIColor, week: UIColor = UIColor.KoyomiColor.black, weekday: UIColor = UIColor.KoyomiColor.black, holiday: (saturday: UIColor, sunday: UIColor) = (UIColor.KoyomiColor.blue, UIColor.KoyomiColor.red), otherMonth: UIColor = UIColor.KoyomiColor.lightGray, separator: UIColor = UIColor.KoyomiColor.lightGray) {
            self.dayBackgrond  = dayBackgrond
            self.weekBackgrond = weekBackgrond
            
            self.week = week
            self.weekday = weekday
            self.holiday.saturday = holiday.saturday
            self.holiday.sunday   = holiday.sunday
            self.otherMonth = otherMonth
            self.separator  = separator
        }
    }
    
    public var style: KoyomiStyle = .standard {
        didSet {
            dayBackgrondColor  = style.colors.dayBackgrond
            weekBackgrondColor = style.colors.weekBackgrond
            weekColor = style.colors.week
            weekdayColor    = style.colors.weekday
            holidayColor    = style.colors.holiday
            otherMonthColor = style.colors.otherMonth
            backgroundColor = style.colors.separator
            sectionSeparator.backgroundColor = style.colors.separator
        }
    }
    
    // use near future
    public var selectionStyle: SelectionStyle = .none {
        didSet {
            model.selectionStyle = {
                switch selectionStyle {
                case .single:   return .single
                case .multiple: return .multiple
                case .none:     return .none
                }
            }()
        }
    }
    
    // Layout properties
    @IBInspectable var sectionSpace: CGFloat = 1.5 {
        didSet {
            sectionSeparator.frame.size.height = sectionSpace
        }
    }
    @IBInspectable var cellSpace: CGFloat = 0.5 {
        didSet {
            if let layout = collectionViewLayout as? KoyomiLayout where layout.cellSpace != cellSpace {
                setCollectionViewLayout(self.layout, animated: false)
            }
        }
    }
    @IBInspectable var weekCellHeight: CGFloat = 25 {
        didSet {
            sectionSeparator.frame.origin.y = inset.top + weekCellHeight
            if let layout = collectionViewLayout as? KoyomiLayout where layout.weekCellHeight != weekCellHeight {
                setCollectionViewLayout(self.layout, animated: false)
            }
        }
    }
    public var inset: UIEdgeInsets = UIEdgeInsetsZero {
        didSet {
            if let layout = collectionViewLayout as? KoyomiLayout where layout.inset != inset {
                setCollectionViewLayout(self.layout, animated: false)
            }
        }
    }
    
    public var weeks: [String] = [] {
        didSet {
            model.weeks = weeks
            reloadData()
        }
    }
    @IBInspectable public var currentDateFormat: String = "M/yyyy"
    
    // Color properties of the appearance
    @IBInspectable public var sectionSeparatorColor: UIColor = UIColor.KoyomiColor.lightGray {
        didSet {
            sectionSeparator.backgroundColor = sectionSeparatorColor
        }
    }
    @IBInspectable public var separatorColor: UIColor = UIColor.KoyomiColor.lightGray {
        didSet {
            backgroundColor = separatorColor
        }
    }
    @IBInspectable public var weekColor       = UIColor.KoyomiColor.black
    @IBInspectable public var weekdayColor    = UIColor.KoyomiColor.black
    @IBInspectable public var otherMonthColor = UIColor.KoyomiColor.lightGray
    public var holidayColor: (saturday: UIColor, sunday: UIColor) = (UIColor.KoyomiColor.blue, UIColor.KoyomiColor.red)
    @IBInspectable public var dayBackgrondColor: UIColor  = .whiteColor()
    @IBInspectable public var weekBackgrondColor: UIColor = .whiteColor()
    
    @IBInspectable public var selectedBackgroundColor = UIColor.KoyomiColor.red
    @IBInspectable public var selectedTextColor: UIColor = .whiteColor()
    
    // KoyomiDelegate
    public weak var calenderDelegate: KoyomiDelegate?

    // Private properties
    private static let cellIdentifier = "KoyomiCell"
    
    private lazy var model: DateModel = .init()
    private let sectionSeparator: UIView = .init()
    
    private var layout: UICollectionViewLayout {
        return KoyomiLayout(inset: inset, cellSpace: cellSpace, sectionSpace: sectionSpace, weekCellHeight: weekCellHeight)
    }
    
    private var dayLabelFont: UIFont?
    private var weekLabelFont: UIFont?

    // MARK: - Initialization -

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
        collectionViewLayout = layout
    }
    
    public init(frame: CGRect, sectionSpace: CGFloat = 1.5, cellSpace: CGFloat = 0.5, inset: UIEdgeInsets = UIEdgeInsetsZero, weekCellHeight: CGFloat = 25) {
        super.init(frame: frame, collectionViewLayout: KoyomiLayout(inset: inset, cellSpace: cellSpace, sectionSpace: sectionSpace, weekCellHeight: weekCellHeight))
        self.sectionSpace = sectionSpace
        self.cellSpace = cellSpace
        self.inset = inset
        self.weekCellHeight = weekCellHeight
        configure()
    }
    
    // MARK: - Public Methods -
    
    public func display(in month: MonthType) {
        model.display(in: month)
        reloadData()
        calenderDelegate?.koyomi?(self, currentDateString: model.dateString(in: .current, withFormat: currentDateFormat))
    }
    
    public func setDayFont(fontName name: String = ".SFUIText-Medium", size: CGFloat) -> Self {
        dayLabelFont = UIFont(name: name, size: size)
        return self
    }
    
    public func setWeekFont(fontName name: String = ".SFUIText-Medium", size: CGFloat) -> Self {
        weekLabelFont = UIFont(name: name, size: size)
        return self
    }
    
    public func currentDateString(withFormat format: String = "M/yyyy") -> String {
        return model.dateString(in: .current, withFormat: format)
    }
    
    public func select(date date: NSDate, to toDate: NSDate? = nil) -> Self {
        model.select(from: date, to: toDate)
        return self
    }
    
    public func unselect(date date: NSDate, to toDate: NSDate? = nil) -> Self {
        model.unselect(from: date, to: toDate)
        return self
    }
    
    public func unselectAll() -> Self {
        model.unselectAll()
        return self
    }
    
    // MARK: - Override Method -
    
    override public func reloadData() {
        super.reloadData()
        setCollectionViewLayout(layout, animated: false)
    }
}

// MARK: - Private Methods -

private extension Koyomi {
    func configure() {
        delegate      = self
        dataSource    = self
        scrollEnabled = false
        
        backgroundColor = separatorColor
        
        registerClass(KoyomiCell.self, forCellWithReuseIdentifier: Koyomi.cellIdentifier)
        
        sectionSeparator.backgroundColor = sectionSeparatorColor
        sectionSeparator.frame = CGRect(x: inset.left, y: inset.top + weekCellHeight, width: frame.width - (inset.top + inset.left), height: sectionSpace)
        addSubview(sectionSeparator)
    }
    
    func configure(cell: KoyomiCell, at indexPath: NSIndexPath) {
        
        cell.content = indexPath.section == 0 ? model.weeks[indexPath.row] : model.dayString(at: indexPath)
        cell.backgroundColor = weekBackgrondColor
        if indexPath.section == 0 {
            cell.textColor = weekColor
            if let font = weekLabelFont {
                cell.setContentFont(fontName: font.fontName, size: font.pointSize)
            }
        } else {
            
            (cell.textColor, cell.backgroundColor) = {
                if model.isSelect(with: indexPath) {
                    return (selectedTextColor, selectedBackgroundColor)
                } else if indexPath.row < model.indexAtBeginning(in: .current) || indexPath.row > model.indexAtEnd(in: .current) {
                    return (otherMonthColor, dayBackgrondColor)
                } else if indexPath.row % 7 == 0 {
                    return (holidayColor.sunday, dayBackgrondColor)
                } else if indexPath.row % 7 == 6 {
                    return (holidayColor.saturday, dayBackgrondColor)
                } else {
                    return (weekdayColor, dayBackgrondColor)
                }
            }()
            
            if let font = dayLabelFont {
                cell.setContentFont(fontName: font.fontName, size: font.pointSize)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate -

extension Koyomi: UICollectionViewDelegate {
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        calenderDelegate?.koyomi?(self, didSelect: model.date(at: indexPath), forItemAt: indexPath)
    }
}

// MARK: - UICollectionViewDataSource -

extension Koyomi: UICollectionViewDataSource {
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? DateModel.dayCountPerRow : DateModel.maxCellCount
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Koyomi.cellIdentifier, forIndexPath: indexPath) as! KoyomiCell
        configure(cell, at: indexPath)
        return cell
    }
}

