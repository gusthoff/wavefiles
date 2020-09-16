-------------------------------------------------------------------------------
--
--                                WAVEFILES
--
--               Type conversion for wavefile I/O operations
--
--  The MIT License (MIT)
--
--  Copyright (c) 2015 -- 2020 Gustavo A. Hoffmann
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

private generic
   Wav_Num_Type : Wav_Numeric_Data_Type;
   type Wav_Data_Type is range <>;
   type PCM_Type is delta <>;
package Audio.Wavefiles.Fixed_Types is

   type PCM_Bits_Type is array (0 .. PCM_Type'Size - 1) of Boolean;
   pragma Pack (PCM_Bits_Type);

   type Wav_Data_Bits_Type is array (0 .. Wav_Data_Type'Size - 1) of Boolean;
   pragma Pack (Wav_Data_Bits_Type);

   Bool_Image  : constant array (Boolean'Range) of Character := ('0', '1');
   Convert_Sample_Debug : constant Boolean := False;

   procedure Print_Sample_Read
     (Wav_Sample : Wav_Data_Type;
      PCM_Sample : PCM_Type);

   procedure Print_Sample_Write
     (PCM_Sample : PCM_Type;
      Wav_Sample : Wav_Data_Type);

   function Convert_Sample (Wav_Sample : Wav_Data_Type) return PCM_Type;

   function Convert_Sample (PCM_Sample : PCM_Type) return Wav_Data_Type;

end Audio.Wavefiles.Fixed_Types;
