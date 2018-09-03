# 本系統為介接交通部PTX平臺資料

import hmac, hashlib, base64
from time import gmtime, strftime

def ptxheader():
    AppID = "PTX AppID"
    Appkey = "PTX AppKey".encode()

    GMTstring = strftime("%a, %d %b %Y %H:%M:%S GMT", gmtime())
    msg = ('x-date: ' + GMTstring).encode()
    HMAC =  hmac.new(Appkey,msg,hashlib.sha1)
    signature = base64.b64encode(HMAC.digest()).decode()
    Authorization = 'hmac username=\"' + AppID + '\", algorithm=\"hmac-sha1\", headers=\"x-date\", signature=\"' + signature + '\"'
    headers = {'Authorization': Authorization,'X-Date': GMTstring,'Accept-Encoding':'gzip, deflate'}

    return headers