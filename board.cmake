# board_runner_args(nrfjprog "--nrf-family=NRF52" "--softreset")
board_runner_args(dfu-util "--pid=0483:df11" "--alt=0" "--dfuse")
board_runner_args(jlink "--device=nRF52840_xxAA" "--speed=4000")

# include(${ZEPHYR_BASE}/boards/common/uf2.board.cmake)
# include(${ZEPHYR_BASE}/boards/common/nrfjprog.board.cmake)

include(${ZEPHYR_BASE}/boards/common/dfu-util.board.cmake)
include(${ZEPHYR_BASE}/boards/common/jlink.board.cmake)
