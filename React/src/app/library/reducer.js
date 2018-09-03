/**
 * general funciton
 */

// 查詢
export function selectDoSomething (state, action) {
  return {
    ...state,
    fetchedPageCount: {
      page: 0,
      oldcount: 0,
      newcount: 0,
      sorting: (
        typeof action !== 'undefined' && action.sorting
        ? action.sorting
        : null
      )
    },
    items: []
  }
}

export function selectDoSomethingHavePrefix (state, action) {
  return {
    ...state,
    fetchedPageCount: {
      page: 0,
      oldcount: 0,
      newcount: 0,
      sorting: (
        typeof action !== 'undefined' && action.sorting
        ? action.sorting
        : null
      )
    },
    items: [],
    prefix: []
  }
}

// 載入
export function loadDoSomething (state) {
  return {
    ...state,
    fetchedPageCount: {
      ...state.fetchedPageCount,
      page: state.fetchedPageCount.page + 1,
      oldcount: state.fetchedPageCount.newcount
    }
  }
}

// 過期
export function invalidateDoSomething (state) {
  return {
    ...state,
    didInvalidate: true
  }
}

// 發出 request
export function requestDoSomething (state) {
  return {
    ...state,
    isFetching: true,
    didInvalidate: false
  }
}

// 發出 PTX request
export function requestDoSomethingPTX (state) {
  return {
    ...state,
    isFetchingPTX: true,
    didInvalidate: false
  }
}

// 回傳成功結果
export function successDoSomething (state, action, items, isDoing = 0) {
  const arr = [isDoSomething(state, items, isDoing)]
  const res = arr !== null ? arr[0] : null
  // console.log(res)
  return {
    ...state,
    isFetching: false,
    isFetchingPTX: false,
    didInvalidate: false,
    ...res,
    receivedAt: action.receivedAt
  }
}

export function successDoSomethingHavePrefix (state, action, items, isDoing = 0) {
  const arr = [isDoSomething(state, items, isDoing)]
  const res = arr !== null ? arr[0] : null
  // console.log(res)
  return {
    isFetching: false,
    didInvalidate: false,
    ...res,
    prefix: action.prefix,
    receivedAt: action.receivedAt
  }
}

// 用 isDoing 變數來判斷是否有啟動分頁功能
// 0: 不啟用(default), 1: 啟用
function isDoSomething (state, items, isDoing) {
  if (isDoing === 0) {
    return {
      items: items
    }
  } else if (isDoing === 1) {
    return {
      fetchedPageCount: {
        ...state.fetchedPageCount,
        newcount: (state.fetchedPageCount.newcount += items.length)
      },
      items: [...state.items, ...items]
    }
  }
}

// 回傳失敗結果
export function failureDoSomething (state, action) {
  return {
    ...state,
    isFetching: false,
    didInvalidate: false,
    err: action.err,
    receivedAt: action.receivedAt
  }
}

/**
 * private funciton - sign
 */

const requiredMsg = '這裡必須填入資料'

export function assignFunMiddleware (state, action, fun) {
  const arr = [fun(state, action)]
  return arr !== null ? arr[0] : null
}

// 紀錄 input 值
export function changeForm (state, action) {
  const _pw = action.formInfo.password
  const _pw_o = state.formInfo.password
  const _repw = action.formInfo.repassword
  if (_pw !== _pw_o && _repw === '') {
    return {
      errMsg: {
        ...state.errMsg,
        repassword: ''
      }
    }
  } else return null
}

// input 格式檢查 (nickname)
export function checkNickname (state, action) {
  const _nn = state.formInfo.nickname
  if (_nn.length > 100) {
    return {
      errMsg: {
        ...state.errMsg,
        nickname: '長度不能超過 100 個字元'
      }
    }
  } else return null
}

