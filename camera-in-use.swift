import CoreMediaIO
import Foundation

var property = CMIOObjectPropertyAddress(
    mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyDevices),
    mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
    mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain)
)

var dataSize: UInt32 = 0
CMIOObjectGetPropertyDataSize(CMIOObjectID(kCMIOObjectSystemObject), &property, 0, nil, &dataSize)

let deviceCount = Int(dataSize) / MemoryLayout<CMIOObjectID>.size
var devices = [CMIOObjectID](repeating: 0, count: deviceCount)
CMIOObjectGetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &property, 0, nil, dataSize, &dataSize, &devices)

for device in devices {
    var isRunning = CMIOObjectPropertyAddress(
        mSelector: CMIOObjectPropertySelector(kCMIODevicePropertyDeviceIsRunningSomewhere),
        mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
        mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain)
    )

    var running: UInt32 = 0
    var runningSize = UInt32(MemoryLayout<UInt32>.size)
    CMIOObjectGetPropertyData(device, &isRunning, 0, nil, runningSize, &runningSize, &running)

    if running == 1 {
        exit(0)
    }
}
exit(1)
