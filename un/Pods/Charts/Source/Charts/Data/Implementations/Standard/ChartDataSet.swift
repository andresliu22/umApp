//
//  ChartDataSet.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

/// Determines how to round DataSet index values for `ChartDataSet.entryIndex(x, rounding)` when an exact x-value is not found.
@objc
public enum ChartDataSetRounding: Int
{
    case up = 0
    case down = 1
    case closest = 2
}

/// The DataSet class represents one group or type of entries (Entry) in the Chart that belong together.
/// It is designed to logically separate different groups of values inside the Chart (e.g. the values for a specific line in the LineChart, or the values of a specific group of bars in the BarChart).
open class ChartDataSet: ChartBaseDataSet
{
    public required init()
    {
        values = []
        
        super.init()
    }
    
    public override init(label: String)
    {
        values = []
        
        super.init(label: label)
    }
    
    @objc public init(values: [ChartDataEntry], label: String)
    {
        self.values = values
        super.init(label: label)
        
        self.calcMinMax()
    }
    
    @objc public convenience init(values: [ChartDataEntry])
    {
        self.init(values: values, label: "DataSet")
    }
    
    // MARK: - Data functions and accessors
    
    /// *
    /// - note: Calls `notifyDataSetChanged()` after setting a new value.
    /// - returns: The array of y-values that this DataSet represents.
    /// the entries that this dataset represents / holds together
    @objc open var values: [ChartDataEntry]
        {
        didSet
        {
            if isIndirectValuesCall {
                isIndirectValuesCall = false
                return
            }
            notifyDataSetChanged()
        }
    }

    // TODO: Temporary fix for performance. Will be removed in 4.0
    private var isIndirectValuesCall = false

    /// maximum y-value in the value array
    internal var _yMax: Double = -Double.greatestFiniteMagnitude
    
    /// minimum y-value in the value array
    internal var _yMin: Double = Double.greatestFiniteMagnitude
    
    /// maximum x-value in the value array
    internal var _xMax: Double = -Double.greatestFiniteMagnitude
    
    /// minimum x-value in the value array
    internal var _xMin: Double = Double.greatestFiniteMagnitude
    
    open override func calcMinMax()
    {
        _yMax = -Double.greatestFiniteMagnitude
        _yMin = Double.greatestFiniteMagnitude
        _xMax = -Double.greatestFiniteMagnitude
        _xMin = Double.greatestFiniteMagnitude

        guard !values.isEmpty else { return }

        values.forEach { calcMinMax(entry: $0) }
    }
    
    open override func calcMinMaxY(fromX: Double, toX: Double)
    {
        _yMax = -Double.greatestFiniteMagnitude
        _yMin = Double.greatestFiniteMagnitude

        guard !values.isEmpty else { return }
        
        let indexFrom = entryIndex(x: fromX, closestToY: .nan, rounding: .down)
        let indexTo = entryIndex(x: toX, closestToY: .nan, rounding: .up)
        
        guard indexTo >= indexFrom else { return }
        (indexFrom...indexTo).forEach { calcMinMaxY(entry: values[$0]) } // only recalculate y
    }
    
    @objc open func calcMinMaxX(entry e: ChartDataEntry)
    {
        _xMin = min(e.x, _xMin)
        _xMax = max(e.x, _xMax)
    }
    
    @objc open func calcMinMaxY(entry e: ChartDataEntry)
    {
        _yMin = min(e.y, _yMin)
        _yMax = max(e.y, _yMax)
    }
    
    /// Updates the min and max x and y value of this DataSet based on the given Entry.
    ///
    /// - parameter e:
    internal func calcMinMax(entry e: ChartDataEntry)
    {
        calcMinMaxX(entry: e)
        calcMinMaxY(entry: e)
    }
    
    /// - returns: The minimum y-value this DataSet holds
    @objc open override var yMin: Double { return _yMin }
    
    /// - returns: The maximum y-value this DataSet holds
    @objc open override var yMax: Double { return _yMax }
    
    /// - returns: The minimum x-value this DataSet holds
    @objc open override var xMin: Double { return _xMin }
    
    /// - returns: The maximum x-value this DataSet holds
    @objc open override var xMax: Double { return _xMax }
    
