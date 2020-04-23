import UIKit
import XCTest

// A roman calculator that sum two roman numbers with string input   i.e. "XIV” + “LX” = “LXXIV"
/*
 Roman value:
 I = 1
 V = 5
 X = 10
 L = 50
 C = 100
 D = 500
 M = 1_000
 */

/*
 Rules to a Roman number:
 
 Numerals can be concatenated to form a larger numeral (“XX” + “II” = “XXII”)
 If a lesser numeral is put before a bigger it means subtraction of the lesser from the bigger (“IV” means four, “CM” means ninehundred)
 If the numeral is I, X or C you can’t have more than three (“II” + “II” = “IV”)
 If the numeral is V, L or D you can’t have more than one (“D” + “D” = “M”)
 */

class RomanCalculator {
    let romanValues: [String: Int] = ["I": 1,
                                      "V": 5,
                                      "X": 10,
                                      "L": 50,
                                      "C": 100,
                                      "D": 500,
                                      "M": 1_000]
    
    func sum(_ romanNumeral1: String, _ romanNuemral2: String) -> String {
        let value1 = getNumericValue(of: romanNumeral1)
        let value2 = getNumericValue(of: romanNuemral2)
        let result = value1 + value2
        
        return getRomanNumeral(for: result)
    }
    
    func getNumericValue(of romanValue: String) -> Int {
        if romanValue.count > 1 {
            let value = parseCompositeValue(romanValue)
            return value
        }
        
        return romanValues[romanValue] ?? 0
    }
    
    private func parseCompositeValue(_ romanValue: String) -> Int {
        if !isValidComposition(romanValue) {
            return 0
        }
        
        var amount = 0
        var previousValue = 0
        
        for romanNumeral in romanValue {
            let numericValue = self.getNumericValue(of: String(romanNumeral))
            
            if previousValue > 0 {
                if previousValue >= numericValue {
                    amount += numericValue
                } else {
                    amount += numericValue - (2 * previousValue)
                }
            } else {
                amount += numericValue
            }
            
            previousValue = numericValue
        }
        
        return amount
    }
    
    private func isValidComposition(_ composition: String) -> Bool {
        let regexRules = "IIII+|XXXX+|CCCC+|VV+|LL+|DD+|IL|IC|ID|IM|VX|VL|VC|VD|VM|XD|XM|LC|LD|LM|DM"
        let regex = try! NSRegularExpression(pattern: regexRules)
        let range = NSRange(location: 0, length: composition.utf16.count)
        
        return regex.firstMatch(in: composition, options: [], range: range) == nil
    }
    
    func getRomanNumeral(for value: Int, formatResult: Bool = true) -> String {
        var romanNumeral: String = ""
        var remainingValue = value
        
        for (romanValue, numericValue) in romanValues.sorted(by: { $0.value > $1.value }) {
            if value >= numericValue {
                romanNumeral += romanValue
                remainingValue -= numericValue
                
                if remainingValue > 0 {
                    romanNumeral += getRomanNumeral(for: remainingValue, formatResult: false)
                }
                
                break
            }
        }
        
        return formatResult ? formatRomanNumeral(romanNumeral) : romanNumeral
    }
    
    private func formatRomanNumeral(_ romanNumeral: String) -> String {
        let wrongPattern = ["IIII", "VIIII", "XXXX", "LXXXX", "CCCC", "DCCCC"]
        let correctPattern = ["IV", "IX", "XL", "XC", "CD", "CM"]
        var formattedValue = romanNumeral
        
        for index in stride(from: wrongPattern.count - 1, through: 0, by: -1) {
            let regex = try! NSRegularExpression(pattern: wrongPattern[index], options: .caseInsensitive)
            formattedValue = regex.stringByReplacingMatches(in: formattedValue, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, formattedValue.count), withTemplate: correctPattern[index])
        }
        
        return formattedValue
    }
}

class KataTests: XCTestCase {
    
    var sut: RomanCalculator!
    
    override func setUp() {
        super.setUp()
        sut = RomanCalculator()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testRomanCalculator_convertSingleLetterInANumber() {
        let value1 = sut.getNumericValue(of: "I")
        XCTAssertEqual(1, value1)
        
        let value5 = sut.getNumericValue(of: "V")
        XCTAssertEqual(5, value5)
        
        let value10 = sut.getNumericValue(of: "X")
        XCTAssertEqual(10, value10)
        
        let value50 = sut.getNumericValue(of: "L")
        XCTAssertEqual(50, value50)
        
        let value100 = sut.getNumericValue(of: "C")
        XCTAssertEqual(100, value100)
        
        let value500 = sut.getNumericValue(of: "D")
        XCTAssertEqual(500, value500)
        
        let value1000 = sut.getNumericValue(of: "M")
        XCTAssertEqual(1_000, value1000)
    }
    
    func testRomanCalculator_convertCompositeValueInANumber() {
        let value1 = sut.getNumericValue(of: "IV")
        XCTAssertEqual(4, value1)
        let value2 = sut.getNumericValue(of: "IX")
        XCTAssertEqual(9, value2)
    }
    
    func testRomanCalculator_withThreeChars_convertCompositeValueInANumber() {
        let value = sut.getNumericValue(of: "XXX")
        XCTAssertEqual(30, value)
    }
    
    func testRomanCalculator_withMoreThanThreeIXorC_returnZero() {
        let valueI = sut.getNumericValue(of: "IIII")
        XCTAssertEqual(0, valueI)
        let valueX = sut.getNumericValue(of: "XXXXX")
        XCTAssertEqual(0, valueX)
        let valueC = sut.getNumericValue(of: "CCCC")
        XCTAssertEqual(0, valueC)
    }
    
    func testRomanCalculator_rulesAboutLesserNumeralBeforeBigger() {
        let value1 = sut.getNumericValue(of: "XM")
        XCTAssertEqual(0, value1)
        let value2 = sut.getNumericValue(of: "IM")
        XCTAssertEqual(0, value2)
    }
    
    func testRomanCalculator_convertNumberOneInRomanNumeral() {
        let value = sut.getRomanNumeral(for: 1)
        XCTAssertEqual("I", value)
    }
    
    func testRomanCalculator_convertNumberFiveInRomanNumeral() {
        let value = sut.getRomanNumeral(for: 5)
        XCTAssertEqual("V", value)
    }
    
    func testRomanCalculator_convertNumberFourInRomanNumeral() {
        let value = sut.getRomanNumeral(for: 4)
        XCTAssertEqual("IV", value)
    }
    
    func testRomanCalculator_convertNumberNineInRomanNumeral() {
        let value = sut.getRomanNumeral(for: 9)
        XCTAssertEqual("IX", value)
    }
    
    func testRomanCalculator_convertNumberThirtyInRomanNumeral() {
        let value = sut.getRomanNumeral(for: 30)
        XCTAssertEqual("XXX", value)
    }
    
    func testRomanCalculator_sumTwoRomanNumerals() {
        let result1 = sut.sum("I", "I")
        XCTAssertEqual("II", result1)
        
        let result2 = sut.sum("IV", "V")
        XCTAssertEqual("IX", result2)
    }
}

KataTests.defaultTestSuite.run()
