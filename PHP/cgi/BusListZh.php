<?php
	include '../api/conn.php';
	header('Content-Type: application/json; charset=utf8');
	// 宣告一個空陣列 $data
	$arr = array();
	$name = $_GET["name"];
	
	if ( (isset($name) && ($name!='')) ) {
		$q = sprintf("set NOCOUNT ON 
				select * from vd_BusListZh where name like '%s%%'", $name) ;
		$item = msQuery($q);
		while($itemArr = sqlsrv_fetch_array($item)) {
			// 宣告一個空陣列 $data
			$data = array();
			// 自行命名做為 json 欄位名稱
			$data["type"] = $itemArr[0];
			$data["url"] = $itemArr[1];
			$data["routeuid"] = $itemArr[2];
      $data["name"] = $itemArr[3]; 
      $data["headsign"] = $itemArr[4];
			$data["outbound"] = $itemArr[5];
			$data["inbound"] = $itemArr[6];
			// 最後再把 $data 存進 $arr 即可
			array_push($arr, $data);
		}
		echo json_encode($arr);
    } 
    else {
		echo '輸入的參數錯誤。';
	}
	// 當成功 echo 出 api 之後，我們必須讓本次資料庫連線 $conn 釋放記憶體
	sqlsrv_close($conn);
 ?>