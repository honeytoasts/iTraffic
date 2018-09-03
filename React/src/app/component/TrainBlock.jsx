import React, { PropTypes, Component } from 'react'
import { connect } from 'react-redux'
import TrainDetailBlock from './TrainDetailBlock.jsx'
import { NavigationArrowForward } from 'material-ui/svg-icons'

import {
  toggleTrainDialog, loadTrainDetail
} from '../action'

const styles = {
  block: {
    margin: '10px',
    padding: '10px 10px',
    backgroundColor: 'white',
    position: 'relative',
    height: '70px',
    fontSize: '14px',
    borderColor: '#8492A6',
    borderStyle: 'solid',
    borderWidth: '0.1px'
  },
  number: {
    position: 'absolute',
    marginLeft: '15px',
    color: '#00A6FF',
    fontSize: '15px'
  },
  traintype: {
    position: 'absolute',
    marginLeft: '70px',
    color: '#0478B7'
  },
  price: {
    position: 'absolute',
    marginLeft: '190px',
    color: '#969FAA'
  },
  departure: {
    position: 'absolute',
    marginLeft: '15px',
    marginTop: '30px',
    fontSize: '16px',
    color: '#47525E'
  },
  arrow: {
    position: 'absolute',
    marginLeft: '65px',
    marginTop: '30px'
  },
  arrive: {
    position: 'absolute',
    marginLeft: '100px',
    marginTop: '30px',
    fontSize: '16px',
    color: '#47525E'
  },
  duration: {
    position: 'absolute',
    marginLeft: '190px',
    marginTop: '30px',
    fontSize: '16px',
    color: '#B8977E'
  }
}

class TrainBlock extends Component {
  render () {
    const {
      trainDialog, type, date, number, traintype, departure, arrive, duration, price, toggleTrainDialog, loadTrainDetail
    } = this.props

    return (
      <div
        style={styles.block}
        onClick={() => {
          toggleTrainDialog({...trainDialog, open: !trainDialog.open, type: type, date: date, number: number, content: <TrainDetailBlock />})
          loadTrainDetail()
        }}
      >
        <div style={styles.number}> <b>{number}</b> </div>
        <div style={styles.traintype}> <b>{traintype}</b> </div>
        <div style={styles.price}> <b>${price}</b> </div>
        <div style={styles.departure}> {departure} </div>
        <div style={styles.arrow}> <NavigationArrowForward /> </div>
        <div style={styles.arrive}> {arrive} </div>
        <div style={styles.duration}> {duration} </div>
      </div>
    )
  }
}

function mapStateToProps (state) {
  const {trainDialog} = state.searchTrainDetail
  return {
    trainDialog
  }
}

export default connect(mapStateToProps, {
  toggleTrainDialog, loadTrainDetail
})(TrainBlock)