    /// - returns: The number of y-values this DataSet represents
    open override var entryCount: Int { return values.count }
    
    /// - returns: The entry object found at the given index (not x-value!)
    /// - throws: out of bounds
    /// if `i` is out of bounds, it may throw an out-of-bounds exception
    open override func entryForIndex(_ i: Int) -> ChartDataEntry?
    {
        guard values.indices.contains(i) else {
            return nil
        }
        return values[i]
    }
    
    /// - returns: The first Entry object found at the given x-value with binary search.
    /// If the no Entry at the specified x-value is found, this method returns the Entry at the closest x-value according to the rounding.
    /// nil if no Entry object at that x-value.
    /// - parameter xValue: the x-value
    /// - parameter closestToY: If there are multiple y-values for the specified x-value,
    /// - parameter rounding: determine whether to round up/down/closest if there is no Entry matching the provided x-value
    open override func entryForXValue(
        _ xValue: Double,
        closestToY yValue: Double,
        rounding: ChartDataSetRounding) -> ChartDataEntry?
    {
        let index = entryIndex(x: xValue, closestToY: yValue, rounding: rounding)
        if index > -1
        {
            return values[index]
        }
        return nil
    }
    
    /// - returns: The first Entry object found at the given x-value with binary search.
    /// If the no Entry at the specified x-value is found, this method returns the Entry at the closest x-value.
    /// nil if no Entry object at that x-value.
    /// - parameter xValue: the x-value
    /// - parameter closestToY: If there are multiple y-values for the specified x-value,
    open override func entryForXValue(
        _ xValue: Double,
        closestToY yValue: Double) -> ChartDataEntry?
    {
        return entryForXValue(xValue, closestToY: yValue, rounding: .closest)
    }
    
    /// - returns: All Entry objects found at the given xIndex with binary search.
    /// An empty array if no Entry object at that index.
    open override func entriesForXValue(_ xValue: Double) -> [ChartDataEntry]
    {
        var entries = [ChartDataEntry]()
        
        var low = values.startIndex
        var high = values.endIndex - 1
        
        while low <= high
        {
            var m = (high + low) / 2
            var entry = values[m]
            
            // if we have a match
            if xValue == entry.x
            {
                while m > 0 && values[m - 1].x == xValue
                {
                    m -= 1
                }
                
                high = values.endIndex
                
                // loop over all "equal" entries
                while m < high
                {
                    entry = values[m]
                    if entry.x == xValue
                    {
                        entries.append(entry)
                    }
                    else
                    {
                        break
                    }
                    
                    m += 1
                }
                
                break
            }
            else
            {
                if xValue > entry.x
                {
                    low = m + 1
                }
                else
                {
                    high = m - 1
                }
            }
        }
        
        return entries
    }
    
    /// - returns: The array-index of the specified entry.
    /// If the no Entry at the specified x-value is found, this method returns the index of the Entry at the closest x-value according to the rounding.
    ///
    /// - parameter xValue: x-value of the entry to search for
    /// - parameter closestToY: If there are multiple y-values for the specified x-value,
    /// - parameter rounding: Rounding method if exact value was not found
    // TODO: This should return `nil` to follow Swift convention
    open override func entryIndex(
        x xValue: Double,
        closestToY yValue: Double,
        rounding: ChartDataSetRounding) -> Int
    {
        var low = values.startIndex
        var high = values.endIndex - 1
        var closest = high
        
        while low < high
        {
            let m = (low + high) / 2
            
            let d1 = values[m].x - xValue
            let d2 = values[m + 1].x - xValue
            let ad1 = abs(d1), ad2 = abs(d2)
            
            if ad2 < ad1
            {
                // [m + 1] is closer to xValue
                // Search in an higher place
                low = m + 1
            }
            else if ad1 < ad2
            {
                // [m] is closer to xValue
                // Search in a lower place
                high = m
            }
            else
            {
                // We have multiple sequential x-value with same distance
                
                if d1 >= 0.0
                {
                    // Search in a lower place
                    high = m
                }
                else if d1 < 0.0
                {
                    // Search in an higher place
                    low = m + 1
                }
            }
            
            closest = high
        }
        
        if closest != -1
        {
            let closestXValue = values[closest].x
            
            if rounding == .up, closestXValue < xValue, closest < values.endIndex - 1
            {
                // If rounding up, and found x-value is lower than specified x, and we can go upper...
                closest += 1
            }
            else if rounding == .down, closestXValue > xValue, closest > values.startIndex
            {
                // If rounding down, and found x-value is upper than specified x, and we can go lower...
                closest -= 1
            }
            
            // Search by closest to y-value
            if !yValue.isNaN
            {
                while closest > 0 && values[closest - 1].x == closestXValue
                {
                    closest -= 1
                }
                
                var closestYValue = values[closest].y
                var closestYIndex = closest
                
                while true
                {
                    closest += 1
                    if closest >= values.endIndex { break }
                    
                    let value = values[closest]
                    
                    if value.x != closestXValue { break }
                    if abs(value.y - yValue) <= abs(closestYValue - yValue)
                    {
                        closestYValue = yValue
                        closestYIndex = closest
                    }
                }
                
                closest = closestYIndex
            }
        }
        
        return closest
    }
    
