# 本系統為介接交通部PTX平臺資料

import pyodbc
import json
import requests
import time
import hashlib
from datetime import datetime
from header import ptxheader

# 確認版本編號，判斷是否須更新資料
def update(city):
    connect = pyodbc.connect('DRIVER={SQL Server};SERVER=localhost;DATABASE=iTraffic;')
    cursor = connect.cursor()
    res = requests.get("http://ptx.transportdata.tw/MOTC/v2/Bus/DataVersion/City/" + city + "?$format=JSON", headers = ptxheader()).text
    versionID = json.loads(res)["VersionID"]

    sql = "select VersionID from DataVersion where Name = '" + city + "'"
    cursor.execute(sql)
    if cursor.fetchone()[0] == versionID :
        return 0
    else:
        sql = "update DataVersion set VersionID = " + str(versionID) + ", Since = getdate() where Name = '" + city + "'"
        cursor.execute(sql)
        cursor.commit()
        return 1

def insert_stop(url, city):
    connect = pyodbc.connect('DRIVER={SQL Server};SERVER=localhost;DATABASE=iTraffic;')
    cursor = connect.cursor()
    res = requests.get(url, headers = ptxheader()).text

    for stop in json.loads(res):
        # 資料可能有可能無
        try:
            if stop["StopName"]["En"] == "":
                estop = None
            else:
                estop = stop["StopName"]["En"]
        except:
            estop = None
        try:
            lon = stop["StopPosition"]["PositionLon"]
        except:
            lon = None
        try:
            lat = stop["StopPosition"]["PositionLat"]
        except:
            lat = None
        try:
            cursor.execute("exec dbo.xp_insertStop ?,?,?,?,?,?,?,?,?", city, stop["StopName"]["Zh_tw"], estop,
            stop["UpdateTime"][0:19], stop["StopUID"], lon, lat, None, None)
            cursor.commit()
        except:
            continue
    del cursor
    connect.close()

def insert_route(url, city):
    connect = pyodbc.connect('DRIVER={SQL Server};SERVER=localhost;DATABASE=iTraffic;')
    cursor = connect.cursor()
    res = requests.get(url, headers = ptxheader()).text

    if "台北市" in city or "新北市" in city:
       for route in json.loads(res):
            try:
                ename = route["RouteName"]["En"]
            except:
                ename = None
            try:
                if route["DepartureStopNameZh"] != "" and route["DestinationStopNameZh"] != "" :
                    cheadsign = route["DepartureStopNameZh"] + " - " + route["DestinationStopNameZh"]
                else:
                    cheadsign = None
            except:    
                cheadsign = None
            try:
                if route["DepartureStopNameEn"] != "" and route["DestinationStopNameEn"] != "":
                    eheadsign = route["DepartureStopNameEn"] + " - " + route["DestinationStopNameEn"]
                else:
                    eheadsign = None
            except:
                eheadsign = None
            cursor.execute("exec dbo.xp_insertBus ?,?,?,?,?,?,?", city, route["RouteName"]["Zh_tw"], ename,
            cheadsign, eheadsign, route["RouteUID"], 0)
            cursor.commit()
            cursor.execute("exec dbo.xp_insertBus ?,?,?,?,?,?,?", city, route["RouteName"]["Zh_tw"], ename,
            cheadsign, eheadsign, route["RouteUID"], 1)
            cursor.commit()
    else:
        for route in json.loads(res):
            for subroute in route["SubRoutes"]:
                try:
                    ename = subroute["SubRouteName"]["En"]
                except:
                    ename = None
                try:
                    cheadsign = subroute["Headsign"].replace("<->"," - ").replace("→"," - ").replace("─"," - ").replace("->"," - ").replace("－"," - ").replace("-", " - ")
                except:                                                          
                    try:
                        if route["DepartureStopNameZh"] != "" and route["DestinationStopNameZh"] != "" :
                            cheadsign = route["DepartureStopNameZh"] + " - " + route["DestinationStopNameZh"]
                        else:
                            cheadsign = None
                    except:    
                        cheadsign = None
                try:
                    if route["DepartureStopNameEn"] != "" and route["DestinationStopNameEn"] != "":
                        eheadsign = route["DepartureStopNameEn"] + " - " + route["DestinationStopNameEn"]
                    else:
                        eheadsign = None
                except:
                    eheadsign = None

                cursor.execute("exec dbo.xp_insertBus ?,?,?,?,?,?,?", city, subroute["SubRouteName"]["Zh_tw"], ename,
                cheadsign, eheadsign, subroute["SubRouteUID"], subroute["Direction"])
                cursor.commit()
    del cursor
    connect.close()

