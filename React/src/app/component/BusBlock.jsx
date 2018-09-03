import React, { PropTypes, Component } from 'react'
import { connect } from 'react-redux'
// import { Link } from 'react-router'
import { ListItem } from 'material-ui/List'
import { white } from 'material-ui/styles/colors'
import { HardwareKeyboardArrowRight } from 'material-ui/svg-icons'

import BusDetailBlock from '../component/BusDetailBlock.jsx'

import {
  changeBusDetail, toggleBusDialog, loadBusDetail
} from '../action'

const style = {
  listitem: {
    color: 'white',
    backgroundColor: 'rgba(52,63,75,0.54)'
  }
}

class BusBlock extends Component {
  render () {
    const {
      type, url, name, headsign, busDialog, changeBusDetail, toggleBusDialog, loadBusDetail
    } = this.props

    return (
      <ListItem style={style.listitem}
        primaryText={name}
        secondaryText={<div style={{ color: 'white' }}>{headsign}</div>}
        rightIcon={<HardwareKeyboardArrowRight color={white} />}
        onClick={() => {
          changeBusDetail({...busDialog, type: type, url: url, name: name, headsign: headsign, content: <BusDetailBlock />})
          loadBusDetail()
          toggleBusDialog()
        }}
      />
    )
  }
}

function mapStateToProps (state) {
  const {busDialog} = state.searchBusDetail
  return {
    busDialog
  }
}

export default connect(mapStateToProps, {
  changeBusDetail, toggleBusDialog, loadBusDetail
})(BusBlock)
