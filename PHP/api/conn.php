<?php
	// 資料庫連線登入
	$servername = 'Your IP';
	$info = array('Database' => 'iTraffic', 'UID' => 'sa', 'PWD' => 'password', 'CharacterSet' => 'UTF-8', 'ReturnDatesAsStrings' => true);
	// 建立資料庫連線
	$conn = sqlsrv_connect($servername, $info);
	// 判斷有無連線
	if( $conn ) {
	}else{
		echo "connect error<br/>";
		die(print_r(sqlsrv_errors(), true));
	}
	// 預先寫一支 select 用的 function
	function msQuery($sql) {
		global $conn;
		$ret = sqlsrv_query($conn, $sql);
		if(!$ret) {
			echo "<br/>";
			die(print_r(sqlsrv_errors(), true));
		}
		return $ret;
	}
	// 預先寫一支 select $res[0] 用的 function
	function selectQuery($sql) {
		global $conn;
		$ret = sqlsrv_query($conn, $sql);
		if(!$ret) {
			echo "<br/>";
			die(print_r(sqlsrv_errors(), true));
		}
		$res = sqlsrv_fetch_array($ret);
		return $res[0];
	}
?>