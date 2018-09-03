import * as actionNames from '../action'

export function drawer (state = {
  docked: false,
  open: false,
  innerWidth: null,
  innerHeight: null
}, action) {
  switch (action.type) {
    case actionNames.RESIZE_DRAWER :
      if (window.innerWidth > 1220) {
        return {
          ...state,
          docked: true,
          open: true,
          innerHeight: window.innerHeight,
          innerWidth: window.innerWidth
        }
      } else {
        return {
          ...state,
          docked: false,
          open: false,
          innerHeight: window.innerHeight,
          innerWidth: window.innerWidth
        }
      }
    case actionNames.CHANGE_DRAWER_VISIBILITY :
      if (window.innerWidth > 1220) {
        return state
      } else {
        return {
          ...state,
          open: !state.open
        }
      }
    default :
      return state
  }
}

export function page (state = {
  language: 'Zh'
}, action) {
  switch (action.type) {
    case actionNames.CHANGE_LANGUAGE :
      return {
        ...state,
        language: action.language
      }
    default :
      return state
  }
}
