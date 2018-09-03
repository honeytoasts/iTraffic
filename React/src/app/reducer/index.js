import { combineReducers } from 'redux'
import { routerReducer } from 'react-router-redux'

import {drawer, page} from './general.js'
import {searchTimetable, storeTimetable, searchTrainDetail, storeTrainDetail} from './timetable.js'
import {searchBus, storeBus, searchBusDetail, storeBusDetail} from './bus.js'
const rootReducer = combineReducers({
  routing: routerReducer,
  drawer, // general ↓
  page,
  searchTimetable, // timetable ↓
  storeTimetable,
  searchTrainDetail,
  storeTrainDetail,
  searchBus,
  storeBus,
  searchBusDetail,
  storeBusDetail
})

export default rootReducer
