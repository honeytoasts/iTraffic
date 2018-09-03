import action from '../library/action.js'

// 查詢條件
export const CHANGE_BUS_SEARCHINFO = 'CHANGE_BUS_SEARCHINFO'
export const changeBusSearchInfo = (searchInfo) => action(CHANGE_BUS_SEARCHINFO, {searchInfo})

// 載入所有公車
export const LOAD_BUS = 'LOAD_BUS'
export const SUCCESS_BUS = 'SUCCESS_BUS'
export const loadBus = () => action(LOAD_BUS)
export const successBus = (items, receiveAt = Date.now()) => action(SUCCESS_BUS, { items, receiveAt })

// 查詢公車資訊
export const TOGGLE_BUS_DIALOG = 'TOGGLE_BUS_DIALOG'
export const CHANGE_BUS_DETAIL = 'CHANGE_BUS_DETAIL'
export const toggleBusDialog = () => action(TOGGLE_BUS_DIALOG)
export const changeBusDetail = (busDialog) => action(CHANGE_BUS_DETAIL, {busDialog})

export const LOAD_BUS_DETAIL = 'LOAD_BUS_DETAIL'
export const LOAD_BUS_PTX = 'LOAD_BUS_PTX'
export const SUCCESS_BUS_DETAIL = 'SUCCESS_BUS_DETAIL'
export const FAILURE_BUS_DETAIL = 'FAILURE_BUS_DETAIL'
export const loadBusDetail = () => action(LOAD_BUS_DETAIL)
export const loadBusPTX = () => action(LOAD_BUS_PTX)
export const successBusDetail = (items, receiveAt = Date.now()) => action(SUCCESS_BUS_DETAIL, {items, receiveAt})
export const failureBusDetail = (err) => action(FAILURE_BUS_DETAIL, {err})