def insert_ST(url, city):
    connect = pyodbc.connect('DRIVER={SQL Server};SERVER=localhost;DATABASE=iTraffic;')
    cursor = connect.cursor()
    res = requests.get(url, headers = ptxheader()).text

    if "台北市" in city or "新北市" in city:
        uid = "RouteUID"
    else:
        uid = "SubRouteUID"
    for route in json.loads(res):
        # 以停靠站點加密成md5
        md5 = hashlib.md5()
        md5.update(json.dumps(route["Stops"]).encode())
        # 判斷路線是否更動或為新增的路線
        cursor.execute("exec dbo.xp_checkBus ?,?,?,?", city, route[uid], route["Direction"], md5.hexdigest())
        cursor.commit()

        sql = """select * from Class C, CO, Object O, Transportation T, TS
              where C.CID = CO.CID and CO.OID = O.OID and O.OID = T.TID and T.TID = TS.TID
              and C.Type = 102 and C.NamePath like '%' + '
              """ + city + "' and T.Number = '" + route[uid] + "' and T.Direction = " + str(route["Direction"]) + " and T.MD5 = '" + md5.hexdigest() + "'"
        cursor.execute(sql)
        if cursor.fetchone() is None:
            for stop in route["Stops"]:
                try:
                    cursor.execute("exec dbo.xp_insertBusST ?,?,?,?,?,?", city, route[uid], route["Direction"],
                    stop["StopUID"], stop["StopName"]["Zh_tw"], stop["StopSequence"])
                    cursor.commit()
                except:
                    continue
    del cursor
    connect.close()

def delete(time, city):
    connect = pyodbc.connect('DRIVER={SQL Server};SERVER=localhost;DATABASE=iTraffic;')
    cursor = connect.cursor()

    cursor.execute("exec dbo.xp_deleteBus ?,?", time, city)
    cursor.commit()
    
    del cursor
    connect.close()

def main():
    city = {"台北市":"Taipei","新北市":"NewTaipei","桃園市":"Taoyuan","台中市":"Taichung","台南市":"Tainan","高雄市":"Kaohsiung","基隆市":"Keelung",
            "新竹市":"Hsinchu","新竹縣":"HsinchuCounty","苗栗縣":"MiaoliCounty","彰化縣":"ChanghuaCounty","南投縣":"NantouCounty","雲林縣":"YunlinCounty",
            "嘉義縣":"ChiayiCounty","嘉義市":"Chiayi","屏東縣":"PingtungCounty","宜蘭縣":"YilanCounty","花蓮縣":"HualienCounty","台東縣":"TaitungCounty",
            "金門縣":"KinmenCounty","澎湖縣":"PenghuCounty","連江縣":"LienchiangCounty"}

    for key, value in city.items():
        if update(value):
           print(key + "公車需要更新")
           start_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

           # 市區公車站牌
           start = time.time()
           insert_stop("http://ptx.transportdata.tw/MOTC/v2/Bus/Stop/City/" + value + "?$format=JSON", "市區公車/" + key)
           end = time.time()
           print("已完成" + key + "公車的站牌資料，花了" + str(end-start) + "秒")

           # 市區公車路線
           start = time.time()
           insert_route("http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/" + value + "?$format=JSON", "市區公車/" + key)
           end = time.time()
           print("已完成" + key + "公車的路線資料，花了" + str(end-start) + "秒")

           # 市區公車路線與站牌
           start = time.time()
           if key == "台北市" or key == "新北市":
              insert_ST("http://ptx.transportdata.tw/MOTC/v2/Bus/DisplayStopOfRoute/City/" + value + "?$format=JSON", "市區公車/" + key)
           else:
              insert_ST("http://ptx.transportdata.tw/MOTC/v2/Bus/StopOfRoute/City/" + value + "?$format=JSON", "市區公車/" + key)
           end = time.time()
           print("已完成" + key + "公車的路線與站牌資料，花了" + str(end-start) + "秒")

           #刪除未被用的路線及站牌
           delete(start_time, "市區公車/" + key)
        else:
           print(key + "公車不用更新")
           
main()