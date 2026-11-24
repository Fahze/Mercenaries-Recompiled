#ifndef RECOMP_LAUNCHER_CHANNEL_H
#define RECOMP_LAUNCHER_CHANNEL_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* RecompLauncher channel (Recomp Achievements SDK). RecompLauncher starts the
 * game with RL_SESSION; without it every call here returns immediately.
 * Init once guest memory is mapped, tick once per game frame on the guest
 * thread, shut down at exit. */
void recomp_launcher_channel_init(void *guest_base, size_t guest_bytes);
void recomp_launcher_channel_frame(void);
void recomp_launcher_channel_shutdown(void);

#ifdef __cplusplus
}
#endif

#endif
