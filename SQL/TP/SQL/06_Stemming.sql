use $(DBName)
-- declare @DBName varchar(3) = 'iEN3'
go

/*
Copyright (c)2006 , Keith Lubell
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
Neither the name of the <ORGANIZATION> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION fn_PorterAlgorithm
	(
		@InWord nvarchar(4000)
	)
RETURNS nvarchar(4000)
AS
BEGIN
    DECLARE @Ret nvarchar(4000), @Temp nvarchar(4000)

    -- DO some initial cleanup
	-- 做一些初步的清理
    SELECT @Ret = LOWER(ISNULL(RTRIM(LTRIM(@InWord)),N''))

    -- only strings greater than 2 are stemmed
	-- 只有大於2的字符串才會被發現
    IF LEN(@Ret) > 2
	BEGIN
	    SELECT @Ret = dbo.fn_PorterStep0(@Ret)
	    SELECT @Ret = dbo.fn_PorterStep1(@Ret)
	    SELECT @Ret = dbo.fn_PorterStep2(@Ret)
	    SELECT @Ret = dbo.fn_PorterStep3(@Ret)
	    SELECT @Ret = dbo.fn_PorterStep4(@Ret)
	    SELECT @Ret = dbo.fn_PorterStep5(@Ret)
	END

	-- End of Porter's algorithm.........returning the word
	-- 波特算法結束.........返回單詞
    RETURN @Ret

END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION fn_PorterCVCpattern
	(
		@Word nvarchar(4000)
	)
RETURNS nvarchar(4000)
AS
BEGIN
	-- local variables
	-- 局部變量
    DECLARE @Ret nvarchar(4000), @i int

	-- checking each character to see if it is a consonent or a vowel. also inputs the information in const_vowel
	-- 檢查每個字符，看它是一個輔音還是元音。也在 const_vowel 中輸入信息
	SELECT @i = 1, @Ret = N''
	WHILE @i <= LEN(@Word)
	BEGIN
		IF CHARINDEX(SUBSTRING(@Word,@i,1), N'aeiou') > 0
		BEGIN
			SELECT @Ret = @Ret + N'v'
		END
		-- if y is not the first character, only then check the previous character
		-- 如果 y 不是第一個字符，那麼只能檢查前一個字符
		ELSE IF SUBSTRING(@Word,@i,1) = N'y' AND @i > 1
		BEGIN
            -- check to see if previous character is a consonent
			-- 檢查以前的字符是否是一個輔音
			IF CHARINDEX(SUBSTRING(@Word,@i-1,1), N'aeiou') = 0
				SELECT @Ret = @Ret + N'v'
			ELSE
				SELECT @Ret = @Ret + N'c'
		END
		Else
		BEGIN
			SELECT @Ret = @Ret + N'c'
		END
		SELECT @i = @i + 1
	END
	RETURN @Ret
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION fn_PorterContainsVowel
	(
		@Word nvarchar(4000)
	)
RETURNS bit
AS
BEGIN
	-- checking word to see if vowels are present
	-- 檢查詞以查看元音是否存在
	DECLARE @pattern nvarchar(4000), @ret bit

	SET @ret = 0

	IF LEN(@Word) > 0
	BEGIN
    	-- find out the CVC pattern
		-- 找出 CVC 模式
    	SELECT @pattern = dbo.fn_PorterCVCpattern(@Word)
		-- check to see if the return pattern contains a vowel
		-- 檢查返回模式是否包含元音
    	IF CHARINDEX( N'v',@pattern) > 0
			SELECT @ret = 1
	END
	RETURN @Ret
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION fn_PorterCountm
	(
		@Word nvarchar(4000)
	)
RETURNS tinyint
AS
BEGIN
	-- A \consonant\ in a word is a letter other than A, E, I, O or U, and other
	-- than Y preceded by a consonant. (The fact that the term `consonant' is
	-- defined to some extent in terms of itself does not make it ambiguous.) So in
	-- TOY the consonants are T and Y, and in SYZYGY they are S, Z and G. If a
	-- letter is not a consonant it is a \vowel\.

	-- A \輔音\一個字是除了 A，E，I，O 或 U 以外的字母，而不是輔音前面的字母。
	-- （這個術語 “輔音” 在某種程度上被定義在本身上並不意味著這一點）。
	-- 所以在 TOY 中，輔音是 T 和 Y ，而在 SYZYGY 中它們是 S ，Z 和 G.
	-- 如果一個字母不是輔音，它是一個 \韻母\。

	-- declaring local variables
	-- 聲明局部變量
	DECLARE @pattern nvarchar(4000), @ret tinyint, @i int, @flag bit

	-- initializing
	-- 初始化
	SELECT @ret = 0, @flag = 0,  @i = 1

	If Len(@Word) > 0
    BEGIN
		-- find out the CVC pattern
		-- 找出 CVC 模式
		SELECT @pattern = dbo.fn_PorterCVCpattern(@Word)
		-- counting the number of m's...
		-- 計算 m 的數量...
		WHILE @i <= LEN(@pattern)
	    BEGIN
        	IF SUBSTRING(@pattern,@i,1) = N'v' OR @flag = 1
		    BEGIN
				SELECT @flag = 1
		        IF SUBSTRING(@pattern,@i,1) = N'c'
					SELECT @ret = @ret + 1, @flag = 0
		    END
			SELECT @i = @i + 1
	    END
    END
    RETURN @Ret
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION fn_PorterEndsCVC
	(
		@Word nvarchar(4000)
	)
RETURNS bit
AS
BEGIN
	-- *o  - the stem ends cvc, where the second c is not W, X or Y (e.g. -WIL, -HOP).
	-- *o - 莖端 cvc，其中第二 c 不是 W，X 或 Y（例如 -WIL，-HOP）。

	-- declaring local variables
	-- 聲明局部變量
	DECLARE @pattern NVARCHAR(3), @ret bit

	SELECT @ret = 0

	-- check to see if atleast 3 characters are present
	-- 檢查是否存在至少 3 個字符
	If LEN(@Word) >= 3
    BEGIN
		-- find out the CVC pattern
		-- we need to check only the last three characters

		-- 找出 CVC 模式
		-- 我們只需要檢查最後三個字符
		SELECT @pattern = RIGHT(dbo.fn_PorterCVCpattern(@Word),3)
		-- check to see if the letters in str match the sequence cvc
		-- 檢查 str 中的字母是否與序列 cvc 匹配
		IF @pattern = N'cvc' AND CHARINDEX(RIGHT(@Word,1), N'wxy') = 0
			SELECT @ret = 1
    END
	RETURN @Ret
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION fn_PorterEndsDoubleCVC
	(
		@Word nvarchar(4000)
	)
RETURNS bit
AS
BEGIN
	-- *o  - the stem ends cvc, where the second c is not W, X or Y (e.g. -WIL, -HOP).
	-- * o - 莖端 cvc，其中第二 c 不是 W，X 或 Y（例如 -WIL，-HOP）。

	-- declaring local variables
	-- 聲明局部變量
	DECLARE @pattern NVARCHAR(3), @ret bit

	SET @ret = 0

	-- check to see if atleast 3 characters are present
	-- 檢查是否存在至少3個字符
	IF Len(@Word) >= 3
    BEGIN
  		-- find out the CVC pattern
    	-- we need to check only the last three characters

		-- 找出CVC模式
		-- 我們只需要檢查最後三個字符
		SELECT @pattern = RIGHT(dbo.fn_PorterCVCpattern(@Word),3)
		-- check to see if the letters in str match the sequence cvc
		-- 檢查str中的字母是否與序列cvc匹配
    	IF @pattern = N'cvc' AND CHARINDEX(RIGHT(@Word,1), N'wxy') = 0
			SELECT @ret = 1
    END
	RETURN @Ret
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION fn_PorterEndsDoubleConsonant
	(
		@Word nvarchar(4000)
	)
RETURNS bit
AS
BEGIN
	-- checking whether word ends with a double consonant (e.g. -TT, -SS).
	-- 檢查單詞是否以雙輔音（例如 -TT，-SS）結束。

	-- declaring local variables
	-- 聲明局部變量
	DECLARE @holds_ends NVARCHAR(2), @ret bit, @hold_third_last NCHAR(1)

	SET @ret = 0
	-- first check whether the size of the word is >= 2
	-- 首先檢查字的大小是否 > = 2
	If Len(@Word) >= 2
    BEGIN
		-- extract 2 characters from right of str
		-- 從 str 右側提取 2 個字符
		SELECT @holds_ends = Right(@Word, 2)
		-- checking if both the characters are same and not double vowel
		-- 檢查兩個字符是否相同，而不是雙元音
    	IF SUBSTRING(@holds_ends,1,1) = SUBSTRING(@holds_ends,2,1) AND CHARINDEX(@holds_ends, N'aaeeiioouu') = 0
	    BEGIN
            -- if the second last character is y, and there are atleast three letters in str
			-- 如果第二個字符是 y，並且 str 中至少有三個字母
            If @holds_ends = N'yy' AND Len(@Word) > 2
		    BEGIN
				-- extracting the third last character
				-- 提取第三個最後一個字符
				SELECT @hold_third_last = LEFT(Right(@Word, 3),1)
                IF CHARINDEX(@hold_third_last, N'aaeeiioouu') > 0
					SET @ret = 1
		    END
            ELSE
				SET @ret = 1
	    END
    END
	RETURN @Ret
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION fn_PorterStep0
	(
		@InWord nvarchar(4000)
	)
RETURNS nvarchar(4000)
AS
BEGIN

	/* STEP 0 */

	--declaring local variables
    DECLARE @Ret nvarchar(4000), @Temp nvarchar(4000)
    DECLARE @Phrase1 NVARCHAR(15), @Phrase2 NVARCHAR(15)
    DECLARE @CursorName CURSOR --, @i int

	--checking word
    SET @Ret = @InWord
    SET @CursorName = CURSOR FOR
	SELECT phrase1, phrase2 FROM UD.dbo.tblPorterStemming WHERE Step = 0 AND @Ret = Phrase1
		ORDER BY Ordering
    OPEN @CursorName

    -- Do Step 0
    FETCH NEXT FROM @CursorName INTO @Phrase1, @Phrase2
    WHILE @@FETCH_STATUS = 0
	BEGIN
	    --IF RIGHT(@Ret ,LEN(@Phrase1)) = @Phrase1
		BEGIN
		    SELECT @temp = LEFT(@Ret, LEN(@Ret) - LEN(@Phrase1))
            IF @temp = 0
				SELECT @Ret = @Phrase2
            	BREAK
		END
	    FETCH NEXT FROM @CursorName INTO @Phrase1, @Phrase2
    END
    -- Free Resources
    CLOSE @CursorName
    DEALLOCATE @CursorName

	--retuning the word
    RETURN @Ret
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION fn_PorterStep1
	(
		@InWord nvarchar(4000)
	)
