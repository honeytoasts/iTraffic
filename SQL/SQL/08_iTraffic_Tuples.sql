use [$(DBName)]
go

--Entity
set identity_insert Entity on
insert into Entity(EID, CName, EName) values(101, '站點', 'Stop')             -- EID = 101
insert into Entity(EID, CName, EName) values(102, '班次', 'Transportation')   -- EID = 102
/*insert into Entity(EID, CName, EName) values(103, '路線', 'Route')          -- EID = 103 */

set identity_insert Entity off
go

declare @CCID int, @CCID2 int

--Member
exec dbo.xp_insertClass 0, 2, '會員', 'Member', @CCID output
exec dbo.xp_insertClass2 @CCID, 2, 'A', 'A'
exec dbo.xp_insertClass2 @CCID, 2, 'B', 'B'
exec dbo.xp_insertClass2 @CCID, 2, 'C', 'C'
exec dbo.xp_insertClass2 @CCID, 2, 'D', 'D'
exec dbo.xp_insertClass2 @CCID, 2, 'E', 'E'
exec dbo.xp_insertClass2 @CCID, 2, 'F', 'F'
exec dbo.xp_insertClass2 @CCID, 2, 'G', 'G'
exec dbo.xp_insertClass2 @CCID, 2, 'H', 'H'
exec dbo.xp_insertClass2 @CCID, 2, 'I', 'I'
exec dbo.xp_insertClass2 @CCID, 2, 'J', 'J'
exec dbo.xp_insertClass2 @CCID, 2, 'K', 'K'
exec dbo.xp_insertClass2 @CCID, 2, 'L', 'L'
exec dbo.xp_insertClass2 @CCID, 2, 'M', 'M'
exec dbo.xp_insertClass2 @CCID, 2, 'N', 'N'
exec dbo.xp_insertClass2 @CCID, 2, 'O', 'O'
exec dbo.xp_insertClass2 @CCID, 2, 'P', 'P'
exec dbo.xp_insertClass2 @CCID, 2, 'Q', 'Q'
exec dbo.xp_insertClass2 @CCID, 2, 'R', 'R'
exec dbo.xp_insertClass2 @CCID, 2, 'S', 'S'
exec dbo.xp_insertClass2 @CCID, 2, 'T', 'T'
exec dbo.xp_insertClass2 @CCID, 2, 'U', 'U'
exec dbo.xp_insertClass2 @CCID, 2, 'V', 'V'
exec dbo.xp_insertClass2 @CCID, 2, 'W', 'W'
exec dbo.xp_insertClass2 @CCID, 2, 'X', 'X'
exec dbo.xp_insertClass2 @CCID, 2, 'Y', 'Y'
exec dbo.xp_insertClass2 @CCID, 2, 'Z', 'Z'

-- Stop
exec dbo.xp_insertClass 0, 101, '站點', 'Stop', @CCID output
exec dbo.xp_insertClass2 @CCID, 101, '高鐵', 'THSR'
exec dbo.xp_insertClass2 @CCID, 101, '台鐵', 'TRA'
exec dbo.xp_insertClass3 @CCID, 101, '公路客運', 'Intercity Bus', 'InterCity'
exec dbo.xp_insertClass @CCID, 101, '市區公車', 'City Bus', @CCID2 output
-- 為配合ptx查詢各縣市的API所使用的英文命名，存在EDes，並使用insertclass3
exec dbo.xp_insertclass3 @CCID2, 101, '台北市', 'Taipei City', 'Taipei'
exec dbo.xp_insertclass3 @CCID2, 101, '新北市', 'New Taipei City', 'NewTaipei'
exec dbo.xp_insertclass3 @CCID2, 101, '桃園市', 'Taoyuan City', 'Taoyuan'
exec dbo.xp_insertclass3 @CCID2, 101, '台中市', 'Taichung City', 'Taichung'
exec dbo.xp_insertclass3 @CCID2, 101, '台南市', 'Tainan City', 'Tainan'
exec dbo.xp_insertclass3 @CCID2, 101, '高雄市', 'Kaohsiung City', 'Kaohsiung'
exec dbo.xp_insertclass3 @CCID2, 101, '基隆市', 'Keelung City', 'Keelung'
exec dbo.xp_insertclass3 @CCID2, 101, '新竹市', 'Hsinchu City', 'Hsinchu'
exec dbo.xp_insertclass3 @CCID2, 101, '新竹縣', 'Hsinchu County', 'HsinchuCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '苗栗縣', 'Miaoli County', 'MiaoliCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '彰化縣', 'Changhua County', 'ChanghuaCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '南投縣', 'Nantou County', 'NantouCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '雲林縣', 'Yunlin County', 'YunlinCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '嘉義縣', 'Chiayi County', 'ChiayiCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '嘉義市', 'Chiayi City', 'Chiayi'
exec dbo.xp_insertclass3 @CCID2, 101, '屏東縣', 'Pingtung County', 'PingtungCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '宜蘭縣', 'Yilan County', 'YilanCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '花蓮縣', 'Hualien County', 'HualienCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '台東縣', 'Taitung County', 'TaitungCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '金門縣', 'Kinmen County', 'KinmenCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '澎湖縣', 'Penghu County', 'PenghuCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '連江縣', 'Lienchiang County', 'LienchiangCounty'

