import { createStore, applyMiddleware } from 'redux'
import { browserHistory } from 'react-router'
import { routerMiddleware } from 'react-router-redux'
import createLogger from 'redux-logger'
import createSagaMiddleware from 'redux-saga'

import rootReducer from '../reducer'
import { LOGGER } from '../action'

// 監聽 saga 事件駐列 -- start
export const activeEffectIds = []
const watchEffectEnd = (effectId) => {
  const effectIndex = activeEffectIds.indexOf(effectId)

  if (effectIndex !== -1) {
    activeEffectIds.splice(effectIndex, 1)
  }
}

const createSagaMiddlewareOpt = {
  sagaMonitor: {
    actionDispatched: (action) => {},
    effectCancelled: watchEffectEnd, // 當 effect 被取消時
    effectRejected: watchEffectEnd,  // 當 effect 有一個錯誤被拒絕時
    effectResolved: watchEffectEnd,  // 當 effect 成功被解決時
    effectTriggered: (e) => {        // 當一個 effect 被觸發時
      if (e.effect.CALL) {
        activeEffectIds.push(e.effectId)
      }
    }
  }
}
// 監聽 saga 事件駐列 -- end

const loggerMiddleware = createLogger()
const sagaMiddleware = createSagaMiddleware(createSagaMiddlewareOpt)
const middleware = routerMiddleware(browserHistory)

let loggerConfig = []
if (process.env.NODE_ENV === 'development') {
  LOGGER && (loggerConfig = [loggerMiddleware])
}

export default function configureStore (initialState) {
  return {
    ...createStore(
      rootReducer,
      initialState,
      applyMiddleware(
        ...loggerConfig,
        sagaMiddleware,
        middleware,
      )
    ),
    runSaga: sagaMiddleware.run
  }
}