// input 格式檢查 (account)
export function checkAccount (state, action) {
  const _ac = state.formInfo.account
  let acm
  let enter = 0
  if (_ac.length === 0) {
    acm = requiredMsg
    enter = 1
  } else if (_ac.match(/([^a-zA-z0-9.])/g)) {
    acm = '只能使用字母 (a-zA-Z)、數字及英文句點'
    enter = 2
  } else if (_ac.length < 5 || _ac.length > 30) {
    acm = '長度需介於 5 到 30 個字元'
    enter = 3
  }
  if (enter > 0) {
    return {
      errMsg: {
        ...state.errMsg,
        account: acm
      }
    }
  } else return null
}

// input 格式檢查 (password)
export function checkPassword (state, action) {
  const _pw = state.formInfo.password
  let pwm
  let enter = 0
  if (_pw.length === 0) {
    pwm = requiredMsg
    enter = 1
  } else if (_pw.length < 8) {
    pwm = '長度需至少 8 個字元'
    // password 正則表示法 參考: http://blog.miniasp.com/post/2008/05/09/Using-Regular-Expression-to-validate-password.aspx
    // } else if (!_pw.match(/^(?=.*\d)(?=.*[A-Z])/g)) {
    // pwm = '密碼至少需包含 1 個數字、1 個大寫英文字母'
    enter = 2
  }
  if (enter > 0) {
    return {
      errMsg: {
        ...state.errMsg,
        password: pwm
      }
    }
  } else return null
}

// input 格式檢查 (repassword)
export function checkRePassword (state, action) {
  const _pw = state.formInfo.password
  const _repw = state.formInfo.repassword
  let repwm
  let enter = 0
  if (_pw !== _repw) {
    repwm = '密碼與確認密碼不相同，請重新輸入'
    enter = 1
  } else if (_repw.length === 0) {
    repwm = requiredMsg
    enter = 2
  }
  if (enter > 0) {
    return {
      errMsg: {
        ...state.errMsg,
        repassword: repwm
      }
    }
  } else return null
}

// input 格式檢查 (oldpassword)
export function checkOldpassword (state, action) {
  const _oldpw = state.formInfo.oldpassword
  let oldpwm
  let enter = 0
  if (_oldpw.length === 0) {
    oldpwm = requiredMsg
    enter = 1
  } else if (_oldpw.length < 8) {
    oldpwm = '長度需至少 8 個字元'
    enter = 2
  }
  if (enter > 0) {
    return {
      errMsg: {
        ...state.errMsg,
        oldpassword: oldpwm
      }
    }
  } else return null
}

// input 格式檢查 (email)
export function checkEmail (state, action) {
  const _em = state.formInfo.email
  let emm
  let enter = 0
  if (_em.length === 0) {
    emm = requiredMsg
    // email 正則表示法 參考: http://ithelp.ithome.com.tw/articles/10094951
    enter = 1
  } else if (!_em.match(/(^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z]+$)/g)) {
    emm = '電子信箱格式錯誤，請重新輸入'
    enter = 2
  } else if (_em.length > 100) {
    emm = '長度不能超過 100 個字元'
    enter = 3
  }
  if (enter > 0) {
    return {
      errMsg: {
        ...state.errMsg,
        email: emm
      }
    }
  } else return null
}

// 判斷登入
export function lState (state, d, position) {
  const num = d.lState
  let lsm
  if (typeof num !== 'undefined') {
    console.log('sign log => 判斷登入 (lState)')
    if (num < 3) {
      if (position === 1) {
        return {
          robot: ''
        }
      } else if (position === 2) {
        if (num === 0) lsm = '帳號或密碼錯誤'
        else if (num === 1) lsm = '尚未完成註冊程序'
        else if (num === 2) lsm = '請先至信箱收取驗證信'
        return {
          formInfo: {
            ...state.formInfo,
            account: '',
            password: ''
          },
          errMsg: {
            ...state.errMsg,
            enter: lsm
          },
          loggedIn: false
        }
      }
    } else {
      const s = d.sid
      const pc = d.pc
      return {
        session: {
          s: s,
          pc: pc
        },
        loggedIn: true
      }
    }
  }
}

// 判斷驗證登入
export function vlState (state, d) {
  const num = d.vlState
  let opt
  if (typeof num !== 'undefined') {
    console.log('sign log => 判斷驗證登入 (vlState)')
    const s = d.sid
    const pc = d.pc
    if (num === 1) opt = { loggedIn: true }
    else if (num === 2) opt = { loggedIn: false }
    return {
      session: {
        s: s,
        pc: pc
      },
      ...opt
    }
  }
}

