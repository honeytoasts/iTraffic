# 本系統為介接交通部PTX平臺資料

import pyodbc
import json
import requests
import time
import hashlib
from datetime import datetime
from header import ptxheader

def update():
    connect = pyodbc.connect('DRIVER={SQL Server};SERVER=localhost;DATABASE=iTraffic;')
    cursor = connect.cursor()
    res = requests.get("http://ptx.transportdata.tw/MOTC/v2/Bus/DataVersion/InterCity?$format=JSON", headers = ptxheader()).text
    versionID = json.loads(res)["VersionID"]

    sql = "select VersionID from DataVersion where Name = 'InterCity'"
    cursor.execute(sql)
    if cursor.fetchone()[0] == versionID :
        del cursor
        connect.close()
        return 0
    else:
        sql = "update DataVersion set VersionID = " + str(versionID) + ", Since = getdate() where Name = 'InterCity'"
        cursor.execute(sql)
        cursor.commit()
        del cursor
        connect.close()
        return 1

def insert_stop(url):
    connect = pyodbc.connect('DRIVER={SQL Server};SERVER=localhost;DATABASE=iTraffic;')
    cursor = connect.cursor()
    res = requests.get(url, headers = ptxheader()).text

    for stop in json.loads(res):
        try:
            if stop["StopName"]["En"] == "" :
                estop = None
            else:
                estop = stop["StopName"]["En"]
            cursor.execute("exec dbo.xp_insertStop ?,?,?,?,?,?,?,?,?", "公路客運", stop["StopName"]["Zh_tw"], estop, stop["UpdateTime"][0:19],
            stop["StopUID"], stop["StopPosition"]["PositionLon"], stop["StopPosition"]["PositionLat"],  None, stop["StopAddress"])
            cursor.commit()
        except:
            continue
    del cursor
    connect.close()

def insert_route(url):
    connect = pyodbc.connect('DRIVER={SQL Server};SERVER=localhost;DATABASE=iTraffic;')
    cursor = connect.cursor()
    res = requests.get(url, headers = ptxheader()).text

    for route in json.loads(res):
        for subroute in route["SubRoutes"]:
            try:
                # 有的第一個子路線的路線編號會硬加0在後面
                if subroute["SubRouteName"]["Zh_tw"][-1] == "0" and len(subroute["SubRouteName"]["Zh_tw"]) > len(route["RouteID"]):
                    number = subroute["SubRouteName"]["Zh_tw"][:-1]
                else:
                    number = subroute["SubRouteName"]["Zh_tw"]
                if route["DepartureStopNameEn"] != "" and route["DestinationStopNameEn"] != "":
                    eheadsign = route["DepartureStopNameEn"] + " - " + route["DestinationStopNameEn"]
                else:
                    eheadsign = None
                cursor.execute("exec dbo.xp_insertBus ?,?,?,?,?,?,?", "公路客運", number, number, 
                subroute["Headsign"].replace("→"," - ").replace("─"," - "), eheadsign, subroute["SubRouteUID"], subroute["Direction"])
                cursor.commit()
            except:
                continue
    del cursor
    connect.close()

def insert_ST(url):
    connect = pyodbc.connect('DRIVER={SQL Server};SERVER=localhost;DATABASE=iTraffic;')
    cursor = connect.cursor()
    res = requests.get(url, headers = ptxheader()).text

    for route in json.loads(res):
        # 以停靠站點加密成md5
        md5 = hashlib.md5()
        md5.update(json.dumps(route["Stops"]).encode())
        #判斷路線是否更動或為新增的路線
        cursor.execute("exec dbo.xp_checkBus ?,?,?,?", "公路客運", route["SubRouteUID"], route["Direction"], md5.hexdigest())
        cursor.commit()
        
        sql = """select * from Class C, CO, Object O, Transportation T, TS
              where C.CID = CO.CID and CO.OID = O.OID and O.OID = T.TID and T.TID = TS.TID
              and C.Type = 102 and C.NamePath like '%' +
              """ + "'公路客運'" + " and T.Number = '" + route["SubRouteUID"] + "' and T.Direction = " + str(route["Direction"]) + " and T.MD5 = '" + md5.hexdigest() + "'"
        cursor.execute(sql)
        if cursor.fetchone() is None:
            for stop in route["Stops"]:
                try:
                    cursor.execute("exec dbo.xp_insertBusST ?,?,?,?,?,?", "公路客運", route["SubRouteUID"], route["Direction"],
                    stop["StopUID"], stop["StopName"]["Zh_tw"], stop["StopSequence"])
                    cursor.commit()
                except:
                    continue
    del cursor
    connect.close()

def delete(time):
    connect = pyodbc.connect('DRIVER={SQL Server};SERVER=localhost;DATABASE=iTraffic;')
    cursor = connect.cursor()

    cursor.execute("exec dbo.xp_deleteBus ?,?", time, "公路客運")
    cursor.commit()
    
    del cursor
    connect.close()

def main():
    if update():
       print("客運需要更新")
       start_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

       # 客運站牌
       start = time.time()
       insert_stop("http://ptx.transportdata.tw/MOTC/v2/Bus/Stop/InterCity?$format=JSON")
       end = time.time()
       print("已完成" + '客運' + "的站牌資料，花了" + str(end-start) + "秒")

       # 客運路線
       start = time.time()
       insert_route("http://ptx.transportdata.tw/MOTC/v2/Bus/Route/InterCity?$format=JSON")
       end = time.time()
       print("已完成" + '客運' + "的路線資料，花了" + str(end-start) + "秒")

       # 客運路線與站牌
       start = time.time()
       insert_ST("http://ptx.transportdata.tw/MOTC/v2/Bus/StopOfRoute/InterCity?$format=JSON")
       end = time.time()
       print("已完成" + '客運' + "的路線與站牌資料，花了" + str(end-start) + "秒")

       #刪除未被用的路線及站牌
       delete(start_time)
    else:
       print("客運不用更新")

main()