RETURNS nvarchar(4000)
AS
BEGIN
    DECLARE @Ret nvarchar(4000)
    DECLARE @Phrase1 NVARCHAR(15), @Phrase2 NVARCHAR(15)
    DECLARE @CursorName CURSOR

    -- DO some initial cleanup
	-- 做一些初步的清理
    SELECT @Ret = @InWord

	/*STEP 1A
		SSES -> SS                         caresses  ->  caress
		IES  -> I                          ponies    ->  poni
										   ties      ->  ti
		SS   -> SS                         caress    ->  caress
		S    ->                            cats      ->  cat
	*/

    -- Create Cursor for Porter Step 1
    SET @CursorName = CURSOR FOR
	SELECT phrase1, phrase2 FROM UD.dbo.tblPorterStemming WHERE Step = 1 AND RIGHT(@Ret ,LEN(Phrase1)) = Phrase1
		ORDER BY Ordering
    OPEN @CursorName

    -- Do Step 1
    FETCH NEXT FROM @CursorName INTO @Phrase1, @Phrase2
    WHILE @@FETCH_STATUS = 0
	BEGIN
	    -- IF RIGHT(@Ret ,LEN(@Phrase1)) = @Phrase1
		BEGIN
		    SELECT @Ret = LEFT(@Ret, LEN(@Ret) - LEN(@Phrase1)) + @Phrase2
		    BREAK
		END
	    FETCH NEXT FROM @CursorName INTO @Phrase1, @Phrase2
	END
    -- Free Resources
	-- 免費資源
    CLOSE @CursorName
    DEALLOCATE @CursorName

	-- STEP 1B
	--
	--   If
	--       (m>0) EED -> EE                     feed      ->  feed
	--                                           agreed    ->  agree
	--   Else
	--       (*v*) ED  ->                        plastered ->  plaster
	--                                           bled      ->  bled
	--       (*v*) ING ->                        motoring  ->  motor
	--                                           sing      ->  sing
	--
	-- If the second or third of the rules in Step 1b is successful, the following is done:
	-- 如果步驟 1b 中的第二或第三條規則成功，則執行以下操作：
	--
	--    AT -> ATE                       conflat(ed)  ->  conflate
	--    BL -> BLE                       troubl(ed)   ->  trouble
	--    IZ -> IZE                       siz(ed)      ->  size
	--    (*d and not (*L or *S or *Z))
	--       -> single letter
	--                                    hopp(ing)    ->  hop
	--                                    tann(ed)     ->  tan
	--                                    fall(ing)    ->  fall
	--                                    hiss(ing)    ->  hiss
	--                                    fizz(ed)     ->  fizz
	--    (m=1 and *o) -> E               fail(ing)    ->  fail
	--                                    fil(ing)     ->  file
	--
	-- The rule to map to a single letter causes the removal of one of the double
	-- letter pair. The -E is put back on -AT, -BL and -IZ, so that the suffixes
	-- ATE, -BLE and -IZE can be recognised later. This E may be removed in step 4.

	-- 映射到單個字母的規則會導致刪除其中一個雙字母對。
	-- -E 被放回到 -AT，-BL 和 -IZ 之後，以後可以識別後綴 ATE，-BLE 和 -IZE。
	-- 此 E 可在步驟 4 中刪除。

	-- declaring local variables
	-- 聲明局部變量
	DECLARE @m tinyint, @Temp nvarchar(4000),@second_third_success bit

	-- initializing
	-- 初始化
	SELECT @second_third_success = 0

	-- (m>0) EED -> EE..else..(*v*) ED  ->(*v*) ING  ->
    IF RIGHT(@Ret ,LEN(N'eed')) = N'eed'
	BEGIN
	    -- counting the number of m--s
		-- 計數 m 的數量
	    SELECT @temp = LEFT(@Ret, LEN(@Ret) - LEN(N'eed'))
	    SELECT @m = dbo.fn_PorterCountm(@temp)
    	If @m > 0
            SELECT @Ret = LEFT(@Ret, LEN(@Ret) - LEN(N'eed')) + N'ee'
	END
    ELSE IF RIGHT(@Ret ,LEN(N'ed')) = N'ed'
	BEGIN
	    -- trim and check for vowel
		-- 修剪和檢查元音
	    SELECT @temp = LEFT(@Ret, LEN(@Ret) - LEN(N'ed'))
	    If dbo.fn_PorterContainsVowel(@temp) = 1
			SELECT @ret = LEFT(@Ret, LEN(@Ret) - LEN(N'ed')), @second_third_success = 1
	END
    ELSE IF RIGHT(@Ret ,LEN(N'ing')) = N'ing'
	BEGIN
	    -- trim and check for vowel
		-- 修剪和檢查元音
	    SELECT @temp = LEFT(@Ret, LEN(@Ret) - LEN(N'ing'))
	    If dbo.fn_PorterContainsVowel(@temp) = 1
			SELECT @ret = LEFT(@Ret, LEN(@Ret) - LEN(N'ing')), @second_third_success = 1
	END

	-- If the second or third of the rules in Step 1b is SUCCESSFUL, the following
	-- is done:

	-- 如果步驟1b中的第二或第三條規則是成功的，則執行以下操作：

	--
	--    AT -> ATE                       conflat(ed)  ->  conflate
	--    BL -> BLE                       troubl(ed)   ->  trouble
	--    IZ -> IZE                       siz(ed)      ->  size
	--    (*d and not (*L or *S or *Z))
	--       -> single letter
	--                                    hopp(ing)    ->  hop
	--                                    tann(ed)     ->  tan
	--                                    fall(ing)    ->  fall
	--                                    hiss(ing)    ->  hiss
	--                                    fizz(ed)     ->  fizz
	--    (m=1 and *o) -> E               fail(ing)    ->  fail
	--

	-- If the second or third of the rules in Step 1b is SUCCESSFUL
	-- 如果步驟 1b 中的第二或第三條規則是成功的
	IF @second_third_success = 1
		BEGIN
    	IF RIGHT(@Ret ,LEN(N'at')) = N'at'	--AT -> ATE
			SELECT @ret = LEFT(@Ret, LEN(@Ret) - LEN(N'at')) + N'ate'
    	ELSE IF RIGHT(@Ret ,LEN(N'bl')) = N'bl'	--BL -> BLE
			SELECT @ret = LEFT(@Ret, LEN(@Ret) - LEN(N'bl')) + N'ble'
    	ELSE IF RIGHT(@Ret ,LEN(N'iz')) = N'iz'	--IZ -> IZE
			SELECT @ret = LEFT(@Ret, LEN(@Ret) - LEN(N'iz')) + N'ize'
    	ELSE IF dbo.fn_PorterEndsDoubleConsonant(@Ret) = 1  /*(*d and not (*L or *S or *Z))-> single letter*/
	    BEGIN
			IF CHARINDEX(RIGHT(@Ret,1), N'lsz') = 0
				SELECT @ret = LEFT(@Ret, LEN(@Ret) - 1)
        END
		ELSE IF dbo.fn_PorterCountm(@Ret) = 1        /*(m=1 and *o) -> E */
	    BEGIN
	       	IF dbo.fn_PorterEndsDoubleCVC(@Ret) = 1
                SELECT @ret = @Ret + N'e'
        END
    END

	----------------------------------------------------------------------------------------------------------
	--
	--STEP 1C
	--
	--    (*v*) Y -> I                    happy        ->  happi
	--                                    sky          ->  sky
	/*
	IF RIGHT(@Ret ,LEN(N'y')) = N'y'
	BEGIN
		-- trim and check for vowel
		-- 修剪和檢查元音
		SELECT @temp = LEFT(@Ret, LEN(@Ret)-1)
		IF dbo.fn_PorterContainsVowel(@temp) = 1
		SELECT @ret = LEFT(@Ret, LEN(@Ret) - 1) + N'i'
	END
	*/
    RETURN @Ret
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION fn_PorterStep2
	(
		@InWord nvarchar(4000)
	)
