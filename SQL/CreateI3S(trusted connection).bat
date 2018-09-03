set Server=localhost

set DBName=iTraffic

set Directory=Project Path

set AdminName = AdminName
set AdminPWD = AdminPWD

set account = account
set password = password

echo "createDB"
sqlcmd -S %Server% -U %account% -P %password% -v DBName = "%DBName%" DirPath = "%Directory%" -i SQL\01_Database.sql
pause

echo "create Views"
sqlcmd -S %Server% -U %account% -P %password% -v DBName = "%DBName%" -i SQL\02_View.sql
pause

echo "create SP and Fun"
sqlcmd -S %Server% -U %account% -P %password% -v DBName = "%DBName%" DLLDir = "%cd%\SQL\DLL" -i SQL\03_SPandFun.sql
pause

echo "insert Tuples"
sqlcmd -S %Server% -U %account% -P %password% -v DBName = "%DBName%" AdminName = %AdminName% AdminPWD = %AdminPWD% -i SQL\04_Tuples.sql
pause

echo "iTraffic_createDB"
sqlcmd -S %Server% -U %account% -P %password% -v DBName = "%DBName%" -i SQL\05_iTraffic_Database.sql
pause

echo "iTraffic_create SP and Fun"
sqlcmd -S %Server% -U %account% -P %password% -v DBName = "%DBName%" -i SQL\07_iTraffic_SPandFun.sql
pause

echo "iTraffic_insert Tuples"
sqlcmd -S %Server% -U %account% -P %password% -v DBName = "%DBName%" -i SQL\08_iTraffic_Tuples.sql
pause

echo "setup SQL functions fn_getDbLocationn"
sqlcmd -S %Server% -U %account% -P %password% -v DBName = "%DBName%" -i TP\SQL\00_fn_getDbLocation.sql
pause

echo "TP_SPandFn"
sqlcmd -S %Server% -U %account% -P %password% -v DBName = "%DBName%" DLLDir = "%cd%\TP\SQL\DLL" -i TP\SQL\02_TP_SPandFn.sql
pause

echo "TP_SPandFn_Stemming"
sqlcmd -S %Server% -U %account% -P %password% -v DBName = "%DBName%" -i TP\SQL\06_Stemming.sql

echo "iTraffic_create Views"
sqlcmd -S %Server% -U %account% -P %password% -v DBName = "%DBName%" -i SQL\06_iTraffic_View.sql
pause