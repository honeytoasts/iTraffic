use $(DBName)
-- declare @DBName varchar(3) = 'iEN3'
go
/*
select t.name, s.row_count
from sys.tables t , sys.dm_db_partition_stats s
where t.object_id = s.object_id and s.index_id in ( 0, 1 ) and t.name not like '%dss%' and t.type_desc = 'USER_TABLE'
*/
/* fn_splitString
Execute :
	select * from fn_splitString( @String, @Delimiter )
Example :
	select * from fn_splitString( N'這是測試的資料，ABCD', '，' )
*/
if exists ( select * from sys.objects where object_id = object_id(N'fn_splitString') and type in ( N'FT', N'FN', N'TF', N'FS') )
	drop function fn_splitString
go

create function fn_splitString( @String nvarchar(max), @delimiter nvarchar(max) )
	returns @splitTable table ( sno int identity(1,1), value nvarchar(max) )
begin
	/*
	-- 1.) xml split
	declare @xml xml = convert( xml, ( '<X>' + replace( @String collate Chinese_Taiwan_Stroke_CS_AS_WS , @delimiter ,'</X><X>' ) + '</X>' ) )
	insert into @splitTable( value )
		select N.value('.', 'nvarchar(max)') as value from @xml.nodes('X') as T(N)
	*/
	/*
	-- 2.) five lines split
	while( len( @String ) > 0 )
	begin
		insert into @splitTable values( iif( charindex( @Delimiter, @String collate Chinese_Taiwan_Stroke_CS_AS_WS ) = 0, @String, left( @String, charindex( @delimiter, @String collate Chinese_Taiwan_Stroke_CS_AS_WS ) - 1 ) ) )
		set @String  = iif( charindex( @Delimiter, @String collate Chinese_Taiwan_Stroke_CS_AS_WS ) = 0, '', stuff( @String collate Chinese_Taiwan_Stroke_CS_AS_WS, 1, len( left( @String, charindex( @delimiter, @String collate Chinese_Taiwan_Stroke_CS_AS_WS ) - 1 ) ) + len( replace( @delimiter, ' ', ',' ) ), '' ) )
	end
	*/
	-- 3.) base split
	declare @leftString nvarchar(max)

	while( len( @String ) > 0 )
	begin
		-- find out the index of @delimiter in @String
		if ( charindex( @Delimiter, @String collate Chinese_Taiwan_Stroke_CS_AS_WS ) = 0 )
		begin
			insert into @splitTable values( @String )
			set @String = ''
		end
		else
		begin
			-- @leftString insert into @splitTable
			set @leftString =  left( @String, charindex( @delimiter, @String collate Chinese_Taiwan_Stroke_CS_AS_WS ) - 1 )
			insert into @splitTable values( @leftString )
			set @String =  stuff( @String collate Chinese_Taiwan_Stroke_CS_AS_WS, 1, len( @leftString ) + len( replace( @delimiter, ' ', ',' ) ), '' )
		end
	end
	return
end
go

/* fn_delimitString
Execute :
	select * from fn_TP_Segmentation( @String, default,  )
Example :
	select * from fn_TP_Segmentation( N'這是測試的資料，哎哟!ABCD是英文字母。', default, default )
	select * from fn_TP_Segmentation( N'這是測試的資料，哎哟!ABCD是英文字母。', 1, 3 )
*/
if exists ( select * from sys.objects where object_id = object_id(N'fn_TP_Segmentation') and type in ( N'FT', N'FN', N'TF', N'FS') )
	drop function fn_TP_Segmentation
go

create function fn_TP_Segmentation( @String nvarchar(max), @Enable int = 0, @delimiterType int = 1 )
	returns @segmentsTable table( SNO int identity(1,1), Position int, Words nvarchar(max), Words_len int, Words_len_en int, Delimiter nvarchar(max) )
