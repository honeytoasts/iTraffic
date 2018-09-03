/**
 * by Bin
 * 2017/07/05
 */

export function sec2time (secs) {
  secs = Math.round(secs)

  let hr = Math.floor(secs / 3600)
  let min = Math.floor((secs - (hr * 3600)) / 60)
  let sec = parseInt(secs - (hr * 3600) - (min * 60))

  hr = hr < 10 ? '0' + hr : hr
  min = min < 10 ? '0' + min : min
  sec = sec < 10 ? '0' + sec : sec

  return hr + ':' + min + ':' + sec
}

export function time2sec (time) {
  let arr = []
  arr = time.split(':')

  return (+arr[0]) * 3600 + (+arr[1]) * 60 + (+arr[2])
}

export function formatTime (time) {
  let res

  if (time) {
    // 01:20:34 --> 01
    const hour = time.substr(0, time.length - 6)
    // 01:20:34 --> 20:34
    const minsec = time.substr(time.length - 5, time.length)

    if (hour === '00' && minsec.substr(0, 1) === '0') { // 00:01:24 --> 1:24
      res = minsec.substr(1, minsec.length)
    } else if (hour === '00') { // 00:11:24 --> 11:24
      res = minsec
    } else if (hour.substr(0, 1) === '0') { // 01:11:24 --> 1:11:24
      res = hour.substr(1, hour.length) + ':' + minsec
    } else {
      res = hour + ':' + minsec
    }

    return res
  }
}

export function formatNumber (count, type) {
  let res
  let million, billion, trillion

  if (count) {
    count = count.toString()
    let length = count.length
    switch (type) {
      case 1: // 需要格式化的
        if (length > 4 && length < 9) { // 萬 ~ 千萬
          million = count.substr(0, length - 4) + '.' + count.substr(length - 4, length)
          if (length >= 7) {
            res = Math.round(million).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',') + '萬'
          } else {
            res = Math.round(million * 10) / 10 + '萬'
          }
        } else if (length > 8 && length < 13) { // 億 ~ 千億
          billion = count.substr(0, length - 8) + '.' + count.substr(length - 8, length)
          if (length >= 11) {
            res = Math.round(billion).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',') + '億'
          } else {
            res = Math.round(billion * 100) / 100 + '億'
          }
        } else if (length > 12 && length < 17) { // 兆 ~ 千兆
          trillion = count.substr(0, length - 12) + '.' + count.substr(length - 12, length)
          if (length >= 15) {
            res = Math.round(trillion).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',') + '兆'
          } else {
            res = Math.round(trillion * 1000) / 1000 + '兆'
          }
        } else if (length > 16) {
          // 太多了...
        } else { // 個 ~ 千
          res = count.replace(/\B(?=(\d{3})+(?!\d))/g, ',')
        }
        break
      case 2: // 不需要格式化的
        res = count.replace(/\B(?=(\d{3})+(?!\d))/g, ',')
        break
    }

    return res
  }
}

export function clearInterval (ytVideoSetInterval) {
  // 當網頁離開時，清空計時器內容
  return window.clearInterval(ytVideoSetInterval)
}

export function orderRouter (order) {
  let res
  switch (order) {
    case 'v' :
      res = 'viewcount_d'
      break
    case 'sa' :
      res = 'since_a'
      break
    case 'sd' :
      res = 'since_d'
      break
    default :
      res = 'since_d'
  }
  return res
}

export function formatDateTime (datetime, type = 0) {
  let res

  const ndt = new Date(datetime)
  const dd = ndt.getDate()
  const mm = ndt.getMonth() + 1
  const yy = ndt.getFullYear()
  let hh = ndt.getHours()
  if (hh.toString().length === 1) { hh = '0' + hh }
  const min = ndt.getMinutes()
  const ss = ndt.getSeconds()

  if (type !== 0) {
    const t = hh + ':' + min + ':' + ss
    res = yy + ' 年 ' + mm + ' 月 ' + dd + ' 日 ' + t
  } else {
    res = yy + ' 年 ' + mm + ' 月 ' + dd + ' 日'
  }

  return res
}

export function since2time (since) {
  let tt = since.substring(11, since.length)

  return tt
}

export function shuffle (array) {
  let currentIndex = array.length
  let temporaryValue, randomIndex

  // While there remain elements to shuffle...
  while (currentIndex !== 0) {
    // Pick a remaining element...
    randomIndex = Math.floor(Math.random() * currentIndex)
    currentIndex -= 1

    // And swap it with the current element.
    temporaryValue = array[currentIndex]
    array[currentIndex] = array[randomIndex]
    array[randomIndex] = temporaryValue
  }

  return array
}

Array.prototype.remove = function (from, to) {
  var rest = this.slice((to || from) + 1 || this.length)
  this.length = from < 0 ? this.length + from : from
  return this.push.apply(this, rest)
}

Array.prototype.groupBy = function(prop) {
  return this.reduce(function(groups, item) {
    const val = item[prop]
    groups[val] = groups[val] || []
    groups[val].push(item)
    return groups
  }, {})
}