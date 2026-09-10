# Configure the zbook runners
board_runner_args(openocd --cmd-pre-init "source [find interface/cmsis-dap.cfg]")
board_runner_args(openocd --cmd-pre-init "source [find target/rp2350.cfg]")
board_runner_args(openocd --cmd-pre-init "adapter speed 4000")

board_runner_args(probe-rs "--chip=RP235x")

# openocd is included first so it stays the default flasher and debugger;
# probe-rs is opt-in via `west flash --runner probe-rs`.
include(${ZEPHYR_BASE}/boards/common/openocd.board.cmake)
include(${ZEPHYR_BASE}/boards/common/probe-rs.board.cmake)