begin
	-- delimiterType = ( 0 => sentences, 1 => segments, 2 => segements add special delimiter )
	set @String = rtrim( ltrim( @String ) )
	declare @oString nvarchar(max) = @String
	-- Split Sentences by Delimiter
	declare @delimiterTable table( words nvarchar(max), gs int )
		insert into @delimiterTable( words, gs ) values
			/* Genernal - 標點符號 */
			--半形換行
			(N'\r',0),(N'\r\n',0),(N'\t',0),(N'\n',0),
			--UNICODE換行
			(nchar(13),0),(nchar(10),0),
			--標點符號
			(N'!',0),(N'！',0),(N'？',0),(N'?',0),(N'。',0),
			(N'ˋ',1),(N'–',1),(N';',1),(N'；',1),(N',',1),(N'，',1),(N'、',1),(N'：',1),(N':',1),
			(N'．',1),(N'●',1),(N'‧',1),
			--其他全形符號
			(N'－',2),(N'*',2),(N'"',2),(N'〝',2),(N'〞',2),(N'“',2),(N'”',2),(N'‘',2),(N'’',2),
			(N'…',2),(N'﹏',2),
			(N'」',2),(N'「',2),(N'『',2),(N'』',2),(N'《',2),(N'》',2),(N'〈',2),(N'〉',2),
			(N'(',2),(N')',2),(N'（',2),(N'）',2),(N'［',2),(N'］',2),(N'〔',2),(N'〕',2),
			(N'﹝',2),(N'﹞',2),(N'【',2),(N'】',2),(N'[',2),(N']',2),(N'{',2),(N'}',2),

			/* Special - 中文口語助詞 */
			-- (N'么',3),(N'兮',3),(N'天呀',3),(N'丟了',3),(N'而已',3),(N'吧',3),(N'呃',3),(N'吶',3),(N'呀',3),
			-- (N'呔',3),(N'呵',3),(N'呸',3),(N'呢',3),(N'尚饗',3),(N'尚飨',3),(N'呦',3),(N'哎',3),(N'哎呀',3),
			-- (N'哎喲',3),(N'哎哟',3),(N'哉',3),(N'咦',3),(N'哇',3),(N'哇呀',3),(N'哇塞',3),(N'唔',3),(N'哩',3),
			-- (N'唄',3),(N'啦',3),(N'啊呀',3),(N'啊哈',3),(N'啊喲',3),(N'啊哟',3),(N'唸了',3),(N'唸着',3),(N'捱了',3),
			-- (N'捱着',3),(N'釦了',3),(N'釦着',3),(N'啵',3),(N'猗',3),(N'喔',3),(N'欹',3),(N'嗨',3),(N'嗨喲',3),
			-- (N'嗨哟',3),(N'嗎',3),(N'嗯',3),(N'嗄',3),(N'嘛',3),(N'麼',3),(N'誒',3),(N'嘿',3),(N'罷了',3),(N'颳了',3),
			-- (N'颳着',3),(N'噫',3),(N'噯',3),(N'噢',3),(N'嚐了',3),(N'歟',3),(N'吗',3),(N'呐',3),(N'呗',3),(N'嗬',3),
			-- (N'嗬喲',3),(N'嗬哟',3),(N'嗳',3),(N'嘞',3),(N'嚯',3),(N'欤',3),(N'罢了',3),(N'诶',3)

			/* Special - 英文 */
			(N'.',4),(N'--',4),(N'<',4),(N'>',4),(N'—',4),(N'#',4),(N'~',4),(N'¡',4),(N'+',4),(N'=',4),
			(N'～',4),(N'♪',4),(N'♫',4),(N'&',4),(N'/',4),(N'_',4),(N'@',4)

	while( len( @String ) > 0 )
	begin
		declare @delimiterMatchedTable table( position int, words nvarchar(max) )

		-- if matched @delimiter, record postition, and delimiter word or delimiter words
		insert into @delimiterMatchedTable( position, words )
			select charindex( words, @String collate Chinese_Taiwan_Stroke_CS_AS_WS ), words
			from @delimiterTable
			where charindex( words, @String collate Chinese_Taiwan_Stroke_CS_AS_WS ) > 0

		-- get position first encountered in @delimiterMatchedTable
		declare @position int = ( select min( t.position ) from @delimiterMatchedTable t, @delimiterTable d where t.words = d.words collate Chinese_Taiwan_Stroke_CS_AS_WS and d.gs <= @delimiterType  ), @gs int = 0, @delimiter nvarchar(max)
		select @gs = t.gs, @delimiter = m.words from @delimiterTable t, @delimiterMatchedTable m where t.words = m.words and m.position = @position
		declare @leftString nvarchar(max) = left( @String collate Chinese_Taiwan_Stroke_CS_AS_WS, iif( @position is null, len( @String ), @position - 1 ) ) + iif( @Enable = 1, iif( @gs = 3 , @delimiter, '' ), '' )
		if ( len( ltrim( rtrim( @leftString ) ) ) > 0 ) begin
			insert into @segmentsTable( words, words_len, Words_len_en, delimiter, position )
				values ( ltrim( rtrim( @leftString ) ), len( ltrim( rtrim( @leftString ) ) ), ( select count(*) from fn_splitString( ltrim( rtrim( @leftString ) ), ' ') ), iif( @position is not null, @delimiter, '' ), charindex( ltrim( rtrim( @leftString ) ), @oString,  iif( @position is null, len( ltrim( rtrim( @leftString ) ) ), @position ) - len( ltrim( rtrim( @leftString ) ) ) ) )
		end

		set @String = right( @String collate Chinese_Taiwan_Stroke_CS_AS_WS, len( @String ) - ( @position + len( @delimiter ) ) + 1 )

		delete from @delimiterMatchedTable
	end
	return
