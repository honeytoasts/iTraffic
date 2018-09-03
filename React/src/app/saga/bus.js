import { put, call, select } from 'redux-saga/effects'

import * as actionNames from '../action'
import api from '../library/api.js'
import getheader from '../library/bus.js'

import { apiURI_WKE, apiURI_BusList, dbName } from '.'

export function * fetchBus (action) {
  const { language } = yield select(state => state.page)
  const { searchInfo } = yield select(state => state.searchBus)

  const jsonBus = yield call(api, 'GET', 'https://chatbot.csie.ncnu.edu.tw:9233/cgi/BusList' + language, {
    name: searchInfo.name
  })

  yield put(actionNames.successBus(jsonBus))
}

export function * fetchBusDetail (action) {
  const { language } = yield select(state => state.page)
  const { busDialog } = yield select(state => state.searchBusDetail)

  try {
    // 從資料庫抓資料
    const jsonBusDetail = yield call(api, 'GET', apiURI_WKE, {
      d: dbName,
      v: 'vd_BusDetail' + language,
      url: busDialog.url,
      name: busDialog.name,
      direction: busDialog.direction,
      s: 'rank_a',
      l: 1000
    })

    yield put(actionNames.successBusDetail(jsonBusDetail))

    // 從PTX抓資料
    yield put(actionNames.loadBusPTX())

    var url = ''; var uid = jsonBusDetail[0].routeuid
    if (busDialog.url === 'InterCity') {
      url = "https://ptx.transportdata.tw/MOTC/v2/Bus/EstimatedTimeOfArrival/InterCity?$filter=SubRouteUID eq '" + uid + "' and Direction eq '" + busDialog.direction + "'&$format=JSON"
    } else if (busDialog.url === 'Taipei' || busDialog.url === 'NewTaipei') {
      url = 'https://ptx.transportdata.tw/MOTC/v2/Bus/EstimatedTimeOfArrival/City/' + busDialog.url + "?$filter=RouteUID eq '" + uid + "' and Direction eq '" + busDialog.direction + "'&$format=JSON"
    } else {
      url = 'https://ptx.transportdata.tw/MOTC/v2/Bus/EstimatedTimeOfArrival/City/' + busDialog.url + "?$filter=SubRouteUID eq '" + uid + "' and Direction eq '" + busDialog.direction + "'&$format=JSON"
    }
    const jsonBusDetailPTX = yield call(api, 'GET', url, {}, getheader())
    jsonBusDetail.map((value, index) => {
      jsonBusDetailPTX.filter((f) => f.StopUID === value.stopuid).map((v, i) => {
        if ((v.PlateNumb === '-1' || v.PlateNumb === '') && (v.IsLastBus === true || v.StopStatus === 3)) {
          value.state = language === 'Zh' ? '末班駛離' : 'Serv Over'
        } else if (v.PlateNumb === '' && v.NextBusTime) {
          value.state = v.NextBusTime.substring(11, 16)
        } else if (v.PlateNumb === '-1' || v.PlateNumb === '' || v.StopStatus === 1) {
          value.state = language === 'Zh' ? '未發車' : 'Depart'
        } else if (v.EstimateTime >= 0 && (v.UpdateTime > value.updatetime)) {
          var number = Math.floor(v.EstimateTime / 60)
          if (number === 1 || number === 0) {
            value.state = language === 'Zh' ? '即將進站' : 'Approach'
          } else {
            value.state = language === 'Zh' ? String(number) + '分' : String(number) + 'min'
          }
        }
      })
    })
    // console.log(jsonBusDetail)
    yield put(actionNames.successBusDetail(jsonBusDetail))
  } catch (err) {
    yield put(actionNames.failureBusDetail(err))
  }
}