// 判斷FB登入
export function fblState (state, d) {
  const num = d.fblState
  if (typeof num !== 'undefined') {
    console.log('sign log => 判斷FB登入 (fblState)')
    if (num !== null) {
      const s = d.sid
      const pc = d.pc
      return {
        session: {
          s: s,
          pc: pc
        },
        loggedIn: true
      }
    }
  }
}

// 判斷FB會員帳號修改成功
export function fbaaState (state, d) {
  const num = d.fbaaState
  if (typeof num !== 'undefined') {
    console.log('sign log => 判斷FB會員帳號修改成功 (fbaaState)')
    return {
      formInfo: {
        ...state.formInfo,
        account: ''
      }
    }
  }
}

// 判斷登出
export function loState (state, d) {
  const num = d.loState
  if (typeof num !== 'undefined') {
    console.log('sign log => 判斷登出 loState')
    if (num === 1) {
      const s = d.sid
      const pc = d.pc
      return {
        session: {
          s: s,
          pc: pc
        },
        loggedIn: false
      }
    }
  }
}

// 補寄驗證信 - 檢查電子信箱
export function vcState (state, d, position) {
  const num = d.vcState
  let vcm
  if (typeof num !== 'undefined') {
    console.log('sign log => 補寄驗證信 - 檢查電子信箱 (vcState)')
    if (position === 1) {
      return {
        robot: ''
      }
    } else if (position === 2) {
      if (num === 0) vcm = '電子信箱錯誤'
      else if (num === 1) vcm = '此帳號尚未完成註冊程序'
      else if (num === 2) vcm = '此帳號已被認證'
      return {
        formInfo: {
          ...state.formInfo,
          email: ''
        },
        errMsg: {
          ...state.errMsg,
          enter: vcm
        }
      }
    }
  }
}

// 忘記密碼 - 檢查帳號、電子信箱
export function pwState (state, d, position) {
  const num = d.pwState
  let pwm
  if (typeof num !== 'undefined') {
    console.log('sign log => 忘記密碼 - 檢查帳號、電子信箱 (pwState)')
    if (position === 1) {
      return {
        robot: ''
      }
    } else if (position === 2) {
      if (num === 0) pwm = '帳號或電子信箱錯誤'
      else if (num === 2) pwm = '使用 Facebook 註冊用戶無法使用「忘記密碼」功能'
      return {
        formInfo: {
          ...state.formInfo,
          account: '',
          email: ''
        },
        errMsg: {
          ...state.errMsg,
          enter: pwm
        }
      }
    }
  }
}

// 檢查帳號
export function acState (state, d) {
  const num = d.acState
  let acm, opt
  if (typeof num !== 'undefined') {
    console.log('sign log => 檢查帳號 (acState)')
    const mid = d.mid
    if (num === 0) {
      acm = '此帳號已有人使用'
      opt = {
        errMsg: {
          ...state.errMsg,
          account: acm
        }
      }
    } else if (num === 1) {
      opt = {
        checkState: {
          ...state.checkState,
          account: true
        }
      }
    }
    return {
      formInfo: {
        ...state.formInfo,
        mid: mid
      },
      ...opt
    }
  }
}

// 檢查FB帳號
export function fbacState (state, d) {
  const num = d.fbacState
  let fbacm
  if (typeof num !== 'undefined') {
    console.log('sign log => 檢查FB帳號 (fbacState)')
    if (num === 0) {
      fbacm = '此帳號已有人使用'
      return {
        errMsg: {
          ...state.errMsg,
          account: fbacm
        }
      }
    } else if (num === 1) {
      return {
        checkState: {
          ...state.checkState,
          account: true
        }
      }
    }
  }
}

