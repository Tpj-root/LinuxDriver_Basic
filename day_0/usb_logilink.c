// usb_logilink.c
// A simple USB driver for LogiLink (abcd:1234)

#include <linux/module.h>       // For MODULE_* macros
#include <linux/kernel.h>       // For printk (kernel's printf)
#include <linux/usb.h>          // The core USB structures

// --- The Match Table ---
// This is the driver's ID card. It tells the kernel:
// "I support Vendor 0xabcd, Product 0x1234".
// The MODULE_DEVICE_TABLE macro helps hotplugging work.
static struct usb_device_id logilink_table[] = {
    { USB_DEVICE(0xabcd, 0x1234) }, // Your USB device ID
    { }                             // Terminating entry (MUST have)
};
MODULE_DEVICE_TABLE(usb, logilink_table);

// --- The Probe Function ---
// Called automatically when your device is plugged in.
static int logilink_probe(struct usb_interface *interface, const struct usb_device_id *id)
{
    // 🔥 YOUR 'HELLO WORLD' PRINT 🔥
    // KERN_INFO is the log level. pr_info() is a handy macro.
    pr_info("[Logilink] HELLO WORLD! Flash drive connected.\n");
    pr_info("[Logilink] Vendor ID: 0x%04X, Product ID: 0x%04X\n", id->idVendor, id->idProduct);
    
    // Return 0 means "I successfully claimed this device"
    return 0;
}

// --- The Disconnect Function ---
// Called automatically when your device is removed.
static void logilink_disconnect(struct usb_interface *interface)
{
    // 🔥 YOUR 'BYE BYE' PRINT 🔥
    pr_info("[Logilink] BYE BYE! Flash drive removed.\n");
}

// --- The USB Driver Structure ---
// This struct ties everything together.
static struct usb_driver logilink_driver = {
    .name       = "logilink_usb",      // Name shown in /sys/bus/usb/drivers/
    .probe      = logilink_probe,      // Point to our probe function
    .disconnect = logilink_disconnect, // Point to our disconnect function
    .id_table   = logilink_table,      // Point to our match table
};

// --- Module Initialization ---
// Runs when you type 'sudo insmod usb_logilink.ko'
static int __init usb_logilink_init(void)
{
    int result;
    pr_info("[Logilink] Driver loading...\n");
    
    // Register the driver with the USB Core
    result = usb_register(&logilink_driver);
    if (result < 0) {
        pr_err("[Logilink] Driver registration failed: %d\n", result);
        return result;
    }
    pr_info("[Logilink] Driver registered successfully.\n");
    return 0;
}

// --- Module Exit ---
// Runs when you type 'sudo rmmod usb_logilink'
static void __exit usb_logilink_exit(void)
{
    usb_deregister(&logilink_driver);
    pr_info("[Logilink] Driver unloaded.\n");
}

// Tell the kernel which functions are init and exit
module_init(usb_logilink_init);
module_exit(usb_logilink_exit);

// Necessary license info. The kernel requires this.
MODULE_LICENSE("GPL"); 
MODULE_AUTHOR("Your Name");
MODULE_DESCRIPTION("A simple hello world USB driver for LogiLink");
