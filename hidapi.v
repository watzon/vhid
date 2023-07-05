module vhid

struct Hid_device {}

struct Hid_device_info {
	path &u8
	vendor_id u16
	product_id u16
	serial_number &u16
	release_number u16
	manufacturer_string &u16
	product_string &u16
	usage_page u16
	usage u16
	interface_number int
	next &Hid_device_info
}

fn C.hid_init() int

pub fn hid_init() int {
	return C.hid_init()
}

fn C.hid_exit() int

pub fn hid_exit() int {
	return C.hid_exit()
}

fn C.hid_enumerate(vendor_id u16, product_id u16) &Hid_device_info

pub fn hid_enumerate(vendor_id u16, product_id u16) &Hid_device_info {
	return C.hid_enumerate(vendor_id, product_id)
}

fn C.hid_free_enumeration(devs &Hid_device_info)

pub fn hid_free_enumeration(devs &Hid_device_info)  {
	C.hid_free_enumeration(devs)
}

fn C.hid_open(vendor_id u16, product_id u16, serial_number &u16) &Hid_device

pub fn hid_open(vendor_id u16, product_id u16, serial_number &u16) &Hid_device {
	return C.hid_open(vendor_id, product_id, serial_number)
}

fn C.hid_open_path(path &u8) &Hid_device

pub fn hid_open_path(path &u8) &Hid_device {
	return C.hid_open_path(path)
}

fn C.hid_write(device &Hid_device, data &u8, length usize) int

pub fn hid_write(device &Hid_device, data &u8, length usize) int {
	return C.hid_write(device, data, length)
}

fn C.hid_read_timeout(dev &Hid_device, data &u8, length usize, milliseconds int) int

pub fn hid_read_timeout(dev &Hid_device, data &u8, length usize, milliseconds int) int {
	return C.hid_read_timeout(dev, data, length, milliseconds)
}

fn C.hid_read(device &Hid_device, data &u8, length usize) int

pub fn hid_read(device &Hid_device, data &u8, length usize) int {
	return C.hid_read(device, data, length)
}

fn C.hid_set_nonblocking(device &Hid_device, nonblock int) int

pub fn hid_set_nonblocking(device &Hid_device, nonblock int) int {
	return C.hid_set_nonblocking(device, nonblock)
}

fn C.hid_send_feature_report(device &Hid_device, data &u8, length usize) int

pub fn hid_send_feature_report(device &Hid_device, data &u8, length usize) int {
	return C.hid_send_feature_report(device, data, length)
}

fn C.hid_get_feature_report(device &Hid_device, data &u8, length usize) int

pub fn hid_get_feature_report(device &Hid_device, data &u8, length usize) int {
	return C.hid_get_feature_report(device, data, length)
}

fn C.hid_close(device &Hid_device)

pub fn hid_close(device &Hid_device)  {
	C.hid_close(device)
}

fn C.hid_get_manufacturer_string(device &Hid_device, string_ &u16, maxlen usize) int

pub fn hid_get_manufacturer_string(device &Hid_device, string_ &u16, maxlen usize) int {
	return C.hid_get_manufacturer_string(device, string_, maxlen)
}

fn C.hid_get_product_string(device &Hid_device, string_ &u16, maxlen usize) int

pub fn hid_get_product_string(device &Hid_device, string_ &u16, maxlen usize) int {
	return C.hid_get_product_string(device, string_, maxlen)
}

fn C.hid_get_serial_number_string(device &Hid_device, string_ &u16, maxlen usize) int

pub fn hid_get_serial_number_string(device &Hid_device, string_ &u16, maxlen usize) int {
	return C.hid_get_serial_number_string(device, string_, maxlen)
}

fn C.hid_get_indexed_string(device &Hid_device, string_index int, string_ &u16, maxlen usize) int

pub fn hid_get_indexed_string(device &Hid_device, string_index int, string_ &u16, maxlen usize) int {
	return C.hid_get_indexed_string(device, string_index, string_, maxlen)
}

fn C.hid_error(device &Hid_device) &u16

pub fn hid_error(device &Hid_device) &u16 {
	return C.hid_error(device)
}

