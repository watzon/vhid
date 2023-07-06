# vhid

V language HID library, wrapping hidapi and libusb.

## Usage

```v
import vhid

fn main() {
    mut device := vhid.open_path("path/to/device")
    defer device.close()

    mut buf := []byte{0, 0, 0, 0, 0, 0, 0, 0}
    device.write(buf)
    device.read(buf)
}
```

## Contributors

- [watzon](https://github.com/watzon) - creator and maintainer
- [karalabe](https://github.com/karalabe) - creator of [karalabe/hid](https://github.com/karalabe/hid), the inspiration for this library

## License

This software is licensed under the MIT license. See [LICENSE](LICENSE) for details.
