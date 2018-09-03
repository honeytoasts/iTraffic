import React, { PropTypes, Component } from 'react'
import { connect } from 'react-redux'
import { Link } from 'react-router'
import Drawer from 'material-ui/Drawer'
import { List, ListItem } from 'material-ui/List'
import { ActionHome, MapsPlace, MapsTransferWithinAStation, ActionDateRange } from 'material-ui/svg-icons'
import ActionInfo from 'material-ui/svg-icons/action/info'

import {
    changeDrawerVisibility
} from '../action'

const styles = {
  sidebar: {
    top: 64
  }
}

class Sidebar extends Component {
  render () {
    const { drawer, changeDrawerVisibility, page } = this.props

    return (
      <Drawer
        open={drawer.open}
        onRequestChange={changeDrawerVisibility}
        docked={drawer.docked}
        containerStyle={styles.sidebar}
      >
        <hr />
        <List>
          <ListItem
            primaryText={page.language === 'Zh' ? '首頁' : 'Home Page'}
            containerElement={page.language === 'Zh' ? <Link to='/' /> : <Link to='/En' />}
            leftIcon={<ActionHome />}
            onClick={changeDrawerVisibility}
          />
          <ListItem
            primaryText={page.language === 'Zh' ? '時刻表查詢' : 'Timetable'}
            containerElement={page.language === 'Zh' ? <Link to='/timetable' /> : <Link to='/timetable/En' />}
            leftIcon={<ActionDateRange />}
            onClick={changeDrawerVisibility}
          />
          <ListItem
            primaryText={page.language === 'Zh' ? '公車動態查詢' : 'Bus Real Time'}
            containerElement={page.language === 'Zh' ? <Link to='/bussearch' /> : <Link to='/bussearch/En' />}
            leftIcon={<ActionDateRange />}
            onClick={changeDrawerVisibility}
          />
          <ListItem
            primaryText={page.language === 'Zh' ? '關於我們' : 'About'}
            containerElement={page.language === 'Zh' ? <Link to='/about' /> : <Link to='/about/En' />}
            leftIcon={<ActionInfo />}
            onClick={changeDrawerVisibility}
          />
        </List>
      </Drawer>
    )
  }
}

Sidebar.propTypes = {
  drawer: PropTypes.object,
  changeDrawerVisibility: PropTypes.func
}

function mapStateToProps (state) {
  const { docked, open } = state.drawer
  const { language } = state.page
  return {
    drawer: {
      docked,
      open
    },
    page: {
      language
    }
  }
}

export default connect(mapStateToProps, {
  changeDrawerVisibility
})(Sidebar)
