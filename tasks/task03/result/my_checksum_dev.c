/*
 * Flexible /dev/checksum device for kernel 6.12+
 *
 * Author: Vojtech Sliva <sli0124@vsb.cz>
 *
 * Features:
 *  - /dev/checksum device
 *  - Algorithms: md5, sha1, sha256, xor
 *  - Level: iterations for hash or XOR bytes
 */

#include <linux/module.h>
#include <linux/init.h>
#include <linux/miscdevice.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include <linux/crypto.h>
#include <linux/slab.h>
#include <linux/string.h>
#include <crypto/hash.h>

#define BUF_SIZE 256
#define MAX_HASH_LEN 64

static char buffer[BUF_SIZE];
static size_t buf_size = 0;

/* module parameters */
static char *algorithm = "sha256";
module_param(algorithm, charp, 0000);
MODULE_PARM_DESC(algorithm, "Algorithm: md5, sha1, sha256, xor");

static int level = 1;
module_param(level, int, 0000);
MODULE_PARM_DESC(level, "Level / iterations / xor bytes");

/* XOR simple checksum */
static void compute_xor(const char *data, size_t len, char *out, int lvl)
{
    unsigned char xor_sum = 0;
    size_t i, max = (len < (size_t)lvl) ? len : (size_t)lvl;

    for (i = 0; i < max; i++)
        xor_sum ^= data[i];

    sprintf(out, "%02x", xor_sum);
    out[2] = '\0';
}

/* Generic hash computation using kernel crypto API */
static int compute_hash(const char *algo, const char *data, size_t len, char *out, int iter)
{
    struct crypto_shash *tfm = NULL;
    struct shash_desc *shash = NULL;
    unsigned char hash[MAX_HASH_LEN];
    int ret = 0;
    int i;

    tfm = crypto_alloc_shash(algo, 0, 0);
    if (IS_ERR(tfm)) {
        printk(KERN_ERR "Failed to allocate hash %s\n", algo);
        return PTR_ERR(tfm);
    }

    shash = kmalloc(sizeof(*shash) + crypto_shash_descsize(tfm), GFP_KERNEL);
    if (!shash) {
        crypto_free_shash(tfm);
        return -ENOMEM;
    }

    shash->tfm = tfm;

    for (i = 0; i < iter; i++) {
        ret = crypto_shash_init(shash);
        if (ret) break;
        ret = crypto_shash_update(shash, data, len);
        if (ret) break;
        ret = crypto_shash_final(shash, hash);
        if (ret) break;
    }

    /* Convert to hex string */
    int digest_size = crypto_shash_digestsize(tfm);
    int j;
    for (j = 0; j < digest_size; j++)
        sprintf(&out[j*2], "%02x", hash[j]);
    out[digest_size*2] = '\0';

    kfree(shash);
    crypto_free_shash(tfm);

    return ret;
}

/* wrapper */
static int compute_checksum(const char *data, size_t len, char *out)
{
    if (strcmp(algorithm, "md5") == 0)
        return compute_hash("md5", data, len, out, level);
    else if (strcmp(algorithm, "sha1") == 0)
        return compute_hash("sha1", data, len, out, level);
    else if (strcmp(algorithm, "sha256") == 0)
        return compute_hash("sha256", data, len, out, level);
    else if (strcmp(algorithm, "sha512") == 0)
        return compute_hash("sha512", data, len, out, level);
    else if (strcmp(algorithm, "xor") == 0) {
        compute_xor(data, len, out, level);
        return 0;
    } else {
        printk(KERN_WARNING "Unknown algorithm %s, defaulting to xor\n", algorithm);
        compute_xor(data, len, out, level);
        return 0;
    }
}

/* /dev read */
static ssize_t checksum_read(struct file *file, char __user *buf,
                             size_t count, loff_t *ppos)
{
    char hash_str[MAX_HASH_LEN*2 + 2];
    int len;

    if (*ppos != 0)
        return 0;

    if (compute_checksum(buffer, buf_size, hash_str) != 0)
        return -EFAULT;

    len = strlen(hash_str);
    hash_str[len] = '\n';
    len += 1;

    if (count < len)
        return -EINVAL;

    if (copy_to_user(buf, hash_str, len))
        return -EFAULT;

    *ppos = len;
    return len;
}

/* /dev write */
static ssize_t checksum_write(struct file *file, const char __user *buf,
                              size_t count, loff_t *ppos)
{
    size_t write_len = (count > BUF_SIZE - 1) ? (BUF_SIZE - 1) : count;

    if (copy_from_user(buffer, buf, write_len))
        return -EFAULT;

    buffer[write_len] = '\0';
    buf_size = write_len;

    printk(KERN_INFO "Checksum buffer updated: %s\n", buffer);
    return count;
}

static const struct file_operations checksum_fops = {
    .owner = THIS_MODULE,
    .read  = checksum_read,
    .write = checksum_write,
};

static struct miscdevice checksum_dev = {
    MISC_DYNAMIC_MINOR,
    "checksum",
    &checksum_fops
};

static int __init checksum_init(void)
{
    int ret = misc_register(&checksum_dev);
    if (ret)
        printk(KERN_ERR "Failed to register /dev/checksum\n");
    else
        printk(KERN_INFO "Checksum module loaded: algorithm=%s, level=%d\n", algorithm, level);

    return ret;
}

static void __exit checksum_exit(void)
{
    misc_deregister(&checksum_dev);
    printk(KERN_INFO "Checksum module unloaded\n");
}

module_init(checksum_init);
module_exit(checksum_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Vojtech Sliva <sli0124@vsb.cz>");
MODULE_DESCRIPTION("/dev checksum (md5, sha1, sha256, xor)");
MODULE_VERSION("3.0");
