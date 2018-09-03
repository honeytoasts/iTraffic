import * as actionNames from '../action'
import {
  // selectDoSomething,
  // loadDoSomething,
  // invalidateDoSomething,
  requestDoSomething,
  requestDoSomethingPTX,
  successDoSomething,
  failureDoSomething
} from '../library/reducer.js'

export function searchBus (state = {
  searchInfo: {
    name: ''
  }
  // ,searchCity: {
  //   taipei: true,
  //   newtaipei: true,
  //   taoyuan: true,
  //   taichung: true,
  //   tainan: true,
  //   kaohsiung: true,
  //   keelung: true,
  //   hsinchu: true,
  //   miaoli: true,
  //   changhua: true,
  //   nantou: true,
  //   yunlin: true,
  //   chiayi: true,
  //   pingtung: true,
  //   yilan: true,
  //   hualien: true,
  //   taitung: true,
  //   kinmen: true,
  //   penghu: true,
  //   lienchiang: true
  // }
}, action) {
  switch (action.type) {
    case actionNames.CHANGE_BUS_SEARCHINFO:
      return {
        ...state,
        searchInfo: action.searchInfo
      }
    default:
      return state
  }
}

export function storeBus (state = {
  isFetching: false,
  items: []
}, action) {
  switch (action.type) {
    case actionNames.LOAD_BUS:
      return requestDoSomething(state)
    case actionNames.SUCCESS_BUS:
      return successDoSomething(state, action, action.items)
    default:
      return state
  }
}

export function searchBusDetail (state = {
  busDialog: {
    open: false,
    type: '',
    url: '',
    name: '',
    headsign: '',
    direction: 0,
    content: ''
  }
}, action) {
  switch (action.type) {
    case actionNames.TOGGLE_BUS_DIALOG:
      return {
        ...state,
        busDialog: {
          ...state.busDialog,
          open: !state.busDialog.open
        }
      }
    case actionNames.CHANGE_BUS_DETAIL:
      return {
        ...state,
        busDialog: action.busDialog
      }
    default:
      return state
  }
}

export function storeBusDetail (state = {
  isFetching: false,
  isFetchingPTX: false,
  items: []
}, action) {
  switch (action.type) {
    case actionNames.LOAD_BUS_BETAIL:
      return requestDoSomething(state)
    case actionNames.LOAD_BUS_PTX:
      return requestDoSomethingPTX(state)
    case actionNames.SUCCESS_BUS_DETAIL:
      return successDoSomething(state, action, action.items)
    case actionNames.FAILURE_BUS_DETAIL:
      return failureDoSomething(state, action)
    default:
      return state
  }
}
