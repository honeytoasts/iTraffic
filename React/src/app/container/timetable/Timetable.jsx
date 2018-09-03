import React, { Component } from 'react'
import { connect } from 'react-redux'
import { Link } from 'react-router'

import RaisedButton from 'material-ui/RaisedButton'
import { MapsDirectionsRailway, MapsTrain } from 'material-ui/svg-icons'

import {changeTrainSearchInfo} from '../../action'

const styles = {
  button: {
    width: '70%',
    height: 50,
    marginTop: 30
  },
  headline: {
    fontSize: 24,
    paddingTop: 16,
    marginBottom: 12,
    fontWeight: 400
  }
}

class Timetable extends Component {
  componentWillMount () {
    const { searchInfo, changeTrainSearchInfo } = this.props
    changeTrainSearchInfo({...searchInfo, type: '', fromStop: '', fromID: '', toStop: '', toID: ''})
  }
  render () {
    const { page } = this.props
    return (
      <div className='choice'>
        <div>
          <RaisedButton
            icon={<MapsDirectionsRailway />}
            backgroundColor='#4682B4'
            labelColor='white'
            style={styles.button}
            containerElement={page.language === 'Zh' ? <Link to='/timetablesearch/THSR' /> : <Link to='/timetablesearch/THSR/En' />}
            label={page.language === 'Zh' ? '高鐵' : 'THSR'}
            labelStyle={{fontSize: '20px'}}
          />
        </div>
        <div>
          <RaisedButton
            icon={<MapsTrain />}
            backgroundColor='#4682B4'
            labelColor='white'
            style={styles.button}
            containerElement={page.language === 'Zh' ? <Link to='/timetablesearch/TRA' /> : <Link to='/timetablesearch/TRA/En' />}
            label={page.language === 'Zh' ? '台鐵' : 'TRA'}
            labelStyle={{fontSize: '20px'}}
          />
        </div>
      </div>
    )
  }
}

function mapStateToProps (state) {
  const {language} = state.page
  const {searchInfo} = state.searchTimetable
  return {
    page: {
      language
    },
    searchInfo
  }
}

export default connect(mapStateToProps, {
  changeTrainSearchInfo
})(Timetable
)