exec dbo.xp_insertClass @CCID, 101, '捷運', 'MRT', @CCID2 output
exec dbo.xp_insertclass3 @CCID2, 101, '台北捷運', 'Taipei MRT', 'TRTC'
exec dbo.xp_insertclass3 @CCID2, 101, '高雄捷運', 'Kaohsiung MRT', 'KRTC'
exec dbo.xp_insertclass3 @CCID2, 101, '桃園捷運', 'Taoyuan MRT', 'TYMC'

--Transportation
exec dbo.xp_insertClass 0, 102, '班次', 'Transportation', @CCID output
exec dbo.xp_insertClass2 @CCID, 102, '高鐵', 'THSR'
exec dbo.xp_insertClass2 @CCID, 102, '台鐵', 'TRA'
exec dbo.xp_insertClass3 @CCID, 102, '公路客運', 'Intercity Bus', 'InterCity'
exec dbo.xp_insertClass @CCID, 102, '市區公車', 'City Bus', @CCID2 output
-- 為配合ptx查詢各縣市的API所使用的英文命名，存在EDes，並使用insertclass3
exec dbo.xp_insertclass3 @CCID2, 102, '台北市', 'Taipei City', 'Taipei'
exec dbo.xp_insertclass3 @CCID2, 102, '新北市', 'New Taipei City', 'NewTaipei'
exec dbo.xp_insertclass3 @CCID2, 102, '桃園市', 'Taoyuan City', 'Taoyuan'
exec dbo.xp_insertclass3 @CCID2, 102, '台中市', 'Taichung City', 'Taichung'
exec dbo.xp_insertclass3 @CCID2, 102, '台南市', 'Tainan City', 'Tainan'
exec dbo.xp_insertclass3 @CCID2, 102, '高雄市', 'Kaohsiung City', 'Kaohsiung'
exec dbo.xp_insertclass3 @CCID2, 102, '基隆市', 'Keelung City', 'Keelung'
exec dbo.xp_insertclass3 @CCID2, 102, '新竹市', 'Hsinchu City', 'Hsinchu'
exec dbo.xp_insertclass3 @CCID2, 102, '新竹縣', 'Hsinchu County', 'HsinchuCounty'
exec dbo.xp_insertclass3 @CCID2, 102, '苗栗縣', 'Miaoli County', 'MiaoliCounty'
exec dbo.xp_insertclass3 @CCID2, 102, '彰化縣', 'Changhua County', 'ChanghuaCounty'
exec dbo.xp_insertclass3 @CCID2, 102, '南投縣', 'Nantou County', 'NantouCounty'
exec dbo.xp_insertclass3 @CCID2, 102, '雲林縣', 'Yunlin County', 'YunlinCounty'
exec dbo.xp_insertclass3 @CCID2, 102, '嘉義縣', 'Chiayi County', 'ChiayiCounty'
exec dbo.xp_insertclass3 @CCID2, 102, '嘉義市', 'Chiayi City', 'Chiayi'
exec dbo.xp_insertclass3 @CCID2, 102, '屏東縣', 'Pingtung County', 'PingtungCounty'
exec dbo.xp_insertclass3 @CCID2, 102, '宜蘭縣', 'Yilan County', 'YilanCounty'
exec dbo.xp_insertclass3 @CCID2, 102, '花蓮縣', 'Hualien County', 'HualienCounty'
exec dbo.xp_insertclass3 @CCID2, 102, '台東縣', 'Taitung County', 'TaitungCounty'
exec dbo.xp_insertclass3 @CCID2, 102, '金門縣', 'Kinmen County', 'KinmenCounty'
exec dbo.xp_insertclass3 @CCID2, 102, '澎湖縣', 'Penghu County', 'PenghuCounty'
exec dbo.xp_insertclass3 @CCID2, 102, '連江縣', 'Lienchiang County', 'LienchiangCounty'

exec dbo.xp_insertClass @CCID, 102, '捷運', 'MRT', @CCID2 output
exec dbo.xp_insertclass3 @CCID2, 102, '台北捷運', 'Taipei MRT', 'TRTC'
exec dbo.xp_insertclass3 @CCID2, 102, '高雄捷運', 'Kaohsiung MRT', 'KRTC'
exec dbo.xp_insertclass3 @CCID2, 102, '桃園捷運', 'Taoyuan MRT', 'TYMC'

