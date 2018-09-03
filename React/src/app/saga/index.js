import { takeLatest } from 'redux-saga'
import { fork } from 'redux-saga/effects'

import * as actionNames from '../action'
import { fetchStopandDate, fetchTimetable, fetchTrainDetail } from './timetable.js'
import { fetchBus, fetchBusDetail } from './bus.js'

export let dbName

if (process.env.NODE_ENV !== 'production') {
  dbName = 'iTraffic'
} else {
  dbName = 'iTraffic'
}

export const apiURI_WKE = 'https://api.csie.ncnu.edu.tw:8888/API/getJSONData.ashx'

export default function * root () {
  // 搜尋條件
  yield fork(takeLatest, actionNames.LOAD_STOP_AND_DATE, fetchStopandDate)
  // 查詢時刻表
  yield fork(takeLatest, actionNames.LOAD_TIMETABLE, fetchTimetable)
  // 查詢班次資訊
  yield fork(takeLatest, actionNames.LOAD_TRAIN_DETAIL, fetchTrainDetail)
  // 查詢公車
  yield fork(takeLatest, actionNames.LOAD_BUS, fetchBus)
  // 查詢公車詳細資訊
  yield fork(takeLatest, actionNames.LOAD_BUS_DETAIL, fetchBusDetail)
}
