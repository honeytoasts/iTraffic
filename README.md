# iTraffic 大眾運輸資訊平台
提供台鐵、高鐵、公路客運、市區公車班次查詢，及其行車動態、預估到站查詢

## 目錄
- [程式安裝](#程式安裝)
- [匯入資料](#匯入資料)
- [架設網站](#架設網站)

## 程式安裝
1. [SQL Server 2017 express](https://go.microsoft.com/fwlink/?linkid=853017)：免費的SQL Server版本，適合開發小型應用程式
2. [SQL Server Mamagement Studio](https://go.microsoft.com/fwlink/?linkid=875802)：供查詢、設計與管理資料庫
3. [XAMPP](https://www.apachefriends.org/zh_tw/download.html)：架設Apache伺服器，撰寫PHP檔案以提供API
4. [Node.js](https://nodejs.org/dist/v8.11.4/node-v8.11.4-x64.msi)

## 匯入資料
### [公共運輸整合資訊流通服務平台](http://ptx.transportdata.tw/PTX/)
此為交通部所提供之開放資料平台，此專案的所有資料皆從此網站抓取<br>
使用前須先[註冊會員](https://ptx.transportdata.tw/PTX/Management/AccountApply)，取得基礎資料(L1)服務的AppID和AppKey，以呼叫API取得所需資料