end
go

/*  fn_TP_Segmentation_LangSplit
Execute :
	select * from fn_TP_Segmentation_LangSplit( @Sentence )
Example :
	select * from fn_TP_Segmentation_LangSplit( N'Mr. Burnt這是測試的I''m a student.資料abcd字串 90%ON★買一送一!!' )
*/
if exists ( select * from sys.objects where object_id = object_id(N'fn_TP_Segmentation_LangSplit') and type in ( N'FT', N'FN', N'TF', N'FS') )
	drop function fn_TP_Segmentation_LangSplit
go

create function fn_TP_Segmentation_LangSplit( @Sentence nvarchar(max) )
	returns @segmentsTable table( SNO int identity(1,1), Words nvarchar(max), Lang nvarchar(10) )
as
begin
	-- 4E00(hex) = 19968(decimal)
	-- 9FD5(hex) = 40917(decimal)
	/*
		12549(decimal) and 12588(decimal)
		16640(decimal) and 40869(decimal)
		63744(decimal) and 64045(decimal)
	*/
	declare @index int = 1, @tmpChar nvarchar(3), @tmpString nvarchar(max), @Status int = null, @preStatus int = null
	while ( @index <= len( @Sentence ) )
	begin
		set @tmpChar  = substring( @Sentence, @index, 1)
		-- @Status : 1 -> English and Number , @Status : 2 -> Chinese, @Status : 0 or null -> Others
		set @Status = iif( patindex('%[-a-zA-Z0-9_'' .]%', @tmpChar) > 0, 1, iif( unicode( @tmpChar ) >= 19968 and unicode( @tmpChar ) <= 40917, 2, 0 ) )

		if @preStatus = @Status
			set @tmpString += @tmpChar
		else
		begin
			if( len( @tmpString ) > 0 and @preStatus in ( 1, 2) )
				insert into @segmentsTable values ( ltrim( rtrim( @tmpString ) ), iif( @preStatus = 1, 'en', 'ch' ) )
			set @tmpString = @tmpChar
			set @preStatus = @Status
		end
		set @index += 1
	end
	if( len( @tmpString ) > 0 and @preStatus in ( 1, 2) )
		insert into @segmentsTable values ( ltrim( rtrim( @tmpString ) ), iif( @preStatus = 1, 'en', 'ch' ) )
	return
end
go

