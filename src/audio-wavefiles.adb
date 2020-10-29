-------------------------------------------------------------------------------
--
--                                WAVEFILES
--
--                              Main package
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
------------------------------------------------------------------------------

with Audio.Wavefiles.Read;
with Audio.Wavefiles.Write;

with Audio.RIFF.Wav.GUIDs;          use Audio.RIFF.Wav.GUIDs;
with Audio.RIFF.Wav.Formats.Report;


package body Audio.Wavefiles is

   procedure Init_Data_For_File_Opening
     (WF   : in out Wavefile);
   procedure Reset_RIFF_Info
     (Info :      out RIFF_Information);

   procedure Init_Data_For_File_Opening
     (WF   : in out Wavefile) is
   begin
      WF.Is_Opened    := True;
      WF.Samples_Read := 0;
      WF.Samples      := 0;
      Reset_RIFF_Info (WF.RIFF_Info);
   end Init_Data_For_File_Opening;

   procedure Create
     (WF   : in out Wavefile;
      Mode :        File_Mode := Out_File;
      Name :        String    := "";
      Form :        String    := "")
   is
      pragma Unreferenced (Form);
   begin
      Init_Data_For_File_Opening (WF);

      if Mode in In_File | Append_File then
         WF.Wave_Format := Default;
      end if;

      Create_Wavefile : declare
         Stream_Mode : constant Ada.Streams.Stream_IO.File_Mode :=
                         Ada.Streams.Stream_IO.File_Mode (Mode);
      begin
         Ada.Streams.Stream_IO.Create (WF.File, Stream_Mode, Name);
         WF.File_Access := Ada.Streams.Stream_IO.Stream (WF.File);
      end Create_Wavefile;

      case Mode is
         when In_File | Append_File =>
            Audio.Wavefiles.Read.Read_Until_Data_Start (WF);
         when Out_File =>
            Audio.Wavefiles.Write.Write_Until_Data_Start (WF);
      end case;
   end Create;

   procedure Open
     (WF   : in out Wavefile;
      Mode :        File_Mode;
      Name :        String;
      Form :        String    := "")
   is
      pragma Unreferenced (Form);
   begin
      if WF.Is_Opened then
         raise Wavefile_Error;
      end if;

      Init_Data_For_File_Opening (WF);

      case Mode is
         when In_File =>
            WF.Wave_Format := Default;
         when Append_File =>
            Parse_Wavefile : declare
               use Ada.Streams.Stream_IO;
               Stream_Mode : constant Ada.Streams.Stream_IO.File_Mode :=
                               Ada.Streams.Stream_IO.File_Mode'(In_File);
            begin
               Open (WF.File, Stream_Mode, Name);
               WF.File_Access := Stream (WF.File);
               Audio.Wavefiles.Read.Read_Until_Data_Start (WF);
               Close (WF.File);
            end Parse_Wavefile;
         when Out_File =>
            null;
      end case;

      Open_Wavefile : declare
         Stream_Mode : constant Ada.Streams.Stream_IO.File_Mode :=
                         Ada.Streams.Stream_IO.File_Mode (Mode);
      begin
         Ada.Streams.Stream_IO.Open (WF.File, Stream_Mode, Name);
         WF.File_Access := Ada.Streams.Stream_IO.Stream (WF.File);
      end Open_Wavefile;

      case Mode is
         when In_File =>
            Audio.Wavefiles.Read.Read_Until_Data_Start (WF);
         when Append_File =>
            null;
         when Out_File =>
            Audio.Wavefiles.Write.Write_Until_Data_Start (WF);
      end case;
   end Open;

   function End_Of_File
     (WF : in out Wavefile) return Boolean
   is
   begin
      if WF.Samples_Read >= WF.Samples or
        Ada.Streams.Stream_IO.End_Of_File (WF.File)
      then
         return True;
      else
         return False;
      end if;
   end End_Of_File;

   procedure Display_Info (WF : in Wavefile) is
   begin
      Audio.RIFF.Wav.Formats.Report.Print (WF.Wave_Format);
   end Display_Info;

   procedure Close (WF : in out Wavefile) is
      use Ada.Streams.Stream_IO;
   begin
      if not WF.Is_Opened then
         raise Wavefile_Error;
      end if;

      if Mode (WF) = Out_File then
         Audio.Wavefiles.Write.Update_Data_Size (WF);
      end if;

      Close (WF.File);

      WF.Is_Opened := False;

   end Close;

   procedure Set_Format_Of_Wavefile
     (WF     : in out Wavefile;
      Format :        Wave_Format_Extensible) is
   begin
      WF.Wave_Format := Format;
   end Set_Format_Of_Wavefile;

   function Format_Of_Wavefile
     (W : Wavefile) return  Wave_Format_Extensible is
   begin
      return W.Wave_Format;
   end Format_Of_Wavefile;

   function Number_Of_Channels
     (W : Wavefile) return Positive is (Positive (W.Wave_Format.Channels));

   function Mode (W : Wavefile) return File_Mode is
     (if Mode (W.File) = In_File then In_File else Out_File);

   function Name
     (W : Wavefile) return String is
     (Ada.Streams.Stream_IO.Name (W.File));

   function Is_Supported_Format (W : Wave_Format_Extensible)
                                 return Boolean is
   begin
      if not (W.Sub_Format = GUID_Undefined
              or W.Sub_Format = GUID_PCM
              or W.Sub_Format = GUID_IEEE_Float)
      then
         return False;
      end if;

      return True;
   end Is_Supported_Format;

   procedure Get_RIFF_Info
     (WF     : in out Wavefile;
      Info   :    out RIFF_Information)
   is
   begin
      if WF.RIFF_Info.Chunks.Is_Empty then
         Audio.Wavefiles.Read.Parse_Wav_Chunks (WF);
      end if;
      Info := WF.RIFF_Info;
   end Get_RIFF_Info;

   procedure Reset_RIFF_Info
     (Info :      out RIFF_Information) is
   begin
      Info.Format  := RIFF_Format_Unknown;
      Info.Id      := RIFF_Identifier_Unknown;
      Info.Chunks.Clear;
   end Reset_RIFF_Info;

end Audio.Wavefiles;
