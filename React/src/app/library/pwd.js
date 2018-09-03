// CharMode函數
// 測試某個字符是屬於哪一類.
function CharMode (iN) {
  if (iN >= 48 && iN <= 57) { // 數字
    return 1
  }
  if (iN >= 65 && iN <= 90) { // 大寫字母
    return 2
  }
  if (iN >= 97 && iN <= 122) { // 小寫字母
    return 4
  } else { return 8 } // 特殊字符
}

// bitTotal函數
// 計算出當前密碼當中一共有多少種模式
function bitTotal (num) {
  let modes = 0
  for (let i = 0; i < 4; i++) {
    if (num & 1) modes++
    num >>>= 1
  }
  return modes
}

// checkStrong函數
// 返回密碼的強度級別
function checkStrong (sPW, min) {
  if (sPW.length <= min) { return 0 } // 密碼太短
  let Modes = 0
  for (let i = 0; i < sPW.length; i++) {
    // 測試每一個字符的類別並統計一共有多少種模式.
    Modes |= CharMode(sPW.charCodeAt(i))
  }
  return bitTotal(Modes)
}

// pwStrength函數
// 當用戶放開鍵盤或密碼輸入框失去焦點時,根據不同的級別顯示不同的顏色
export default function pwStrength (pwd, minlength) {
  if (pwd === null || pwd === '') {
    return -1
  } else {
    return checkStrong(pwd, minlength)
  }
}
