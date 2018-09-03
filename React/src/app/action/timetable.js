import action from '../library/action.js'

// 搜尋條件
export const LOAD_STOP_AND_DATE = 'LOAD_STOP_AND_DATE'
export const SUCCESS_STOP_AND_DATE = 'SUCCESS_STOP_AND_DATE'
export const loadStopandDate = () => action(LOAD_STOP_AND_DATE)
export const successStopandDate = (items) => action(SUCCESS_STOP_AND_DATE, {items})

// 查詢
export const CHANGE_TRAIN_SEARCHINFO = 'CHANGE_TRAIN_SEARCHINFO'
export const CHANGE_STOP = 'CHANGE_STOP'
export const CHANGE_ERRORTEXT = 'CHANGE_ERRORTEXT'
export const changeTrainSearchInfo = (searchInfo) => action(CHANGE_TRAIN_SEARCHINFO, {searchInfo})
export const changeStop = () => action(CHANGE_STOP)
export const changeErrortext = (errorText) => action(CHANGE_ERRORTEXT, {errorText})

// 時刻表
export const LOAD_TIMETABLE = 'LOAD_TIMETABLE'
export const SUCCESS_TIMETABLE = 'SUCCESS_TIMETABLE'
export const loadTimetable = () => action(LOAD_TIMETABLE)
export const successTimetable = (items, receiveAt = Date.now()) => action(SUCCESS_TIMETABLE, { items, receiveAt })

// 班次資訊
export const TOGGLE_TRAIN_DIALOG = 'TOGGLE_TRAIN_DIALOG'
export const toggleTrainDialog = (trainDialog) => action(TOGGLE_TRAIN_DIALOG, {trainDialog})

export const LOAD_TRAIN_DETAIL = 'LOAD_TRAIN_DETAIL'
export const SUCCESS_TRAIN_DETAIL = 'SUCCESS_TRAIN_DETAIL'
export const FAILURE_TRAIN_DETAIL = 'FAILURE_TRAIN_DETAIL'
export const loadTrainDetail = () => action(LOAD_TRAIN_DETAIL)
export const successTrainDetail = (items, receiveAt = Date.now()) => action(SUCCESS_TRAIN_DETAIL, {items, receiveAt})
export const failureTrainDetail = (err) => action(FAILURE_TRAIN_DETAIL, {err})