RETURNS nvarchar(4000)
AS
BEGIN
	/*STEP 2

		(m>0) ATIONAL ->  ATE           relational     ->  relate
		(m>0) TIONAL  ->  TION          conditional    ->  condition
										rational       ->  rational
		(m>0) ENCI    ->  ENCE          valenci        ->  valence
		(m>0) ANCI    ->  ANCE          hesitanci      ->  hesitance
		(m>0) IZER    ->  IZE           digitizer      ->  digitize
	Also,
		(m>0) BLI    ->   BLE           conformabli    ->  conformable

		(m>0) ALLI    ->  AL            radicalli      ->  radical
		(m>0) ENTLI   ->  ENT           differentli    ->  different
		(m>0) ELI     ->  E             vileli        - >  vile
		(m>0) OUSLI   ->  OUS           analogousli    ->  analogous
		(m>0) IZATION ->  IZE           vietnamization ->  vietnamize
		(m>0) ATION   ->  ATE           predication    ->  predicate
		(m>0) ATOR    ->  ATE           operator       ->  operate
		(m>0) ALISM   ->  AL            feudalism      ->  feudal
		(m>0) IVENESS ->  IVE           decisiveness   ->  decisive
		(m>0) FULNESS ->  FUL           hopefulness    ->  hopeful
		(m>0) OUSNESS ->  OUS           callousness    ->  callous
		(m>0) ALITI   ->  AL            formaliti      ->  formal
		(m>0) IVITI   ->  IVE           sensitiviti    ->  sensitive
		(m>0) BILITI  ->  BLE           sensibiliti    ->  sensible
	Also,
		(m>0) LOGI    ->  LOG           apologi        -> apolog

	The test for the string S1 can be made fast by doing a program switch on
	the penultimate letter of the word being tested. This gives a fairly even
	breakdown of the possible values of the string S1. It will be seen in fact
	that the S1-strings in step 2 are presented here in the alphabetical order
	of their penultimate letter. Similar techniques may be applied in the other
	steps.

	通過對正在測試的單詞的倒數第二個字母進行程序切換，可以快速測試字符串 S1。
	這給出了字符串 S1 的可能值的相當均勻的分解。
	實際上可以看出，步驟 2 中的 S1 字符串按照倒數第二個字母的字母順序顯示在這裡。
	在其他步驟中可以應用類似的技術。
	*/

	-- declaring local variables
	-- 聲明局部變量
    DECLARE @Ret nvarchar(4000), @Temp nvarchar(4000)
    DECLARE @Phrase1 NVARCHAR(15), @Phrase2 NVARCHAR(15)
    DECLARE @CursorName CURSOR --, @i int

	-- checking word
	-- 檢查詞
    SET @Ret = @InWord
    SET @CursorName = CURSOR FOR
	SELECT phrase1, phrase2 FROM UD.dbo.tblPorterStemming WHERE Step = 2 AND RIGHT(@Ret ,LEN(Phrase1)) = Phrase1
		ORDER BY Ordering
    OPEN @CursorName

    -- Do Step 2
    FETCH NEXT FROM @CursorName INTO @Phrase1, @Phrase2
    WHILE @@FETCH_STATUS = 0
	BEGIN
	    -- IF RIGHT(@Ret ,LEN(@Phrase1)) = @Phrase1
		BEGIN
		    SELECT @temp = LEFT(@Ret, LEN(@Ret) - LEN(@Phrase1))
			IF dbo.fn_PorterCountm(@temp) > 0
				SELECT @Ret = LEFT(@Ret, LEN(@Ret) - LEN(@Phrase1)) + @Phrase2
				BREAK
		END
	    FETCH NEXT FROM @CursorName INTO @Phrase1, @Phrase2
    END
    -- Free Resources
	-- 免費資源
    CLOSE @CursorName
    DEALLOCATE @CursorName

	-- retuning the word
	-- 重新調整這個詞
    RETURN @Ret
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION fn_PorterStep3
	(
		@InWord nvarchar(4000)
	)
