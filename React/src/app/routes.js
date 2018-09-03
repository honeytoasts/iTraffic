import React from 'react'
import { Router, Route, IndexRoute } from 'react-router'

// root
import App from './container/App.jsx'
import Timetable from './container/timetable/Timetable.jsx'
import TimetableSearchZh from './container/timetable/TimetableSearchZh.jsx'
import TimetableSearchEn from './container/timetable/TimetableSearchEn.jsx'
import TimetableListZh from './container/timetable/TimetableListZh.jsx'
import TimetableListEn from './container/timetable/TimetableListEn.jsx'
import BusSearch from './container/BusSearch.jsx'
import About from './container/About.jsx'
const routes = (history) => (
  <Router history={history}>
    <Route path='/' component={App}>
      <IndexRoute component={About} />
      <Route path='/En' component={About} />
      <Route path='/about' component={About} />
      <Route path='/about/En' component={About} />
      <Route path='/timetable' component={Timetable} />
      <Route path='/timetable/En' component={Timetable} />
      <Route path='/timetablesearch/:type' component={TimetableSearchZh} />
      <Route path='/timetablesearch/:type/En' component={TimetableSearchEn} />
      <Route path='/timetablelist/:type' component={TimetableListZh} />
      <Route path='/timetablelist/:type/En' component={TimetableListEn} />
      <Route path='/bussearch' component={BusSearch} />
      <Route path='/bussearch/En' component={BusSearch} />
    </Route>
  </Router>
)

export default routes
