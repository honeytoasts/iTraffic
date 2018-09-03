import React, {PropTypes, Component} from 'react'
import { connect } from 'react-redux'

import Subheader from 'material-ui/Subheader'
import Dialog from 'material-ui/Dialog'
import FlatButton from 'material-ui/FlatButton'
import BusBlock from '../component/BusBlock.jsx'
import CircularProgress from 'material-ui/CircularProgress'

import '../library/yt.js'

import {loadBus, changeBusSearchInfo, toggleBusDialog, changeBusDetail, loadBusDetail} from '../action'

const style = {
  subheader: {
    color: '#17B8E2',
    backgroundColor: '#343F4B',
    lineHeight: 2.5
  },
  title: {
    backgroundColor: 'rgba(33, 150, 243,1)',
    fontSize: 20,
    color: 'white'
  }
}

class BusSearch extends Component {
  componentWillMount () {
    const { searchInfo, loadBus } = this.props

    if (searchInfo.name !== '') {
      loadBus()
    }
  }
  componentWillUpdate (nextProps, nextState) {
    const {searchInfo, loadBus} = this.props

    if (nextProps.location.pathname !== this.props.location.pathname && searchInfo.name !== '') { loadBus() }
  }
  render () {
    const {page, searchInfo, loadBus, storeBus, changeBusDetail, loadBusDetail, busDialog, changeBusSearchInfo, toggleBusDialog} = this.props

    let arr = []
    let groupbylist = []

    // dialog裡面的button
    const actions = [
      <FlatButton
        className={busDialog.direction === 0 ? 'w3-blue' : ''}
        label={page.language === 'Zh' ? '去程' : 'Outbound'}
        onClick={() => {
          changeBusDetail({...busDialog, direction: 0})
          loadBusDetail()
        }}
      />,
      <FlatButton
        className={busDialog.direction === 1 ? 'w3-blue' : ''}
        label={page.language === 'Zh' ? '返程' : 'Inbound'}
        onClick={() => {
          changeBusDetail({...busDialog, direction: 1})
          loadBusDetail()
        }}
      />,
      <FlatButton
        label={page.language === 'Zh' ? '關閉' : 'Close'}
        primary
        onClick={() => {
          changeBusDetail({...busDialog, direction: 0})
          toggleBusDialog()
        }}
      />
    ]

    return (
      <div className='w3-container  w3-margin-top'>
        <input
          className='w3-input '
          type='text'
          placeholder={page.language === 'Zh' ? '輸入路線名稱' : 'Input the route name'}
          onChange={(e) => {
            changeBusSearchInfo({...searchInfo, name: e.target.value})
            if (e.target.value !== '') {
              loadBus()
            } else {
              changeBusSearchInfo({...searchInfo, name: '空白'})
              loadBus()
            }
          }} />
        <div id='bustimeresult' style={{padding: '20px 0'}}>
          {storeBus.isFetching ? (
            <CircularProgress />
        ) : (
          storeBus.items.length > 0 ? (
            <div>
              {
                (() => {
                  storeBus.items.map((d) => { // group by ["Taichung", "Tainan", "Kinmen", "Kaohsiung"]
                    arr.push({type: d.type})
                  })
                  const groupby = arr.groupBy('type')
                  groupbylist = Object.keys(groupby)
                }
                )()
              }
              {
                groupbylist.map((d, i) => // for loop 4 times
                  <div key={i}>
                    <Subheader style={style.subheader}>{d}</Subheader>
                    {
                      storeBus.items.filter((f) => f.type === d).map((dd, i) =>
                        <BusBlock key={i} type={dd.type} url={dd.url} name={dd.name} headsign={dd.headsign} />
                      )
                    }
                  </div>
                )
              }
            </div>
          ) : ('')
        )}
        </div>
        <Dialog // 不能放在map裡 不然會一次噴出好幾個
          className='alertDialog'
          contentStyle={{width: '90%'}}
          title={<div><div>{busDialog.name}</div><div>{busDialog.headsign}</div></div>}
          titleStyle={style.title}
          actions={actions}
          autoScrollBodyContent
          modal={false}
          open={busDialog.open}
          onRequestClose={() => { toggleBusDialog() }}
          autoDetectWindowHeight
        >
          <div>{busDialog.content}</div>
        </Dialog>
      </div>
    )
  }
}

BusSearch.propTypes = {
  loadBus: PropTypes.func
}

function mapStateToProps (state) {
  const {searchInfo} = state.searchBus
  const {isFetching, items} = state.storeBus
  const {busDialog} = state.searchBusDetail
  const {language} = state.page

  return {
    page: {
      language
    },
    searchInfo,
    storeBus: {
      isFetching,
      items
    },
    busDialog
  }
}

export default connect(mapStateToProps, {
  loadBus, changeBusSearchInfo, toggleBusDialog, loadBusDetail, changeBusDetail
})(BusSearch)
