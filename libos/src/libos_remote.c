#include "libos_remote.h"

#include <asm-generic/errno-base.h>
#include <string.h>

#include "log.h"
#include "pal.h"
#include "socket_utils.h"

PAL_HANDLE sock = NULL;

int init_remote_socket(void) {
    int ret;

    ret = PalSocketCreate(PAL_IPV4, PAL_SOCKET_TCP, 0, &sock);
    if (ret != 0) {
        log_error("[E] Failed to create PAL socket: %d", ret);
        sock = NULL;
        return -EIO;
    }

    struct pal_socket_addr server_addr = {
        .domain = PAL_IPV4,
        .ipv4 =
            {
                .addr = htonl(0x7f000001),  // localhost
                .port = htons(12345),
            },
    };

    bool in_progress = false;
    ret              = PalSocketConnect(sock, &server_addr, NULL, &in_progress);
    if (ret != 0) {
        log_error("[E] PalSocketConnect failed: %d", ret);

        // cleanup
        // TODO: check how it is actually done
        sock = NULL;
        return -EIO;
    }

    if (in_progress) {
        /* Non-blocking connection in progress. This can be handled by polling
           or waiting for writability. For now we log and keep the socket open. */
        log_warning("[W] PalSocketConnect returned inprogress=true; connection not finished yet");
    } else {
        log_always("[i] Connected to remote syscall server via PAL");
    }

    return 0;
}
