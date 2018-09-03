import React, { PropTypes, Component } from 'react'
import { connect } from 'react-redux'

import CircularProgress from 'material-ui/CircularProgress'
import { white } from 'material-ui/styles/colors'

const styles = {
  content: {
    padding: '0px 12px 12px'
  },
  table: {
    width: '100%',
    borderCollapse: 'collapse'
  },
  tableTd: {
    border: '1px solid #ddd',
    padding: '2px'
  },
  tableTh: { // 標頭
    paddingTop: '12px',
    paddingBottom: '12px',
    textAlign: 'left',
    border: '1px solid #ddd',
    padding: '8px'
  }
}

class TrainDetailBlock extends Component {
  constructor (props) {
    super(props)
    const {items} = this.props
    this.state = {
      itemsJson: items
    }
  }
  componentDidUpdate (prevProps, prevState) {
    const {items, searchInfo, language} = this.props

    if (prevProps.items !== items) {
      if (items.length > 0) {
        if (searchInfo.type === '台鐵' || searchInfo.type === 'TRA') {
          items.map((d) => {
            if (d.passrank >= d.rank) d.state = language === 'Zh' ? '已發車' : 'Depart'
            else if (d.rank === (d.passrank + 1)) {
              if (d.delaytime === 0) d.state = language === 'Zh' ? '準點' : 'On time'
              else if (d.delaytime > 0) d.state = language === 'Zh' ? '慢' + d.delaytime + ' 分' : 'Delay ' + d.delaytime + ' min'
            }
            return d
          })
          this.setState({itemsJson: items})
        }
      }
    }
  }
  render () {
    const {searchInfo, isFetching, items, language} = this.props
    const {itemsJson} = this.state

    return (
      <div>
        {
          isFetching ? (
            <CircularProgress />
          ) : (
            items.length > 0 ? (
              searchInfo.type === '台鐵' || searchInfo.type === 'TRA'
              ? (
                <div style={styles.content}>
                  <table style={styles.table}>
                    <tr className={'w3-dark-grey'}style={{color: white}}>
                      <th style={styles.tableTh} />
                      <th style={styles.tableTh}>{language === 'Zh' ? '站名' : 'Stop'}</th>
                      <th style={styles.tableTh}>{language === 'Zh' ? '到達時間' : 'Arrive'}</th>
                      <th style={styles.tableTh}>{language === 'Zh' ? '開車時間' : 'Depart'}</th>
                      <th style={styles.tableTh}>{language === 'Zh' ? '狀態' : 'State'}</th>
                    </tr>
                    {
                    itemsJson.map((row, index) => (
                      <tr key={index}
                        className={row.state === 'On time' || row.state === '準點' ? 'w3-amber'
                                  : row.state === 'Depart' || row.state === '已發車' ? 'w3-light-grey'
                                  : row.state === '' ? white : 'w3-red'}
                        style={{fontSize: '14px'}}
                      >
                        <td style={styles.tableTd}>{row.rank}</td>
                        <td style={styles.tableTd}>{row.stop}</td>
                        <td style={styles.tableTd}>{row.arrive}</td>
                        <td style={styles.tableTd}>{row.departure}</td>
                        <td style={styles.tableTd}>{row.state}</td>
                      </tr>
                  ))}
                  </table>
                </div>
              )
              : (
                <div style={styles.content}>
                  <table style={styles.table}>
                    <tr className={'w3-dark-grey'}style={{color: white}}>
                      <th style={styles.tableTh} />
                      <th style={styles.tableTh}>{language === 'Zh' ? '站名' : 'Stop'}</th>
                      <th style={styles.tableTh}>{language === 'Zh' ? '到達時間' : 'Arrive'}</th>
                      <th style={styles.tableTh}>{language === 'Zh' ? '開車時間' : 'Depart'}</th>
                    </tr>
                    {
                    items.map((row, index) => (
                      <tr key={index} style={{fontSize: '14px'}}>
                        <td style={styles.tableTd}>{row.rank}</td>
                        <td style={styles.tableTd}>{row.stop}</td>
                        <td style={styles.tableTd}>{row.arrive}</td>
                        <td style={styles.tableTd}>{row.departure}</td>
                      </tr>
                  ))}
                  </table>
                </div>
              )
            ) : ('No Data.')
          )
        }
      </div>
    )
  }
}
TrainDetailBlock.propTypes = {
  searchInfo: PropTypes.object
}

function mapStateToProps (state) {
  const {searchInfo} = state.searchTimetable
  const { isFetching, items } = state.storeTrainDetail
  const {language} = state.page

  return {
    language,
    searchInfo,
    isFetching,
    items
  }
}

export default connect(mapStateToProps, {
})(TrainDetailBlock)
