import React, { PropTypes, Component } from 'react'
import { connect } from 'react-redux'

import Header from './Header.jsx'
import Sidebar from './Sidebar.jsx'
import { resizeDrawer, changeLanguage } from '../action'

class App extends Component {
  componentWillMount () {
    const { changeLanguage } = this.props
    const language = this.props.location.pathname.indexOf('En') === -1 ? 'Zh' : 'En'
    changeLanguage(language)
  }
  componentDidMount () {
    const {
      resizeDrawer
    } = this.props
    resizeDrawer()

    window.onresize = () => {
      resizeDrawer()
    }
  }
  componentWillUpdate (nextProps, nextState) {
    const {changeLanguage} = this.props

    if (nextProps.location.pathname !== this.props.location.pathname) {
      const language = nextProps.location.pathname.indexOf('En') === -1 ? 'Zh' : 'En'
      changeLanguage(language)
    }
  }
  render () {
    const { children } = this.props

    return (
      <div>
        <Header pathname={this.props.location.pathname} search={this.props.location.search} />
        <Sidebar />
        <div className='iTraffic-screen'>
          {children}
        </div>
      </div>
    )
  }
}

App.propTypes = {
  resizeDrawer: PropTypes.func,
  changeLanguage: PropTypes.func
}

function mapStateToProps (state) {
  return {
  }
}

export default connect(mapStateToProps, {
  resizeDrawer, changeLanguage
})(App)
