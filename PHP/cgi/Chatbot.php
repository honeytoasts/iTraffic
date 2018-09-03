<?php
	include '../api/conn.php';
	header('Content-Type: application/json; charset=utf8');
	// 宣告一個空陣列 $data
	$arr = array();
	$FBID = $_GET["FBID"]; $answer = $_GET["answer"];
	
	if ( (isset($FBID) && ($FBID!='')) && (isset($answer) && ($answer!='')) ) {
		$q = sprintf("exec xp_Chatbot '%s', '%s'", $FBID, $answer) ;
		$item = msQuery($q);

		$q = sprintf("select Response from Chatbot where FBID = '%s'", $FBID) ;
		$item = msQuery($q);

		echo sqlsrv_fetch_array($item)[0] ;
		// while($itemArr = sqlsrv_fetch_array($item)) {
		// 	// 宣告一個空陣列 $data
		// 	$data = array();
		// 	// 自行命名做為 json 欄位名稱
		// 	// if ($itemArr[1] != 'TRA') {
		// 		$data["response"] = $itemArr[0];
		// 		// 最後再把 $data 存進 $arr 即可
		// 		array_push($arr, $data);
		// 	// }
		// }
		// echo json_encode($arr);
    } 
    else {
		echo '輸入的參數錯誤。';
	}
	// 當成功 echo 出 api 之後，我們必須讓本次資料庫連線 $conn 釋放記憶體
	sqlsrv_close($conn);
 ?>