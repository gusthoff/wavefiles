-------------------------------------------------------------------------------
--
--                                WAVEFILES
--
--                   Wavefile I/O operations for PCM buffers
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

with Audio.Wavefiles.Data_Types;   use Audio.Wavefiles.Data_Types;

#if NUM_TYPE'Defined and then (NUM_TYPE = "FLOAT") then
with Audio.Wavefiles.Generic_Float_Wav_Float_PCM_IO;
with Audio.Wavefiles.Generic_Fixed_Wav_Float_PCM_IO;
#else
with Audio.Wavefiles.Generic_Float_Wav_Fixed_PCM_IO;
with Audio.Wavefiles.Generic_Fixed_Wav_Fixed_PCM_IO;
#end if;

#if NUM_TYPE'Defined and then (NUM_TYPE = "FLOAT") then
package body Audio.Wavefiles.Generic_Float_PCM_IO is
#else
package body Audio.Wavefiles.Generic_Fixed_PCM_IO is
#end if;

   package PCM_Fixed_Wav_16 is new
#if NUM_TYPE'Defined and then (NUM_TYPE = "FLOAT") then
     Audio.Wavefiles.Generic_Fixed_Wav_Float_PCM_IO
#else
     Audio.Wavefiles.Generic_Fixed_Wav_Fixed_PCM_IO
#end if;
     (Wav_Sample    => Wav_Fixed_16,
      PCM_Sample    => PCM_Sample,
      PCM_MC_Sample => PCM_MC_Sample);

   package PCM_Fixed_Wav_24 is new
#if NUM_TYPE'Defined and then (NUM_TYPE = "FLOAT") then
     Audio.Wavefiles.Generic_Fixed_Wav_Float_PCM_IO
#else
     Audio.Wavefiles.Generic_Fixed_Wav_Fixed_PCM_IO
#end if;
     (Wav_Sample    => Wav_Fixed_24,
      PCM_Sample    => PCM_Sample,
      PCM_MC_Sample => PCM_MC_Sample);

   package PCM_Fixed_Wav_32 is new
#if NUM_TYPE'Defined and then (NUM_TYPE = "FLOAT") then
     Audio.Wavefiles.Generic_Fixed_Wav_Float_PCM_IO
#else
     Audio.Wavefiles.Generic_Fixed_Wav_Fixed_PCM_IO
#end if;
     (Wav_Sample    => Wav_Fixed_32,
      PCM_Sample    => PCM_Sample,
      PCM_MC_Sample => PCM_MC_Sample);

   package PCM_Float_Wav_32 is new
#if NUM_TYPE'Defined and then (NUM_TYPE = "FLOAT") then
     Audio.Wavefiles.Generic_Float_Wav_Float_PCM_IO
#else
     Audio.Wavefiles.Generic_Float_Wav_Fixed_PCM_IO
#end if;
     (Wav_Sample    => Wav_Float_32,
      PCM_Sample    => PCM_Sample,
      PCM_MC_Sample => PCM_MC_Sample);

   package PCM_Float_Wav_64 is new
#if NUM_TYPE'Defined and then (NUM_TYPE = "FLOAT") then
     Audio.Wavefiles.Generic_Float_Wav_Float_PCM_IO
#else
     Audio.Wavefiles.Generic_Float_Wav_Fixed_PCM_IO
#end if;
     (Wav_Sample    => Wav_Float_64,
      PCM_Sample    => PCM_Sample,
      PCM_MC_Sample => PCM_MC_Sample);

   function Get
     (WF   : in out Wavefile) return PCM_MC_Sample
   is
      Ch : constant Positive := Positive (WF.Wave_Format.Channels);
   begin
      if not WF.Is_Opened then
         raise Wavefile_Error;
      end if;
      if not Is_Supported_Format (WF.Wave_Format) then
         raise Wavefile_Unsupported;
      end if;

      WF.Samples_Read := WF.Samples_Read + Long_Integer (Ch);

      if Is_Float_Format (WF.Wave_Format) then
         case WF.Wave_Format.Bits_Per_Sample is
            when Bit_Depth_8 | Bit_Depth_16 | Bit_Depth_24 =>
               raise Wavefile_Unsupported;
            when Bit_Depth_32 =>
               return PCM_Float_Wav_32.Get (WF);
            when Bit_Depth_64 =>
               return PCM_Float_Wav_64.Get (WF);
         end case;
      else
         --  Always assume fixed-point PCM format
         case WF.Wave_Format.Bits_Per_Sample is
            when Bit_Depth_8 =>
               raise Wavefile_Unsupported;
            when Bit_Depth_16 =>
               return PCM_Fixed_Wav_16.Get (WF);
            when Bit_Depth_24 =>
               return PCM_Fixed_Wav_24.Get (WF);
            when Bit_Depth_32 =>
               return PCM_Fixed_Wav_32.Get (WF);
            when Bit_Depth_64 =>
               raise Wavefile_Unsupported;
         end case;
      end if;

   end Get;

   procedure Put
     (WF   : in out Wavefile;
      PCM  :        PCM_MC_Sample) is
   begin
      if not WF.Is_Opened then
         raise Wavefile_Error;
      end if;

      if not Is_Supported_Format (WF.Wave_Format) then
         raise Wavefile_Unsupported;
      end if;

      if Is_Float_Format (WF.Wave_Format) then
         case WF.Wave_Format.Bits_Per_Sample is
            when Bit_Depth_8 | Bit_Depth_16 | Bit_Depth_24 =>
               raise Wavefile_Unsupported;
            when Bit_Depth_32 =>
               PCM_Float_Wav_32.Put (WF, PCM);
            when Bit_Depth_64 =>
               PCM_Float_Wav_64.Put (WF, PCM);
         end case;
      else
         --  Always assume fixed-point PCM format
         case WF.Wave_Format.Bits_Per_Sample is
            when Bit_Depth_8 =>
               raise Wavefile_Unsupported;
            when Bit_Depth_16 =>
               PCM_Fixed_Wav_16.Put (WF, PCM);
            when Bit_Depth_24 =>
               PCM_Fixed_Wav_24.Put (WF, PCM);
            when Bit_Depth_32 =>
               PCM_Fixed_Wav_32.Put (WF, PCM);
            when Bit_Depth_64 =>
               raise Wavefile_Unsupported;
         end case;
      end if;

   end Put;

#if NUM_TYPE'Defined and then (NUM_TYPE = "FLOAT") then
end Audio.Wavefiles.Generic_Float_PCM_IO;
#else
end Audio.Wavefiles.Generic_Fixed_PCM_IO;
#end if;
