module vhid

import sync
import arrays

#flag -I./hidapi -I./hidapi/hidapi
#flag linux -I./libusb/libusb -DDEFAULT_VISIBILITY="" -DOS_LINUX -D_GNU_SOURCE -DPOLL_NFDS_TYPE=int -lrt
#flag darwin -DOS_DARWIN -framework CoreFoundation -framework IOKit
#flag windows -DOS_WINDOWS -lsetupapi

$if linux {
	#include <poll.h>
	#include "os/threads_posix.c"
	#include "os/poll_posix.c"

	#include "os/linux_usbfs.c"
	#include "os/linux_netlink.c"

	#include "core.c"
	#include "descriptor.c"
	#include "hotplug.c"
	#include "io.c"
	#include "strerror.c"
	#include "sync.c"

	#include "libusb/hid.c"
} $else $if darwin {
	#include "mac/hid.c"
} $else $if windows {
	#include "windows/hid.c"
}

const (
    err_device_closed        	= 'hid: device closed'
    err_unsupported_platform 	= 'hid: unsupported platform'
	err_failed_to_enumerate  	= 'hid: failed to enumerate devices'
	err_failed_to_open_device	= 'hid: failed to open device'
	err_unknown_failure      	= 'hid: unknown failure'
)

struct DeviceInfo {
pub mut:
    path         string
    vendor_id    u16
    product_id   u16
    release      u16
    serial       string
    manufacturer string
    product      string
    usage_page   u16
    usage        u16
    @interface   int
	mutex        sync.RwMutex
}

struct Device {
mut:
	info DeviceInfo
	device &Hid_device
}


// Enumerate returns a list of all the HID devices attached to the system w
pub fn enumerate(vendorID u16, productID u16) ![]DeviceInfo {
	mut head := C.hid_enumerate(vendorID, productID)
	if head == unsafe { nil } {
		return error(err_failed_to_enumerate)
	}
	defer {
		C.hid_free_enumeration(head)
	}
	mut infos := []DeviceInfo{}
	for ; head != unsafe { nil }; head = head.next {
		mut info := DeviceInfo{
			path: unsafe { cstring_to_vstring(head.path) }
			vendor_id: u16(head.vendor_id)
			product_id: u16(head.product_id)
			release: u16(head.release_number)
			usage_page: u16(head.usage_page)
			usage: u16(head.usage)
			@interface: int(head.interface_number)
			mutex: sync.new_rwmutex()
		}
		if head.serial_number != unsafe { nil } {
			info.serial = unsafe { string_from_wide(head.serial_number) }
		}
		if head.product_string != unsafe { nil } {
			info.product = unsafe { string_from_wide(head.product_string) }
		}
		if head.manufacturer_string != unsafe { nil } {
			info.manufacturer = unsafe { string_from_wide(head.manufacturer_string) }
		}
		infos << info
	}
	return infos
}

// Open connects to an HID device by its path n
pub fn (mut info DeviceInfo) open() !&Device {
	info.mutex.@lock()
	defer { info.mutex.unlock() }
	mut path := info.path.str
	mut device := C.hid_open_path(path)
	if device == unsafe { nil } {
		return error(err_failed_to_open_device)
	}
	return &Device{
		info: info
		device: device
	}
}

// Close releases the HID USB device han
pub fn (mut dev Device) close() {
	dev.info.mutex.@lock()
	defer { dev.info.mutex.unlock() }
	if dev.device != unsafe { nil } {
		C.hid_close(dev.device)
		dev.device = unsafe { nil }
	}
}

// Write sends an output report to a HID dev
pub fn (mut dev Device) write(b []u8) !int {
	if b.len == 0 {
		return 0
	}
	dev.info.mutex.@lock()
	mut device := dev.device
	dev.info.mutex.unlock()
	if device == unsafe { nil } {
		return error(err_device_closed)
	}
	mut report := []u8{}
	$if windows {
		report = arrays.concat(u8(0), ...b)
	} $else {
		report = b.clone()
	}
	mut written := C.hid_write(device, &report, report.len)
	if written == -1 {
		dev.info.mutex.@lock()
		device = dev.device
		dev.info.mutex.unlock()
		if device == unsafe { nil } {
			return error(err_device_closed)
		}
		mut message := C.hid_error(device)
		if message == unsafe { nil } {
			return error(err_unknown_failure)
		}
		mut failure := unsafe { string_from_wide(message) }
		return error('hidapi: ' + failure)
	}
	return written
}

// SendFeatureReport sends a feature report to a HID de
pub fn (mut dev Device) send_feature_report(b []u8) !int {
	if b.len == 0 {
		return 0
	}
	dev.info.mutex.@lock()
	mut device := dev.device
	dev.info.mutex.unlock()
	if device == unsafe { nil } {
		return error(err_device_closed)
	}
	mut written := C.hid_send_feature_report(device, &b[0], b.len)
	if written == -1 {
		dev.info.mutex.@lock()
		device = dev.device
		dev.info.mutex.unlock()
		if device == unsafe { nil } {
			return error(err_device_closed)
		}
		mut message := C.hid_error(device)
		if message == unsafe { nil } {
			return error(err_unknown_failure)
		}
		mut failure := unsafe { string_from_wide(message) }
		return error('hidapi: ' + failure)
	}
	return written
}

// Read retrieves an input report from a HID dev
pub fn (mut dev Device) read(b []u8) !int {
	if b.len == 0 {
		return 0
	}
	dev.info.mutex.@lock()
	mut device := dev.device
	dev.info.mutex.unlock()
	if device == unsafe { nil } {
		return error(err_device_closed)
	}
	mut nread := C.hid_read(device, &b[0], b.len)
	if nread == -1 {
		dev.info.mutex.@lock()
		device = dev.device
		dev.info.mutex.unlock()
		if device == unsafe { nil } {
			return error(err_device_closed)
		}
		mut message := C.hid_error(device)
		if message == unsafe { nil } {
			return error(err_unknown_failure)
		}
		mut failure := unsafe { string_from_wide(message) }
		return error('hidapi: ' + failure)
	}
	return nread
}

// GetFeatureReport retreives a feature report from a HID de
pub fn (mut dev Device) get_feature_report(b []u8) !int {
	if b.len == 0 {
		return 0
	}
	dev.info.mutex.@lock()
	mut device := dev.device
	dev.info.mutex.unlock()
	if device == unsafe { nil } {
		return error(err_device_closed)
	}
	mut nread := C.hid_get_feature_report(device, &b[0], b.len)
	if nread == -1 {
		dev.info.mutex.@lock()
		device = dev.device
		dev.info.mutex.unlock()
		if device == unsafe { nil } {
			return error(err_device_closed)
		}
		mut message := C.hid_error(device)
		if message == unsafe { nil } {
			return error(err_unknown_failure)
		}
		mut failure := unsafe { string_from_wide(message) }
		return error('hidapi: ' + failure)
	}
	return nread
}