// 檢查電子信箱
export function emState (state, d) {
  const num = d.emState
  let emm, opt
  if (typeof num !== 'undefined') {
    console.log('sign log => 檢查電子信箱 (emState)')
    const mid = d.mid
    if (num === 0) {
      emm = '此電子信箱已有人使用'
      opt = {
        errMsg: {
          ...state.errMsg,
          email: emm
        }
      }
    } else if (num === 1) {
      opt = {
        checkState: {
          ...state.checkState,
          email: true
        }
      }
    }
    return {
      formInfo: {
        ...state.formInfo,
        mid: mid
      },
      ...opt
    }
  }
}

// 判斷刪除會員
export function deState (state, d) {
  const num = d.deState
  if (typeof num !== 'undefined') {
    console.log('sign log => 判斷刪除會員 (deState)')
    if (num === 1) {
      return {
        formInfo: {
          ...state.formInfo,
          mid: -1
        }
      }
    }
  }
}

// 判斷註冊成功
export function reState (state, d) {
  const num = d.reState
  if (typeof num !== 'undefined') {
    console.log('sign log => 判斷註冊成功 (reState)')
    if (num === 1) {
      return {
        formInfo: {
          ...state.formInfo,
          mid: -1
        }
      }
    }
  }
}

// 檢查 Email key 後回傳 name
export function keyState (state, d) {
  const num = d.keyState
  let opt
  if (typeof num !== 'undefined') {
    console.log('sign log => 檢查 Email key 後回傳 name (keyState)')
    const username = d.username
    if (num === 0) opt = { returnUserName: '' }
    else if (num === 1) opt = { returnUserName: username }
    return {
      verifyCode: '',
      ...opt
    }
  }
}

// 判斷修改密碼
export function cpState (state, d) {
  const num = d.cpState
  let cpm, opt
  if (typeof num !== 'undefined') {
    console.log('sign log => 判斷修改密碼 (cpState)')
    if (num === 2) {
      cpm = '舊密碼錯誤'
      opt = {
        oldpassword: ''
      }
    } else if (num === 3) cpm = '舊密碼與新密碼相同'
    return {
      formInfo: {
        ...state.formInfo,
        ...opt,
        password: '',
        repassword: ''
      },
      errMsg: {
        ...state.errMsg,
        enter: cpm
      }
    }
  }
}

/**
 * private function - collection
 */

// input 格式檢查 (name)
export function checkCollection (state, action) {
  const _cln = state.formInfo.name
  let clnm
  let enter = 0
  if (_cln.length === 0) {
    clnm = requiredMsg
    enter = 1
  } else if (_cln.length > 30) {
    clnm = '長度不能超過 30 個字元'
    enter = 2
  }
  if (enter > 0) {
    return {
      errMsg: {
        name: clnm
      }
    }
  } else return null
}

 // 檢查收藏清單名稱
export function clnState (state, d) {
  const num = d.clnState
  let clnm, opt
  if (typeof num !== 'undefined') {
    const cidnew = d.cid
    if (num === 0) {
      clnm = '已存在有相同名稱的收藏清單'
      opt = {
        errMsg: {
          name: clnm
        }
      }
    } else if (num === 1) {
      opt = {
        checkState: {
          name: true
        }
      }
    }
    return {
      formInfo: {
        ...state.formInfo,
        cidnew: cidnew
      },
      ...opt
    }
  }
}

// 判斷刪除收藏清單
export function declState (state, d) {
  const num = d.declState
  if (typeof num !== 'undefined') {
    if (num === 1) {
      return {
        formInfo: {
          ...state.formInfo,
          cidnew: -1
        }
      }
    }
  }
}

// 判斷新建收藏清單成功
export function clState (state, d) {
  const num = d.clState
  if (typeof num !== 'undefined') {
    if (num === 3 || num === 1) {
      return {
        formInfo: {
          ...state.formInfo,
          cidnew: -1
        }
      }
    } else if (num > 0) {
      return {
        formInfo: {
          ...state.formInfo,
          cid: -1
        }
      }
    }
  }
}

/**
 * private function - note
 */

export function manageNoteDoSomething (vid, datatype, name, currenttime, ac, nid) {
  return {
    vid: vid,
    databyte: datatype,
    name: name,
    currenttime: currenttime,
    ac: ac,
    nid: nid
  }
}
