

# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2023 Nautech Systems Pty Ltd. All rights reserved.
#  https://nautechsystems.io
#
#  Licensed under the GNU Lesser General Public License Version 3.0 (the "License");
#  You may not use this file except in compliance with the License.
#  You may obtain a copy of the License at https://www.gnu.org/licenses/lgpl-3.0.en.html
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# -------------------------------------------------------------------------------------------------

from cpython.datetime cimport datetime
from cpython.datetime cimport timedelta

from libc.stdint cimport uint8_t
from libc.stdint cimport uint64_t


from nautilus_trader.common.clock cimport Clock
from nautilus_trader.common.timer cimport TimeEvent
from nautilus_trader.model.data.bar cimport BarType
#from nautilus_trader.model.data.tick cimport QuoteTick
from nautilus_trader.model.data.tick cimport TradeTick
from nautilus_trader.model.data.orderflowbar cimport OrderFlowBar
from nautilus_trader.model.objects cimport Price
from nautilus_trader.model.objects cimport Quantity
from nautilus_trader.indicators.zscore cimport Zscore
from nautilus_trader.indicators.supertrend cimport SuperTrend


cdef class OrderFlowBarBuilder:
    cdef BarType _bar_type
    cdef readonly double size_increment
    cdef readonly double price_increment
    #cdef readonly uint8_t price_precision
    #"""The price precision for the builders instrument.\n\n:returns: `uint8`"""
    cdef readonly uint8_t size_precision
    """The size precision for the builders instrument.\n\n:returns: `uint8`"""
    cdef readonly bint initialized
    """If the builder is initialized.\n\n:returns: `bool`"""
    cdef readonly uint64_t ts_last
    """The UNIX timestamp (nanoseconds) when the builder last updated.\n\n:returns: `uint64_t`"""
    cdef readonly int count
    """The builders current update count.\n\n:returns: `int`"""
    cdef readonly object on_bar
    """The on_bar callback function.\n\n:returns: `object`"""
    cdef bint _partial_set
    cdef Price _last_close
    cdef Price last_price
    cdef int tick_direction 
    cdef Price _open
    cdef Price _high
    cdef Price _low
    cdef Price _close
    cdef Quantity volume
    
    cdef object ask_price
    cdef object ask_volume
    cdef object bid_price 
    cdef object bid_volume 

    #extra valiables 
    cdef int pressure_levels 
    cdef int support_levels
    cdef double imbalance_ratio
    cdef double  bottom_imbalance 
    cdef double  bottom_imbalance_price 
    cdef double  middle_imbalance 
    cdef double  middle_imbalance_price 
    cdef double  top_imbalance 
    cdef double  top_imbalance_price 
    cdef double  point_of_control 
    cdef double  poc_imbalance    
    cdef int     index1
    cdef int     index2 
    cdef double  max_volume 
    cdef double  total_volume 
    cdef double  delta 
    cdef double  value_delta 
    cdef bint    up_bar
    cdef int     tag

    #define of functions 
    cpdef void set_partial(self, OrderFlowBar partial_bar) except *
    
    cpdef void update(
        self, 
        Price price, 
        Quantity size, 
        uint64_t ts_event
    ) except *

    cpdef void reset(self) except *

    cpdef OrderFlowBar build_now(self)

    cdef void _build_now_and_send(self)

    cdef void _build_and_send(self, uint64_t ts_event, uint64_t ts_init)

    cpdef OrderFlowBar build(self, uint64_t ts_event, uint64_t ts_init)

    cpdef void handle_trade_tick(self, TradeTick tick) except *

    cdef void _apply_update(
        self, 
        Price price, 
        Quantity size, 
        uint64_t ts_event
    ) except *


cdef class SuperTrendOrderFlowBarAggregator(OrderFlowBarBuilder):
    cdef SuperTrend supertrend_indicator

cdef class ZscoreOrderFlowBarAggregator(OrderFlowBarBuilder):
    cdef double zs_threshold
    cdef Zscore zscore  
    cdef double last_zscore_value

cdef class CumsumOrderFlowBarAggregator(OrderFlowBarBuilder):
    cdef double return_of_bar

cdef class ValueOrderFlowBarAggregator(OrderFlowBarBuilder):
    cdef object _cum_value

    cpdef object get_cumulative_value(self)

cdef class TimeOrderFlowBarAggregator(OrderFlowBarBuilder):
    cdef Clock _clock
    cdef str _timer_name
    cdef readonly timedelta interval
    """The aggregators time interval.\n\n:returns: `timedelta`"""
    cdef readonly uint64_t next_close_ns
    """The aggregators next closing time.\n\n:returns: `uint64_t`"""
    cdef bint _build_on_next_tick
    cdef uint64_t _stored_open_ns
    cdef uint64_t _stored_close_ns
    cdef bint _build_with_no_updates
    cdef bint _timestamp_on_close

    cpdef datetime get_start_time(self)

    cpdef void stop(self)

    cdef timedelta _get_interval(self)

    cpdef void _set_build_timer(self)

    cpdef void _build_bar(self, TimeEvent event)