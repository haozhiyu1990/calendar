import Foundation

for i in 1...9 {
    for j in 1...i {
        if j == 1 {
            print("\(j) x \(i) = \(j * i)", terminator: "  ")
        } else {
            print(String(format: "\(j) x \(i) = %2d", j * i), terminator: "  ")
        }
    }
    print("")
}
