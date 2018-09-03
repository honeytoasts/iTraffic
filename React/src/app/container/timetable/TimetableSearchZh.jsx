import React, { PropTypes, Component } from 'react'
import { connect } from 'react-redux'
import { Link } from 'react-router'
import IconButton from 'material-ui/IconButton'
import { NavigationMoreVert, ActionSwapVert } from 'material-ui/svg-icons'
import RaisedButton from 'material-ui/RaisedButton'
import AutoComplete from 'material-ui/AutoComplete'
import DatePicker from 'material-ui/DatePicker'
import TimePicker from 'material-ui/TimePicker'

import {
  loadStopandDate,
  changeTrainSearchInfo,
  changeStop,
  changeErrortext
} from '../../action'

const styles = {
  smallIcon: {
    width: 20,
    height: 20
  },
  mediumIcon: {
    width: 30,
    height: 30
  },
  small: {
    marginTop: 25,
    paddingLeft: 0,
    position: 'absolute',
    right: '30px'
  },
  search: {
    width: '90%'
  },
  change: {
    position: 'absolute',
    right: '10px',
    top: '160px',
    height: '160px'
  },
  error: {
    textAlign: 'left'
  }
}

class TimetableSearchZh extends Component {
  componentWillMount () {
    const { searchInfo, loadStopandDate, changeTrainSearchInfo, changeErrortext, params } = this.props
    const type = params.type === 'THSR' ? '高鐵' : '台鐵'
    changeTrainSearchInfo({...searchInfo, type: type})
    changeErrortext({fromError: '', toError: ''})
    loadStopandDate()
  }
  render () {
    const {
      searchInfo, searchLimit, errorText, innerHeight, changeTrainSearchInfo, changeStop, changeErrortext
    } = this.props

    return (
      <div>
        <div style={{height: (innerHeight), textAlign: 'center'}} className='w3-padding-16'>
          <div className='search'>
            <h4 style={{color: 'white', backgroundColor: '#062c4c9c', padding: '0 5px 0 5px'}}>{searchInfo.type}</h4>
            <div className='textfield'>
              <table className='searchtable'>
                <tr>
                  <td>
                    <AutoComplete
                      hintText='出發站'
                      dataSource={searchLimit.stopName}
                      floatingLabelText='出發站'
                      fullWidth
                      searchText={searchInfo.fromStop}
                      errorStyle={styles.error}
                      errorText={errorText.fromError}
                      onUpdateInput={(searchText) => {
                        changeTrainSearchInfo({...searchInfo, fromStop: searchText})
                      }}
                      filter={(text, key) => {
                        return key.toLowerCase().includes(text.toLowerCase())
                      }}
                      onBlur={(e) => {
                        if (searchLimit.stopName.indexOf(e.target.value) === -1) {
                          changeErrortext({...errorText, fromError: '請輸入正確的車站名稱'})
                        } else {
                          changeErrortext({...errorText, fromError: ''})
                          changeTrainSearchInfo({...searchInfo, fromID: searchLimit.stopID[searchLimit.stopName.indexOf(searchInfo.fromStop)]})
                        }
                      }}
                    />
                    <IconButton
                      iconStyle={styles.smallIcon}
                      style={styles.small}
                    >
                      <NavigationMoreVert />
                    </IconButton>
                  </td>
                </tr>
                <tr>
                  <td>
                    <AutoComplete
                      hintText='抵達站'
                      dataSource={searchLimit.stopName}
                      floatingLabelText='抵達站'
                      fullWidth
                      searchText={searchInfo.toStop}
                      errorStyle={styles.error}
                      errorText={errorText.toError}
                      onUpdateInput={(searchText) => {
                        changeTrainSearchInfo({...searchInfo, toStop: searchText})
                      }}
                      filter={(text, key) => {
                        return key.toLowerCase().includes(text.toLowerCase())
                      }}
                      onBlur={(e) => {
                        if (searchLimit.stopName.indexOf(e.target.value) === -1) {
                          changeErrortext({...errorText, toError: '請輸入正確的車站名稱'})
                        } else {
                          changeErrortext({...errorText, toError: ''})
                          changeTrainSearchInfo({...searchInfo, toID: searchLimit.stopID[searchLimit.stopName.indexOf(searchInfo.toStop)]})
                        }
                      }}
                    />
                    <IconButton
                      iconStyle={styles.smallIcon}
                      style={styles.small}
                    >
                      <NavigationMoreVert />
                    </IconButton>
                  </td>
                </tr>
                <tr>
                  <td colSpan='2'>
                    <DatePicker
                      floatingLabelText='日期'
                      fullWidth
                      minDate={searchLimit.minDate}
                      maxDate={searchLimit.maxDate}
                      value={searchInfo.date ? searchInfo.date : new Date()}
                      onChange={(event, date) => {
                        changeTrainSearchInfo({...searchInfo, date: date})
                      }}
                    />
                  </td>
                </tr>
                <tr>
                  <td colSpan='2'>
                    <TimePicker
                      format='24hr'
                      floatingLabelText='時間'
                      fullWidth
                      value={searchInfo.time ? searchInfo.time : new Date()}
                      onChange={(event, time) => {
                        changeTrainSearchInfo({...searchInfo, time: time})
                      }}
                    />
                  </td>
                </tr>
              </table>
            </div>
            <IconButton iconStyle={styles.mediumIcon} style={styles.change} onClick={changeStop}>
              <ActionSwapVert />
            </IconButton>
            <RaisedButton
              backgroundColor='#4682B4'
              labelColor='white'
              label='搜尋' style={styles.search}
              containerElement={
                searchInfo.type === '高鐵' || searchInfo.type === 'THSR'
                ? <Link to={'/timetablelist/THSR?from=' + searchInfo.fromID + '&to=' + searchInfo.toID +
                  '&date=' + new Date(searchInfo.date.getTime() - searchInfo.date.getTimezoneOffset() * 60000).toJSON().substring(0, 10) +
                  '&time=' + new Date(searchInfo.time.getTime() - searchInfo.time.getTimezoneOffset() * 60000).toJSON().substring(11, 16)} />
                : <Link to={'/timetablelist/TRA?from=' + searchInfo.fromID + '&to=' + searchInfo.toID +
                  '&date=' + new Date(searchInfo.date.getTime() - searchInfo.date.getTimezoneOffset() * 60000).toJSON().substring(0, 10) +
                  '&time=' + new Date(searchInfo.time.getTime() - searchInfo.time.getTimezoneOffset() * 60000).toJSON().substring(11, 16)} />
              }
            />
          </div>
        </div>
      </div>
    )
  }
}

TimetableSearchZh.propTypes = {
  loadStopandDate: PropTypes.func,
  innerHeight: PropTypes.number,
  changeTrainSearchInfo: PropTypes.func,
  changeStop: PropTypes.func,
  changeErrortext: PropTypes.func,
  searchInfo: PropTypes.object,
  searchLimit: PropTypes.object,
  errorText: PropTypes.object
}

function mapStateToProps (state) {
  const {searchInfo, searchLimit, errorText} = state.searchTimetable
  const {innerHeight} = state.drawer
  const {language} = state.page

  return {
    searchInfo,
    searchLimit,
    errorText,
    innerHeight,
    page: {
      language
    }
  }
}

export default connect(mapStateToProps, {
  loadStopandDate,
  changeTrainSearchInfo,
  changeErrortext,
  changeStop
})(TimetableSearchZh)