/* fn_TP_Tokenization_EN
Execute :
	select * from fn_TP_Tokenization_EN( @String, @nGram, @min_nGram )
Example :
	select * from fn_TP_Tokenization_EN( N'I''m a student, and he is a student, too.', 5, default )
*/
if exists ( select * from sys.objects where object_id = object_id(N'fn_TP_Tokenization_EN') and type in ( N'FT', N'FN', N'TF', N'FS') )
	drop function fn_TP_Tokenization_EN
go

create function fn_TP_Tokenization_EN( @String nvarchar(max), @nGram int, @min_nGram int = 1 )
	returns @tokensTable table( Words nvarchar(max) )
as
begin
	set @String = replace( @String, ',', '' )
	declare @tmpTokensTable table( sno int, words nvarchar(max) )
	insert into @tmpTokensTable(sno, words)
		select sno, value from fn_splitString( @String, ' ' )

	declare @lenTmpTokensTable int = @@rowcount, @i int = @min_nGram
	set @nGram = iif( @nGram < @lenTmpTokensTable , @nGram, @lenTmpTokensTable )
	while( @i <= @nGram )
	begin
		declare @j int = 1
		while ( (@j + @i -1 ) <= @lenTmpTokensTable )
		begin
			insert into @tokensTable( words ) select stuff( (select ' '+words from @tmpTokensTable where sno between @j and @j + @i -1 for xml path('') ), 1, 1, '' )
			set @j += 1
		end
		set @i += 1
	end
	-- delete token word, which contains blank char
	delete from  @tokensTable where words like ''

	-- delete token word not in English range
	/*
	declare @deleteChar table( words nvarchar(max) )
	insert into @deleteChar select words from @tmpTokensTable where words like '% %'
	delete from @tokensTable where words in ( select t.words from @tokensTable t, @deleteChar d where t.words like N'%' + d.words + '%' )
	*/
	return
end
go

/* fn_TP_Tokenization_CH
Execute :
	select * from fn_TP_Tokenization_CH( @String, @nGram, @min_nGram )
Example :
	select * from fn_TP_Tokenization_CH( '這是●測試的資 料', 5, default )
*/
if exists ( select * from sys.objects where object_id = object_id(N'fn_TP_Tokenization_CH') and type in ( N'FT', N'FN', N'TF', N'FS') )
	drop function fn_TP_Tokenization_CH
go

create function fn_TP_Tokenization_CH( @String nvarchar(max), @nGram int, @min_nGram int = 1 )
	returns @tokensTable table( Words nvarchar(max) )
as
begin
	declare @i int = @min_nGram
	set @nGram = iif( @nGram < len( @String ), @nGram, len( @String )  )
	while( @i <= @nGram )
	begin
		declare @j int = 1
		while ( (@j + @i -1 ) <= len(@String) )
		begin
			insert into @tokensTable( words ) select substring( @String, @j, @i )
			set @j += 1
		end
		set @i += 1
	end

	-- delete token word, which contains blank char
	delete from  @tokensTable where words like '% %'

	-- delete token word not in Chinese range
	declare @deleteChar table( words nvarchar(max) )
	insert into @deleteChar select words from @tokensTable where len(words) = 1 and unicode( words ) not between 19968 and 40917
	delete from @tokensTable where words in ( select t.words from @tokensTable t, @deleteChar d where t.words like N'%' + d.words + '%' )
	return
end
go

/* fn_TP_Tokenization
Execute :
	select * from fn_TP_Tokenization( @String, @CH_nGram, @EN_nGram )
Example :
	declare @String nvarchar(max) = N'★歡慶10周年★賀!!Happy New Year~ 全部 70% OFF喔'
	select * from fn_TP_Tokenization( @String, 8, 5 )
*/
if exists ( select * from sys.objects where object_id = object_id(N'fn_TP_Tokenization') and type in ( N'FT', N'FN', N'TF', N'FS') )
	drop function fn_TP_Tokenization
go

create function fn_TP_Tokenization( @String nvarchar(max), @CH_nGram int = 8, @EN_nGram int = 5 )
	returns @tokensTable table( Words nvarchar(max) )
