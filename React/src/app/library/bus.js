var CryptoJS = require('crypto-js')

export default function () {
  var AppID = 'PTX AppID'
  var AppKey = 'PTX AppKey'

  var GMTString = new Date().toGMTString()
  var encrypted = CryptoJS.HmacSHA1('x-date: ' + GMTString, AppKey)
  var HMAC = CryptoJS.enc.Base64.stringify(encrypted)
  var Authorization = 'hmac username="' + AppID + '", algorithm="hmac-sha1", headers="x-date", signature="' + HMAC + '"'

  return {'Authorization': Authorization, 'X-Date': GMTString/* ,'Accept-Encoding': 'gzip' */} // 如果要將js運行在伺服器，可額外加入 'Accept-Encoding': 'gzip'，要求壓縮以減少網路傳輸資料量
}
