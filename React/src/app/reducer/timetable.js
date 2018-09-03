import * as actionNames from '../action'
import {
  // selectDoSomething,
  // loadDoSomething,
  // invalidateDoSomething,
  requestDoSomething,
  successDoSomething,
  failureDoSomething
} from '../library/reducer.js'

export function searchTimetable (state = {
  searchInfo: {
    type: '',
    fromStop: '',
    fromID: '',
    toStop: '',
    toID: '',
    date: new Date(),
    time: new Date(),
    sortBy: 'departure_a'
  },
  searchLimit: {
    stopID: [],
    stopName: [],
    minDate: null,
    maxDate: null
  },
  errorText: {
    fromError: '',
    toError: ''
  }
}, action) {
  switch (action.type) {
    case actionNames.LOAD_STOP_AND_DATE:
      return state
    case actionNames.SUCCESS_STOP_AND_DATE:
      var fromStop = ''; var toStop = ''
      if (state.searchInfo.fromID !== '') {
        fromStop = action.items.stopName[action.items.stopID.indexOf(state.searchInfo.fromID)]
      }
      if (state.searchInfo.toID !== '') {
        toStop = action.items.stopName[action.items.stopID.indexOf(state.searchInfo.toID)]
      }

      return {
        ...state,
        searchInfo: {
          ...state.searchInfo,
          fromStop: fromStop,
          toStop: toStop
        },
        searchLimit: {
          ...state.searchLimit,
          stopID: action.items.stopID,
          stopName: action.items.stopName,
          minDate: new Date(action.items.mindate),
          maxDate: new Date(action.items.maxdate)
        }
      }
    case actionNames.CHANGE_TRAIN_SEARCHINFO:
      return {
        ...state,
        searchInfo: action.searchInfo
      }
    case actionNames.CHANGE_STOP :
      return {
        ...state,
        searchInfo: {
          ...state.searchInfo,
          fromStop: state.searchInfo.toStop,
          fromID: state.searchInfo.toID,
          toStop: state.searchInfo.fromStop,
          toID: state.searchInfo.fromID
        }
      }
    case actionNames.CHANGE_ERRORTEXT :
      return {
        ...state,
        errorText: action.errorText
      }
    default:
      return state
  }
}

export function storeTimetable (state = {
  isFetching: false,
  items: []
}, action) {
  switch (action.type) {
    case actionNames.LOAD_TIMETABLE :
      return requestDoSomething(state)
    case actionNames.SUCCESS_TIMETABLE :
      return successDoSomething(state, action, action.items)
    default:
      return state
  }
}

export function searchTrainDetail (state = {
  trainDialog: {
    open: false,
    type: '',
    date: '',
    number: '',
    content: ''
  }
}, action) {
  switch (action.type) {
    case actionNames.TOGGLE_TRAIN_DIALOG :
      return {
        ...state,
        trainDialog: {
          open: !state.trainDialog.open,
          type: action.trainDialog.type,
          date: action.trainDialog.date,
          number: action.trainDialog.number,
          content: action.trainDialog.content
        }
      }
    default:
      return state
  }
}

export function storeTrainDetail (state = {
  isFetching: false,
  items: []
}, action) {
  switch (action.type) {
    case actionNames.LOAD_TRAIN_DETAIL :
      return requestDoSomething(state)
    case actionNames.SUCCESS_TRAIN_DETAIL :
      return successDoSomething(state, action, action.items)
    case actionNames.FAILURE_TRAIN_DETAIL :
      return failureDoSomething(state, action)
    default:
      return state
  }
}
