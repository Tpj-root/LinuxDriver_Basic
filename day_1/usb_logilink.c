// usb_logilink.c (ADD THIS to your existing code)

// Add this header at the top with other includes
#include <linux/device.h>

// Add this variable to track if device is ours
static int our_device_connected = 0;

// Modify your probe function - ADD these lines
static int logilink_probe(struct usb_interface *interface, const struct usb_device_id *id)
{
    pr_info("[Logilink] HELLO WORLD! Flash drive connected.\n");
    pr_info("[Logilink] Vendor ID: 0x%04X, Product ID: 0x%04X\n", id->idVendor, id->idProduct);
    
    // NEW CODE: Set a flag that udev can read
    our_device_connected = 1;
    
    // NEW CODE: Create a sysfs file to notify userspace
    struct device *dev = &interface->dev;
    dev_set_drvdata(dev, &our_device_connected);
    
    return 0;
}

// Modify your disconnect function
static void logilink_disconnect(struct usb_interface *interface)
{
    pr_info("[Logilink] BYE BYE! Flash drive removed.\n");
    our_device_connected = 0;
}
