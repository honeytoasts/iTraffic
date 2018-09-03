import { put, call, select } from 'redux-saga/effects'

import * as actionNames from '../action'
import api from '../library/api.js'

import { apiURI_WKE, apiURI_BusList, dbName } from '.'

export function * fetchStopandDate (action) {
  const { searchInfo } = yield select(state => state.searchTimetable)
  const { language } = yield select(state => state.page)

  const jsonStop = yield call(api, 'GET', apiURI_WKE, {
    d: dbName,
    v: 'vd_StopList' + language,
    type: searchInfo.type,
    s: 'stopid_d',
    l: 10000
  })
  var stopName = []; var stopID = []
  for (var i = 0; i < jsonStop.length; i++) {
    stopName = [...stopName, jsonStop[i].stop]
    stopID = [...stopID, jsonStop[i].stopid]
  }

  const jsonDate = yield call(api, 'GET', apiURI_WKE, {
    d: dbName,
    v: 'vd_MaxminDate' + language,
    type: searchInfo.type,
    s: 'date_d',
    l: 10000
  })

  var jsonmain = {'stopID': stopID, 'stopName': stopName, 'maxdate': jsonDate[0].date, 'mindate': jsonDate[jsonDate.length - 1].date}
  yield put(actionNames.successStopandDate(jsonmain))
}

export function * fetchTimetable (action) {
  const { searchInfo } = yield select(state => state.searchTimetable)
  const { language } = yield select(state => state.page)
  let date = new Date(searchInfo.date.getTime() - (searchInfo.date.getTimezoneOffset() * 60000)).toJSON().substring(0, 10)

  const jsonTimetable = yield call(api, 'GET', apiURI_WKE, {
    d: 'iTraffic2',
    v: 'vd_TrainTimetable' + language,
    type: searchInfo.type,
    fromstopid: searchInfo.fromID,
    tostopid: searchInfo.toID,
    date: date,
    s: searchInfo.sortBy,
    l: 10000
  })
  // console.log(jsonTimetable)
  yield put(actionNames.successTimetable(jsonTimetable))
}

export function * fetchTrainDetail (action) {
  const { trainDialog } = yield select(state => state.searchTrainDetail)
  const { language } = yield select(state => state.page)
  // yield put(actionNames.loadTrainDeatil())
  try {
    const jsonTrainDetail = yield call(api, 'GET', apiURI_WKE, {
      d: dbName,
      v: 'vd_TrainDetail' + language,
      type: trainDialog.type,
      date: trainDialog.date,
      number: trainDialog.number,
      s: 'rank_a',
      l: 1000
    })
    // console.log(jsonTrainDetail)

    yield put(actionNames.successTrainDetail(jsonTrainDetail))
  } catch (err) {
    yield put(actionNames.failureTrainDetail(err))
  }
}
