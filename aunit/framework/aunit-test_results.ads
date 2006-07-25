------------------------------------------------------------------------------
--                                                                          --
--                         GNAT COMPILER COMPONENTS                         --
--                                                                          --
--                   A U N I T . T E S T _ R E S U L T S                    --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                                                                          --
--                       Copyright (C) 2000-2006, AdaCore                   --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 2,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License --
-- for  more details.  You should have  received  a copy of the GNU General --
-- Public License  distributed with GNAT;  see file COPYING.  If not, write --
-- to  the  Free Software Foundation,  51  Franklin  Street,  Fifth  Floor, --
-- Boston, MA 02110-1301, USA.                                              --
--                                                                          --
-- GNAT is maintained by AdaCore (http://www.adacore.com)                   --
--                                                                          --
------------------------------------------------------------------------------

with Ada_Containers;
with Ada_Containers_Restricted_Doubly_Linked_Lists;

--  Test reporting.
--
--  Generic formals size the reporting data structures, which have to be
--  be statically allocated (ZFP subset does not allow dynamic allocation by
--  default). Since failure messages can be rather large, this allows tradeoffs
--  between verbosity and memory requirements.
generic
   Max_Tests_Per_Harness : Positive;   --  Max test cases per harness
   Max_Errors_Per_Harness : Natural;   --  Max unhandled exceptions per harness
   Max_Failures_Per_Harness : Natural; --  Max failed routines per harness
   Max_Failure_Message_Size : Natural; --  Max size of failure message
   Test_Name_Size : Natural;           --  Max test case name size
   Routine_Name_Size : Natural;        --  Max routine description size
package AUnit.Test_Results is

   type Result is limited private;
   type Result_Access is access all Result;
   --  Record result. A result object is associated with the execution of a
   --  top-level test suite.

   subtype Test_String is String (1 .. Test_Name_Size);
   subtype Routine_String is String (1 .. Routine_Name_Size);
   subtype Message_String is String (1 .. Max_Failure_Message_Size);
   --  Strings used for reporting results

   type Test_Failure is record
      Test_Name    : Test_String;
      Routine_Name : Routine_String;
      Message      : Message_String;
   end record;
   --  Description of a test routine failures and unexpected exceptions
   --  Unexpected exceptions are only logged when exception handling is
   --  available in the run-time library

   type Test_Success is record
      Test_Name    : Test_String;
      Routine_Name : Routine_String;
   end record;
   --  Decription of a test routine success

   use Ada_Containers;

   subtype Successes_Range is Count_Type
      range 0 .. Count_Type (Max_Tests_Per_Harness);
   package Success_Lists is
     new Ada_Containers_Restricted_Doubly_Linked_Lists
       (Test_Success);
   --  Containers for successes

   subtype Errors_Range is Count_Type
      range 0 .. Count_Type (Max_Errors_Per_Harness);
   package Error_Lists is
     new Ada_Containers_Restricted_Doubly_Linked_Lists (Test_Failure);
   --  Containers for unexpected exceptions

   subtype Failures_Range is Count_Type
      range 0 .. Count_Type (Max_Failures_Per_Harness);
   package Failure_Lists is
     new Ada_Containers_Restricted_Doubly_Linked_Lists (Test_Failure);
   --  Containers for failures

   procedure Add_Error
     (R                       : in out Result;
      Test_Name               : Test_String;
      Routine_Name            : Routine_String;
      Message                 : Message_String);
   --  Record an unexpected exception

   procedure Add_Failure
     (R                       : in out Result;
      Test_Name               : Test_String;
      Routine_Name            : Routine_String;
      Message                 : Message_String);
   --  Record a test routine failure

   procedure Add_Success
     (R                       : in out Result;
      Test_Name               : Test_String;
      Routine_Name            : Routine_String);
   --  Record a test routine success

   function Error_Count (R : Result) return Errors_Range;
   --  Number of routines with unexpected exceptions

   procedure Errors (R : in out Result;
                     E : in out Error_Lists.List);
   --  List of routines with unexpected exceptions

   function Failure_Count (R : Result) return Failures_Range;
   --  Number of failed routines

   procedure Failures (R : in out Result;
                       F : in out Failure_Lists.List);
   --  List of failed routines

   function Format (Name : String) return Test_String;
   --  Format a string to use as a test name

   procedure Start_Test (R : in out Result; Subtest_Count : Count_Type);
   --  Set count for a test run

   function Success_Count (R : Result) return Successes_Range;
   --  Number of successful routines

   procedure Successes (R : in out Result;
                        S : in out Success_Lists.List);
   --  List of successful routines

   function Successful (R : Result) return Boolean;
   --  All routines successful?

   function Test_Count (R : Result) return Ada_Containers.Count_Type;
   --  Number of routines run

private

   type Result is limited record
      Tests_Run      : Count_Type := 0;
      Errors_List    : Error_Lists.List (Errors_Range'Last);
      Failures_List  : Failure_Lists.List (Failures_Range'Last);
      Successes_List : Success_Lists.List (Successes_Range'Last);
   end record;

   pragma Inline (Error_Count, Failure_Count, Success_Count, Test_Count);

end AUnit.Test_Results;
