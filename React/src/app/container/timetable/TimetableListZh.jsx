import React, { PropTypes, Component } from 'react'
import { connect } from 'react-redux'

import { white } from 'material-ui/styles/colors'
import Dialog from 'material-ui/Dialog'
import FlatButton from 'material-ui/FlatButton'
import ContentSort from 'material-ui/svg-icons/content/sort'
import { EditorAttachMoney, ImageTimelapse, ImageTimer } from 'material-ui/svg-icons'
import IconMenu from 'material-ui/IconMenu'
import MenuItem from 'material-ui/MenuItem'
import IconButton from 'material-ui/IconButton'
import CircularProgress from 'material-ui/CircularProgress'

import TrainBlock from '../../component/TrainBlock.jsx'

import {
  loadStopandDate, changeTrainSearchInfo, loadTimetable, toggleTrainDialog
} from '../../action'

const styles = {
  infoBlock: {
    margin: '10px',
    padding: '10px 10px',
    backgroundColor: 'rgb(7, 80, 116)',
    position: 'relative',
    height: '95px',
    fontSize: '15px',
    color: 'white',
    whiteSpace: 'nowrap'
  },
  info: {
    marginLeft: '15px',
    marginRight: '15px'
  }
}

class TimetableListZh extends Component {
  componentWillMount () {
    const {searchInfo, loadStopandDate, changeTrainSearchInfo, loadTimetable, location, params} = this.props

    var fromID = location.query.from
    var toID = location.query.to
    var date = new Date(location.query.date)
    var time = new Date(location.query.date + ' ' + location.query.time)
    var type = params.type === 'THSR' ? '高鐵' : '台鐵'

    changeTrainSearchInfo({...searchInfo, type: type, fromID: fromID, toID: toID, date: date, time: time})
    loadStopandDate()
    loadTimetable()
  }
  render () {
    const {searchInfo, changeTrainSearchInfo, loadTimetable, storeTimetable, toggleTrainDialog, trainDialog, params} = this.props
    const actions = [
      <FlatButton
        label='CLOSE'
        primary
        onClick={() => { toggleTrainDialog({...trainDialog}) }}
      />
    ]
    let date = new Date(searchInfo.date.getTime() - (searchInfo.date.getTimezoneOffset() * 60000)).toJSON().substring(0, 10)
    let time = new Date(searchInfo.time.getTime() - (searchInfo.time.getTimezoneOffset() * 60000)).toJSON().substring(11, 16)

    return (
      <div>
        <div>
          <div style={styles.infoBlock}>
            <div style={styles.info}>
              <div style={{color: 'orange'}}> <h5 style={{margin: '0 0 0 0'}}>{searchInfo.type}</h5> </div>
              <div>
                從&nbsp;&nbsp;{searchInfo.fromStop}&nbsp;&nbsp;
                往&nbsp;&nbsp;{searchInfo.toStop}
              </div>
              <div>{date}&nbsp;&nbsp;{time} &nbsp;&nbsp; 出發</div>
            </div>
          </div>
          {/* 時刻表結果 */}
          {
            storeTimetable.isFetching ? (
              <CircularProgress />
            ) : (
              storeTimetable.items.length > 0 ? (
                storeTimetable.items.filter((f) => f.departure >= time).map((d, i) =>
                  <TrainBlock key={i} type={searchInfo.type} date={date} number={d.number} traintype={d.traintype} price={d.price}
                    departure={d.departure} arrive={d.arrive} duration={d.duration} />
                )
              ) : (<div style={{padding: '10px 10px'}}>查無車次，請重新查詢</div>)
            )
          }
        </div>
        {/* 即時動態dialog */}
        <Dialog
          className='alertDialog'
          contentStyle={{width: '100%', height: '150%'}}
          title={<div><div>{searchInfo.type}&nbsp;&nbsp;&nbsp;{trainDialog.number}</div></div>}
          actions={actions}
          autoScrollBodyContent
          modal={false}
          onRequestClose={() => { toggleTrainDialog({...trainDialog}) }}
          open={trainDialog.open}
          bodyStyle={{padding: '0 0 0 0 '}}
        >
          <div>{trainDialog.content}</div>
        </Dialog>
        {/* 排序時刻表按鈕 */}
        <div>
          <IconMenu
            style={{position: 'fixed', right: 25, bottom: 25}}
            iconButtonElement={
              <IconButton
                iconStyle={{width: 50, height: 50}}
                style={{backgroundColor: '#075074', width: 60, height: 60, padding: 5}}
                className='w3-circle '>
                <ContentSort color={white} />
              </IconButton>
            }
            anchorOrigin={{horizontal: 'right', vertical: 'bottom'}}
            targetOrigin={{horizontal: 'right', vertical: 'bottom'}}
          >
            <MenuItem
              className={searchInfo.sortBy === 'price_a' ? 'w3-orange' : ''}
              leftIcon={<EditorAttachMoney color={'w3-black'} />}
              primaryText='票價'
              onClick={() => {
                changeTrainSearchInfo({...searchInfo, sortBy: 'price_a'})
                loadTimetable()
              }}
            />
            <MenuItem
              className={searchInfo.sortBy === 'duration_a' ? 'w3-orange' : ''}
              leftIcon={<ImageTimelapse color={'w3-black'} />}
              primaryText='行車時間'
              onClick={() => {
                changeTrainSearchInfo({...searchInfo, sortBy: 'duration_a'})
                loadTimetable()
              }}
            />
            <MenuItem
              className={searchInfo.sortBy === 'departure_a' ? 'w3-orange' : ''}
              leftIcon={<ImageTimer color={'w3-black'} />}
              primaryText='出發時間'
              onClick={() => {
                changeTrainSearchInfo({...searchInfo, sortBy: 'departure_a'})
                loadTimetable()
              }}
            />
            <MenuItem
              className={searchInfo.sortBy === 'arrive_a' ? 'w3-orange' : ''}
              leftIcon={<ImageTimer color={'w3-black'} />}
              primaryText='抵達時間'
              onClick={() => {
                changeTrainSearchInfo({...searchInfo, sortBy: 'arrive_a'})
                loadTimetable()
              }}
             />
          </IconMenu>
        </div>
      </div>

    )
  }
}

TimetableListZh.propTypes = {
  loadStopandDate: PropTypes.func,
  changeTrainSearchInfo: PropTypes.func,
  searchInfo: PropTypes.object,
  loadTimetable: PropTypes.func,
  toggleTrainDialog: PropTypes.func
}

function mapStateToProps (state) {
  const {searchInfo} = state.searchTimetable
  const {isFetching, items} = state.storeTimetable
  const {trainDialog} = state.searchTrainDetail
  const {language} = state.page
  return {
    page: {
      language
    },
    searchInfo,
    storeTimetable: {
      isFetching,
      items
    },
    trainDialog
  }
}

export default connect(mapStateToProps, {
  loadStopandDate, changeTrainSearchInfo, loadTimetable, toggleTrainDialog
})(TimetableListZh)
