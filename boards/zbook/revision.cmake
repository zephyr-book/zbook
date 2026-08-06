# SPDX-License-Identifier: Apache-2.0
#
# Copyright (c) 2026, Centro de Inovacao EDGE
#
# P1 is the original zbook hardware (default, unchanged). P2 re-pins most
# peripherals and adds new ones per zbook-p2-schematics.pdf.

set(BOARD_REVISIONS "p1" "p2")

if(NOT DEFINED BOARD_REVISION)
  set(BOARD_REVISION "p1")
elseif(NOT BOARD_REVISION IN_LIST BOARD_REVISIONS)
  message(FATAL_ERROR "Invalid board revision, ${BOARD_REVISION}, valid revisions are: p1, p2")
endif()
