import action from '../library/action.js'

// 側邊欄
export const RESIZE_DRAWER = 'RESIZE_DRAWER'                       // 網頁載入後，根據視窗寬度所給定的初始值
export const CHANGE_DRAWER_VISIBILITY = 'CHANGE_DRAWER_VISIBILITY' // 使用者點擊選單行為
export const resizeDrawer = () => action(RESIZE_DRAWER)
export const changeDrawerVisibility = () => action(CHANGE_DRAWER_VISIBILITY)

// 語言
export const CHANGE_LANGUAGE = 'CHANGE_LANGUAGE'
export const changeLanguage = (language) => action(CHANGE_LANGUAGE, {language})