RETURNS nvarchar(4000)
AS
BEGIN

	/*STEP 3
		(m>0) ICATE ->  IC              triplicate     ->  triplic
		(m>0) ATIVE ->                  formative      ->  form
		(m>0) ALIZE ->  AL              formalize      ->  formal
		(m>0) ICITI ->  IC              electriciti    ->  electric
		(m>0) ICAL  ->  IC              electrical     ->  electric
		(m>0) FUL   ->                  hopeful        ->  hope
		(m>0) NESS  ->                  goodness       ->  good
	*/

	-- declaring local variables
    DECLARE @Ret nvarchar(4000), @Temp nvarchar(4000)
    DECLARE @Phrase1 NVARCHAR(15), @Phrase2 NVARCHAR(15)
    DECLARE @CursorName CURSOR, @i int

	-- checking word
    SET @Ret = @InWord
    SET @CursorName = CURSOR FOR
	SELECT phrase1, phrase2 FROM UD.dbo.tblPorterStemming WHERE Step = 3 AND RIGHT(@Ret ,LEN(Phrase1)) = Phrase1
		ORDER BY Ordering
    OPEN @CursorName

    -- Do Step 2
    FETCH NEXT FROM @CursorName INTO @Phrase1, @Phrase2
    WHILE @@FETCH_STATUS = 0
	BEGIN
	    -- IF RIGHT(@Ret ,LEN(@Phrase1)) = @Phrase1
		BEGIN
		    SELECT @temp = LEFT(@Ret, LEN(@Ret) - LEN(@Phrase1))
            IF dbo.fn_PorterCountm(@temp) > 0
				SELECT @Ret = LEFT(@Ret, LEN(@Ret) - LEN(@Phrase1)) + @Phrase2
				BREAK
		END
	    FETCH NEXT FROM @CursorName INTO @Phrase1, @Phrase2
    END

    -- Free Resources
    CLOSE @CursorName
    DEALLOCATE @CursorName

    -- retuning the word
    RETURN @Ret
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION fn_PorterStep4
	(
		@InWord nvarchar(4000)
	)