-- 站位
exec dbo.xp_insertClass 0, 101, '站位', 'Station', @CCID output
exec dbo.xp_insertClass2 @CCID, 101, '高鐵', 'THSR'
exec dbo.xp_insertClass2 @CCID, 101, '台鐵', 'TRA'
exec dbo.xp_insertClass3 @CCID, 101, '公路客運', 'Intercity Bus', 'InterCity'
exec dbo.xp_insertClass @CCID, 101, '市區公車', 'City Bus', @CCID2 output
-- 為配合ptx查詢各縣市的API所使用的英文命名，存在EDes，並使用insertclass3
exec dbo.xp_insertclass3 @CCID2, 101, '台北市', 'Taipei City', 'Taipei'
exec dbo.xp_insertclass3 @CCID2, 101, '新北市', 'New Taipei City', 'NewTaipei'
exec dbo.xp_insertclass3 @CCID2, 101, '桃園市', 'Taoyuan City', 'Taoyuan'
exec dbo.xp_insertclass3 @CCID2, 101, '台中市', 'Taichung City', 'Taichung'
exec dbo.xp_insertclass3 @CCID2, 101, '台南市', 'Tainan City', 'Tainan'
exec dbo.xp_insertclass3 @CCID2, 101, '高雄市', 'Kaohsiung City', 'Kaohsiung'
exec dbo.xp_insertclass3 @CCID2, 101, '基隆市', 'Keelung City', 'Keelung'
exec dbo.xp_insertclass3 @CCID2, 101, '新竹市', 'Hsinchu City', 'Hsinchu'
exec dbo.xp_insertclass3 @CCID2, 101, '新竹縣', 'Hsinchu County', 'HsinchuCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '苗栗縣', 'Miaoli County', 'MiaoliCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '彰化縣', 'Changhua County', 'ChanghuaCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '南投縣', 'Nantou County', 'NantouCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '雲林縣', 'Yunlin County', 'YunlinCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '嘉義縣', 'Chiayi County', 'ChiayiCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '嘉義市', 'Chiayi City', 'Chiayi'
exec dbo.xp_insertclass3 @CCID2, 101, '屏東縣', 'Pingtung County', 'PingtungCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '宜蘭縣', 'Yilan County', 'YilanCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '花蓮縣', 'Hualien County', 'HualienCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '台東縣', 'Taitung County', 'TaitungCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '金門縣', 'Kinmen County', 'KinmenCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '澎湖縣', 'Penghu County', 'PenghuCounty'
exec dbo.xp_insertclass3 @CCID2, 101, '連江縣', 'Lienchiang County', 'LienchiangCounty'

exec dbo.xp_insertClass @CCID, 101, '捷運', 'MRT', @CCID2 output
exec dbo.xp_insertclass3 @CCID2, 101, '台北捷運', 'Taipei MRT', 'TRTC'
exec dbo.xp_insertclass3 @CCID2, 101, '高雄捷運', 'Kaohsiung MRT', 'KRTC'
exec dbo.xp_insertclass3 @CCID2, 101, '桃園捷運', 'Taoyuan MRT', 'TYMC'

-- PTX資料版本
insert into DataVersion(Name) values('TRA')
insert into DataVersion(Name) values('THSR')
insert into DataVersion(Name) values('InterCity')
insert into DataVersion(Name) values('Taipei')
insert into DataVersion(Name) values('NewTaipei')
insert into DataVersion(Name) values('Taoyuan')
insert into DataVersion(Name) values('Taichung')
insert into DataVersion(Name) values('Tainan')
insert into DataVersion(Name) values('Kaohsiung')
insert into DataVersion(Name) values('Keelung')
insert into DataVersion(Name) values('Hsinchu')
insert into DataVersion(Name) values('HsinchuCounty')
insert into DataVersion(Name) values('MiaoliCounty')
insert into DataVersion(Name) values('ChanghuaCounty')
insert into DataVersion(Name) values('NantouCounty')
insert into DataVersion(Name) values('YunlinCounty')
insert into DataVersion(Name) values('ChiayiCounty')
insert into DataVersion(Name) values('Chiayi')
insert into DataVersion(Name) values('PingtungCounty')
insert into DataVersion(Name) values('YilanCounty')
insert into DataVersion(Name) values('HualienCounty')
insert into DataVersion(Name) values('TaitungCounty')
insert into DataVersion(Name) values('KinmenCounty')
insert into DataVersion(Name) values('PenghuCounty')
insert into DataVersion(Name) values('LienchiangCounty')
insert into DataVersion(Name) values('TRTC')
insert into DataVersion(Name) values('KRTC')
insert into DataVersion(Name) values('TYMC')

go