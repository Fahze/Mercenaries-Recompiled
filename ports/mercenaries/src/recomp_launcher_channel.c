/*
 * RecompLauncher channel: a thin bridge to the Recomp Achievements SDK
 * (third_party/rl-achievements).
 *
 * RecompLauncher hands the game a channel name in RL_SESSION. Through it the
 * launcher can load a list for this game (achievements, leaderboards and a
 * rich presence script, all written against Xbox guest memory) and shows the
 * game's presence line on Discord and on the player's profile. The list lives
 * on RecompLauncher's side, so this file never needs to know what it checks.
 *
 * Without RL_SESSION (any launch outside RecompLauncher, or an account that
 * has no channel) the SDK returns immediately from every call.
 */
#include <windows.h>
#include <stdint.h>
#include <string.h>

#include "recomp_launcher_channel.h"
#include "rl_achievements.h"

int recomp_dev_menu_visible(void);
int recomp_freecam_enabled(void);

static unsigned char *g_guest;
static size_t g_guest_bytes;
static int g_started;
static int g_casual_sent;

/* Guest memory as the list's "xbox" addresses see it: the flat 64 MiB guest
 * address space. The first 64 KiB are never mapped by the game. Pages are
 * checked with VirtualQuery rather than caught as faults, because the
 * runtime's vectored exception handler owns guest access violations. */
static int readable(const unsigned char *p, size_t n)
{
    uintptr_t at = (uintptr_t)p, end = at + n;
    if (end < at) return 0;
    while (at < end) {
        MEMORY_BASIC_INFORMATION mbi;
        DWORD protection;
        uintptr_t next;
        if (!VirtualQuery((const void *)at, &mbi, sizeof(mbi)) ||
            mbi.State != MEM_COMMIT || (mbi.Protect & (PAGE_GUARD | PAGE_NOACCESS)))
            return 0;
        protection = mbi.Protect & 0xffu;
        if (protection != PAGE_READONLY && protection != PAGE_READWRITE &&
            protection != PAGE_WRITECOPY && protection != PAGE_EXECUTE_READ &&
            protection != PAGE_EXECUTE_READWRITE && protection != PAGE_EXECUTE_WRITECOPY)
            return 0;
        next = (uintptr_t)mbi.BaseAddress + mbi.RegionSize;
        if (next <= at) return 0;
        at = next;
    }
    return 1;
}

static uint32_t read_guest(uint32_t address, uint8_t *buffer, uint32_t num_bytes, void *ud)
{
    (void)ud;
    if (!g_guest || !buffer || num_bytes == 0 || address < 0x10000u ||
        address >= g_guest_bytes || num_bytes > g_guest_bytes - address ||
        !readable(g_guest + address, num_bytes))
        return 0;
    memcpy(buffer, g_guest + address, num_bytes);
    return num_bytes;
}

void recomp_launcher_channel_init(void *guest_base, size_t guest_bytes)
{
    if (g_started) return;
    g_started = 1;
    g_guest = (unsigned char *)guest_base;
    g_guest_bytes = guest_bytes;
    rl_ach_init("xbox", read_guest, NULL);
}

void recomp_launcher_channel_frame(void)
{
    if (!g_started) return;
    /* Developer tools change the game state outside normal play: unlocks from
     * this session then count as Casual instead of Ranked. */
    if (!g_casual_sent && rl_ach_connected() &&
        (recomp_dev_menu_visible() || recomp_freecam_enabled())) {
        rl_ach_casual("debug");
        g_casual_sent = 1;
    }
    rl_ach_frame();
}

void recomp_launcher_channel_shutdown(void)
{
    if (!g_started) return;
    g_started = 0;
    rl_ach_shutdown();
}
