module main

import vhid

fn main() {
	mut devices := vhid.enumerate(0, 0) or {
		panic("Failed to enumerate devices")
	}
	for device in devices {
		println(device.serial)
	}
}

// mut report := []u8{len: 255, cap: 255, init: u8(0)}
// report[0] = 0x5
// device.get_feature_report(report) or {
// 	panic("Failed to read")
// }
// println(report[1..].bytestr())
