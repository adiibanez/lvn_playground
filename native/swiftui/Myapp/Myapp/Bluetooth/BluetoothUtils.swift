import CoreBluetooth

enum DataType {
    case uint8, uint16, uint32, int8, int16, int32, float, double, boolean, utf8String, rawData
}

public class BluetoothUtils {
    
    static var uuidMap: [String: (String, DataType)] {
        get {
            return [
                
                // MARK: - Characteristics
                "00002A43-0000-1000-8000-00805F9B34FB": ("alertCategoryId", .uint8), // Alert Category ID
                "00002A06-0000-1000-8000-00805F9B34FB": ("alertLevel", .uint8), // Alert Level
                "00002A3F-0000-1000-8000-00805F9B34FB": ("alertStatus", .uint8), // Alert Status
                "00002AB3-0000-1000-8000-00805F9B34FB": ("altitude", .int32), // Altitude
                "00002A58-0000-1000-8000-00805F9B34FB": ("analog", .rawData), // Analog
                "00002A59-0000-1000-8000-00805F9B34FB": ("analogOutput", .rawData), // Analog output
                "00002A19-0000-1000-8000-00805F9B34FB": ("batteryLevel", .uint8), // Battery Level
                "00002A2B-0000-1000-8000-00805F9B34FB": ("currentTime", .rawData), // Current Time
                "00002A56-0000-1000-8000-00805F9B34FB": ("digital", .rawData), // Digital
                "00002A57-0000-1000-8000-00805F9B34FB": ("digitalOutput", .rawData), // Digital output
                "00002A26-0000-1000-8000-00805F9B34FB": ("firmwareRevisionString", .utf8String), // Firmware Revision String
                "00002A8A-0000-1000-8000-00805F9B34FB": ("firstName", .utf8String), // First Name
                "00002A00-0000-1000-8000-00805F9B34FB": ("deviceName", .utf8String), // Device Name
                "00002A03-0000-1000-8000-00805F9B34FB": ("reconnectionAddress", .rawData), // Reconnection Address
                "00002A05-0000-1000-8000-00805F9B34FB": ("serviceChanged", .rawData), // Service Changed
                "00002A27-0000-1000-8000-00805F9B34FB": ("hardwareRevisionString", .utf8String), // Hardware Revision String
                "00002A6F-0000-1000-8000-00805F9B34FB": ("humidity", .float), // Humidity
                "00002A90-0000-1000-8000-00805F9B34FB": ("lastName", .utf8String), // Last Name
                "00002AAE-0000-1000-8000-00805F9B34FB": ("latitude", .int32), // Latitude
                "00002AAF-0000-1000-8000-00805F9B34FB": ("longitude", .int32), // Longitude
                "00002A29-0000-1000-8000-00805F9B34FB": ("manufacturerNameString", .utf8String), // Manufacturer Name String
                "00002A21-0000-1000-8000-00805F9B34FB": ("measurementInterval", .int32), // Measurement Interval
                "00002A24-0000-1000-8000-00805F9B34FB": ("modelNumberString", .utf8String), // Model Number String
                "00002A6D-0000-1000-8000-00805F9B34FB": ("pressure", .float), // Pressure
                "00002A78-0000-1000-8000-00805F9B34FB": ("rainfall", .int32), // Rainfall
                "00002A25-0000-1000-8000-00805F9B34FB": ("serialNumberString", .utf8String), // Serial Number String
                "00002A3B-0000-1000-8000-00805F9B34FB": ("serviceRequired", .boolean), // Service Required
                "00002A28-0000-1000-8000-00805F9B34FB": ("softwareRevisionString", .utf8String), // Software Revision String
                "00002A3D-0000-1000-8000-00805F9B34FB": ("string", .utf8String), // String
                "00002A23-0000-1000-8000-00805F9B34FB": ("systemId", .rawData), // System ID
                "00002A6E-0000-1000-8000-00805F9B34FB": ("temperature", .float), // Temperature
                "00002A1F-0000-1000-8000-00805F9B34FB": ("temperatureCelsius", .float),// Temperature Celsius
                "00002A20-0000-1000-8000-00805F9B34FB": ("temperatureFahrenheit", .float),// Temperature Fahrenheit
                "00002A15-0000-1000-8000-00805F9B34FB": ("timeBroadcast", .rawData), // Time Broadcast
                "00002a37-0000-1000-8000-00805f9b34fb": ("heartRateMeasurement", .uint16), // Heart Rate Measurement
                "00002a5b-0000-1000-8000-00805f9b34fb": ("cscMeasurement", .rawData), // CSC Measurement
                "00002902-0000-1000-8000-00805f9b34fb": ("clientCharacteristicConfig", .rawData), // Client Characteristic Config
                
                
                // MARK: - Services
                "00001800-0000-1000-8000-00805F9B34FB": ("genericAccess", .rawData),//Generic Access
                "00001811-0000-1000-8000-00805F9B34FB": ("alertNotificationService",.rawData), // Alert Notification Service
                "00001815-0000-1000-8000-00805F9B34FB": ("automationIO",.rawData),//Automation IO
                "0000180F-0000-1000-8000-00805F9B34FB": ("batteryService", .uint8), // Battery Service
                "0000183B-0000-1000-8000-00805F9B34FB": ("binarySensor",.rawData),//Binary Sensor
                "00001805-0000-1000-8000-00805F9B34FB": ("currentTimeService",.rawData),//Current Time Service
                "0000180A-0000-1000-8000-00805F9B34FB": ("deviceInformation",.utf8String),//Device Information
                "0000183C-0000-1000-8000-00805F9B34FB": ("emergencyConfiguration",.rawData),//Emergency Configuration
                "0000181A-0000-1000-8000-00805F9B34FB": ("environmentalSensing",.rawData),//Environmental Sensing
                "00001801-0000-1000-8000-00805F9B34FB": ("genericAttribute",.rawData),//Generic Attribute
                "00001812-0000-1000-8000-00805F9B34FB": ("humanInterfaceDevice", .rawData),//Human Interface Device
                "00001802-0000-1000-8000-00805F9B34FB": ("immediateAlert",.rawData),//Immediate Alert
                "00001821-0000-1000-8000-00805F9B34FB": ("indoorPositioning", .rawData),//Indoor Positioning
                "00001803-0000-1000-8000-00805F9B34FB": ("linkLoss",.rawData),//Link Loss
                "00001819-0000-1000-8000-00805F9B34FB": ("locationAndNavigation", .rawData),// Location and Navigation
                "00001825-0000-1000-8000-00805F9B34FB": ("objectTransferService", .rawData),//Object Transfer Service
                "00001824-0000-1000-8000-00805F9B34FB": ("transportDiscovery",.rawData), //Transport Discovery
                "00001804-0000-1000-8000-00805F9B34FB": ("txPower", .int8), //Tx Power
                "0000181C-0000-1000-8000-00805F9B34FB": ("userData",.rawData) //User Data
                
            ]
        }
    }
    
    class func name(for uuid: CBUUID) -> String {
        print("BluetoothUUID: \(uuid.uuidString)")
        return uuidMap[uuid.uuidString]?.0 ?? "unknown"
    }
    
    class func dataType(for uuid: CBUUID) -> DataType? {
        return uuidMap[uuid.uuidString]?.1
    }
    
    
    class var allMappings : [String: (String, DataType)] {
        return uuidMap
    }
    
    class func isKnown(uuid: CBUUID) -> Bool {
        return uuidMap[uuid.uuidString] != nil
    }
    
    
    
    
}