as
begin
	declare @segmentsTable table( sno int identity(1,1), words nvarchar(max), Lang nvarchar(10) )
	insert into @segmentsTable( words, Lang )
		select words, Lang from fn_TP_Segmentation_LangSplit( @String )
	declare @endi int = @@rowcount, @i int = 1, @segWords nvarchar(max), @segLang nvarchar(6)
	while( @i <= @endi )
	begin
		select @segWords = words, @segLang = Lang from @segmentsTable where sno = @i
		if( @segLang = 'ch' )
			insert into @tokensTable( words ) select * from fn_TP_Tokenization_CH( @segWords, @CH_nGram, default )
		else
			insert into @tokensTable( words ) select * from fn_TP_Tokenization_EN( @segWords, @EN_nGram, default )
		set @i += 1
	end
	return
end
go

/* fn_KE_Vocabulary
Execute :
	select * from fn_KE_Vocabulary( @String, default )
Example :
	declare @String nvarchar(max) = N'中國第3季國內生產毛額（GDP）成長年率達7.3%是2009年來最低但中國優於市場預期主要拜北京當局鬆綁房地產限制和擴大支出等政策所賜'
	select * from fn_KE_Vocabulary( @String, default )
*/
if exists ( select * from sys.objects where object_id = object_id( N'fn_KE_Vocabulary' ) and type in ( N'FT', N'FN', N'TF', N'FS') )
	drop function fn_KE_Vocabulary
go

create function fn_KE_Vocabulary( @String nvarchar(max), @nGram int = 8 )
	returns @keywordsTable table ( Rank int identity(1,1), Position int, Words nvarchar(max), Words_Len int, Words_Len_en int, PoS binary(2), Field binary(16) )
