# 本系統為介接交通部PTX平臺資料

import pyodbc
import json
import requests
import hashlib
from datetime import datetime,timedelta
from header import ptxheader
import time

def update(url):
    connect = pyodbc.connect('DRIVER={SQL Server};SERVER=localhost;DATABASE=iTraffic;')
    cursor = connect.cursor()
    res = requests.get(url, headers = ptxheader()).text
    date = (datetime.now()).strftime("%Y-%m-%d")
    year, month, day = date.split("-")
 
    #先將班次動態清除
    cursor.execute("update Transportation set PassRank = NULL, DelayTime = NULL")
    cursor.commit()
    for train in json.loads(res):
        try:
            numbers = train["TrainNo"]
            cursor.execute("exec dbo.xp_updateTrainState ?,?,?,?,?,?,?,?", "台鐵", year, month, day, numbers,
            train["StationID"], train["StationName"]["Zh_tw"].replace("臺","台"), train["DelayTime"])
            cursor.commit()
        except:
            continue
def main():
    #台鐵班次狀態
    while (True): 
        try:
            update("http://ptx.transportdata.tw/MOTC/v2/Rail/TRA/LiveTrainDelay?$format=JSON")
            print("complete")
            time.sleep(90)  #平台更新資料時間為2分鐘
        except:
            time.sleep(90)  #平台更新資料時間為2分鐘
        
main()