RETURNS nvarchar(4000)
AS
BEGIN
	--STEP 4
	--
	--    (m>1) AL    ->                  revival        ->  reviv
	--    (m>1) ANCE  ->                  allowance      ->  allow
	--    (m>1) ENCE  ->                  inference      ->  infer
	--    (m>1) ER    ->                  airliner       ->  airlin
	--    (m>1) IC    ->                  gyroscopic     ->  gyroscop
	--    (m>1) ABLE  ->                  adjustable     ->  adjust
	--    (m>1) IBLE  ->                  defensible     ->  defens
	--    (m>1) ANT   ->                  irritant       ->  irrit
	--    (m>1) EMENT ->                  replacement    ->  replac
	--    (m>1) MENT  ->                  adjustment     ->  adjust
	--    (m>1) ENT   ->                  dependent      ->  depend
	--    (m>1 and (*S or *T)) ION ->     adoption       ->  adopt
	--    (m>1) OU    ->                  homologou      ->  homolog
	--    (m>1) ISM   ->                  communism      ->  commun
	--    (m>1) ATE   ->                  activate       ->  activ
	--    (m>1) ITI   ->                  angulariti     ->  angular
	--    (m>1) OUS   ->                  homologous     ->  homolog
	--    (m>1) IVE   ->                  effective      ->  effect
	--    (m>1) IZE   ->                  bowdlerize     ->  bowdler
	--
	-- The suffixes are now removed. All that remains is a little tidying up.
	-- 後綴已被刪除。剩下的只有一點點整理。

    DECLARE @Ret nvarchar(4000), @Temp nvarchar(4000)
    DECLARE @Phrase1 NVARCHAR(15)
    DECLARE @CursorName CURSOR

	-- checking word
    SELECT @Ret = @InWord
    SET @CursorName = CURSOR FOR
	SELECT phrase1 FROM UD.dbo.tblPorterStemming WHERE Step = 4 AND RIGHT(@Ret ,LEN(Phrase1)) = Phrase1
		ORDER BY Ordering
    OPEN @CursorName

    -- Do Step 4
    FETCH NEXT FROM @CursorName INTO @Phrase1
    WHILE @@FETCH_STATUS = 0
	BEGIN
	    -- IF RIGHT(@Ret ,LEN(@Phrase1)) = @Phrase1
		BEGIN
		    SELECT @temp = LEFT(@Ret, LEN(@Ret) - LEN(@Phrase1))
            IF dbo.fn_PorterCountm(@temp) > 1
			BEGIN
			    IF RIGHT(@Ret ,LEN(N'ion')) = N'ion'
				BEGIN
				    IF RIGHT(@temp ,1) = N's' OR RIGHT(@temp ,1) = N't'
					SELECT @Ret = LEFT(@Ret, LEN(@Ret) - LEN(@Phrase1))
				END
			    ELSE
					SELECT @Ret = LEFT(@Ret, LEN(@Ret) - LEN(@Phrase1))
			END
            BREAK
		END
	    FETCH NEXT FROM @CursorName INTO @Phrase1
    END

    -- Free Resources
    CLOSE @CursorName
    DEALLOCATE @CursorName

    -- retuning the word
    RETURN @Ret
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION fn_PorterStep5
	(
		@InWord nvarchar(4000)
	)