begin
	declare @tmp_nGram int, @index int, @c_index int, @rString nvarchar(max)
	declare @tmpkeywordsTable table ( position int, words nvarchar(max), words_len int, words_len_en int, pos binary(2), field binary(16) )
	declare @tmpTokensTable table ( words nvarchar(max), words_len int, words_len_en int )
	declare @tmpWords table ( position int, words nvarchar(max), words_len int, words_len_en int, pos binary(2), field binary(16) )

	-- 判斷是否含 @delimiter, 有先進行切割成 Segement
	declare @segements table( sno int, position int, words nvarchar(max), words_len int, words_len_en int )
	insert into @segements
		select sno, position, words, words_len, words_len_en from fn_TP_Segmentation( @String, default, 4 )

	if ( @@rowcount > 1)
	begin
		declare segements cursor for
			select sno, position, words, words_len, words_len_en from @segements order by sno asc
		open segements
		declare @sno int, @position int, @words nvarchar(max), @words_len int, @words_len_en int
		fetch next from segements into @sno, @position, @words, @words_len, @words_len_en
		while( @@fetch_status = 0 )
		begin
			set @index = ( @position + @words_len - 1 )
			set @c_index = 0
			set @rString = reverse( @words )
			while( len( @rString ) > 1 )
			begin
				set @tmp_nGram = iif( len(@rString) > @nGram, @nGram, len( @rString ) )
				-- 每次取長度 2-nGram 的 words 跟字典進行比對
				while( @tmp_nGram > 1 )
				begin
					insert into @tmpTokensTable( words, words_len, words_len_en )
						values (
							substring( @rString, 1, @tmp_nGram ),
							@tmp_nGram,
							( select count(*) from fn_splitString( ltrim( rtrim(
								substring( @rString, 1, @tmp_nGram )
							) ), ' ') )
						)
					set @tmp_nGram -= 1
				end
				-- 比對最先出現且長度最長的 words
				insert into @tmpWords
					select top 1 ( @index - ( @c_index + t.words_len ) + 1 ) as position, t.words, t.words_len, t.words_len_en, k.pos, k.field from @tmpTokensTable t, UD.dbo.ReverseKeywords k where t.words = k.Words order by t.words_len desc

				if exists( select * from @tmpWords )
				begin
					select top 1 @c_index = ( @c_index + words_len ) from @tmpWords
					insert into @tmpkeywordsTable( position, words, words_len, words_len_en, pos, field )
						select position, reverse( words ), words_len, words_len_en, pos, field from @tmpWords
					set @rString = ( select substring( @rString, charindex( words, @rString ) + words_len, len( @rString ) ) from @tmpWords )
				end
				else
				begin
					set @rString = ( select substring( @rString, 2, len( @rString )-1 ) )
					set @c_index += 1
				end
				-- 若沒有釋放會造成 @暫存 的內容未被清空, 繼續使用上次表格內容
				delete from @tmpWords
				delete from @tmpTokensTable
			end
			fetch next from segements into @sno, @position, @words, @words_len, @words_len_en
		end
		close segements
		deallocate segements
	end
	else
	begin
		set @index = len( @String )
		set @c_index = 0
		set @rString = reverse( @String )
		while( len( @rString ) > 1 )
		begin
			set @tmp_nGram = iif( len(@rString) > @nGram, @nGram, len( @rString ) )
			-- 每次取長度 2-nGram 的 words 跟字典進行比對
			while( @tmp_nGram > 1 )
			begin
				insert into @tmpTokensTable( words, words_len, words_len_en )
					values (
						substring( @rString, 1, @tmp_nGram ),
						@tmp_nGram,
						( select count(*) from fn_splitString( ltrim( rtrim(
							substring( @rString, 1, @tmp_nGram )
						) ), ' ') )
					)
				set @tmp_nGram -= 1
			end
			-- 比對最先出現且長度最長的 words
			insert into @tmpWords
				select top 1 ( @index - ( @c_index + t.words_len ) + 1 ) as position, t.words, t.words_len, t.words_len_en, k.pos, k.field from @tmpTokensTable t, UD.dbo.ReverseKeywords k where t.words = k.Words order by t.words_len desc

			if exists( select * from @tmpWords )
			begin
				select top 1 @c_index = ( @c_index + words_len ) from @tmpWords
				insert into @tmpkeywordsTable( position, words, words_len, words_len_en, pos, field )
					select position, reverse( words ), words_len, words_len_en, pos, field from @tmpWords
				set @rString = ( select substring( @rString, charindex( words, @rString ) + words_len, len( @rString ) ) from @tmpWords )
			end
			else
			begin
				set @rString = ( select substring( @rString, 2, len( @rString )-1 ) )
				set @c_index += 1
			end
			-- 若沒有釋放會造成 @暫存 的內容未被清空, 繼續使用上次表格內容
			delete from @tmpWords
			delete from @tmpTokensTable
		end
	end

	-- 根據位置排序後匯入 @keywordsTable
	insert into @keywordsTable( position, words, words_len, words_len_en, pos, field )
		select position, words, words_len, words_len_en, pos, field from @tmpkeywordsTable order by position asc
	return
end
go

/* fn_PE_RegexMatch
Execute :
	select * from fn_PE_RegexMatch( @Text nvarchar(max) , @Pattern nvarchar(max) )
Example :
	declare @String nvarchar(max) = N'中國第3季國內生產毛額（GDP）成長年率達7.3%，是2009年來最低，但中國優於市場預期，主要拜北京當局鬆綁房地產限制和擴大支出等政策所賜。'
	select * from fn_PE_RegexMatch( @String, N'([\d][\d]*)年|([\d][\d]*).([\d][\d]*)%+' )
*/

exec sp_configure 'clr enable', '1'
go
RECONFIGURE
go

if exists ( select * from sys.objects o where o.name = N'fn_PE_RegexMatch' and o.type in (N'FT', N'FN', N'TF','FS') )
	drop function fn_PE_RegexMatch
go

if exists ( select * from sys.assemblies asms where asms.name = N'CLR_UDF_Regex' )
    drop assembly CLR_UDF_Regex
go

--create assembly CLR_UDF_Regex from 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\DLL\RegExp.dll'
declare @s varchar(1000)
select @s = DB_NAME()
select @s = '$(DLLDir)\RegExp.dll'

