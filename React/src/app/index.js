import React from 'react'
import { render } from 'react-dom'

import { Provider } from 'react-redux'
import { browserHistory } from 'react-router'
import { syncHistoryWithStore } from 'react-router-redux'
import { CookiesProvider } from 'react-cookie'

import rootSaga from './saga'
import configureStore from './store'

import routes from './routes.js'

import injectTapEventPlugin from 'react-tap-event-plugin'
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider'

/* For Material-UI which provides onTouchTap() to all React Components. */
injectTapEventPlugin()

const initialState = window.__INITIAL_STATE__
const store = configureStore(initialState)
const history = syncHistoryWithStore(browserHistory, store)

/* remove comment mark below after you add sagas codes. */
store.runSaga(rootSaga)

import './library/fbsdk.js'
import './css/w3.css'
import './css/main.css'

const rootElement = document.getElementById('root')
const Main = () => {
  return (
    <Provider store={store}>
      { /* Tell the Router to use our enhanced history */ }
      <CookiesProvider>
        <MuiThemeProvider>
          {routes(history)}
        </MuiThemeProvider>
      </CookiesProvider>
    </Provider>
  )
}

let renderDom = () => {
  render(<Main />, rootElement)
}

renderDom()
