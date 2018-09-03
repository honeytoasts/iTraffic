# 本系統為介接交通部PTX平臺資料

import pyodbc
import json
import requests
import time
import hashlib
from datetime import datetime, timedelta
from header import ptxheader

def insert_stop(url):
    connect = pyodbc.connect('DRIVER={SQL Server};SERVER=localhost;DATABASE=iTraffic;')
    cursor = connect.cursor()
    res = requests.get(url, headers = ptxheader()).text
        
    for stop in json.loads(res):
        try:
            cursor.execute("exec dbo.xp_insertStop ?,?,?,?,?,?,?,?,?", "高鐵", stop["StationName"]["Zh_tw"].replace("臺","台"), stop["StationName"]["En"],
            stop["UpdateTime"][0:19], stop["StationID"], stop["StationPosition"]["PositionLon"], stop["StationPosition"]["PositionLat"],  None, stop["StationAddress"])
            cursor.commit()
        except:
            continue
    del cursor
    connect.close()

def insert_timetable(url):
    connect = pyodbc.connect('DRIVER={SQL Server};SERVER=localhost;DATABASE=iTraffic;')
    cursor = connect.cursor()
    res = requests.get(url, headers = ptxheader()).text

    for train in json.loads(res):
        try:
            # 以車次時刻加密成md5
            md5 = hashlib.md5()
            md5.update(json.dumps(train["StopTimes"]).encode())
           
            # 判斷是否需建班次          
            sql = "select TID from Transportation where Number = "+train["DailyTrainInfo"]["TrainNo"]+" and MD5 = '"+md5.hexdigest()+"'"  
            cursor.execute(sql)
            if cursor.fetchone() is not None:
                pass
            else:
                # insert Transportation
                cursor.execute("exec dbo.xp_insertTrain ?,?,?,?,?,?,?,?,?,?,?,?", "高鐵", None, None, None, None,
                train["DailyTrainInfo"]["TrainNo"], train["DailyTrainInfo"]["StartingStationID"], train["DailyTrainInfo"]["StartingStationName"]["Zh_tw"].replace("臺","台"),
                train["DailyTrainInfo"]["EndingStationID"], train["DailyTrainInfo"]["EndingStationName"]["Zh_tw"].replace("臺","台"), 
                train["DailyTrainInfo"]["Direction"], md5.hexdigest())
                cursor.commit()
                # insert ST and TS
                for stop in train["StopTimes"] :
                    cursor.execute("exec dbo.xp_insertTrainST ?,?,?,?,?,?,?,?", "高鐵", train["DailyTrainInfo"]["TrainNo"], md5.hexdigest(),
                    stop["StopSequence"], stop["StationID"], stop["StationName"]["Zh_tw"].replace("臺","台"), stop["ArrivalTime"], stop["DepartureTime"])                      
                    cursor.commit()
            # insert Dailytimetable
            year, month, day = train["TrainDate"].split("-")
            cursor.execute("exec dbo.xp_insertDailyTimetable ?,?,?,?,?,?", "高鐵", year, month, day, train["DailyTrainInfo"]["TrainNo"], md5.hexdigest())
            cursor.commit()
        except:
            continue
    del cursor
    connect.close()

def insert_price(url):
    connect = pyodbc.connect('DRIVER={SQL Server};SERVER=localhost;DATABASE=iTraffic;')
    cursor = connect.cursor()
    res = requests.get(url, headers = ptxheader()).text
    price = json.loads(res)

    for i in range(0,3,1) :
        try:
            cursor.execute("exec dbo.xp_insertPrice ?,?,?,?,?,?,?,?,?,?","高鐵", price[0]["OriginStationID"], price[0]["OriginStationName"]["Zh_tw"].replace("臺","台"),
            price[0]["DestinationStationID"], price[0]["DestinationStationName"]["Zh_tw"].replace("臺","台"),
            price[0]["Fares"][i]["TicketType"], "全票", int(price[0]["Fares"][i]["Price"]), None, price[0]["SrcUpdateTime"][0:19])
            cursor.commit()
        except:
            continue
    del cursor
    connect.close()

def main():
    #高鐵站點
    start = time.time()
    insert_stop("http://ptx.transportdata.tw/MOTC/v2/Rail/THSR/Station?$format=JSON")
    end = time.time()
    print("已完成" + '高鐵' + "的站牌資料，花了" + str(end-start) + "秒")

    #高鐵時刻表
    start = time.time()
    day = datetime.now()
    maxdate = (datetime.now()+timedelta(days=40)).strftime("%Y-%m-%d")
    while (day.strftime("%Y-%m-%d") <= maxdate):
        format = day.strftime("%Y-%m-%d")
        insert_timetable("http://ptx.transportdata.tw/MOTC/v2/Rail/THSR/DailyTimetable/TrainDate/"+format+"?$format=JSON")
        day = day + timedelta(days=1)
    end = time.time()
    print("已完成" + '高鐵' + "的時刻表資料，花了" + str(end-start) + "秒")

    #高鐵票價
    start = time.time()
    stationID = ["0990","1000","1010","1020","1030","1035","1040","1043","1047","1050","1060","1070"]
    for i in range(0, len(stationID), 1):
        for j in range(0, len(stationID), 1):
            if i != j :
               insert_price("http://ptx.transportdata.tw/MOTC/v2/Rail/THSR/ODFare/"+stationID[i]+"/to/"+stationID[j]+"?$format=json")
    end = time.time()
    print("已完成" + '高鐵' + "的票價資料，花了" + str(end-start) + "秒")

main()