RETURNS nvarchar(4000)
AS
BEGIN
	-- STEP 5a
	--
	--    (m>1) E     ->                  probate        ->  probat
	--                                    rate           ->  rate
	--    (m=1 and not *o) E ->           cease          ->  ceas
	--
	-- STEP 5b
	--
	--    (m>1 and *d and *L) -> single letter
	--                                    controll       ->  control
	--                                    roll           ->  roll

	-- declaring local variables
    DECLARE @Ret nvarchar(4000), @Temp nvarchar(4000), @m tinyint
    SET @Ret = @InWord

	-- Step5a
	/*
		IF RIGHT(@Ret , 1) = N'e'	            --word ends with e
		BEGIN
			SELECT @temp = LEFT(@Ret, LEN(@Ret) - 1)
			SELECT @m = dbo.fn_PorterCountm(@temp)
			IF @m > 1						--m>1
			SELECT @Ret = LEFT(@Ret, LEN(@Ret) - 1)
			ELSE IF @m = 1					--m=1
			BEGIN
				IF dbo.fn_PorterEndsCVC(@temp) = 0		--not *o
				SELECT @Ret = LEFT(@Ret, LEN(@Ret) - 1)
			END
		END
	*/
	----------------------------------------------------------------------------------------------------------
	--
	-- Step5b
	IF dbo.fn_PorterCountm(@Ret) > 1
	BEGIN
		IF dbo.fn_PorterEndsDoubleConsonant(@Ret) = 1 AND RIGHT(@Ret, 1) = N'l'
			SELECT @Ret = LEFT(@Ret, LEN(@Ret) - 1)
	END
	-- retuning the word
	RETURN @Ret
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- fn_Stemming
if exists (select * from sys.objects where object_id = object_id(N'fn_Stemming') and type in (N'FT', N'FN', N'TF', N'FS'))
	drop function fn_Stemming
go

create function fn_Stemming(@String nvarchar(255))
  returns nvarchar(255)
begin
  declare @tmpTable table(SNO int, Words nvarchar(100))

  insert into @tmpTable(SNO, Words)
	  select SNO, dbo.fn_PorterAlgorithm(value)
	  from fn_splitString(@String, ' ')

  --select * from @tmpTable

  declare @StemmingString nvarchar(255) = (
    select rtrim((
		select Words + ' '
		from @tmpTable
		for xml path('')
    ))
  )

  return @StemmingString
end
go