create assembly CLR_UDF_Regex from ( @s )
go

create function fn_PE_RegexMatch( @Text nvarchar(max) , @Pattern nvarchar(max) )
	returns table( SNO int, Position int, Token nvarchar(max), Token_len int ) with execute as caller
as
	external name CLR_UDF_Regex.UDF_RegExp.RegExp
go

/* fn_PE_Pattern
Execute :
	select * from fn_PE_Pattern( @String )
Example :
	declare @String nvarchar(max) = N'中國第3季國內生產毛額（GDP）成長年率達7.3%，是2009年來最低，但中國優於市場預期，主要拜北京當局鬆綁房地產限制和擴大支出等政策所賜。'
	select * from fn_PE_Pattern( @String )
*/
if exists ( select * from sys.objects where object_id = object_id( N'fn_PE_Pattern' ) and type in ( N'FT', N'FN', N'TF', N'FS') )
	drop function fn_PE_Pattern
go

create function fn_PE_Pattern( @String nvarchar(max) )
	returns @patternTable table ( Rank int identity(1,1), Position int, Words nvarchar(max), Words_len int, Words_len_en int, Type nvarchar(255), Field binary(16) )
begin
	declare @tmpPatternTable table ( position int, words nvarchar(max), words_len int, words_len_en int, type nvarchar(255), field binary(16) )

	declare patterns cursor for
		select type, field from UD.dbo.vd_patternlist group by type, field order by type asc
	open patterns
	declare @Type nvarchar(max), @Field binary(16)
	fetch next from patterns into @Type, @Field
	while( @@fetch_status = 0 )
	begin
		declare @Pattern nvarchar(max) =  ( select stuff( ( select '|'+exp from UD.dbo.vd_patternlist where type = @Type for xml path('') ), 1, 1, '') )
		--declare @Pattern nvarchar(max) =''
		--select @Pattern=@Pattern + exp + '|' from UD.dbo.vd_patternlist where type = @Type
		--set @Pattern = SUBSTRING( @Pattern, 1, len( @Pattern )-1 )
		insert into @tmpPatternTable( position, words, words_len, words_len_en, type, field )
			select Position, Token, Token_len, ( select count(*) from fn_splitString( ltrim( rtrim( Token ) ), ' ') ), @Type, @Field from fn_PE_RegexMatch( @String, @Pattern )
		/*
		-- 先進行切割成 Segement
		declare @segements table( sno int, position int, words nvarchar(max) )
		insert into @segements
			select sno, position, words from fn_TP_Segmentation( @String, default, 1 )

		declare segements cursor for
			select sno, position, words from @segements order by sno asc
		open segements
		declare @sno int, @index int, @words nvarchar(max)
		fetch next from segements into @sno, @index, @words
		while( @@fetch_status = 0 )
		begin
			insert into @tmpPatternTable( position, words, words_len, words_len_en, type, field )
				select ( @index + Position -1 ), Token, Token_len, ( select count(*) from fn_splitString( ltrim( rtrim( Token ) ), ' ') ), @Type, @Field from fn_PE_RegexMatch( @words, @Pattern )
			fetch next from segements into @sno, @index, @words
		end
		close segements
		deallocate segements
		delete from @segements
		*/
		fetch next from patterns into @Type, @Field
	end
	close patterns
	deallocate patterns

	-- 根據位置排序後匯入 @keywordsTable
	insert into @patternTable( position, words, words_len, words_len_en, type, field )
		select position, words, words_len, words_len_en, type, field from @tmpPatternTable order by Position asc
	return
end
go

/*
declare @String nvarchar(max) = N'中國第3季國內生產毛額（GDP）成長年率達7.3%，是2009年來最低，但中國優於市場預期，主要拜北京當局鬆綁房地產限制和擴大支出等政策所賜。'
select * from fn_TP_Segmentation( @String, default, 1 )
--select * from fn_KE_Vocabulary( @String, default )
*/
