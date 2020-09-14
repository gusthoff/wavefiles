-------------------------------------------------------------------------------
--
--                                WAVEFILES
--
--                            Wavefile writing
--
--  The MIT License (MIT)
--
--  Copyright (c) 2015 Gustavo A. Hoffmann
--
--  Permission is hereby granted, free of charge, to any person obtaining a
--  copy of this software and associated documentation files (the "Software"),
--  to deal in the Software without restriction, including without limitation
--  the rights to use, copy, modify, merge, publish, distribute, sublicense,
--  and / or sell copies of the Software, and to permit persons to whom the
--  Software is furnished to do so, subject to the following conditions:
--
--  The above copyright notice and this permission notice shall be included in
--  all copies or substantial portions of the Software.
--
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
--  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
--  DEALINGS IN THE SOFTWARE.
-------------------------------------------------------------------------------

with Audio.RIFF;

package Audio.Wavefiles.Write is

   procedure Open
     (WF          : in out Wavefile;
      File_Name   : String;
      Wave_Format : RIFF.Wave_Format_Extensible);

   generic
      type PCM_Type is digits <>;
      type MC_Samples is array (Positive range <>) of PCM_Type;
   procedure Put_Float
     (WF   : in out Wavefile;
      PCM  :        MC_Samples);

   generic
      type PCM_Type is delta <>;
      type MC_Samples is array (Positive range <>) of PCM_Type;
   procedure Put_Fixed
     (WF   : in out Wavefile;
      PCM  :        MC_Samples);

   procedure Close (WF         : in out Wavefile);

end Audio.Wavefiles.Write;
