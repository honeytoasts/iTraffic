import React, { PropTypes, Component } from 'react'
import { connect } from 'react-redux'
import { Router, Route, IndexRoute, Link } from 'react-router'
import {
  AppBar, IconButton, IconMenu, MenuItem
} from 'material-ui'
import { ImageDehaze, ActionLanguage } from 'material-ui/svg-icons'
import { grey100, grey900 } from 'material-ui/styles/colors'

import {
  changeDrawerVisibility, changeLanguage
} from '../action'

const styles = {
  title: {
    color: 'rgb(71,82,94)',
    fontSize: 30
  },
  appbar: {
    position: 'fixed',
    top: 0,
    left: 0,
    background: grey100
  },
  menu: {
    paddingTop: 100
  }
}

class AppBars extends Component {
  render () {
    const {changeDrawerVisibility, changeLanguage, pathname, search} = this.props

    var pathnames = ''
    if (pathname.indexOf('En') === -1) {
      if (pathname === '/') { pathnames = '' } else { pathnames = pathname }
    } else { pathnames = pathname.substring(0, pathname.length - 3) }

    return (
      <AppBar style={styles.appbar}
        title='iTraffic'
        titleStyle={styles.title}
        iconElementLeft={
          <IconButton >
            <ImageDehaze color={grey900} />
          </IconButton>
        }
        onLeftIconButtonClick={changeDrawerVisibility}
        iconElementRight={
          <IconMenu
            iconButtonElement={
              <IconButton>
                <ActionLanguage />
              </IconButton>
            }
            iconStyle={{fill: grey900}}
          >
            <MenuItem
              primaryText='中文'
              onClick={() => { changeLanguage('Zh') }}
              containerElement={<Link to={pathnames + search} />}
            />
            <MenuItem
              primaryText='English'
              onClick={() => { changeLanguage('En') }}
              containerElement={<Link to={pathnames + '/En' + search} />}
            />
          </IconMenu>
        }
      />
    )
  }
}

AppBars.propTypes = {
  changeDrawerVisibility: PropTypes.func,
  changeLanguage: PropTypes.func
}

function mapStateToProps (state) {
  return {
  }
}

export default connect(mapStateToProps, {
  changeDrawerVisibility, changeLanguage
})(AppBars)
