using System;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.Generic;

public partial class UDF_RegExp
{
    [SqlFunction(DataAccess = DataAccessKind.Read, FillRowMethodName = "FillMatches", TableDefinition = "SNO int, Position int, Token nvarchar(max), Token_Len int")]
    public static IEnumerable RegExp(string Input, string Pattern)
    {
        List<RegexMatch> GroupCollection = new List<RegexMatch>();

        try
        {
            MatchCollection matches = Regex.Matches(Input, Pattern, RegexOptions.IgnoreCase, TimeSpan.FromSeconds(3));

            //Match m = Regex.Match(Input, Pattern);
            int i = 1;
            foreach (Match match in matches)
            {
                GroupCollection.Add(new RegexMatch(i, match.Index + 1, match.Value, match.Value.Length));
                i = i + 1;
            }
        }
        catch (RegexMatchTimeoutException ex)
        {
            //String msg = string.Format("Regex Timeout for {1} after {2} elapsed. Tried pattern {0}", ex.Pattern, ex.Message, ex.MatchTimeout.Seconds.ToString());
            String msg = string.Format(ex.Message.ToString());
            SqlContext.Pipe.Send(msg);
        }

        catch (ArgumentOutOfRangeException ex)
        {
            String msg = string.Format(ex.ToString());
            SqlContext.Pipe.Send(msg);
        }
        finally
        { }

        return GroupCollection;
    }

    public static void FillMatches(object Group, out SqlInt32 SNO, out SqlInt32 Position, out SqlString Token, out SqlInt32 Token_Len)
    {
        RegexMatch rm = (RegexMatch)Group;
        SNO = rm.SNO;
        Position = rm.Position;
        Token = rm.Token;
        Token_Len = rm.Token_Len;
    }

    private class RegexMatch
    {
        public SqlInt32 SNO { get; set; }
        public SqlInt32 Position { get; set; }
        public SqlString Token { get; set; }
        public SqlInt32 Token_Len { get; set; }        

        public RegexMatch(SqlInt32 SNO, SqlInt32 Position, SqlString match, SqlInt32 match_len)
        {
            this.SNO = SNO;
            this.Position = Position;
            this.Token = match;
            this.Token_Len = match_len;           
        }
    }
};
