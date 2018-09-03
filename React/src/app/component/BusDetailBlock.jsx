import React, { PropTypes, Component } from 'react'
import { connect } from 'react-redux'
import Avatar from 'material-ui/Avatar'
import { ListItem } from 'material-ui/List'
import CircularProgress from 'material-ui/CircularProgress'

import {
  changeBusDetail, loadBusDetail
} from '../action'

const style = {
  redavatar: {
    borderRadius: 5,
    width: '70px',
    textAlign: 'center',
    backgroundColor: 'red',
    color: 'white'
  },
  grayavatar: {
    borderRadius: 5,
    width: '70px',
    textAlign: 'center',
    color: 'white'
  },
  brownavatar: {
    borderRadius: 5,
    width: '70px',
    textAlign: 'center',
    backgroundColor: '#795548',
    color: 'white'
  },
  orangeavatar: {
    borderRadius: 5,
    width: '70px',
    textAlign: 'center',
    backgroundColor: '#FFA726',
    color: 'white'
  }
}

class BusDetailBlock extends Component {
  render () {
    const {isFetching, isFetchingPTX, items} = this.props
    return (
      <div>
        {
          isFetching ? (
            <CircularProgress />
          ) : (
            items.length > 0 ? (
              items.map((d, i) =>
                <ListItem
                  className={i % 2 === 1 ? 'w3-light-grey' : ''}
                  key={i}
                  primaryText={<span >{d.stop}</span>}
                  secondaryText={
                    isFetchingPTX ? (
                      <CircularProgress />
                    ) : (
                      ((d.state === 'Approach' || d.state === '即將進站') && <Avatar style={style.redavatar}> {d.state} </Avatar>) ||
                      (((d.state >= '1min' || d.state >= '1分') && (d.state <= '5min' || d.state <= '5分') && (d.state.length === 4 || d.state.length === 2)) && <Avatar style={style.orangeavatar}> {d.state} </Avatar>) ||
                      ((d.state.indexOf('min') !== -1 || d.state.indexOf('分') !== -1) && <Avatar style={style.brownavatar}> {d.state} </Avatar>) ||
                      (<Avatar style={style.grayavatar}> {d.state} </Avatar>)
                    )
                  }
                />
              )
            ) : ('No Data.')
          )
        }
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { isFetching, isFetchingPTX, items } = state.storeBusDetail
  return {
    isFetching,
    isFetchingPTX,
    items
  }
}

export default connect(mapStateToProps, {
  changeBusDetail, loadBusDetail
})(BusDetailBlock)