    /// - returns: The array-index of the specified entry
    ///
    /// - parameter e: the entry to search for
    // TODO: Should be returning `nil` to follow Swift convention
    open override func entryIndex(entry e: ChartDataEntry) -> Int
    {
        return values.firstIndex { $0 === e } ?? -1
    }
    
    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to the end of the list.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter e: the entry to add
    /// - returns: True
    // TODO: This should return `Void` to follow Swift convention
    open override func addEntry(_ e: ChartDataEntry) -> Bool
    {
        calcMinMax(entry: e)

        isIndirectValuesCall = true
        values.append(e)
        
        return true
    }
    
    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to their appropriate index respective to it's x-index.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter e: the entry to add
    /// - returns: True
    // TODO: This should return `Void` to follow Swift convention
    open override func addEntryOrdered(_ e: ChartDataEntry) -> Bool
    {
        calcMinMax(entry: e)
        
        isIndirectValuesCall = true
        if values.count > 0 && values.last!.x > e.x
        {
            var closestIndex = entryIndex(x: e.x, closestToY: e.y, rounding: .up)
            while values[closestIndex].x < e.x
            {
                closestIndex += 1
            }
            values.insert(e, at: closestIndex)
        }
        else
        {
            values.append(e)
        }
        
        return true
    }
    
    /// Removes an Entry from the DataSet dynamically.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter entry: the entry to remove
    /// - returns: `true` if the entry was removed successfully, else if the entry does not exist
    // TODO: This should return the removed entry to follow Swift convention.
    open override func removeEntry(_ entry: ChartDataEntry) -> Bool
    {
        guard let i = values.firstIndex(where: { $0 === entry }) else { return false }

        isIndirectValuesCall = true
        values.remove(at: i)

        notifyDataSetChanged()
        return true
    }
    
    /// Removes the first Entry (at index 0) of this DataSet from the entries array.
    ///
    /// - returns: `true` if successful, `false` if not.
    // TODO: This should return the removed entry to follow Swift convention.
    open override func removeFirst() -> Bool
    {
        guard !values.isEmpty else { return false }

        isIndirectValuesCall = true
        values.removeFirst()

        notifyDataSetChanged()
        return true
    }
    
    /// Removes the last Entry (at index size-1) of this DataSet from the entries array.
    ///
    /// - returns: `true` if successful, `false` if not.
    // TODO: This should return the removed entry to follow Swift convention.
    open override func removeLast() -> Bool
    {
        guard !values.isEmpty else { return false }

        isIndirectValuesCall = true
        values.removeLast()

        notifyDataSetChanged()
        return true
    }
    
    /// Checks if this DataSet contains the specified Entry.
    /// - returns: `true` if contains the entry, `false` if not.
    open override func contains(_ e: ChartDataEntry) -> Bool
    {
        return values.contains(e)
    }
    
    /// Removes all values from this DataSet and recalculates min and max value.
    open override func clear()
    {
        values.removeAll(keepingCapacity: true)
    }
    
    // MARK: - Data functions and accessors
    
    // MARK: - NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! ChartDataSet
        
        copy.values = values
        copy._yMax = _yMax
        copy._yMin = _yMin
        
        return copy
    }
}
