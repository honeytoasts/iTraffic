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
            cursor.execute("exec dbo.xp_insertStop ?,?,?,?,?,?,?,?,?", "台鐵", stop["StationName"]["Zh_tw"].replace("臺","台"), stop["StationName"]["En"],
            stop["UpdateTime"][0:19], stop["StationID"], stop["StationPosition"]["PositionLon"], stop["StationPosition"]["PositionLat"], stop["StationPhone"],
            stop["StationAddress"])
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
                # 有的班次沒NoteEn會出錯
                try:
                    Note_En = train["DailyTrainInfo"]["Note"]["En"]
                except:
                    Note_En = ""
                #有的班次沒有車種
                if "Tze" in train["DailyTrainInfo"]["TrainTypeName"]["En"] :
                    if '普悠瑪' in train["DailyTrainInfo"]["TrainTypeName"]["Zh_tw"] :
                        ctraintype = "普悠瑪"; etraintype = "Puyuma"
                    elif '太魯閣' in train["DailyTrainInfo"]["TrainTypeName"]["Zh_tw"] :
                        ctraintype = "太魯閣"; etraintype = "Taroko"
                    else:
                        ctraintype = "自強"; etraintype = "Tze-Chiang"
                elif "Chu" in train["DailyTrainInfo"]["TrainTypeName"]["En"] :
                    ctraintype = "莒光"; etraintype = "Chu-Kuang"
                elif "Fu" in train["DailyTrainInfo"]["TrainTypeName"]["En"] :
                    ctraintype = "復興"; etraintype = "Fu-Hsing"
                elif "Fast" in train["DailyTrainInfo"]["TrainTypeName"]["En"]:
                    ctraintype = "區間快"; etraintype = "Fast Local Train"
                elif "Local" in train["DailyTrainInfo"]["TrainTypeName"]["En"]:
                    ctraintype = "區間車"; etraintype = "Local Train"
                elif "Ordinary" in train["DailyTrainInfo"]["TrainTypeName"]["En"]:
                    ctraintype = "普快車"; etraintype = "Local Train"

                cursor.execute("exec dbo.xp_insertTrain ?,?,?,?,?,?,?,?,?,?,?,?", "台鐵", ctraintype,etraintype,
                train["DailyTrainInfo"]["Note"]["Zh_tw"], Note_En, train["DailyTrainInfo"]["TrainNo"],
                train["DailyTrainInfo"]["StartingStationID"], train["DailyTrainInfo"]["StartingStationName"]["Zh_tw"].replace("臺","台"),
                train["DailyTrainInfo"]["EndingStationID"], train["DailyTrainInfo"]["EndingStationName"]["Zh_tw"].replace("臺","台"), 
                train["DailyTrainInfo"]["Direction"], md5.hexdigest())
                cursor.commit()
                # insert ST and TS
                for stop in train["StopTimes"] :
                    cursor.execute("exec dbo.xp_insertTrainST ?,?,?,?,?,?,?,?", "台鐵", train["DailyTrainInfo"]["TrainNo"], md5.hexdigest(),
                    stop["StopSequence"], stop["StationID"], stop["StationName"]["Zh_tw"].replace("臺","台"), stop["ArrivalTime"], stop["DepartureTime"])                      
                    cursor.commit()
            # insert Dailytimetable
            year, month, day = train["TrainDate"].split("-")
            cursor.execute("exec dbo.xp_insertDailyTimetable ?,?,?,?,?,?", "台鐵", year, month, day, train["DailyTrainInfo"]["TrainNo"], md5.hexdigest())
            cursor.commit()
        except:
            continue
    del cursor
    connect.close()

def insert_price(url):
    connect = pyodbc.connect('DRIVER={SQL Server};SERVER=localhost;DATABASE=iTraffic;')
    cursor = connect.cursor()
    res = requests.get(url, headers = ptxheader()).text

    traintype = {0:["自強","普悠瑪","太魯閣"], 1:["自強","普悠瑪","太魯閣"], 5:["莒光"], 6:["莒光"],
                10:["復興","區間車","區間快"], 11:["復興","區間車","區間快"], 15:["普快車"], 16:["普快車"]}
    tickettype = {0:"全票", 1:"優待票", 5:"全票", 6:"優待票", 10:"全票", 11:"優待票", 15:"全票", 16:"優待票"}
    note = {0:None, 1:"孩童票、敬老票、愛心票", 5:None, 6:"孩童票、敬老票、愛心票", 10:None, 11:"孩童票、敬老票、愛心票", 15:None, 16:"孩童票、敬老票、愛心票"}

    for price in json.loads(res):
        try:
            for j in [0,1,5,6,10,11,15,16]:
                for traintypes in traintype[j]:
                    cursor.execute("exec dbo.xp_insertPrice ?,?,?,?,?,?,?,?,?,?","台鐵", price["OriginStationID"], price["OriginStationName"]["Zh_tw"].replace("臺","台"),
                    price["DestinationStationID"], price["DestinationStationName"]["Zh_tw"].replace("臺","台"), traintypes, tickettype[j], int(price["Fares"][j]["Price"]), note[j], price["UpdateTime"][0:19])        
                    cursor.commit()
        except:
            continue

def main():    
    #台鐵站點
    start = time.time()
    insert_stop("http://ptx.transportdata.tw/MOTC/v2/Rail/TRA/Station?$format=JSON")
    end = time.time()
    print("已完成" + '台鐵' + "的站牌資料，花了" + str(end-start) + "秒")

    #台鐵時刻表
    start = time.time()
    day = datetime.now()
    maxdate = (datetime.now()+timedelta(days=70)).strftime("%Y-%m-%d")
    while (day.strftime("%Y-%m-%d") <= maxdate):
        format = day.strftime("%Y-%m-%d")
        insert_timetable("http://ptx.transportdata.tw/MOTC/v2/Rail/TRA/DailyTimetable/TrainDate/"+format+"?$format=JSON")
        day = day + timedelta(days=1)
    end = time.time()
    print("已完成" + '台鐵' + "的時刻表資料，花了" + str(end-start) + "秒")

    #台鐵票價
    start = time.time() 
    insert_price("http://ptx.transportdata.tw/MOTC/v2/Rail/TRA/ODFare?$format=JSON")
    end = time.time()
    print("已完成" + '台鐵' + "的票價資料，花了" + str(end-start) + "秒")
    
main()