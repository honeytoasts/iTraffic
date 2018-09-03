import React, { Component } from 'react'
import { ListItem } from 'material-ui/List'
import { Link } from 'react-router'

import { ActionBuild, DeviceDataUsage, ActionLanguage, FileFolderShared } from 'material-ui/svg-icons'

class About extends Component {
  render () {
    return (
      <div className='w3-container'>
        <h5>ABOUT US</h5>
        <p style={{margin: 0}}>Provide complete timetables for TRA, THSR and Bus in Taiwan.
                               Furthermore, we also provide real-time bus and TRA information.</p>
        <p style={{margin: 0}}>提供完整的台鐵、高鐵及公路客運與市區公車班次時刻資訊。並且提供即時公車與台鐵動態資訊。</p>
        <p style={{margin: 0}}>本系統介接交通部PTX服務平臺資料</p>
        {/* <img style={{width: '50%'}}src={require('../img/PTX_logo1.png')} /> */}
        <p style={{margin: 0}}>並且提供即時公車動態資訊。<br></br></p>
        <div style={{backgroundColor: '#ffffffbd', marginBottom: '15px'}}>
          <ListItem
            primaryText='Data source'
            leftIcon={<DeviceDataUsage />}
            initiallyOpen
            nestedItems={[
              <ListItem
                key={1}
                primaryText='PTX'
                containerElement={<Link to='http://ptx.transportdata.tw/PTX' target='_blank' />}
                leftIcon={<ActionLanguage />}
              />,
              <ListItem
                key={2}
                primaryText='TRA'
                containerElement={<Link to='http://www.thsrc.com.tw/index.html' target='_blank' />}
                leftIcon={<ActionLanguage />}
              />,
              <ListItem
                key={3}
                primaryText='THSR'
                containerElement={<Link to='https://www.railway.gov.tw/tw/index.html' target='_blank' />}
                leftIcon={<ActionLanguage />}
               />
            ]}
          />
          <ListItem
            primaryText='Open Source'
            leftIcon={<FileFolderShared />}
            initiallyOpen
            nestedItems={[
              <ListItem
                key={1}
                primaryText='w3.css'
                containerElement={<Link to='https://www.w3schools.com/lib/w3.css' target='_blank' />}
                leftIcon={<ActionLanguage />}
              />
            ]}
          />
          <ListItem
            primaryText='Web design resource'
            leftIcon={<ActionBuild />}
            initiallyOpen
            nestedItems={[
              <ListItem
                key={1}
                primaryText='illustrio'
                containerElement={<Link to='https://illustrio.com/' target='_blank' />}
                leftIcon={<ActionLanguage />}
              />,
              <ListItem
                key={2}
                primaryText='Google Fonts'
                containerElement={<Link to='https://fonts.google.com/' target='_blank' />}
                leftIcon={<ActionLanguage />}
              />,
              <ListItem
                key={3}
                primaryText='Icons8'
                containerElement={<Link to='https://icons8.com/' target='_blank' />}
                leftIcon={<ActionLanguage />}
              />,
              <ListItem
                key={4}
                primaryText='Material-UI'
                containerElement={<Link to='https://v0.material-ui.com/#/' target='_blank' />}
                leftIcon={<ActionLanguage />}
              />,
              <ListItem
                key={5}
                primaryText='Unsplash'
                containerElement={<Link to='https://unsplash.com/' target='_blank' />}
                leftIcon={<ActionLanguage />}
              />
            ]}
          />
        </div>
      </div>
    )
  }
}

export default (About)
